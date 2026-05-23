package com.dhn.smishing

import android.accessibilityservice.AccessibilityService
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.os.SystemClock
import android.util.Log
import android.view.accessibility.AccessibilityEvent
import android.view.accessibility.AccessibilityNodeInfo
import android.view.accessibility.AccessibilityWindowInfo

/**
 * 브라우저: **마지막으로 검사한(이동한) URL** 과 주소창이 같으면 어떤 이벤트도 무시.
 */
class BrowserAccessibilityService : AccessibilityService() {
    companion object {
        private const val TAG = "SmishingBrowserA11y"
        private const val TYPING_SETTLE_MS = 1200L
        private const val TYPING_VERIFY_MS = 350L
        private const val NAV_QUIET_MS = 300L
        private const val NAV_MAX_WAIT_MS = 750L
        private const val NAV_RETRY_MS = 160L
        private const val NAV_MAX_ATTEMPTS = 7
        private const val EVENT_MIN_INTERVAL_MS = 350L
        private const val BAR_CACHE_MS = 600L

        @Volatile
        private var instance: BrowserAccessibilityService? = null

        @Volatile
        private var overlayCheckGeneration: Long = 0L

        fun isOverlayStillValid(expectedUrl: String, checkToken: Long): Boolean {
            if (checkToken != overlayCheckGeneration) return false
            val svc = instance ?: return false
            val bar = svc.readCommittedUrlFromBar() ?: return false
            return UrlNormalizer.isSameBrowserPage(bar, expectedUrl)
        }

        fun beginBrowserOverlayCheck(expectedUrl: String): Long =
            overlayCheckGeneration

        fun markBrowserOverlayShown(url: String) {
            val svc = instance ?: return
            svc.markPageAlerted(url)
        }

    }

    /** 마지막으로 0001 알림을 띄운 URL — 같으면 터치 이벤트만 무시 (재검사는 UriCheckCache) */
    private var lastAlertedUrl: String? = null

    private val mainHandler = Handler(Looper.getMainLooper())
    private var typingSettle: Runnable? = null
    private var typingVerify: Runnable? = null
    private var navQuietRunnable: Runnable? = null
    private var navDeadlineRunnable: Runnable? = null
    private var navCoalesceStarted = 0L
    private var navAttempt = 0
    private var urlBarTyping: Boolean = false
    private var lastEventAt = 0L
    private var cachedBarUrl: String? = null
    private var cachedBarAt = 0L

    override fun onServiceConnected() {
        super.onServiceConnected()
        instance = this
        Log.i(TAG, "connected")
    }

    override fun onDestroy() {
        instance = null
        super.onDestroy()
    }

    override fun onAccessibilityEvent(event: AccessibilityEvent?) {
        event ?: return
        val pkg = event.packageName?.toString() ?: return
        val type = event.eventType

        if (pkg !in BrowserPackages.all) {
            if (type == AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) {
                resetSession("left_browser")
            }
            return
        }

        if (!ProtectionPrefs.isActive(applicationContext)) return

        val now = SystemClock.elapsedRealtime()
        if (lastAlertedUrl != null && now - lastEventAt < EVENT_MIN_INTERVAL_MS) {
            return
        }
        lastEventAt = now

        if (shouldIgnoreSamePage()) return

        val urlBarEvent = isUrlBarEvent(event)
        val isTypingEvent =
            type == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED &&
                (urlBarEvent || urlBarTyping)

        if (type == AccessibilityEvent.TYPE_VIEW_TEXT_CHANGED && urlBarEvent) {
            urlBarTyping = true
            cancelNav()
            scheduleTypingCheck(pkg)
            return
        }

        if (isTypingEvent) {
            urlBarTyping = true
            cancelNav()
            scheduleTypingCheck(pkg)
            return
        }

        if (type != AccessibilityEvent.TYPE_WINDOW_CONTENT_CHANGED) return

        urlBarTyping = false
        cancelTyping()
        scheduleNavigationCheck(pkg)
    }

    /** 이미 처리한 URL과 같으면 터치·리렌더 이벤트 전부 무시 */
    private fun shouldIgnoreSamePage(): Boolean {
        val alerted = lastAlertedUrl ?: return false
        val nowElapsed = SystemClock.elapsedRealtime()
        cachedBarUrl?.let { cached ->
            if (nowElapsed - cachedBarAt < BAR_CACHE_MS) {
                return UrlNormalizer.isSameBrowserPage(cached, alerted)
            }
        }
        val barUrl = readCommittedUrlFromBar() ?: return true
        return UrlNormalizer.isSameBrowserPage(barUrl, alerted)
    }

    private fun markPageAlerted(url: String) {
        lastAlertedUrl = url
        invalidateBarCache()
        overlayCheckGeneration++
        Log.d(TAG, "alerted → ${UrlNormalizer.canonicalBrowserKey(url)}")
    }

    private fun scheduleTypingCheck(pkg: String) {
        cancelTyping()
        typingSettle = Runnable {
            val first = readCommittedUrlFromBar() ?: return@Runnable
            typingVerify = Runnable {
                val second = readCommittedUrlFromBar() ?: return@Runnable
                if (UrlNormalizer.canonicalBrowserKey(second) !=
                    UrlNormalizer.canonicalBrowserKey(first)
                ) {
                    return@Runnable
                }
                urlBarTyping = false
                fireCheck(pkg, second, "typing")
            }
            mainHandler.postDelayed(typingVerify!!, TYPING_VERIFY_MS)
        }
        mainHandler.postDelayed(typingSettle!!, TYPING_SETTLE_MS)
    }

