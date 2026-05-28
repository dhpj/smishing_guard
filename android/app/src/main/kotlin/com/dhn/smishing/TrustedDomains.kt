package com.dhn.smishing

import android.net.Uri

/**
 * 신뢰 도메인 매칭 — 저장·검사 모두 쿼리/프래그먼트 제거 후
 * `host` 또는 `host/path` 로 비교 (Flutter [TrustedDomainMatcher] 와 동일 규칙).
 */
object TrustedDomains {
    fun matches(url: String, patterns: List<String>): Boolean {
        if (patterns.isEmpty()) return false
        val urlKey = canonicalKeyForUrl(url) ?: return false
        for (raw in patterns) {
            if (matchesKey(urlKey, raw)) return true
        }
        return false
    }

    fun matchesKey(urlKey: String, pattern: String): Boolean {
        val p = pattern.trim().lowercase()
        if (p.isEmpty()) return false

        if (p.startsWith("*.")) {
            val suffix = p.substring(2)
            val host = urlKey.substringBefore('/')
            return host == suffix || host.endsWith(".$suffix")
        }

        if (!p.contains('/')) {
            val host = urlKey.substringBefore('/')
            return host == p || host.endsWith(".$p")
        }

        return urlKey == p || urlKey.startsWith("$p/")
    }

    fun canonicalKeyForUrl(url: String): String? {
        var s = url.trim()
        if (s.isEmpty()) return null
        if (!s.contains("://")) {
            s = if (s.startsWith("www.", ignoreCase = true)) "https://$s" else "https://$s"
        }
        s = stripQueryFragment(s)
        val uri = Uri.parse(s)
        val host = uri.host?.lowercase() ?: return null
        var path = uri.path ?: ""
        if (path.isEmpty() || path == "/") return host
        path = path.trimEnd('/')
        return "$host$path"
    }

    /** 등록 시 정규화 (저장 문자열 목록 반환). */
    fun normalizeForStorage(rawLines: List<String>): List<String> {
        val out = linkedSetOf<String>()
        for (raw in rawLines) {
            normalizePattern(raw)?.let { out.add(it) }
        }
        return out.toList()
    }

    fun normalizePattern(raw: String): String? {
        var s = raw.trim().lowercase()
        if (s.isEmpty()) return null

        if (s.startsWith("*.")) {
            var suffix = s.substring(2)
            suffix = stripQueryFragment(suffix)
            val slash = suffix.indexOf('/')
            if (slash >= 0) suffix = suffix.substring(0, slash)
            if (suffix.isEmpty()) return null
            return "*.$suffix"
        }

        s = stripQueryFragment(s)
        if (!s.contains("://") && !s.contains("/")) {
            return s.substringBefore(':')
        }

        val withScheme = if (s.contains("://")) s else "https://$s"
        val uri = Uri.parse(withScheme)
        val host = uri.host?.lowercase() ?: return null
        var path = uri.path ?: ""
        if (path.isEmpty() || path == "/") return host
        if (!path.startsWith("/")) path = "/$path"
        path = path.trimEnd('/')
        return "$host$path"
    }

    private fun stripQueryFragment(s: String): String {
        var t = s
        val q = t.indexOf('?')
        if (q >= 0) t = t.substring(0, q)
        val f = t.indexOf('#')
        if (f >= 0) t = t.substring(0, f)
        return t.trim()
    }
}
