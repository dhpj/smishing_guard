package com.dhn.smishing

import android.content.Context
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import org.json.JSONObject
import java.io.BufferedReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import java.util.concurrent.Executors

object UriCheckBridge {
    private const val TAG = "UriCheckBridge"
    private const val HTTP_CONNECT_MS = 5000
    private const val HTTP_READ_MS = 5000
    private val executor = Executors.newSingleThreadExecutor()
    private val mainHandler = Handler(Looper.getMainLooper())

    private val inboundSmsFingerLock = Any()
    private var lastInboundFinger: Pair<Int, Long>? = null
    private val inFlightKeys = mutableSetOf<String>()
    private val inFlightLock = Any()

    fun checkText(
        context: Context,
        text: String,
        source: String,
        senderTitle: String? = null,
        appLabel: String? = null,
        messageBody: String? = null,
    ) {
        val trimmed = text.trim()
        if (trimmed.isBlank()) return
        if (!ProtectionPrefs.isActive(context)) return

        Log.d(TAG, "checkText ($source) len=${trimmed.length} preview=${trimmed.take(120)}")

        val urls = UrlNormalizer.extractAllFromText(trimmed)
        if (urls.isEmpty()) {
            Log.w(TAG, "no url in text ($source) len=${trimmed.length}")
            return
        }
        if (!urls.any { isKnownTestDangerUrl(it) } && inboundSmsDedup(urls, source)) return
        Log.d(TAG, "found ${urls.size} url(s) ($source): ${urls.joinToString()}")
        val bodyForDisplay = messageBody?.trim()?.takeIf { it.isNotEmpty() } ?: trimmed
        val msgCtx = OverlayWarningWindow.MessageContext(
            messageBody = bodyForDisplay,
            senderTitle = senderTitle,
            appLabel = appLabel,
        )
        urls.forEach { checkAndWarn(context, it, source, msgCtx) }
    }

    fun checkAndWarn(
        context: Context,
        rawUrl: String,
        source: String,
        messageContext: OverlayWarningWindow.MessageContext? = null,
        browserCheckToken: Long? = null,
    ) {
        val displayUri =
            UrlNormalizer.parseFromText(rawUrl) ?: UrlNormalizer.normalize(rawUrl) ?: return
        if (!ProtectionPrefs.isActive(context)) return

        val cacheKey = UrlNormalizer.canonicalBrowserKey(displayUri)
        UriCheckCache.get(cacheKey)?.let { cached ->
            deliverResult(context, displayUri, source, messageContext, browserCheckToken, cached)
            return
        }

        synchronized(inFlightLock) {
            if (!inFlightKeys.add(cacheKey)) return
        }

        executor.execute {
            try {
                val prefs = context.getSharedPreferences("FlutterSharedPreferences", Context.MODE_PRIVATE)
                val mock = prefs.getBoolean("flutter.mock_mode", false)
                val base = prefs.getString("flutter.api_base_url", null)
                    ?: "http://210.114.225.58:8087"
                val endpoint = "$base/check_uri"
                val userId = prefs.getString("flutter.api_userid", null)?.trim().orEmpty()
                val useLocalTestRules = mock || isKnownTestDangerUrl(displayUri)
                if (mock) {
                    Log.w(TAG, "mock_mode ON — 서버 대신 로컬 규칙만 사용 ($displayUri)")
                }
                if (!useLocalTestRules && userId.isEmpty()) {
                    Log.w(TAG, "no userid — skip check ($source)")
                    return@execute
                }

                val result =
                    if (useLocalTestRules) localDangerCheck(displayUri, mock)
                    else postCheck(endpoint, userId, displayUri)
                Log.d(TAG, "check uri=$displayUri code=${result.code} (mock=$mock)")
                UriCheckCache.put(cacheKey, result.code, result.message)
                deliverResult(
                    context,
                    displayUri,
                    source,
                    messageContext,
                    browserCheckToken,
                    UriCheckCache.Entry(result.code, result.message, SystemClock.elapsedRealtime()),
                )
            } catch (e: Exception) {
                Log.e(TAG, "check failed: ${e.message}", e)
            } finally {
                synchronized(inFlightLock) { inFlightKeys.remove(cacheKey) }
            }
        }
    }

