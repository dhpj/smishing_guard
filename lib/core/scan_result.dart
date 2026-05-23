enum UrlSource {
  sms,
  smsNotif,
  kakao,
  telegram,
  line,
  browser,
  notif,
  manual;

  static UrlSource fromWire(String? wire) {
    switch (wire) {
      case 'sms':
        return UrlSource.sms;
      case 'sms_notif':
      case 'sms_db':
        return UrlSource.smsNotif;
      case 'kakao':
        return UrlSource.kakao;
      case 'telegram':
        return UrlSource.telegram;
      case 'line':
        return UrlSource.line;
      case 'browser':
        return UrlSource.browser;
      case 'notif':
        return UrlSource.notif;
      default:
        return UrlSource.manual;
    }
  }

  String get displayName => switch (this) {
        UrlSource.sms || UrlSource.smsNotif => '문자',
        UrlSource.kakao => '카카오톡',
        UrlSource.telegram => '텔레그램',
        UrlSource.line => 'LINE',
        UrlSource.browser => '브라우저',
        UrlSource.notif || UrlSource.manual => '기타',
      };
}

class ScanResult {
  ScanResult({
    required this.url,
    required this.source,
    required this.code,
    required this.message,
    required this.checkedAt,
    String? entryId,
    this.bodyText,
    this.senderTitle,
  }) : entryId = entryId ?? newEntryId();

  final String entryId;
  final String url;
  final UrlSource source;
  final String code;
  final String message;
  final DateTime checkedAt;
  final String? bodyText;
  final String? senderTitle;

  static String newEntryId() =>
      '${DateTime.now().microsecondsSinceEpoch}_${DateTime.now().hashCode}';

  bool get isDangerous => code == '0001';
  bool get isSafe => code == '0000';

  bool get hasMessageDetail =>
      bodyText != null && bodyText!.trim().isNotEmpty;

  String get resultLabel => switch (code) {
        '0000' => '안전',
        '0001' => '스미싱 주의',
        _ => code.startsWith('HTTP_') ? '연결 오류' : '검사 실패',
      };

  /// 타임라인 적재용 — 매 탐지마다 고유 ID·현재 시각
  ScanResult forTimeline() {
    return ScanResult(
      entryId: newEntryId(),
      url: url,
      source: source,
      code: code,
      message: message,
      checkedAt: DateTime.now(),
      bodyText: bodyText,
      senderTitle: senderTitle,
    );
  }

  Map<String, dynamic> toJson() => {
        'entryId': entryId,
        'url': url,
        'source': source.name,
        'code': code,
        'message': message,
        'checkedAt': checkedAt.toIso8601String(),
        if (bodyText != null && bodyText!.isNotEmpty) 'bodyText': bodyText,
        if (senderTitle != null && senderTitle!.isNotEmpty)
          'senderTitle': senderTitle,
      };

  factory ScanResult.fromJson(Map<String, dynamic> json) {
    final url = json['url'] as String? ?? '';
    final checkedAt = DateTime.tryParse(json['checkedAt'] as String? ?? '') ??
        DateTime.now();
    return ScanResult(
      entryId: json['entryId'] as String? ??
          '${checkedAt.microsecondsSinceEpoch}_$url',
      url: url,
      source: UrlSource.values.firstWhere(
        (s) => s.name == json['source'],
        orElse: () => UrlSource.manual,
      ),
      code: json['code'] as String? ?? '',
      message: json['message'] as String? ?? '',
      checkedAt: checkedAt,
      bodyText: json['bodyText'] as String?,
      senderTitle: json['senderTitle'] as String?,
    );
  }
}
