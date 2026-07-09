import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smishing_guard/core/scan_result.dart';
import 'package:smishing_guard/core/timeline_store.dart';
import 'package:smishing_guard/features/history/history_page.dart';
import 'package:smishing_guard/features/settings/settings_page.dart';
import 'package:smishing_guard/main.dart';

const _outDir = 'docs/play-store-checklist/deliverables';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    _installMocks();
    SharedPreferences.setMockInitialValues({
      'vibrate_on_detect': true,
      'sound_on_detect': false,
      'overlay_compact_mode': false,
      'quiet_hours_enabled': false,
      'alert_mode': 'overlay',
    });
  });

  testWidgets('capture timeline screenshot', (tester) async {
    TimelineStore.instance.entries
      ..clear()
      ..addAll(_sampleTimeline());
    await _capturePage(tester, const HistoryPage(), '5.screenshot_02_timeline_1080x1920.png');
  });

  testWidgets('capture settings screenshot', (tester) async {
    await _capturePage(tester, const SettingsPage(), '6.screenshot_03_settings_1080x1920.png');
  });
}

List<ScanResult> _sampleTimeline() => [
      ScanResult(
        url: 'https://bit.ly/suspicious-link',
        source: UrlSource.kakao,
        code: '0001',
        message: '스미싱 주의',
        checkedAt: DateTime(2026, 7, 8, 17, 21),
        bodyText: '택배 배송 안내입니다. 아래 링크에서 수령 정보를 확인해 주세요.',
        senderTitle: '냠냠냠',
      ),
      ScanResult(
        url: 'https://m.example-phish.site/login',
        source: UrlSource.smsNotif,
        code: '0001',
        message: '스미싱 주의',
        checkedAt: DateTime(2026, 7, 7, 11, 5),
        bodyText: '[Web발신] 금융기관 보안 강화를 위해 즉시 본인 인증을 진행해 주세요.',
        senderTitle: '1588-0000',
      ),
    ];

void _installMocks() {
  const native = MethodChannel('smishing_guard/native');
  const packageInfo = MethodChannel('dev.fluttercommunity.plus/package_info');
  const secureStorage = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(native, (call) async {
    switch (call.method) {
      case 'getPermissionStatus':
        return {
          'sms': true,
          'postNotifications': true,
          'overlay': true,
          'notificationListener': true,
          'accessibility': true,
          'batteryOptimization': false,
          'allReady': true,
        };
      default:
        return null;
    }
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(packageInfo, (call) async {
    if (call.method == 'getAll') {
      return {
        'appName': '경남 안심링크',
        'packageName': 'com.dhn.smishing',
        'version': '0.4.18',
        'buildNumber': '36',
        'buildSignature': '',
        'installerStore': '',
      };
    }
    return null;
  });

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(secureStorage, (call) async {
    switch (call.method) {
      case 'read':
      case 'write':
      case 'delete':
      case 'deleteAll':
        return null;
      default:
        return null;
    }
  });
}

Future<void> _capturePage(
  WidgetTester tester,
  Widget page,
  String fileName,
) async {
  tester.view.physicalSize = const Size(360, 780);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    RepaintBoundary(
      key: const Key('screenshot_root'),
      child: MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: kBrandSeed),
          useMaterial3: true,
        ),
        home: page,
      ),
    ),
  );

  await tester.pump();
  await tester.pump(const Duration(milliseconds: 800));

  final boundary = tester.renderObject(find.byKey(const Key('screenshot_root')))
      as RenderRepaintBoundary;
  final image = await boundary.toImage(pixelRatio: 1.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);

  final out = File('$_outDir/$fileName');
  await out.parent.create(recursive: true);
  await out.writeAsBytes(byteData!.buffer.asUint8List());
}
