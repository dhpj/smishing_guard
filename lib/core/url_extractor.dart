final _urlPattern = RegExp(
  r'(https?:\/\/[^\s<>"\]\u0085\u2028\u2029\u3131-\u318E\uAC00-\uD7A3]+|www\.[^\s<>"\]\u0085\u2028\u2029\u3131-\u318E\uAC00-\uD7A3]+)',
  caseSensitive: false,
);

/// http(s) 없이 도메인만: bit.ly/a, shop.coupang.com, naver.co.kr/foo
final _schemelessPattern = RegExp(
  r'(?<![@\w])(?:www\.)?(?:[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.){1,8}[a-zA-Z]{2,}(?::\d{1,5})?(?:\/[^\s<>()"「」\]（），。…!?]*)?',
  caseSensitive: false,
);

/// 스킴 없는 IPv4 + 선택 경로·포트 (옥텟 범위 대략 검증)
final _ipv4NoSchemePattern = RegExp(
  r'(?<![\d.])(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}(?::\d{1,5})?(?:\/\S*)?',
);

final _leadingBracketTag = RegExp(r'^\[[^\]]+\]\s*');
final _leadingParensAds = RegExp(r'^(\([^)]+\))+');
final _dashFenceLine = RegExp(r'^-{3,}$');
final _zeroWidthAndBom = RegExp(r'[\u200B-\u200F\u2060-\u206F\uFEFF]');

/// SMS·알림 본문(줄 단위 `[Web발신]`·`(광고)` 등 포함)에서 URL 후보 추출.
/// Android `UrlNormalizer.preprocessForUrlScan` 과 동등한 전처리.
class UrlExtractor {
  static String preprocessForScan(String raw) {
    if (raw.isEmpty) return raw;
    final stripped = raw.replaceAll(_zeroWidthAndBom, '');
    final sb = StringBuffer();
    for (final ch in stripped.runes) {
      switch (ch) {
        case 0xFF1A:
          sb.write(':');
          break;
        case 0xFF0F:
          sb.write('/');
          break;
        case 0x3002:
          sb.write('.');
          break;
        case 0x061B:
          sb.write(';');
          break;
        case 0x060C:
          sb.write(',');
          break;
        default:
          sb.writeCharCode(ch);
      }
    }
    return sb.toString().replaceAll('\uFEFF', ' ');
  }

  static List<String> extract(String text) {
    final found = <String>{};
    final canon = preprocessForScan(text);

    void collectFrom(String blob) {
      if (blob.isEmpty) return;
      for (final pattern in [_urlPattern, _schemelessPattern, _ipv4NoSchemePattern]) {
        for (final match in pattern.allMatches(blob)) {
          var raw = match.group(0);
          if (raw == null || raw.isEmpty) continue;
          raw = raw.replaceAll(RegExp(r'[.,;:!?）、\]]+$'), '');
          final n = normalize(raw);
          if (n != null) found.add(n);
        }
      }
    }

    _collectRollingHttp(canon, found);
    collectFrom(canon);

    for (final rawLine in canon.split(RegExp(r'[\r\n]+'))) {
      var line = rawLine.trim();
      line = line.replaceFirst(_dashFenceLine, '').trim();
      line = line.replaceFirst(_leadingParensAds, '').trim();
      line = line.replaceFirst(_leadingBracketTag, '').trim();
      if (line.isEmpty) continue;
      collectFrom(line);
    }

    return found.toList();
  }

  /// `(광고)…한글https://…한글` — http 위치부터 한글·공백 전까지만
  static void _collectRollingHttp(String raw, Set<String> found) {
    var i = 0;
    while (i < raw.length) {
      final h1 = raw.indexOf('http://', i);
      final h2 = raw.indexOf('https://', i);
      final candidates = [h1, h2].where((x) => x >= 0);
      if (candidates.isEmpty) break;
      final idx = candidates.reduce((a, b) => a < b ? a : b);
      final clip = _clipHttpRun(raw.substring(idx));
      if (clip.length >= 11) {
        final n = normalize(_trimGlue(clip));
        if (n != null) found.add(n);
      }
      i = idx + (clip.isEmpty ? 1 : clip.length);
    }
  }

  static String _clipHttpRun(String tail) {
    final sb = StringBuffer();
    for (final ch in tail.runes) {
      if (ch >= 0xAC00 && ch <= 0xD7A3) break;
      if (ch >= 0x3131 && ch <= 0x318E) break;
      if (ch <= 0x20 || ch == 0x85 || ch == 0x2028 || ch == 0x2029) break;
      if (ch == 0x22 || ch == 0x3C || ch == 0x3E || ch == 0x5C) break;
      sb.writeCharCode(ch);
    }
    return sb.toString();
  }

  static String _trimGlue(String raw) {
    var x = raw.trim();
    for (final needle in ['https://', 'http://', 'www.']) {
      final i = x.toLowerCase().indexOf(needle);
      if (i > 0) x = x.substring(i);
    }
    while (x.isNotEmpty) {
      final cp = x.codeUnitAt(x.length - 1);
      if ((cp >= 0xAC00 && cp <= 0xD7A3) ||
          (cp >= 0x3131 && cp <= 0x318E) ||
          '.,;:!?）、」』】'.contains(x[x.length - 1])) {
        x = x.substring(0, x.length - 1);
      } else {
        break;
      }
    }
    return x;
  }

  static String? normalize(String url) {
    var u = _trimGlue(url.trim());
    if (u.contains(' ') || u.contains('@')) return null;
    final lower = u.toLowerCase();
    if (lower.startsWith('http://')) return u;
    if (lower.startsWith('https://')) return u;
    if (lower.startsWith('www.')) return 'https://$u';
    // IPv4 + 포트/경로 (스킴 없음)
    if (_ipv4BareOnly.hasMatch(lower)) return 'http://$u';
    // 도메인 형태만 https 붙임
    if (_domainLike.hasMatch(lower)) return 'https://$u';
    return null;
  }

  /// 전체 문자열이 IPv4(+선택 :포트 /경로)인지 (정규화 판별용)
  static final _ipv4BareOnly = RegExp(
    r'^(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)(?:\.(?:25[0-5]|2[0-4]\d|1\d{2}|[1-9]?\d)){3}(?::\d{1,5})?(?:\/\S*)?$',
  );

  static final _domainLike = RegExp(
    r'^(?:www\.)?(?:[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?\.){1,8}[a-z]{2,}(?::\d{1,5})?(?:\/[^\s<>()\]]*)?$',
    caseSensitive: false,
  );
}