    private fun scheduleNavigationCheck(pkg: String) {
        readCommittedUrlFromBar() ?: return

        if (navCoalesceStarted == 0L) {
            navCoalesceStarted = 1L
            navDeadlineRunnable = Runnable {
                navCoalesceStarted = 0L
                navQuietRunnable?.let { mainHandler.removeCallbacks(it) }
                navQuietRunnable = null
                navDeadlineRunnable = null
                beginNavigationRetries(pkg)
            }
            mainHandler.postDelayed(navDeadlineRunnable!!, NAV_MAX_WAIT_MS)
        }

        navQuietRunnable?.let { mainHandler.removeCallbacks(it) }
        navQuietRunnable = Runnable {
            navCoalesceStarted = 0L
            navDeadlineRunnable?.let { mainHandler.removeCallbacks(it) }
            navDeadlineRunnable = null
            navQuietRunnable = null
            beginNavigationRetries(pkg)
        }
        mainHandler.postDelayed(navQuietRunnable!!, NAV_QUIET_MS)
    }

    private fun beginNavigationRetries(pkg: String) {
        navAttempt = 0
        runNavigationAttempt(pkg)
    }

    private fun runNavigationAttempt(pkg: String) {
        navAttempt++
        val url = readCommittedUrlFromBar()
        if (url == null || !UrlNormalizer.looksLikeCommittedBrowsingUrl(url)) {
            if (navAttempt < NAV_MAX_ATTEMPTS) {
                mainHandler.postDelayed({ runNavigationAttempt(pkg) }, NAV_RETRY_MS)
            }
            return
        }
        fireCheck(pkg, url, "nav#$navAttempt")
    }

    private fun fireCheck(pkg: String, url: String, reason: String) {
        val checkToken = overlayCheckGeneration
        Log.d(TAG, "[$pkg] check ($reason) token=$checkToken → $url")
        UriCheckBridge.checkAndWarn(
            applicationContext,
            url,
            "browser",
            browserCheckToken = checkToken,
        )
    }

    private fun readCommittedUrlFromBar(): String? {
        val now = SystemClock.elapsedRealtime()
        cachedBarUrl?.let { if (now - cachedBarAt < BAR_CACHE_MS) return it }

        val raw = scrapeUrlBar(null)?.toString()?.trim().orEmpty()
        if (raw.isEmpty()) return null
        val parsed = UrlNormalizer.parseFromText(raw) ?: return null
        if (!UrlNormalizer.looksLikeCommittedBrowsingUrl(parsed)) return null
        cachedBarUrl = parsed
        cachedBarAt = now
        return parsed
    }

    private fun invalidateBarCache() {
        cachedBarUrl = null
        cachedBarAt = 0L
    }

    private fun scrapeUrlBar(event: AccessibilityEvent?): CharSequence? {
        event?.source?.let { scrapeFromUrlBarNodes(it)?.let { return it } }
        if (event != null) {
            event.text?.forEach { seq ->
                val s = seq?.toString()?.trim().orEmpty()
                if (s.isNotBlank() && looksLikeBarText(s)) return seq
            }
        }
        scrapeFromUrlBarNodes(rootInActiveWindow)?.let { return it }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
            for (window in windows) {
                if (window.type != AccessibilityWindowInfo.TYPE_APPLICATION) continue
                scrapeFromUrlBarNodes(window.root)?.let { return it }
            }
        }
        return null
    }

    private fun scrapeFromUrlBarNodes(root: AccessibilityNodeInfo?): CharSequence? {
        root ?: return null
        val id = root.viewIdResourceName.orEmpty().lowercase()
        if (isUrlBarId(id)) {
            sequenceOf(root.text, root.contentDescription).forEach {
                val s = it?.toString()?.trim().orEmpty()
                if (s.isNotBlank() && looksLikeBarText(s)) return it
            }
        }
        for (i in 0 until root.childCount) {
            scrapeFromUrlBarNodes(root.getChild(i))?.let { return it }
        }
        return null
    }

    private fun isUrlBarId(id: String): Boolean {
        if (id.isEmpty()) return false
        return id.contains("url_bar") ||
            id.contains("omnibox") ||
            id.contains("location_bar") ||
            id.contains("location") && id.contains("bar") ||
            id.contains("address_bar") ||
            id.contains("search_box") ||
            id.contains("searchbox") ||
            id.contains("toolbar") && id.contains("url") ||
            id.endsWith(":url") ||
            (id.contains("line_1") && (id.contains("browser") || id.contains("whale") || id.contains("chrome")))
    }

    private fun isUrlBarEvent(event: AccessibilityEvent): Boolean {
        val id = event.source?.viewIdResourceName.orEmpty().lowercase()
        return isUrlBarId(id)
    }

    private fun looksLikeBarText(raw: String): Boolean {
        val l = raw.lowercase()
        return l.startsWith("http") ||
            l.startsWith("www.") ||
            (l.contains('.') && !l.contains(' ') && !l.contains('@') && l.length >= 4)
    }

    private fun resetSession(reason: String) {
        lastAlertedUrl = null
        invalidateBarCache()
        urlBarTyping = false
        cancelTyping()
        cancelNav()
        overlayCheckGeneration++
        Log.d(TAG, "reset ($reason)")
    }

    private fun cancelTyping() {
        typingSettle?.let { mainHandler.removeCallbacks(it) }
        typingVerify?.let { mainHandler.removeCallbacks(it) }
        typingSettle = null
        typingVerify = null
    }

    private fun cancelNav() {
        navQuietRunnable?.let { mainHandler.removeCallbacks(it) }
        navDeadlineRunnable?.let { mainHandler.removeCallbacks(it) }
        navQuietRunnable = null
        navDeadlineRunnable = null
        navCoalesceStarted = 0L
    }

    override fun onInterrupt() {
        cancelTyping()
        cancelNav()
    }
}
