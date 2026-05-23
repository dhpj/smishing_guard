package com.dhn.smishing

/** Chrome, Whale, Firefox, Edge, Samsung Internet, Opera, Brave 등 */
object BrowserPackages {
    val all = setOf(
        // Google Chrome / Chromium
        "com.android.chrome",
        "com.chrome.beta",
        "com.android.chrome.dev",
        "com.google.android.apps.chrome",
        // Naver Whale
        "com.naver.whale",
        // Samsung Internet
        "com.sec.android.app.sbrowser",
        "com.sec.android.app.sbrowser.beta",
        // Mozilla Firefox
        "org.mozilla.firefox",
        "org.mozilla.firefox_beta",
        "org.mozilla.fenix",
        // Microsoft Edge
        "com.microsoft.emmx",
        // Opera
        "com.opera.browser",
        "com.opera.mini.native",
        "com.opera.touch",
        // Brave, Vivaldi, DuckDuckGo, Kiwi
        "com.brave.browser",
        "com.vivaldi.browser",
        "com.duckduckgo.mobile.android",
        "com.kiwibrowser.browser",
        // 기타 Chromium 계열
        "com.mi.globalbrowser",
        "com.huawei.browser",
        "com.UCMobile.intl",
        "com.yandex.browser",
    )
}
