import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'trusted_domain_matcher.dart';

/// 사용자 설정 키·기본값. 네이티브는 `flutter.<key>` 로 동일하게 읽는다.
abstract final class AppUserSettings {
  static const vibrateOnDetectKey = 'vibrate_on_detect';
  static const soundOnDetectKey = 'sound_on_detect';
  static const compactOverlayKey = 'overlay_compact_mode';
  static const alertModeKey = 'alert_mode';
  static const quietHoursEnabledKey = 'quiet_hours_enabled';
  static const quietHoursStartKey = 'quiet_hours_start_min';
  static const quietHoursEndKey = 'quiet_hours_end_min';
  static const trustedDomainsKey = 'trusted_domains_json';
  static const snoozeUntilKey = 'protection_snooze_until_ms';
  static const privacyPolicyUrlKey = 'privacy_policy_url';

  static const alertModeOverlay = 'overlay';
  static const alertModeNotification = 'notification';

  static const defaultPrivacyPolicyUrl = '';

  static Future<bool> vibrateOnDetect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(vibrateOnDetectKey) ?? true;
  }

  static Future<void> setVibrateOnDetect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(vibrateOnDetectKey, value);
  }

  static Future<bool> soundOnDetect() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(soundOnDetectKey) ?? false;
  }

  static Future<void> setSoundOnDetect(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(soundOnDetectKey, value);
  }

  static Future<bool> compactOverlayMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(compactOverlayKey) ?? false;
  }

  static Future<void> setCompactOverlayMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(compactOverlayKey, value);
  }

  static Future<String> alertMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(alertModeKey) ?? alertModeOverlay;
  }

  static Future<void> setAlertMode(String mode) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(alertModeKey, mode);
  }

  static Future<bool> quietHoursEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(quietHoursEnabledKey) ?? false;
  }

  static Future<void> setQuietHoursEnabled(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(quietHoursEnabledKey, value);
  }

  /// 자정 기준 분 (0~1439). 기본 23:00~07:00
  static Future<int> quietHoursStartMin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(quietHoursStartKey) ?? 23 * 60;
  }

  static Future<int> quietHoursEndMin() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(quietHoursEndKey) ?? 7 * 60;
  }

  static Future<void> setQuietHoursRange(int startMin, int endMin) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(quietHoursStartKey, startMin);
    await prefs.setInt(quietHoursEndKey, endMin);
  }

  static Future<List<String>> trustedDomains() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(trustedDomainsKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return TrustedDomainMatcher.normalizeForStorage(
          decoded.map((e) => e.toString()),
        );
      }
    } catch (_) {}
    return [];
  }

  static Future<void> setTrustedDomains(List<String> domains) async {
    final cleaned = TrustedDomainMatcher.normalizeForStorage(domains);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(trustedDomainsKey, jsonEncode(cleaned));
  }

  /// UI 표시·매칭용 정규화 (저장과 동일 규칙).
  static List<String> normalizeTrustedDomainEntries(Iterable<String> raw) =>
      TrustedDomainMatcher.normalizeForStorage(raw);

  static Future<int> snoozeUntilMs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(snoozeUntilKey);
    if (raw == null || raw.isEmpty) return 0;
    return int.tryParse(raw) ?? 0;
  }

  static Future<void> setSnoozeUntil(int epochMs) async {
    final prefs = await SharedPreferences.getInstance();
    if (epochMs <= 0) {
      await prefs.remove(snoozeUntilKey);
    } else {
      await prefs.setString(snoozeUntilKey, epochMs.toString());
    }
  }

  static Future<bool> isSnoozed() async {
    final until = await snoozeUntilMs();
    return until > DateTime.now().millisecondsSinceEpoch;
  }

  static Future<String?> privacyPolicyUrl() async {
    final prefs = await SharedPreferences.getInstance();
    final url = prefs.getString(privacyPolicyUrlKey)?.trim();
    if (url == null || url.isEmpty) return null;
    return url;
  }

  static Future<void> setPrivacyPolicyUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      await prefs.remove(privacyPolicyUrlKey);
    } else {
      await prefs.setString(privacyPolicyUrlKey, trimmed);
    }
  }

  /// 방해 금지 시간 여부 (로컬 시각).
  static bool isQuietHoursNow({
    required bool enabled,
    required int startMin,
    required int endMin,
    DateTime? now,
  }) {
    if (!enabled) return false;
    final t = now ?? DateTime.now();
    final cur = t.hour * 60 + t.minute;
    if (startMin == endMin) return false;
    if (startMin < endMin) return cur >= startMin && cur < endMin;
    return cur >= startMin || cur < endMin;
  }

  /// 신뢰 도메인 — `example.com`, `https://a.com/path?q=1` 등 (쿼리 무시).
  static bool isTrustedUrl(String url, List<String> patterns) =>
      TrustedDomainMatcher.isTrusted(url, patterns);

  static String formatMinutes(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}';
  }
}