    private fun deliverResult(
        context: Context,
        displayUri: String,
        source: String,
        messageContext: OverlayWarningWindow.MessageContext?,
        browserCheckToken: Long?,
        result: UriCheckCache.Entry,
    ) {
        val detectedAt = System.currentTimeMillis()
        val entryId = "${detectedAt}_${displayUri.hashCode()}_${System.nanoTime()}"
        val payload = mutableMapOf(
            "entryId" to entryId,
            "source" to source,
            "url" to displayUri,
            "code" to result.code,
            "message" to result.message,
            "checkedAt" to detectedAt.toString(),
        )
        messageContext?.messageBody?.let { payload["bodyText"] = it }
        messageContext?.senderTitle?.let { payload["senderTitle"] = it }
        messageContext?.appLabel?.let { payload["appLabel"] = it }
        NativeBridgePlugin.emit(payload)

        if (!ApiResultCodes.isSmishing(result.code)) {
            Log.d(TAG, "no overlay ($source) code=${result.code}")
            return
        }

        mainHandler.post {
            if (source == "browser") {
                // 캐시 hit 등 재진입 경로에서 같은 페이지가 재차 오버레이를 띄우는 것 차단
                if (BrowserAccessibilityService.isAlreadyAlertedFor(displayUri)) {
                    Log.d(TAG, "skip already-alerted browser overlay for $displayUri")
                    return@post
                }
                val token = browserCheckToken
                if (token == null ||
                    !BrowserAccessibilityService.isOverlayStillValid(displayUri, token)
                ) {
                    Log.d(TAG, "skip stale browser overlay for $displayUri")
                    return@post
                }
            }
            OverlayWarningWindow.show(
                context.applicationContext,
                displayUri,
                result.message,
                sticky = true,
                source,
                messageContext,
                detectedAtMillis = detectedAt,
            )
            if (source == "browser") {
                BrowserAccessibilityService.markBrowserOverlayShown(displayUri)
            }
        }
    }

    private data class CheckResult(val code: String, val message: String)

    private fun postCheck(endpoint: String, userId: String, uri: String): CheckResult {
        val conn = URL(endpoint).openConnection() as HttpURLConnection
        conn.requestMethod = "POST"
        conn.connectTimeout = HTTP_CONNECT_MS
        conn.readTimeout = HTTP_READ_MS
        conn.setRequestProperty("userid", userId)
        conn.setRequestProperty("Content-Type", "application/json")
        conn.doOutput = true
        OutputStreamWriter(conn.outputStream).use { it.write(JSONObject().put("uri", uri).toString()) }
        val httpCode = conn.responseCode
        val stream = if (httpCode in 200..299) conn.inputStream else conn.errorStream
        val text = stream.bufferedReader().use(BufferedReader::readText)
        conn.disconnect()
        val json = JSONObject(text)
        val codeVal = ApiResultCodes.parseFromJson(json)
        val messageVal = json.optString("message", json.optString("msg", ""))
        Log.d(TAG, "response http=$httpCode raw=${json.opt("code")} norm=$codeVal")
        if (httpCode !in 200..299) {
            Log.w(TAG, "check_uri HTTP $httpCode body=$text")
        }
        return CheckResult(codeVal, messageVal)
    }

    /** Google Safe Browsing 테스트 URL — 서버가 0000을 돌려줘도 QA용으로 위험 처리 */
    private fun isKnownTestDangerUrl(uri: String): Boolean =
        uri.lowercase().contains("testsafebrowsing.appspot.com")

    private fun localDangerCheck(uri: String, mockEnabled: Boolean): CheckResult {
        val lower = uri.lowercase()
        val dangerous =
            listOf("phish", "evil", "fake", "scam", "malware", "virus").any { lower.contains(it) }
                || isKnownTestDangerUrl(uri)
        if (!dangerous) {
            return CheckResult(ApiResultCodes.SAFE, if (mockEnabled) "안전(Mock)" else "안전")
        }
        val msg = when {
            mockEnabled -> "테스트 페이지로 분류되어 주의 표시했습니다.(Mock)"
            isKnownTestDangerUrl(uri) ->
                "Google Safe Browsing 테스트 URL로 주의 표시했습니다."
            else -> "주의가 필요한 URL로 분류되었습니다."
        }
        return CheckResult(ApiResultCodes.SMISHING, msg)
    }

    /** URL 없는 알림 미리보기가 먼저 오면 본문 SMS 검사를 막지 않도록 URL 기준으로만 중복 제거 */
    private fun inboundSmsDedup(urls: List<String>, source: String): Boolean {
        if (source != "sms" && source != "sms_db" && source != "sms_notif") return false
        val fp = urls.sorted().joinToString("|").hashCode()
        val now = SystemClock.elapsedRealtime()
        synchronized(inboundSmsFingerLock) {
            val prev = lastInboundFinger
            if (prev != null && prev.first == fp && now - prev.second < 3000L) {
                Log.d(TAG, "skip duplicate sms urls ($source)")
                return true
            }
            lastInboundFinger = fp to now
        }
        return false
    }
}
