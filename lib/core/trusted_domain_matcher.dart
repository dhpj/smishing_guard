/// 신뢰 도메인 등록·매칭 (쿼리·프래그먼트 제거 후 host 또는 host/path 비교).
abstract final class TrustedDomainMatcher {
  /// 저장용 — URL·쿼리 포함 입력도 `host` 또는 `host/path` 로 정규화.
  static List<String> normalizeForStorage(Iterable<String> rawLines) {
    final out = <String>[];
    final seen = <String>{};
    for (final raw in rawLines) {
      final n = normalizePattern(raw);
      if (n != null && seen.add(n)) out.add(n);
    }
    return out;
  }

  static String? normalizePattern(String raw) {
    var s = raw.trim().toLowerCase();
    if (s.isEmpty) return null;

    if (s.startsWith('*.')) {
      var suffix = s.substring(2);
      suffix = _stripQueryFragment(suffix);
      final slash = suffix.indexOf('/');
      if (slash >= 0) suffix = suffix.substring(0, slash);
      if (suffix.isEmpty) return null;
      return '*.$suffix';
    }

    s = _stripQueryFragment(s);
    if (!s.contains('://') && !s.contains('/')) {
      return s.split(':').first;
    }

    final uri = _parseAsUri(s);
    if (uri == null) return null;
    final host = uri.host;
    if (host.isEmpty) return null;

    var path = uri.path;
    if (path == '/' || path.isEmpty) return host;
    if (!path.startsWith('/')) path = '/$path';
    path = path.replaceAll(RegExp(r'/+$'), '');
    return '$host$path';
  }

  static bool isTrusted(String url, List<String> storedPatterns) {
    if (storedPatterns.isEmpty) return false;
    final key = canonicalKeyForUrl(url);
    if (key == null) return false;
    for (final pattern in storedPatterns) {
      if (_matches(key, pattern)) return true;
    }
    return false;
  }

  /// 검사 대상 URL → `host` 또는 `host/path` (쿼리·프래그먼트 없음).
  static String? canonicalKeyForUrl(String url) {
    var s = url.trim();
    if (s.isEmpty) return null;
    if (!s.contains('://')) {
      s = s.startsWith('www.') ? 'https://$s' : 'https://$s';
    }
    s = _stripQueryFragment(s);
    final uri = Uri.tryParse(s);
    if (uri == null || uri.host.isEmpty) return null;
    final host = uri.host.toLowerCase();
    var path = uri.path;
    if (path.isEmpty || path == '/') return host;
    path = path.replaceAll(RegExp(r'/+$'), '');
    return '$host$path';
  }

  static bool _matches(String urlKey, String pattern) {
    final p = pattern.trim().toLowerCase();
    if (p.isEmpty) return false;

    if (p.startsWith('*.')) {
      final suffix = p.substring(2);
      final host = urlKey.contains('/') ? urlKey.substring(0, urlKey.indexOf('/')) : urlKey;
      return host == suffix || host.endsWith('.$suffix');
    }

    if (!p.contains('/')) {
      final host = urlKey.contains('/') ? urlKey.substring(0, urlKey.indexOf('/')) : urlKey;
      return host == p || host.endsWith('.$p');
    }

    return urlKey == p || urlKey.startsWith('$p/');
  }

  static String _stripQueryFragment(String s) {
    var t = s;
    final q = t.indexOf('?');
    if (q >= 0) t = t.substring(0, q);
    final f = t.indexOf('#');
    if (f >= 0) t = t.substring(0, f);
    return t.trim();
  }

  static Uri? _parseAsUri(String s) {
    if (s.contains('://')) return Uri.tryParse(s);
    return Uri.tryParse('https://$s');
  }
}
