import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/app_user_settings.dart';
import '../../core/scan_pipeline.dart';
import '../../core/scan_stats.dart';
import '../../utils/korean_date_format.dart';
import '../../main.dart';
import '../../services/native_bridge.dart';
import '../../services/permission_rationale.dart';
import '../../services/permission_service.dart';
import '../../widgets/ad_banner_carousel.dart';
import '../../widgets/permission_ui.dart';
import '../history/history_page.dart';
import '../legal/legal_notice_page.dart';
import '../settings/settings_page.dart';

class GuardStatusPage extends StatefulWidget {
  const GuardStatusPage({super.key});

  @override
  State<GuardStatusPage> createState() => _GuardStatusPageState();
}

class _GuardStatusPageState extends State<GuardStatusPage>
    with RouteAware, WidgetsBindingObserver {
  static const _protectionKey = 'protection_enabled';

  bool _protecting = false;
  String? _lastMessage;
  int _adReloadToken = 0;
  Map<String, bool> _permissionStatus = {};
  bool _protectionSnoozed = false;
  int _snoozeUntilMs = 0;
  ScanStatsSnapshot _stats = const ScanStatsSnapshot(
    todayScans: 0,
    todayBlocked: 0,
    totalScans: 0,
    totalBlocked: 0,
  );

  @override
  void initState() {
    super.initState();
    ScanPipeline.instance.addListener((r) {
      if (!mounted) return;
      setState(() {
        _lastMessage =
            '${r.source.displayName}: ${r.url} · ${r.resultLabel}';
      });
      _refreshStats();
    });
    NativeBridge.instance.startListening();
    WidgetsBinding.instance.addObserver(this);
    _restoreProtection();
    _refreshPermissionStatus();
    _refreshStats();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _openTimelineIfRequested();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionStatus();
      _refreshStats();
      _openTimelineIfRequested();
    }
  }

  Future<void> _refreshPermissionStatus() async {
    final status = await PermissionService.instance.getStatus();
    final snoozeUntil = await AppUserSettings.snoozeUntilMs();
    final now = DateTime.now().millisecondsSinceEpoch;
    if (mounted) {
      setState(() {
        _permissionStatus = status;
        _snoozeUntilMs = snoozeUntil;
        _protectionSnoozed = snoozeUntil > now;
      });
    }
  }

  Future<void> _refreshStats() async {
    final snap = await ScanStats.instance.read();
    if (mounted) setState(() => _stats = snap);
  }

  Future<void> _openTimelineIfRequested() async {
    if (!await NativeBridge.instance.consumeOpenTimelineRequest()) return;
    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
    _reloadAds();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    appRouteObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPush() => _reloadAds();

  @override
  void didPopNext() {
    _reloadAds();
    _refreshPermissionStatus();
    _refreshStats();
  }

  void _reloadAds() {
    if (!mounted) return;
    setState(() => _adReloadToken++);
  }

  Future<void> _restoreProtection() async {
    final prefs = await SharedPreferences.getInstance();
    final on = prefs.getBool(_protectionKey) ?? false;
    if (!on) return;
    await NativeBridge.instance.startProtection();
    if (mounted) setState(() => _protecting = true);
  }

  Future<void> _setProtection(bool on) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_protectionKey, on);
    setState(() => _protecting = on);
  }

  Future<void> _toggle() async {
    if (_protecting) {
      await _setProtection(false);
      await NativeBridge.instance.stopProtection();
      return;
    }
    await PermissionService.instance.runSetupWizard(context);
    if (!mounted) return;
    await _refreshPermissionStatus();
    final status = await PermissionService.instance.getStatus();
    if (!mounted || status['allReady'] != true) return;
    await _setProtection(true);
    await NativeBridge.instance.startProtection();
  }

  Future<void> _openHistory() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HistoryPage()),
    );
    _reloadAds();
    _refreshStats();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text('경남 안심링크'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: '타임라인',
            onPressed: _openHistory,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              _reloadAds();
              _refreshStats();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdBannerCarousel(reloadToken: _adReloadToken),
              const SizedBox(height: 14),
              _HeroStatusCard(protecting: _protecting),
              const SizedBox(height: 14),
              _ProtectionToggleCard(
                protecting: _protecting,
                onToggle: _toggle,
              ),
              if (_protectionSnoozed) ...[
                const SizedBox(height: 10),
                Material(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(14),
                  child: ListTile(
                    dense: true,
                    leading: Icon(Icons.snooze, color: Colors.amber.shade900),
                    title: const Text(
                      '보호 일시 중지 중',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                    subtitle: Text(
                      '${formatKoreanDateTime(DateTime.fromMillisecondsSinceEpoch(_snoozeUntilMs))} 까지\n'
                      '설정에서 해제할 수 있습니다.',
                      style: const TextStyle(fontSize: 12, height: 1.3),
                    ),
                    trailing: const Icon(Icons.chevron_right, size: 20),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SettingsPage()),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: _StatTile(
                      label: '오늘 검사',
                      value: _stats.todayScans,
                      unit: '건',
                      valueColor: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StatTile(
                      label: '차단',
                      value: _stats.todayBlocked,
                      unit: '건',
                      valueColor: const Color(0xFFDC2626),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              _PermissionsCard(
                status: _permissionStatus,
                onTap: (key) async {
                  switch (key) {
                    case 'notificationListener':
                      await NativeBridge.instance
                          .openNotificationAccessSettings();
                      break;
                    case 'accessibility':
                      await PermissionService.instance
                          .openAccessibilitySettings(context);
                      break;
                    case 'overlay':
                      await NativeBridge.instance.openOverlaySettings();
                      break;
                    case 'batteryOptimization':
                      await NativeBridge.instance.openBatterySettings();
                      break;
                  }
                  await _refreshPermissionStatus();
                },
              ),
              const SizedBox(height: 14),
              _OpenHistoryTile(onTap: _openHistory),
              if (_lastMessage != null) ...[
                const SizedBox(height: 14),
                _LastScanLine(message: _lastMessage!),
              ],
              const SizedBox(height: 18),
              Center(
                child: TextButton.icon(
                  icon: Icon(
                    Icons.gavel_outlined,
                    size: 14,
                    color: Colors.grey.shade600,
                  ),
                  label: Text(
                    '오탐·면책 안내 보기',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalNoticePage(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 4),
              Center(
                child: Text(
                  '경남 안심링크 · v0.4.23',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroStatusCard extends StatelessWidget {
  const _HeroStatusCard({required this.protecting});
  final bool protecting;

  @override
  Widget build(BuildContext context) {
    final activeGradient = const LinearGradient(
      colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
    final idleGradient = LinearGradient(
      colors: [Colors.grey.shade500, Colors.grey.shade700],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: protecting ? activeGradient : idleGradient,
        boxShadow: [
          BoxShadow(
            color: (protecting
                    ? const Color(0xFF1D4ED8)
                    : Colors.grey.shade400)
                .withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/icon/guard_shield.png',
            width: 88,
            height: 88,
            filterQuality: FilterQuality.high,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '현재 상태',
                  style: TextStyle(
                    fontSize: 13,
                    color: Color(0xFFDBEAFE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  protecting ? '보호 활성화됨' : '보호 꺼짐',
                  style: const TextStyle(
                    fontSize: 24,
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'SMS · 카카오톡 · 텔레그램 · 브라우저',
                  style: TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFFBFDBFE),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: protecting
                        ? const Color(0xFF22C55E)
                        : Colors.white24,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    protecting ? '실시간 감지중' : '대기 중',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProtectionToggleCard extends StatelessWidget {
  const _ProtectionToggleCard({
    required this.protecting,
    required this.onToggle,
  });

  final bool protecting;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '실시간 보호',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  protecting
                      ? '메시지를 받는 즉시 자동으로 검사합니다'
                      : '보호를 시작하면 권한 안내가 표시됩니다',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF64748B),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: protecting,
            onChanged: (_) => onToggle(),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.valueColor,
  });

  final String label;
  final int value;
  final String unit;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: valueColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PermissionsCard extends StatelessWidget {
  const _PermissionsCard({required this.status, required this.onTap});
  final Map<String, bool> status;
  final Future<void> Function(String key) onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            child: Text(
              '권한 상태',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
          const SizedBox(height: 2),
          for (final entry in PermissionRationales.mainScreenOrder)
            PermissionCompactRow(
              entry: entry,
              granted: status[entry.key] ?? false,
              required: entry.requiredForProtection,
              onTap: () => onTap(entry.key),
            ),
          PermissionGuideLink(entries: PermissionRationales.mainScreenOrder),
        ],
      ),
    );
  }
}

class _OpenHistoryTile extends StatelessWidget {
  const _OpenHistoryTile({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: scheme.primary.withOpacity(0.06),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: scheme.primary.withOpacity(0.16),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '검사 이력 보기',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '최근 검사 결과와 차단된 링크를 확인할 수 있어요',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF475569),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 22,
              color: scheme.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _LastScanLine extends StatelessWidget {
  const _LastScanLine({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          const Icon(Icons.history, size: 16, color: Color(0xFF64748B)),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 11.5,
                color: Color(0xFF475569),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
