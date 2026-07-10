import 'dart:async';

import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

import '../main.dart' show kBrandSeed;
import 'native_bridge.dart';
import '../widgets/accessibility_disclosure_dialog.dart';
import '../widgets/permission_ui.dart';
import 'permission_rationale.dart';

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

  /// 접근성 설정 — Play 정책용 앱 내 명시적 고지·동의 후 시스템 설정으로 이동
  Future<void> openAccessibilitySettings(BuildContext context) async {
    final ok = await AccessibilityDisclosure.ensureConsent(context);
    if (!ok || !context.mounted) return;
    await NativeBridge.instance.openAccessibilitySettings();
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
    Timer? autoPoll;
    bool pollStarted = false;

    final result = await showDialog<bool>(
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
                autoPoll?.cancel();
                Navigator.of(dialogCtx).pop(true);
              }
            }

            if (!pollStarted) {
              pollStarted = true;
              // 권한 설정 화면에서 돌아왔는지 사용자가 새로고침을 누르지 않아도
              // 1초마다 자동으로 확인해서 모두 완료되면 팝업을 닫는다.
              autoPoll = Timer.periodic(const Duration(seconds: 1), (_) {
                refreshFromNative();
              });
            }

            Widget row(
              PermissionRationaleEntry entry,
              Future<void> Function() openSettings,
            ) {
              final ok = rowOk(entry.key);
              final icon = ok ? Icons.check_circle : Icons.warning_amber_rounded;
              final color = ok ? kBrandSeed : Colors.orange.shade800;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(icon, color: color),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  title: Text(
                    entry.title,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(ok ? '완료됨' : '설정 필요'),
                  trailing: FilledButton(
                    onPressed: () async {
                      await openSettings();
                      await refreshFromNative();
                    },
                    child: const Text('설정 열기'),
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
                      Text(
                        '아래 권한·설정은 스미싱 링크 탐지와 경고에만 사용됩니다.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.4,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 12),
                      row(
                        PermissionRationales.sms,
                        () async {
                          await Permission.sms.request();
                          await NativeBridge.instance.requestRuntimePermissions();
                        },
                      ),
                      row(
                        PermissionRationales.postNotifications,
                        () async {
                          await Permission.notification.request();
                        },
                      ),
                      row(
                        PermissionRationales.overlay,
                        NativeBridge.instance.openOverlaySettings,
                      ),
                      row(
                        PermissionRationales.notificationListener,
                        NativeBridge.instance.openNotificationAccessSettings,
                      ),
                      row(
                        PermissionRationales.accessibility,
                        () => openAccessibilitySettings(dialogCtx),
                      ),
                      TextButton.icon(
                        onPressed: () => showPermissionGuideSheet(
                          dialogCtx,
                          entries: PermissionRationales.setupWizardOrder,
                          title: '권한 안내',
                        ),
                        icon: const Icon(Icons.help_outline),
                        label: const Text('권한이 왜 필요한지 보기'),
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
                  onPressed: () {
                    autoPoll?.cancel();
                    Navigator.pop(dialogCtx, false);
                  },
                  child: const Text('나중에'),
                ),
              ],
            );
          },
        );
      },
    );
    autoPoll?.cancel();
    return result;
  }

  Future<void> _showSetupDialog(BuildContext context) async {
    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('보호 기능 설정'),
        content: Text(
          '경남 안심링크가 링크를 검사하고 위험 시 알려 드리려면 '
          '몇 가지 권한·설정이 필요합니다.\n\n'
          '${PermissionRationales.setupWizardOrder.map((e) => '• ${e.title} — ${e.summary}').join('\n')}\n\n'
          '다음 화면에서 설정을 마친 뒤, 「권한이 왜 필요한지 보기」에서 자세한 설명을 확인할 수 있습니다.',
          style: const TextStyle(height: 1.45),
        ),
        actions: [
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('계속')),
        ],
      ),
    );
  }

}
