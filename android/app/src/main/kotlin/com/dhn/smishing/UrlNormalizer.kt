package com.dhn.smishing

import android.util.Patterns
import java.net.URI

private val zeroWidthChars = Regex("""[\u200B-\u200F\u2060-\u206F\uFEFF]""")

object UrlNormalizer {
    private val domainPattern = Regex(
        """^[a-zA-Z0-9][-a-zA-Z0-9.]*\.[a-zA-Z]{2,}(/[^\s<>'"]*)?$""",
        RegexOption.IGNORE_CASE,
    )

    /** 한글·자모가 URL 뒤에 붙어도 정규식이 같이 먹지 않도록 제외 */
    private val urlInText =
        Regex(
            """https?://[^\s<>'"\u0085\u2028\u2029\u3131-\u318E\uAC00-\uD7A3]+""",
            RegexOption.IGNORE_CASE,
        )

    /** http(s) 미부착: bit.ly/foo, coupang.com, www.naver.co.kr 등 */
    private val schemelessWebLink =
        Regex(
            """(?<![@\w])(?:www\.)?(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.){1,8}[a-zA-Z]{2,}(?::\d{1,5})?(?:/[^\s<>()"「」\]（），。…!?]*)?""",
            RegexOption.IGNORE_CASE,
        )

    /** 예: 210.114.225.58:8088/path (스킴 없음, 옥텟 검증) — 전체 조각용 */
    private val ipv4BareFragment =
        Regex(
            """^(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}(?::\d{1,5})?(?:/\S*)?$""",
        )

    /** 본문 속 임베디드 IPv4·경로 검색용 */
    private val ipv4InText =
        Regex(
            """(?<![\d.])(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}(?::\d{1,5})?(?:/\S*)?""",
        )

    /** SMS·카톡 등: 전각 : / 및 제로폭 문자가 있어도 http(s) 패턴이 잡히도록 전처리 */
    fun preprocessForUrlScan(raw: String): String {
        if (raw.isBlank()) return raw
        var t = raw
        t = zeroWidthChars.replace(t, "")
        val sb = StringBuilder(t.length + 16)
        for (ch in t) {
            when (ch) {
                '\uFF1A' -> sb.append(':') // ：
                '\uFF0F' -> sb.append('/') // ／
                '\u3002' -> sb.append('.') // 。
                '\u061B' -> sb.append(';') // ؛
                '\u060C' -> sb.append(',') // ،
                else -> sb.append(ch)
            }
        }
        return sb.toString().replace('\uFEFF', ' ')
    }

    fun normalize(raw: String?): String? {
        if (raw.isNullOrBlank()) return null
        var t = raw.trim().trimEnd('.', ',', ';', '!', ')', ']', '\uFEFF')
        t = wrapStrip(t)
        if (t.contains(" ")) return null
        if (t.startsWith("http://", ignoreCase = true)) return fullHttpUrlCleanup(t)
        if (t.startsWith("https://", ignoreCase = true)) return fullHttpUrlCleanup(t)
        if (t.startsWith("www.", ignoreCase = true)) return fullHttpUrlCleanup("https://$t")
        if (ipv4BareFragment.matches(t)) return fullHttpUrlCleanup("http://$t")
        return if (domainPattern.matches(t) || schemelessWebLink.matches(t)) {
            fullHttpUrlCleanup("https://$t")
        } else null
    }

    private fun wrapStrip(line: String): String {
        var s = line
        if ((s.startsWith("(") && s.endsWith(")")) ||
            (s.startsWith("<") && s.endsWith(">"))
        ) {
            s = s.substring(1, s.length - 1).trim()
        }
        return s
    }

    private fun fullHttpUrlCleanup(u: String): String =
        u.trimEnd('.', ',', ';', '!', ')', ']', '"', '\'', '\uFEFF')

    /**
     * 브라우저 주소창 비교용 — http/https·끝 슬래시·대소문자 차이로 재알림 나지 않게.
     */
    fun isSameBrowserPage(urlA: String, urlB: String): Boolean {
        val ka = canonicalBrowserKey(urlA)
        val kb = canonicalBrowserKey(urlB)
        if (ka == kb) return true
        return try {
            val ua = URI(ka)
            val ub = URI(kb)
            val hostA = ua.host?.lowercase() ?: return false
            val hostB = ub.host?.lowercase() ?: return false
            if (hostA != hostB) return false
            val pathA = (ua.path ?: "").trimEnd('/').ifEmpty { "/" }
            val pathB = (ub.path ?: "").trimEnd('/').ifEmpty { "/" }
            pathA == pathB || pathA.startsWith(pathB) || pathB.startsWith(pathA)
        } catch (_: Exception) {
            false
        }
    }

