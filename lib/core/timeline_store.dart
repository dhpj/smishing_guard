import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'scan_result.dart';

/// 스미싱 주의(0001)만 로컬 보관 — 최대 1개월 · 최대 200건
class TimelineStore {
  TimelineStore._();
  static final TimelineStore instance = TimelineStore._();

  static const _prefKey = 'timeline_dangerous_v1';
  static const maxCount = 200;
  static const maxAge = Duration(days: 30);

  final List<ScanResult> entries = [];

  Future<void> load() async {
    entries.clear();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefKey);
    if (raw == null || raw.isEmpty) return;

    try {
      final list = jsonDecode(raw) as List<dynamic>;
      final now = DateTime.now();
      for (final item in list) {
        if (item is! Map) continue;
        final r = ScanResult.fromJson(Map<String, dynamic>.from(item));
        if (!r.isDangerous) continue;
        if (now.difference(r.checkedAt) > maxAge) continue;
        entries.add(r);
      }
      entries.sort((a, b) => b.checkedAt.compareTo(a.checkedAt));
      while (entries.length > maxCount) {
        entries.removeLast();
      }
    } catch (_) {
      entries.clear();
    }
  }

  Future<void> add(ScanResult result) async {
    if (!result.isDangerous) return;
    final entry = result.forTimeline();
    entries.removeWhere((e) => e.entryId == entry.entryId);
    entries.insert(0, entry);
    _pruneInMemory();
    await _persist();
  }

  /// 모든 위험 검사 이력을 즉시 비운다. 사용자가 설정·타임라인 화면에서
  /// 본인 이력을 직접 제거할 때 사용 — PIPA 의 '사용자 권리: 삭제 요청' 항목.
  Future<void> clear() async {
    entries.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefKey);
  }

  void _pruneInMemory() {
    final now = DateTime.now();
    entries.removeWhere((e) => now.difference(e.checkedAt) > maxAge);
    while (entries.length > maxCount) {
      entries.removeLast();
    }
  }

  Future<void> _persist() async {
    _pruneInMemory();
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(entries.map((e) => e.toJson()).toList());
    await prefs.setString(_prefKey, encoded);
  }
}
