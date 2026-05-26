import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart' show kBrandSeed;
import 'native_bridge.dart';

class PermissionService {
  PermissionService._();
  static final PermissionService instance = PermissionService._();

  Future<Map<String, bool>> getStatus() async {
    final raw = await NativeBridge.instance.getPermissionStatus();
    return raw.map((k, v) => MapEntry(k, v == true));
  }

  /// 메인 화면 · 문자 권한 행
  Future<void> requestSmsFromSettings(BuildContext context) async {
    await NativeBridge.instance.requestRuntimePermissions();
    await Permission.sms.request();
    if (context.mounted) {
      await getStatus();
    }
  }

  /// 보호 시작 전: 미설정 항목이 있을 때만 안내·설정 패널 표시
  Future<void> runSetupWizard(BuildContext context) async {
    final initial = await getStatus();
    if (initial['allReady'] == true) return;

    await NativeBridge.instance.requestRuntimePermissions();
    await Permission.sms.request();
    if (await Permission.notification.isDenied) {
      await Permission.notification.request();
    }

    if (!context.mounted) return;
    await _showSetupDialog(context);

    while (context.mounted) {
      final status = await getStatus();
      if (!context.mounted) return;
      if (status['allReady'] == true) return;
      final acknowledged = await _showUnifiedSetupPanel(context, status);
      if (!context.mounted || acknowledged != true) return;
      await Future.delayed(const Duration(milliseconds: 250));
    }
  }

  /// 한 화면에서 미설정 항목을 나열하고, 각각 바로 설정 화면으로 연결 가능
  Future<bool?> _showUnifiedSetupPanel(
    BuildContext parentContext,
    Map<String, bool> snapshot,
  ) async {
    return showDialog<bool>(
      context: parentContext,
      barrierDismissible: false,
      builder: (dialogCtx) {
        var status = {...snapshot};
        bool rowOk(String key) => status[key] ?? false;

        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            Future<void> refreshFromNative() async {
              final fresh = await getStatus();
              if (!ctx.mounted) return;
              setDialogState(() {
                status = {...fresh};
              });
              if (fresh['allReady'] == true && dialogCtx.mounted) {
                Navigator.of(dialogCtx).pop(true);
              }
            }

            Widget row(String title, String key, Future<void> Function() openSettings) {
              final ok = rowOk(key);
              final icon = ok ? Icons.check_circle : Icons.warning_amber_rounded;
              final color = ok ? kBrandSeed : Colors.orange.shade800;
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: Icon(icon, color: color),
                  title: Text(title),
                  subtitle: Text(ok ? '완료됨' : '설정이 필요합니다'),
                  trailing: ok
                      ? null
                      : FilledButton(
                          onPressed: () async {
                            await openSettings();
                            await refreshFromNative();
                          },
                          child: const Text('열기'),
                        ),
                ),
              );
            }

            return AlertDialog(
              title: const Text('필요한 설정을 한 번에 확인하세요'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      row(
                        'SMS 수신·읽기',
                        'sms',
                        () async {
                          await Permission.sms.request();
                          await NativeBridge.instance.requestRuntimePermissions();
                        },
                      ),
                      row(
                        '앱 알림 (Android 13+)',
                        'postNotifications',
                        () async {
                          await Permission.notification.request();
                        },
                      ),
                      row(
                        '다른 앱 위에 표시',
                        'overlay',
                        NativeBridge.instance.openOverlaySettings,
                      ),
                      row(
                        '알림 접근 (카카오톡·텔레그램·LINE 등)',
                        'notificationListener',
                        NativeBridge.instance.openNotificationAccessSettings,
                      ),
                      row(
                        '접근성 (Whale·Chrome 등 주소 표시 줄)',
                        'accessibility',
                        NativeBridge.instance.openAccessibilitySettings,
                      ),
                      TextButton.icon(
                        onPressed: refreshFromNative,
                        icon: const Icon(Icons.refresh),
                        label: const Text('설정을 마쳤어요 · 다시 확인'),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx, false),
                  child: const Text('나중에'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _showSetupDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('보호 기능 설정'),
        content: const Text(
          '다음 권한이 필요합니다.\n\n'
          '1. SMS — 문자 URL 검사\n'
          '2. 알림 — 카카오톡 등 메시지 검사\n'
          '3. 다른 앱 위 표시 — 위험 URL 경고\n'
          '4. 접근성 — Whale·Chrome·Firefox 등 브라우저 주소창\n\n'
          '※ 브라우저 검사는 Android 접근성으로만 가능합니다.\n※ 알림을 통한 카카오톡 알림 등은 패키지·템플릿에 따라 URL이 알림 본문에 없을 수 있습니다.',
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('계속')),
        ],
      ),
    );
  }

}
