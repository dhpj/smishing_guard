import '../core/scan_result.dart';

/// 타임라인·상세 화면용 — 발송자/앱명 중복 줄 제거 후 본문만
String formatMessageBodyForDisplay(ScanResult result) {
  var body = result.bodyText?.trim() ?? '';
  if (body.isEmpty) return '';

  final skip = <String>{
    if (result.senderTitle != null && result.senderTitle!.trim().isNotEmpty)
      result.senderTitle!.trim(),
    result.source.displayName,
  };

  final lines = body.split(RegExp(r'\n+'));
  var start = 0;
  while (start < lines.length && skip.contains(lines[start].trim())) {
    start++;
  }

  return lines.sublist(start).join('\n').trim();
}
