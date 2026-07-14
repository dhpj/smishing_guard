package com.dhn.smishing

import android.content.Context
import android.content.Intent
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.net.Uri
import android.os.Handler
import android.os.Looper
import android.view.View
import android.widget.ImageView
import org.json.JSONArray
import org.json.JSONObject
import org.json.JSONTokener
import java.net.HttpURLConnection
import java.net.URL

/**
 * 오버레이 노출 시 광고 1건을 비동기로 받아와 카드 안에 채워준다.
 * - prefs 의 mock_mode / api_base_url / api_userid 를 그대로 사용한다(네이티브에서 채워주는 값).
 * - 실패하면 조용히 사라진다 — 오버레이 본문 동작에 영향 없음.
 */
object OverlayAdLoader {
    private const val DEFAULT_BASE_URL = "https://smishing.dhn.kr"
    private const val CONNECT_TIMEOUT_MS = 4_000
    private const val READ_TIMEOUT_MS = 4_000
    private const val IMAGE_TIMEOUT_MS = 5_000
    private const val MAX_IMAGE_BYTES = 2_000_000

    private val main = Handler(Looper.getMainLooper())

    fun loadInto(
        context: Context,
        container: View,
        imageView: ImageView,
    ) {
        val appCtx = context.applicationContext
        Thread({
            val ad = fetchFirstAd(appCtx) ?: return@Thread
            val bitmap = downloadBitmap(ad.imgUrl) ?: return@Thread

            main.post {
                if (!imageView.isAttachedToWindow) return@post
                imageView.setImageBitmap(bitmap)
                container.visibility = View.VISIBLE
                if (ad.imgLink.isNotEmpty()) {
                    container.setOnClickListener { openLink(appCtx, ad.imgLink) }
                } else {
                    container.isClickable = false
                }
            }
        }, "overlay-ad-loader").start()
    }

    private data class Ad(val imgUrl: String, val imgLink: String)

    private fun fetchFirstAd(context: Context): Ad? {
        val prefs = context.getSharedPreferences(
            "FlutterSharedPreferences", Context.MODE_PRIVATE,
        )
        if (prefs.getBoolean("flutter.mock_mode", false)) return null

        val rawBase = prefs.getString("flutter.api_base_url", null)?.trim()
        val base = (if (rawBase.isNullOrBlank()) DEFAULT_BASE_URL else rawBase).trimEnd('/')
        val userId = prefs.getString("flutter.api_userid", null)?.trim().orEmpty()
        if (userId.isEmpty()) return null

        return try {
            val conn = (URL("$base/get_ad_img").openConnection() as HttpURLConnection).apply {
                requestMethod = "POST"
                connectTimeout = CONNECT_TIMEOUT_MS
                readTimeout = READ_TIMEOUT_MS
                setRequestProperty("userid", userId)
                setRequestProperty("Content-Type", "application/json")
                doInput = true
                doOutput = true
            }
            try {
                conn.outputStream.use {
                    it.write("""{"type":1}""".toByteArray(Charsets.UTF_8))
                }
                if (conn.responseCode != 200) return null
                val text = conn.inputStream.bufferedReader().use { it.readText() }
                parseAdResponse(text)
            } finally {
                conn.disconnect()
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun parseAdResponse(text: String): Ad? {
        return try {
            val arr: JSONArray = when (val v = JSONTokener(text).nextValue()) {
                is JSONArray -> v
                is JSONObject -> {
                    if (v.optString("img_url", "").isNotEmpty()) {
                        JSONArray().apply { put(v) }
                    } else {
                        listOf("data", "list", "items", "result")
                            .firstNotNullOfOrNull { v.optJSONArray(it) }
                            ?: return null
                    }
                }
                else -> return null
            }
            if (arr.length() == 0) return null
            val item = arr.optJSONObject(0) ?: return null
            val imgUrl = item.optString("img_url", "").trim()
            val imgLink = item.optString("img_link", "").trim()
            if (imgUrl.isEmpty()) null else Ad(imgUrl, imgLink)
        } catch (_: Exception) {
            null
        }
    }

    private fun downloadBitmap(url: String): Bitmap? {
        return try {
            val conn = (URL(url).openConnection() as HttpURLConnection).apply {
                connectTimeout = IMAGE_TIMEOUT_MS
                readTimeout = IMAGE_TIMEOUT_MS
                instanceFollowRedirects = true
            }
            try {
                if (conn.responseCode != 200) return null
                val bytes = conn.inputStream.use { input ->
                    val bao = java.io.ByteArrayOutputStream()
                    val buf = ByteArray(8 * 1024)
                    var total = 0
                    while (true) {
                        val n = input.read(buf)
                        if (n <= 0) break
                        total += n
                        if (total > MAX_IMAGE_BYTES) return null
                        bao.write(buf, 0, n)
                    }
                    bao.toByteArray()
                }
                BitmapFactory.decodeByteArray(bytes, 0, bytes.size)
            } finally {
                conn.disconnect()
            }
        } catch (_: Exception) {
            null
        }
    }

    private fun openLink(context: Context, link: String) {
        try {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(link))
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            context.startActivity(intent)
        } catch (_: Exception) {
        }
    }
}
