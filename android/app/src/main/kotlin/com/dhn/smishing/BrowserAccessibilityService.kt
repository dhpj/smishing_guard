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

        /**
         * 브라우저 외 패키지에 이만큼 머무르면 visit 정보를 클리어한다.
         * - 시스템 UI/IME/메뉴 깜빡임(보통 200~500ms)은 흡수
         * - 브라우저 종료 후 재실행 / 다른 앱 다녀온 후 복귀(보통 1초+) 는 새 visit 처리
         */
        private const val LEAVE_BROWSER_CLEAR_VISIT_MS = 1500L

        @Volatile
        private var instance: BrowserAccessibilityService? = null

        @Volatile
        private var overlayCheckGeneration: Long = 0L

        /**
         * 보호 OFF→ON 토글 등 외부에서 visit 상태를 강제로 비울 때 호출.
         * (시스템 UI/런처 깜빡임에는 영향을 주지 않는다.)
         */
        fun clearFiredUrls() {
            val svc = instance ?: return
            svc.currentVisitKey = null
            svc.firedInCurrentVisit = false
        }

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

        /** 같은 페이지에서 이미 한 번 알림을 띄웠는지 — 캐시 hit 경로 가드 */
        fun isAlreadyAlertedFor(url: String): Boolean {
            val svc = instance ?: return false
            val alerted = svc.lastAlertedUrl ?: return false
            return UrlNormalizer.isSameBrowserPage(url, alerted)
        }
    }

    /** 마지막으로 0001 알림을 띄운 URL — 같으면 터치 이벤트만 무시 (재검사는 UriCheckCache) */
    private var lastAlertedUrl: String? = null

    /**
     * 현재 사용자가 「보고 있는」 페이지의 canonical key.
     *
     * URL bar 가 다른 URL 로 한 번이라도 바뀌면 새 visit 으로 갱신된다 — 탭 닫기·새 탭·다른
     * URL 이동·about:blank 경유 모두 visit 변화로 잡힘. 같은 visit 안에서만 1회 발사.
     */
    @Volatile
    private var currentVisitKey: String? = null

    /** 현재 visit 에서 이미 검사 발사했는가 */
    @Volatile
    private var firedInCurrentVisit: Boolean = false

    private val mainHandler = Handler(Looper.getMainLooper())
    private var typingSettle: Runnable? = null
    private var typingVerify: Runnable? = null
    private var navQuietRunnable: Runnable? = null
    private var navDeadlineRunnable: Runnable? = null
    /** 브라우저 외 머무름이 충분히 길면 visit 정보를 클리어 — 위에서 정의한 상수 만큼 지연 */
    private var clearVisitRunnable: Runnable? = null
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
                scheduleVisitClear()
            }
            return
        }

        // 브라우저 패키지 이벤트가 들어왔다 — 짧게 깜빡인 거면 visit clear 예약을 취소.
        // 충분히 오래 떠나 있었다면 이미 실행돼 visit 이 null 인 상태일 것.
        cancelVisitClear()

        if (!ProtectionPrefs.isActive(applicationContext)) return

        val now = SystemClock.elapsedRealtime()
        if (now - lastEventAt < EVENT_MIN_INTERVAL_MS) {
            return
        }
        lastEventAt = now

        // URL bar 변화로 visit 갱신 감지 — 탭 닫기·새 탭·다른 URL 이동 시 같은 URL 도
        // 새 방문으로 인정해 알림이 다시 뜨도록 한다.
        detectVisitChange()

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

    /**
     * URL bar 의 현재 값을 읽어 visit 변화를 감지한다. 다른 페이지로 한 번이라도 이동한 적이
     * 있다면 (탭 닫기 → 새 탭 → 같은 URL 재방문 포함) `firedInCurrentVisit` 가 false 로 돌아가
     * 다시 1회 알림이 가능해진다.
     */
    private fun detectVisitChange() {
        val barUrl = readCommittedUrlFromBar() ?: return
        val key = UrlNormalizer.canonicalBrowserKey(barUrl)
        if (key != currentVisitKey) {
            Log.d(TAG, "visit changed: ${currentVisitKey ?: "(none)"} → $key")
            currentVisitKey = key
            firedInCurrentVisit = false
            lastAlertedUrl = null
        }
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
        // 진행 중이던 nav 타이머·typing 타이머가 같은 URL에 대해 한 번 더 fireCheck
        // 하는 것을 차단한다 — 캐시 hit으로 오버레이가 폭주하는 원인.
        cancelNav()
        cancelTyping()
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
        val key = UrlNormalizer.canonicalBrowserKey(url)

        // 현재 visit 의 URL 이 아직 미정이면 이 fire 가 첫 검사이므로 visit 키도 함께 정함.
        if (currentVisitKey == null) {
            currentVisitKey = key
        }

        // 정책: 「현재 페이지(visit)에서 같은 URL 은 단 1회」
        //  - typing 분기 / nav 분기 / 메뉴·허공 터치로 인한 재진입 모두 차단
        //  - URL bar 가 다른 페이지로 한 번이라도 바뀐 적이 있다면 detectVisitChange 가
        //    firedInCurrentVisit 을 false 로 되돌려 같은 URL 도 새 방문으로 인정.
        if (firedInCurrentVisit && key == currentVisitKey) {
            Log.d(TAG, "[$pkg] skip same-visit ($reason) → $url")
            return
        }

        // 보조 가드: 다른 분기가 먼저 표시한 알림과 같은 URL 이면 즉시 차단.
        lastAlertedUrl?.let { alerted ->
            if (UrlNormalizer.isSameBrowserPage(url, alerted)) {
                Log.d(TAG, "[$pkg] skip already-alerted ($reason) → $url")
                return
            }
        }

        // 발사 시점에 즉시 기록 — 응답이 늦게 와도 재발사를 막는다.
        firedInCurrentVisit = true
        currentVisitKey = key

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
        // 주의: currentVisitKey 와 firedInCurrentVisit 은 클리어하지 않는다.
        // 시스템 UI/런처/IME 가 잠깐 떠서 pkg 가 브라우저 외부로 잡힐 때 비워지면
        // 브라우저로 돌아온 즉시 같은 페이지가 새 visit 으로 인식돼 알림이 재발사된다.
        // 실제 visit 변화는 URL bar 변화를 통해 detectVisitChange 가 잡는다.
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

    /**
     * 브라우저 외 패키지로 이동한 직후 호출. 일정 시간 머무르면 visit 정보를 클리어해
     * 「브라우저 종료 후 같은 페이지로 재실행 시 알림이 다시 뜨도록」 만든다.
     * 그 사이 브라우저로 돌아오면 [cancelVisitClear] 가 예약을 취소한다.
     */
    private fun scheduleVisitClear() {
        cancelVisitClear()
        val r = Runnable {
            currentVisitKey = null
            firedInCurrentVisit = false
            lastAlertedUrl = null
            Log.d(TAG, "visit cleared (away from browser ≥ ${LEAVE_BROWSER_CLEAR_VISIT_MS}ms)")
            clearVisitRunnable = null
        }
        clearVisitRunnable = r
        mainHandler.postDelayed(r, LEAVE_BROWSER_CLEAR_VISIT_MS)
    }

    private fun cancelVisitClear() {
        clearVisitRunnable?.let {
            mainHandler.removeCallbacks(it)
            clearVisitRunnable = null
        }
    }

    override fun onInterrupt() {
        cancelTyping()
        cancelNav()
        cancelVisitClear()
    }
}
