String formatKoreanDateTime(DateTime d) {
  final period = d.hour < 12 ? '오전' : '오후';
  final hour12 = d.hour == 0
      ? 12
      : d.hour > 12
          ? d.hour - 12
          : d.hour;
  final m = d.month.toString().padLeft(2, '0');
  final day = d.day.toString().padLeft(2, '0');
  final min = d.minute.toString().padLeft(2, '0');
  final sec = d.second.toString().padLeft(2, '0');
  return '${d.year}년 $m월 $day일 $period $hour12시 $min분 $sec초';
}

String truncatePreview(String text, {int maxLen = 72}) {
  final t = text.replaceAll(RegExp(r'\s+'), ' ').trim();
  if (t.length <= maxLen) return t;
  return '${t.substring(0, maxLen).trimRight()}…';
}
