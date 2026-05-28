import 'package:shared_preferences/shared_preferences.dart';

/// 메인 화면의 통계 카드(오늘 검사 / 차단) 를 위한 가벼운 카운터 저장소.
///
/// 정확도 100% 를 목표로 하지 않고 사용자 체감용 — 네이티브에서 검사한
/// 안전 결과는 Flutter 측으로 push 되지 않으므로 일부 누락이 있을 수 있다.
class ScanStats {
  ScanStats._();
  static final ScanStats instance = ScanStats._();

  static const _kTodayDate = 'scan_today_date_v1';
  static const _kTodayScans = 'scan_today_count_v1';
  static const _kTodayBlocked = 'scan_today_blocked_v1';
  static const _kTotalScans = 'scan_total_count_v1';
  static const _kTotalBlocked = 'scan_total_blocked_v1';

  static String _todayKey() {
    final d = DateTime.now();
    return '${d.year.toString().padLeft(4, '0')}-'
        '${d.month.toString().padLeft(2, '0')}-'
        '${d.day.toString().padLeft(2, '0')}';
  }

  Future<void> _ensureToday(SharedPreferences prefs) async {
    final today = _todayKey();
    if (prefs.getString(_kTodayDate) != today) {
      await prefs.setString(_kTodayDate, today);
      await prefs.setInt(_kTodayScans, 0);
      await prefs.setInt(_kTodayBlocked, 0);
    }
  }

  Future<void> recordScan() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    await prefs.setInt(_kTodayScans, (prefs.getInt(_kTodayScans) ?? 0) + 1);
    await prefs.setInt(_kTotalScans, (prefs.getInt(_kTotalScans) ?? 0) + 1);
  }

  Future<void> recordBlocked() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    await prefs.setInt(_kTodayBlocked, (prefs.getInt(_kTodayBlocked) ?? 0) + 1);
    await prefs.setInt(_kTotalBlocked, (prefs.getInt(_kTotalBlocked) ?? 0) + 1);
  }

  Future<void> resetAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kTodayDate);
    await prefs.remove(_kTodayScans);
    await prefs.remove(_kTodayBlocked);
    await prefs.remove(_kTotalScans);
    await prefs.remove(_kTotalBlocked);
  }

  Future<ScanStatsSnapshot> read() async {
    final prefs = await SharedPreferences.getInstance();
    await _ensureToday(prefs);
    return ScanStatsSnapshot(
      todayScans: prefs.getInt(_kTodayScans) ?? 0,
      todayBlocked: prefs.getInt(_kTodayBlocked) ?? 0,
      totalScans: prefs.getInt(_kTotalScans) ?? 0,
      totalBlocked: prefs.getInt(_kTotalBlocked) ?? 0,
    );
  }
}

class ScanStatsSnapshot {
  const ScanStatsSnapshot({
    required this.todayScans,
    required this.todayBlocked,
    required this.totalScans,
    required this.totalBlocked,
  });

  final int todayScans;
  final int todayBlocked;
  final int totalScans;
  final int totalBlocked;
}