    fun canonicalBrowserKey(url: String): String {
        val sample = parseFromText(url) ?: normalize(url) ?: return url.trim().lowercase()
        return try {
            val uri = URI(sample)
            val host = uri.host?.lowercase() ?: return sample.lowercase()
            val path = (uri.path ?: "").trimEnd('/')
            val scheme = when (uri.scheme?.lowercase()) {
                "http", "https", null -> "https"
                else -> uri.scheme.lowercase()
            }
            val port = uri.port
            val portSuffix =
                if (port > 0 && port != 80 && port != 443) ":$port" else ""
            "$scheme://$host$portSuffix$path"
        } catch (_: Exception) {
            sample.lowercase().trimEnd('/')
        }
    }

    private val ipv4 = Regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}$")

    /**
     * 주소 표시 줄이 타자 중 불완전한 상태가 아닐 때만 검사(URI 파싱 + 최소 레이블 수).
     */
    fun looksLikeCommittedBrowsingUrl(parsedNormalizedUrl: String): Boolean {
        val sample = preprocessForUrlScan(parsedNormalizedUrl).trim()
        return try {
            val uri = URI(sample)
            val host = uri.host ?: return false
            if (host.endsWith('.')) return false
            if (host.startsWith('[') || host.contains(':')) return true
            if (ipv4.matches(host)) return true

            val labels = host.split('.').filter { it.isNotEmpty() }
            if (labels.size < 2) return false
            if (labels.any { lb -> lb.startsWith('-') || lb.endsWith('-') }) return false

            labels.last().length >= 2
        } catch (_: Exception) {
            false
        }
    }

    fun parseFromText(text: String?): String? {
        if (text.isNullOrBlank()) return null
        val t = preprocessForUrlScan(text).trim()
        normalize(t)?.let { return it }
        urlInText.find(t)?.let { normalize(trimSmsGlue(it.value)) }?.let { return it }
        schemelessWebLink.find(t)?.let { normalize(trimSmsGlue(it.value)) }?.let { return it }
        ipv4InText.find(t)?.let { normalize(trimSmsGlue(it.value)) }?.let { return it }
        val wm = Patterns.WEB_URL.matcher(t)
        if (wm.find()) normalize(trimSmsGlue(wm.group()))?.let { return it }
        firstRollingHttpClip(t)?.let { clip ->
            normalize(trimSmsGlue(clip))?.let { return it }
        }
        return null
    }

    /** parseFromText 용 · 본문 임베디드 URL 한 개 */
    private fun firstRollingHttpClip(s: String): String? {
        val idx = indexOfAnyHttp(s, 0)
        if (idx < 0) return null
        val c = clipHttpRunFromTail(s.substring(idx))
        return c.takeIf { it.length >= 11 }
    }

    /**
     * 문자·알림 본문 **전체**에서 URL 후보를 모두 뽑는다 (개수 제한 없음).
     */
    fun extractAllFromText(text: String): List<String> {
        val canon = preprocessForUrlScan(text)
        if (canon.isBlank()) return emptyList()
        val found = linkedSetOf<String>()
        // 광고 문구·한글 앞뒤가 있어도 http(s):// 위치부터 잘라내는 방식을 먼저
        addRollingHttpScans(canon, found)
        addPatternUrls(canon, found)
        addRollingSchemelessScans(canon, found)
        return found.toList()
    }

    /**
     * 정규식 lookbehind/경계 때문에 놓치는 **`한글(https://···)한글`**·**`/http://···`** 패턴까지
     * `http(s)://` 위치부터 한글·공백 전까지 긁어서 후보 추가.
     */
    private fun addRollingHttpScans(raw: String, found: MutableSet<String>) {
        var i = 0
        while (i <= raw.lastIndex) {
            val idx = indexOfAnyHttp(raw, i)
            if (idx < 0) break
            val tail = raw.substring(idx)
            val clipped = clipHttpRunFromTail(tail)
            if (clipped.length >= 11) tryAddUrl(found, clipped)
            i = idx + clipped.length.coerceAtLeast(1)
        }
    }

    private fun indexOfAnyHttp(raw: String, from: Int): Int {
        if (from > raw.lastIndex) return -1
        val haystack = raw.substring(from)
        val h1 = haystack.indexOf("http://", ignoreCase = true)
        val h2 = haystack.indexOf("https://", ignoreCase = true)
        val cand = sequenceOf(h1, h2).filter { it >= 0 }.minOrNull() ?: return -1
        return from + cand
    }

    private fun clipHttpRunFromTail(tail: String): String {
        if (!tail.regionMatches(0, "http://", 0, 7, ignoreCase = true) &&
            !tail.regionMatches(0, "https://", 0, 8, ignoreCase = true)
        ) {
            return ""
        }
        val sb = StringBuilder()
        for (ch in tail) {
            if (Character.isWhitespace(ch)) break
            if (ch == '\u0085' || ch == '\u2028' || ch == '\u2029') break

            val script = Character.UnicodeScript.of(ch.code)
            when (script) {
                Character.UnicodeScript.HANGUL,
                Character.UnicodeScript.HIRAGANA,
                Character.UnicodeScript.KATAKANA,
                -> break
                else -> { /* continue checks */ }
            }
            if (ch.code in 0x3131..0x318E) break
            if (!isRoughUrlCharSms(ch)) break
            sb.append(ch)
        }
        return sb.toString()
    }

    /** SMS용: 가시 ASCII·퍼센트 인코딩·괄호 등 URL에 흔한 문자. `" < > \` 는 본문과 경계로 보고 제외 */
    private fun isRoughUrlCharSms(ch: Char): Boolean {
        val cp = ch.code
        if (cp in 33..126) {
            if (cp in listOf(34, 60, 62, 92)) return false
            return !ch.isWhitespace()
        }
        return Character.UnicodeScript.of(cp) == Character.UnicodeScript.LATIN && ch.isLetter()
    }

    /** ANDROID Patterns.WEB_URL + http(s)·도메인 정규 — 줄 단위로 잘라 쓰지 않음 */
    private fun addPatternUrls(src: String, found: MutableSet<String>) {
        val m = Patterns.WEB_URL.matcher(src)
        while (m.find()) {
            tryAddUrl(found, m.group())
        }
        urlInText.findAll(src).forEach { tryAddUrl(found, it.value) }
        schemelessWebLink.findAll(src).forEach { tryAddUrl(found, it.value) }
        ipv4InText.findAll(src).forEach { tryAddUrl(found, it.value) }
    }

    private fun tryAddUrl(found: MutableSet<String>, fragment: String) {
        val glued = trimSmsGlue(fragment)
        normalize(glued)?.let { found.add(it); return }
        firstRollingHttpClip(glued)?.let { clip ->
            normalize(trimSmsGlue(clip))?.let { found.add(it) }
        }
    }

    /** `광고문구 naver.com/path 한글` — 스킴 없는 도메인을 본문에서 롤링 */
    private fun addRollingSchemelessScans(raw: String, found: MutableSet<String>) {
        val tld = Regex(
            """(?i)(?:www\.)?(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.)+(?:com|co\.kr|kr|net|org|io|me|app|dev|xyz|click|link|top|site|shop|info|biz)(?::\d{1,5})?(?:/[^\s\u3131-\u318E\uAC00-\uD7A3<>()"「」]*)?""",
        )
        tld.findAll(raw).forEach { m ->
            val hit = m.value
            if (hit.contains('@')) return@forEach
            tryAddUrl(found, hit)
        }
    }

    /**
     * Web URL 앞·뒤에 메시지(한글, 광고 괄호…)가 붙어도 http(s)://·www. 부터만 남긴다.
     */
    private fun trimSmsGlue(raw: String): String {
        var x = raw.trim().trimStart('<', '[', '(', '{', '「', '『', '【', '"', '\'', '*', '［', '＜')
        val anchor = sequenceOf(
            x.indexOf("https://", ignoreCase = true),
            x.indexOf("http://", ignoreCase = true),
            x.indexOf("www.", ignoreCase = true),
        ).filter { it >= 0 }.minOrNull()
        if (anchor != null && anchor > 0) x = x.substring(anchor)
        while (x.isNotEmpty()) {
            val last = x.last()
            val hangul =
                Character.UnicodeScript.of(last.code) == Character.UnicodeScript.HANGUL ||
                    last.code in 0x3131..0x318E
            when {
                hangul -> x = x.dropLast(1)
                last in smsTrailingGarbage -> x = x.dropLast(1)
                else -> break
            }
        }
        return x.trim()
    }

    /**
     * URL 뒤에 붙는 문장 부호 등(괄호·닫는 기호 제외 보수적)만 제거한다.
     * `)` 는 URL 경로에 쓰이는 경우가 있어 빼두었다—한글·일반 마침부호는 제거된다.
     */
    private val smsTrailingGarbage =
        setOf(
            ']', '}', '>', '"', '\'', '」', '』', '】', '〉', '》',
            ',', '.', ';', ':', '!', '?', '，', '。', '．', '、', '；', '…', '⋯',
            '*', '※', '·', '•', '►', '▶',
        )
}
