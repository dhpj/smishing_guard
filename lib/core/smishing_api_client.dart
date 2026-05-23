import 'dart:convert';

import 'package:http/http.dart' as http;

import 'url_extractor.dart';

/// 서버 베이스: http://host:port — 경로는 /check_uri, /set_userid, /get_ad_img
class SmishingApiClient {
  SmishingApiClient({
    required this.baseUrl,
    required this.userId,
    this.mockMode = false,
  });

  static const defaultBaseUrl = 'http://210.114.225.58:8087';

  static const codeSafe = '0000';
  static const codeSmishing = '0001';

  final String baseUrl;
  final String userId;
  final bool mockMode;

  String get checkUriUrl => '$baseUrl/check_uri';
  String get setUseridUrl => '$baseUrl/set_userid';
  String get getAdImgUrl => '$baseUrl/get_ad_img';

  /// Header [android_id] only — body 없음. HTTP 200 + userid 필수.
  Future<String> issueUserId(String androidId) async {
    if (mockMode) {
      return 'mock-${androidId.hashCode.abs()}';
    }
    final response = await http
        .post(
          Uri.parse(setUseridUrl),
          headers: {'android_id': androidId},
        )
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) {
      throw SmishingServiceUnavailableException(
        'set_userid HTTP ${response.statusCode}',
      );
    }

    final body = jsonDecode(response.body);
    if (body is Map) {
      final id = body['userid']?.toString().trim() ?? '';
      if (id.isNotEmpty) return id;
    }
    throw SmishingServiceUnavailableException('set_userid: userid 없음');
  }

  static bool isKnownTestDangerUrl(String uri) =>
      uri.toLowerCase().contains('testsafebrowsing.appspot.com');

  static String _normalizeCode(dynamic raw) {
    if (raw == null) return '';
    final s = raw.toString().trim();
    if (s == '1' || s == '0001') return codeSmishing;
    if (s == '0' || s == '0000') return codeSafe;
    final n = int.tryParse(s);
    if (n == 1) return codeSmishing;
    if (n == 0) return codeSafe;
    return s;
  }

  Future<UriCheckResponse> checkUri(String uri) async {
    final normalized = UrlExtractor.normalize(uri) ?? uri;
    if (mockMode || isKnownTestDangerUrl(normalized)) {
      return _mockCheck(normalized);
    }

    final response = await http
        .post(
          Uri.parse(checkUriUrl),
          headers: {
            'userid': userId,
            'Content-Type': 'application/json',
          },
          body: jsonEncode({'uri': normalized}),
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw UriCheckException(
        code: 'HTTP_${response.statusCode}',
        message: '서버 응답 오류 (${response.statusCode})',
      );
    }

    final body = jsonDecode(response.body) as Map<String, dynamic>;
    final code = _normalizeCode(body['code']);
    final message = body['message']?.toString() ?? body['msg']?.toString() ?? '';

    if (code != codeSafe && code != codeSmishing) {
      throw UriCheckException(
        code: code,
        message: message.isNotEmpty ? message : '검사 실패',
      );
    }

    return UriCheckResponse(code: code, message: message);
  }

  Future<List<AdImageResponse>> getAdImages() async {
    if (mockMode) return [];

    final response = await http
        .post(
          Uri.parse(getAdImgUrl),
          headers: {'userid': userId},
        )
        .timeout(const Duration(seconds: 8));

    if (response.statusCode != 200) return [];

    final body = jsonDecode(response.body);
    final out = <AdImageResponse>[];
    for (final item in _parseAdImageList(body)) {
      final imgUrl = item['img_url']?.toString().trim() ?? '';
      if (imgUrl.isEmpty) continue;
      final imgLink = item['img_link']?.toString().trim() ?? '';
      out.add(AdImageResponse(imgUrl: imgUrl, imgLink: imgLink));
    }
    return out;
  }

  /// 서버: `[{ "img_url": "...", "img_link": "..." }, ...]` 또는 단일 객체
  static List<Map<String, dynamic>> _parseAdImageList(dynamic body) {
    if (body is List) {
      return body
          .whereType<Map>()
          .map((e) => Map<String, dynamic>.from(e))
          .toList();
    }
    if (body is Map) {
      if (body['img_url'] != null) {
        return [Map<String, dynamic>.from(body)];
      }
      for (final key in ['data', 'list', 'items', 'result']) {
        final inner = body[key];
        if (inner != null) {
          final parsed = _parseAdImageList(inner);
          if (parsed.isNotEmpty) return parsed;
        }
      }
    }
    return [];
  }

  UriCheckResponse _mockCheck(String uri) {
    final lower = uri.toLowerCase();
    if (['phish', 'evil', 'fake', 'scam', 'malware', 'virus'].any(lower.contains) ||
        lower.contains('testsafebrowsing.appspot.com')) {
      return const UriCheckResponse(
        code: codeSmishing,
        message: 'Mock: 스미싱 주의',
      );
    }
    return const UriCheckResponse(code: codeSafe, message: 'Mock: 안전');
  }
}

class UriCheckResponse {
  const UriCheckResponse({required this.code, required this.message});

  final String code;
  final String message;

  bool get isSafe => code == SmishingApiClient.codeSafe;
  bool get isSmishing => code == SmishingApiClient.codeSmishing;
}

class AdImageResponse {
  const AdImageResponse({required this.imgUrl, required this.imgLink});

  final String imgUrl;
  final String imgLink;
}

class UriCheckException implements Exception {
  UriCheckException({required this.code, required this.message});

  final String code;
  final String message;

  @override
  String toString() => 'UriCheckException($code: $message)';
}

class SmishingServiceUnavailableException implements Exception {
  SmishingServiceUnavailableException(this.detail);

  final String detail;

  @override
  String toString() => 'SmishingServiceUnavailableException($detail)';
}
