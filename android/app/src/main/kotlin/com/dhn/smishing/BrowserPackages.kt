package com.dhn.smishing

import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.util.Log

/**
 * 브라우저 패키지 화이트리스트.
 *
 * 두 가지 경로의 union 으로 판정한다:
 *   1. **하드코딩 [baseSet]** — 한국·글로벌에서 자주 쓰이는 브라우저 식별자 모음. 디바이스 조회
 *      가 어떤 이유로 실패해도 일단 동작하도록 보장하는 fallback.
 *   2. **동적 [dynamicSet]** — `PackageManager.queryIntentActivities` 로 디바이스에 실제로
 *      설치되어 "임의의 https 호스트" 를 처리할 수 있는 액티비티를 조회한 결과. 새 브라우저가
 *      나와도 코드 수정 없이 자동 인식된다.
 *
 *  - manifest 의 `<queries>` 에 http/https `VIEW` intent 가 등록되어 있어야 Android 11+ 의
 *    패키지 가시성 제한 하에서도 조회가 동작한다 (이미 등록되어 있음).
 *  - 일반 deep link 앱(Twitter 의 twitter.com 호스트 등)은 자신의 도메인만 받기 때문에, 서로
 *    다른 호스트 두 개를 모두 처리하는 패키지로 교집합을 좁히면 자연스럽게 제외된다.
 */
object BrowserPackages {
    private const val TAG = "SmishingBrowsers"

    private val baseSet: Set<String> = setOf(
        // Google Chrome / Chromium
        "com.android.chrome",
        "com.chrome.beta",
        "com.chrome.dev",
        "com.chrome.canary",
        "com.google.android.apps.chrome",
        "org.chromium.chrome",
        // Naver Whale
        "com.naver.whale",
        "com.naver.whale.beta",
        // Samsung Internet
        "com.sec.android.app.sbrowser",
        "com.sec.android.app.sbrowser.beta",
        "com.sec.android.app.sbrowser.lite",
        // Mozilla Firefox 계열
        "org.mozilla.firefox",
        "org.mozilla.firefox_beta",
        "org.mozilla.fenix",
        "org.mozilla.fennec_fdroid",
        "org.mozilla.focus",
        "org.mozilla.klar",
        // Microsoft Edge
        "com.microsoft.emmx",
        "com.microsoft.emmx.beta",
        "com.microsoft.emmx.dev",
        "com.microsoft.emmx.canary",
        // Opera
        "com.opera.browser",
        "com.opera.browser.beta",
        "com.opera.mini.native",
        "com.opera.mini.native.beta",
        "com.opera.touch",
        "com.opera.gx",
        // Brave
        "com.brave.browser",
        "com.brave.browser_beta",
        "com.brave.browser_nightly",
        // Vivaldi
        "com.vivaldi.browser",
        "com.vivaldi.browser.snapshot",
        // DuckDuckGo
        "com.duckduckgo.mobile.android",
        "com.duckduckgo.mobile.android.debug",
        // Kiwi
        "com.kiwibrowser.browser",
        // Chinese / Asian
        "com.mi.globalbrowser",
        "com.mi.globalbrowser.mini",
        "com.huawei.browser",
        "com.UCMobile.intl",
        "com.UCMobile.x86",
        "com.yandex.browser",
        "com.tencent.mtt",         // QQ
        "com.baidu.browser.inter",
        "com.qihoo.contents",      // 360
        // Privacy / niche
        "org.bromite.bromite",
        "org.lineageos.jelly",
        "acr.browser.lightning",
        "acr.browser.barebones",
        "org.adblockplus.browser",
        "com.cake.browser",
        "com.cloudmosa.puffinFree",
        "mark.via.gp",
        "mark.via",
        "com.androidbull.incognito.browser",
        "com.startpage.app",
        "org.torproject.torbrowser",
        "info.guardianproject.orfox",
    )

    @Volatile
    private var dynamicSet: Set<String> = emptySet()

    /** 현재까지 알려진 모든 브라우저 패키지 — base ∪ dynamic */
    val all: Set<String>
        get() = if (dynamicSet.isEmpty()) baseSet else baseSet + dynamicSet

    /**
     * `PackageManager` 로 "임의 https URL 을 처리할 수 있는 모든 패키지" 를 조회해서 동적 집합을
     * 갱신한다. 서로 다른 두 호스트에 대해 모두 응답하는 패키지로 교집합을 잡으면 일반 deep link
     * 앱은 제외되고 브라우저만 남는다.
     */
    fun refresh(context: Context) {
        try {
            val pm = context.packageManager
            val a = resolveForUrl(pm, "https://www.example.com/").toSet()
            val b = resolveForUrl(pm, "https://nonexistent-host.test/path").toSet()
            val both = a.intersect(b)
            if (both.isNotEmpty()) {
                dynamicSet = both
                Log.i(TAG, "discovered ${both.size} browser(s) on device: $both")
            } else {
                Log.w(TAG, "no browsers discovered via PackageManager — using baseSet only")
            }
        } catch (e: Exception) {
            Log.e(TAG, "browser discovery failed: ${e.message}", e)
        }
    }

    private fun resolveForUrl(pm: PackageManager, url: String): List<String> {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            .addCategory(Intent.CATEGORY_BROWSABLE)
        val list = pm.queryIntentActivities(intent, 0)
        return list.mapNotNull { it.activityInfo?.packageName }
    }
}
