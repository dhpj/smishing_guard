import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/scan_pipeline.dart';
import '../../main.dart';
import '../../services/native_bridge.dart';
import '../../services/permission_service.dart';
import '../../widgets/ad_banner_carousel.dart';
import '../history/history_page.dart';
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
  bool _setupPrompted = false;
  String? _lastMessage;
  int _adReloadToken = 0;
  Map<String, bool> _permissionStatus = {};

  @override
  void initState() {
    super.initState();
    ScanPipeline.instance.addListener((r) {
      if (!mounted) return;
      setState(() {
        _lastMessage =
            '${r.source.displayName}: ${r.url} · ${r.resultLabel}';
      });
    });
    NativeBridge.instance.startListening();
    WidgetsBinding.instance.addObserver(this);
    _restoreProtection();
    _refreshPermissionStatus();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _promptSetupOnce();
      _openTimelineIfRequested();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissionStatus();
      _openTimelineIfRequested();
    }
  }

  Future<void> _refreshPermissionStatus() async {
    final status = await PermissionService.instance.getStatus();
    if (mounted) setState(() => _permissionStatus = status);
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

  Future<void> _promptSetupOnce() async {
    if (_setupPrompted || !mounted) return;
    _setupPrompted = true;
    final status = await PermissionService.instance.getStatus();
    if (!mounted || status['allReady'] == true) return;
    await PermissionService.instance.runSetupWizard(context);
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
    await _setProtection(true);
    await NativeBridge.instance.startProtection();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smishing Guard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.timeline),
            tooltip: '타임라인',
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryPage()),
              );
              _reloadAds();
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
              _reloadAds();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AdBannerCarousel(reloadToken: _adReloadToken),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        _protecting ? Icons.shield : Icons.shield_outlined,
                        size: 64,
                        color: _protecting ? Colors.green : Colors.grey,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _protecting ? '보호 중' : '보호 꺼짐',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '보호 시작 시 권한을 요청합니다.\n'
                        '스미싱 판정 시 상단 경고 알림이 뜨며, 알림을 직접 닫기 전까지 유지 됩니다.',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: _toggle,
                icon: Icon(_protecting ? Icons.stop : Icons.play_arrow),
                label: Text(_protecting ? '보호 중지' : '보호 시작'),
              ),
              const SizedBox(height: 24),
              Text('권한 설정', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 4),
              Text(
                '문자·알림 접근·접근성·다른 앱 위에 표시가 모두 켜져야 보호가 동작합니다.\n'
                '배터리 최적화는 권장 사항이며, 미설정이어도 사용할 수 있습니다.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade700,
                    ),
              ),
              const SizedBox(height: 8),
              _permissionLinkTile(
                label: '문자 (SMS 수신·읽기)',
                statusKey: 'sms',
                required: true,
                onOpenSettings: () async {
                  await PermissionService.instance
                      .requestSmsFromSettings(context);
                  await _refreshPermissionStatus();
                },
              ),
              _permissionLinkTile(
                label: '알림 접근 (카카오톡·텔레그램·LINE 등)',
                statusKey: 'notificationListener',
                required: true,
                onOpenSettings: () async {
                  await NativeBridge.instance
                      .openNotificationAccessSettings();
                  await _refreshPermissionStatus();
                },
              ),
              _permissionLinkTile(
                label: '접근성 (브라우저 주소창)',
                statusKey: 'accessibility',
                required: true,
                onOpenSettings: () async {
                  await NativeBridge.instance.openAccessibilitySettings();
                  await _refreshPermissionStatus();
                },
              ),
              _permissionLinkTile(
                label: '다른 앱 위에 표시',
                statusKey: 'overlay',
                required: true,
                onOpenSettings: () async {
                  await NativeBridge.instance.openOverlaySettings();
                  await _refreshPermissionStatus();
                },
              ),
              _permissionLinkTile(
                label: '배터리 최적화 제외 (권장)',
                statusKey: 'batteryOptimization',
                required: false,
                onOpenSettings: () async {
                  await NativeBridge.instance.openBatterySettings();
                  await _refreshPermissionStatus();
                },
              ),
              if (_lastMessage != null) ...[
                const SizedBox(height: 16),
                Text('최근 검사', style: Theme.of(context).textTheme.titleSmall),
                Text(_lastMessage!, style: const TextStyle(fontSize: 12)),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _permissionLinkTile({
    required String label,
    required String statusKey,
    required bool required,
    required Future<void> Function() onOpenSettings,
  }) {
    final granted = _permissionStatus[statusKey] ?? false;
    final IconData statusIcon;
    final Color statusColor;
    if (granted) {
      statusIcon = Icons.check_circle;
      statusColor = const Color(0xFF2E7D32);
    } else if (required) {
      statusIcon = Icons.block;
      statusColor = const Color(0xFFC62828);
    } else {
      statusIcon = Icons.info_outline;
      statusColor = Colors.orange.shade800;
    }

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, color: statusColor, size: 22),
          const SizedBox(width: 10),
          Icon(
            Icons.open_in_new,
            size: 18,
            color: Colors.grey.shade600,
          ),
        ],
      ),
      onTap: onOpenSettings,
    );
  }
}
