import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/app_user_settings.dart';
import '../../core/scan_stats.dart';
import '../../core/timeline_store.dart';
import '../../main.dart' show kBrandSeed;
import '../../services/native_bridge.dart';
import '../../services/permission_rationale.dart';
import '../../services/permission_service.dart';
import '../../utils/korean_date_format.dart';
import '../legal/legal_notice_page.dart';
import '../legal/terms_of_service_page.dart';
import '../../widgets/branded_time_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _trustedDomainsController = TextEditingController();

  bool _vibrateOnDetect = true;
  bool _soundOnDetect = false;
  bool _compactOverlay = false;
  bool _quietHoursEnabled = false;
  int _quietStartMin = 23 * 60;
  int _quietEndMin = 7 * 60;
  int _snoozeUntilMs = 0;
  String _appVersion = '';
  Map<String, bool> _permissionStatus = {};

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final domains = await AppUserSettings.trustedDomains();
    final info = await PackageInfo.fromPlatform();

    setState(() {
      _vibrateOnDetect = prefs.getBool(AppUserSettings.vibrateOnDetectKey) ?? true;
      _soundOnDetect = prefs.getBool(AppUserSettings.soundOnDetectKey) ?? false;
      _compactOverlay = prefs.getBool(AppUserSettings.compactOverlayKey) ?? false;
      _quietHoursEnabled =
          prefs.getBool(AppUserSettings.quietHoursEnabledKey) ?? false;
      _quietStartMin = prefs.getInt(AppUserSettings.quietHoursStartKey) ?? 23 * 60;
      _quietEndMin = prefs.getInt(AppUserSettings.quietHoursEndKey) ?? 7 * 60;
      _snoozeUntilMs = 0;
      _trustedDomainsController.text = domains.join('\n');
      _appVersion = '${info.version}+${info.buildNumber}';
    });

    final snooze = await AppUserSettings.snoozeUntilMs();
    final status = await PermissionService.instance.getStatus();
    if (mounted) {
      setState(() {
        _snoozeUntilMs = snooze;
        _permissionStatus = status;
      });
    }
  }

  bool get _isSnoozed =>
      _snoozeUntilMs > DateTime.now().millisecondsSinceEpoch;

  Future<void> _persistUserPrefs({bool invalidateNative = true}) async {
    await AppUserSettings.setVibrateOnDetect(_vibrateOnDetect);
    await AppUserSettings.setSoundOnDetect(_soundOnDetect);
    await AppUserSettings.setCompactOverlayMode(_compactOverlay);
    // 수익화 방향(오버레이 광고) 기준: 알림 전용 모드는 잠시 비활성화.
    await AppUserSettings.setAlertMode(AppUserSettings.alertModeOverlay);
    await AppUserSettings.setQuietHoursEnabled(_quietHoursEnabled);
    await AppUserSettings.setQuietHoursRange(_quietStartMin, _quietEndMin);
    await _saveTrustedDomains(showSnackBar: false);
    if (invalidateNative) {
      await NativeBridge.instance.invalidateProtectionCache();
    }
  }

  Future<void> _saveTrustedDomains({bool showSnackBar = true}) async {
    final raw = _trustedDomainsController.text
        .split(RegExp(r'[\n,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty);
    final normalized = AppUserSettings.normalizeTrustedDomainEntries(raw);
    await AppUserSettings.setTrustedDomains(normalized);
    if (mounted) {
      setState(() {
        _trustedDomainsController.text = normalized.join('\n');
      });
    }
    if (showSnackBar && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            normalized.isEmpty
                ? '신뢰 도메인을 모두 삭제했습니다'
                : '신뢰 도메인 ${normalized.length}건을 저장했습니다',
          ),
        ),
      );
    }
  }

  Future<void> _pickQuietTime({required bool start}) async {
    final initial = TimeOfDay(
      hour: (start ? _quietStartMin : _quietEndMin) ~/ 60,
      minute: (start ? _quietStartMin : _quietEndMin) % 60,
    );
    final picked = await showBrandedTimePicker(
      context: context,
      initialTime: initial,
      title: start ? '방해 금지 시작' : '방해 금지 종료',
      subtitle: '이 시간대에는 진동·소리·경고 창·탐지 알림을 띄우지 않습니다.',
    );
    if (picked == null || !mounted) return;
    setState(() {
      final min = picked.hour * 60 + picked.minute;
      if (start) {
        _quietStartMin = min;
      } else {
        _quietEndMin = min;
      }
    });
    await AppUserSettings.setQuietHoursRange(_quietStartMin, _quietEndMin);
    await AppUserSettings.setQuietHoursEnabled(_quietHoursEnabled);
  }

  Future<void> _setSnooze(Duration duration) async {
    final until = DateTime.now().add(duration).millisecondsSinceEpoch;
    await AppUserSettings.setSnoozeUntil(until);
    await NativeBridge.instance.invalidateProtectionCache();
    setState(() => _snoozeUntilMs = until);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '보호 일시 중지 — ${formatKoreanDateTime(DateTime.fromMillisecondsSinceEpoch(until))} 까지',
          ),
        ),
      );
    }
  }

  Future<void> _setSnoozeUntilEndOfDay() async {
    final now = DateTime.now();
    final end = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final target = end.isAfter(now) ? end : end.add(const Duration(days: 1));
    await AppUserSettings.setSnoozeUntil(target.millisecondsSinceEpoch);
    await NativeBridge.instance.invalidateProtectionCache();
    setState(() => _snoozeUntilMs = target.millisecondsSinceEpoch);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('오늘 자정까지 보호를 일시 중지합니다')),
      );
    }
  }

  Future<void> _clearSnooze() async {
    await AppUserSettings.setSnoozeUntil(0);
    await NativeBridge.instance.invalidateProtectionCache();
    setState(() => _snoozeUntilMs = 0);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('보호 일시 중지를 해제했습니다')),
      );
    }
  }

  Future<void> _openPermission(String key) async {
    switch (key) {
      case 'postNotifications':
        await Permission.notification.request();
        break;
      case 'notificationListener':
        await NativeBridge.instance.openNotificationAccessSettings();
        break;
      case 'accessibility':
        await PermissionService.instance.openAccessibilitySettings(context);
        break;
      case 'overlay':
        await NativeBridge.instance.openOverlaySettings();
        break;
      case 'batteryOptimization':
        await NativeBridge.instance.openBatterySettings();
        break;
    }
    final status = await PermissionService.instance.getStatus();
    if (mounted) setState(() => _permissionStatus = status);
  }

  Future<void> _confirmClearTimeline() async {
    await TimelineStore.instance.load();
    final count = TimelineStore.instance.entries.length;
    if (!mounted) return;
    if (count == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('비울 타임라인 이력이 없습니다')),
      );
      return;
    }
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('타임라인 비우기'),
        content: Text('위험 탐지 기록 $count건을 모두 삭제할까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('비우기')),
        ],
      ),
    );
    if (ok != true) return;
    await TimelineStore.instance.clear();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('타임라인을 비웠습니다')),
      );
    }
  }

  Future<void> _confirmResetStats() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('통계 초기화'),
        content: const Text('오늘 검사·차단 및 누적 통계를 0으로 되돌릴까요?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('취소')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('초기화')),
        ],
      ),
    );
    if (ok != true) return;
    await ScanStats.instance.resetAll();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('통계를 초기화했습니다')),
      );
    }
  }

  Future<void> _clearCheckCache() async {
    await NativeBridge.instance.clearUriCheckCache();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL 검사 캐시를 비웠습니다')),
      );
    }
  }

  Future<void> _openUrl(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('열 수 없습니다: $url')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (_isSnoozed)
            Card(
              color: Colors.amber.shade50,
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: Icon(Icons.snooze, color: Colors.amber.shade900),
                title: const Text('보호 일시 중지 중'),
                subtitle: Text(
                  '${formatKoreanDateTime(DateTime.fromMillisecondsSinceEpoch(_snoozeUntilMs))} 까지\n'
                  '검사·경고가 동작하지 않습니다.',
                ),
                trailing: TextButton(onPressed: _clearSnooze, child: const Text('해제')),
              ),
            ),

          _SectionHeader(title: '탐지 알림', icon: Icons.notifications_active_outlined),
          SwitchListTile(
            title: const Text('스미싱 탐지 시 진동'),
            subtitle: const Text('경고 표시 시 짧게 한 번 진동합니다.'),
            value: _vibrateOnDetect,
            onChanged: (v) async {
              setState(() => _vibrateOnDetect = v);
              await AppUserSettings.setVibrateOnDetect(v);
            },
          ),
          SwitchListTile(
            title: const Text('스미싱 탐지 시 소리'),
            subtitle: const Text('짧은 알림음을 재생합니다 (무음 모드는 기기 설정을 따릅니다).'),
            value: _soundOnDetect,
            onChanged: (v) async {
              setState(() => _soundOnDetect = v);
              await AppUserSettings.setSoundOnDetect(v);
            },
          ),
          SwitchListTile(
            title: const Text('오버레이 간단 모드'),
            subtitle: const Text(
              '메시지 미리보기/한 줄 진단을 숨기고 URL 중심으로 높이를 줄여 표시합니다.',
            ),
            value: _compactOverlay,
            onChanged: (v) async {
              setState(() => _compactOverlay = v);
              await AppUserSettings.setCompactOverlayMode(v);
              await NativeBridge.instance.invalidateProtectionCache();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(v ? '오버레이 간단 모드를 켰습니다' : '오버레이 간단 모드를 껐습니다'),
                ),
              );
            },
          ),
          // [임시 비활성화] 오버레이/알림 선택 UI
          // 오버레이 광고 노출을 위해 현재는 오버레이 모드 고정.
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.only(left: 4, right: 4),
            child: Text(
              '탐지 알림은 현재 오버레이 우선으로 고정되어 있습니다. '
              '오버레이 권한이 없으면 시스템 알림으로 자동 대체됩니다.',
              style: TextStyle(fontSize: 12, color: Color(0xFF64748B), height: 1.35),
            ),
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: '방해 금지 시간', icon: Icons.bedtime_outlined),
          SwitchListTile(
            title: const Text('야간·무음 모드 사용'),
            subtitle: Text(
              _quietHoursEnabled
                  ? '${AppUserSettings.formatMinutes(_quietStartMin)} ~ '
                      '${AppUserSettings.formatMinutes(_quietEndMin)} — '
                      '검사는 계속하되 진동·소리·오버레이·탐지 알림은 띄우지 않습니다.'
                  : '지정한 시간대에는 사용자 알림만 끕니다.',
            ),
            value: _quietHoursEnabled,
            onChanged: (v) async {
              setState(() => _quietHoursEnabled = v);
              await AppUserSettings.setQuietHoursEnabled(v);
            },
          ),
          if (_quietHoursEnabled) ...[
            const SizedBox(height: 8),
            QuietHoursTimeTile(
              label: '시작',
              timeLabel: AppUserSettings.formatMinutes(_quietStartMin),
              onTap: () => _pickQuietTime(start: true),
            ),
            QuietHoursTimeTile(
              label: '종료',
              timeLabel: AppUserSettings.formatMinutes(_quietEndMin),
              onTap: () => _pickQuietTime(start: false),
            ),
          ],

          const SizedBox(height: 16),
          _SectionHeader(title: '보호 일시 중지', icon: Icons.snooze),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '보호 스위치는 켜 둔 채로, 잠시 검사·경고만 멈춥니다. 회의·테스트 시 유용합니다.',
              style: TextStyle(fontSize: 12.5, height: 1.35, color: Color(0xFF64748B)),
            ),
          ),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton(onPressed: () => _setSnooze(const Duration(hours: 1)), child: const Text('1시간')),
              OutlinedButton(onPressed: _setSnoozeUntilEndOfDay, child: const Text('오늘 하루')),
              if (_isSnoozed)
                FilledButton.tonal(onPressed: _clearSnooze, child: const Text('중지 해제')),
            ],
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: '신뢰 도메인', icon: Icons.verified_user_outlined),
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
            child: Text(
              '등록한 주소는 위험으로 판정되어도 경고·타임라인에 남기지 않습니다. '
              '도메인·URL·쿼리 포함 주소 모두 가능하며, 저장 시 쿼리는 제거된 형태로 맞춥니다. '
              '예: `example.com`, `https://bank.com/login?id=1`',
              style: TextStyle(fontSize: 12.5, height: 1.35, color: Color(0xFF64748B)),
            ),
          ),
          TextField(
            controller: _trustedDomainsController,
            maxLines: 4,
            decoration: const InputDecoration(
              hintText: 'example.com\n*.mycompany.co.kr',
              border: OutlineInputBorder(),
            ),
            onSubmitted: (_) => _saveTrustedDomains(),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.tonal(
              onPressed: _saveTrustedDomains,
              child: const Text('신뢰 도메인 저장'),
            ),
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: '권한·시스템 설정', icon: Icons.security_outlined),
          for (final entry in PermissionRationales.mainScreenOrder)
            _PermissionShortcutTile(
              title: entry.title,
              granted: _permissionStatus[entry.key] ?? false,
              requiredForProtection: entry.requiredForProtection,
              onOpen: () => _openPermission(entry.key),
            ),

          const SizedBox(height: 16),
          _SectionHeader(title: '데이터 관리', icon: Icons.storage_outlined),
          ListTile(
            leading: const Icon(Icons.delete_sweep_outlined),
            title: const Text('타임라인 비우기'),
            subtitle: const Text('위험 탐지 기록만 삭제합니다'),
            onTap: _confirmClearTimeline,
          ),
          ListTile(
            leading: const Icon(Icons.bar_chart_outlined),
            title: const Text('통계 초기화'),
            subtitle: const Text('오늘 검사·차단 및 누적 카운트'),
            onTap: _confirmResetStats,
          ),
          ListTile(
            leading: const Icon(Icons.cached_outlined),
            title: const Text('URL 검사 캐시 비우기'),
            subtitle: const Text('같은 URL을 다시 서버에 물어봅니다'),
            onTap: _clearCheckCache,
          ),

          const SizedBox(height: 16),
          _SectionHeader(title: '정보·지원', icon: Icons.info_outline),
          ListTile(
            leading: const Icon(Icons.description_outlined),
            title: const Text('이용약관'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TermsOfServicePage()),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined),
            title: const Text('개인정보처리방침'),
            subtitle: Text(
              AppUserSettings.defaultPrivacyPolicyUrl,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            onTap: () => _openUrl(AppUserSettings.defaultPrivacyPolicyUrl),
          ),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('오탐·면책 안내'),
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LegalNoticePage()),
            ),
          ),
          if (_appVersion.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.smartphone_outlined),
              title: const Text('앱 버전'),
              subtitle: Text(_appVersion),
            ),

        ],
      ),
    );
  }

  @override
  void dispose() {
    _trustedDomainsController.dispose();
    super.dispose();
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, required this.icon});
  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Row(
        children: [
          Icon(icon, size: 20, color: kBrandSeed),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionShortcutTile extends StatelessWidget {
  const _PermissionShortcutTile({
    required this.title,
    required this.granted,
    required this.requiredForProtection,
    required this.onOpen,
  });

  final String title;
  final bool granted;
  final bool requiredForProtection;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final Color statusColor;
    final String statusText;
    if (granted) {
      statusColor = const Color(0xFF15803D);
      statusText = '허용됨';
    } else if (requiredForProtection) {
      statusColor = const Color(0xFFB91C1C);
      statusText = '필요';
    } else {
      statusColor = const Color(0xFFB45309);
      statusText = '권장';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          granted ? Icons.check_circle : Icons.settings_outlined,
          color: granted ? kBrandSeed : Colors.grey.shade600,
        ),
        title: Text(title),
        subtitle: Text(
          statusText,
          style: TextStyle(
            color: statusColor,
            fontWeight: FontWeight.w700,
            fontSize: 12.5,
          ),
        ),
        trailing: granted
            ? const Icon(Icons.chevron_right, size: 18)
            : FilledButton(
                onPressed: onOpen,
                child: const Text('열기'),
              ),
        onTap: onOpen,
      ),
    );
  }
}

