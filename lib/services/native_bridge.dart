import 'dart:async';

import 'package:flutter/services.dart';

import '../core/scan_pipeline.dart';
import '../core/scan_result.dart';
import '../core/scan_stats.dart';

class NativeBridge {
  NativeBridge._();
  static final NativeBridge instance = NativeBridge._();

  static const _method = MethodChannel('smishing_guard/native');
  static const _events = EventChannel('smishing_guard/events');

  StreamSubscription<dynamic>? _sub;

  void startListening() {
    _sub ??= _events.receiveBroadcastStream().listen((event) async {
      if (event is! Map) return;
      final source = _parseSource(event['source'] as String?);
      final code = event['code'] as String?;
      final url = event['url'] as String?;
      final message = event['message'] as String? ?? '';
      final bodyText = event['bodyText'] as String?;
      final senderTitle = event['senderTitle'] as String?;
      final checkedAtMs = int.tryParse(event['checkedAt'] as String? ?? '');
      final entryId = event['entryId'] as String?;

      if (code != null && url != null && url.isNotEmpty) {
        final result = ScanResult(
          entryId: entryId,
          url: url,
          source: source,
          code: code,
          message: message,
          checkedAt: checkedAtMs != null
              ? DateTime.fromMillisecondsSinceEpoch(checkedAtMs)
              : DateTime.now(),
          bodyText: bodyText,
          senderTitle: senderTitle,
        );
        // 네이티브가 보낸 모든 검사 결과(안전·위험)는 1건씩 카운팅한다.
        // 위험 결과만 별도로 recordResult 가 타임라인·차단 카운터에 반영.
        await ScanStats.instance.recordScan();
        if (result.isDangerous) {
          ScanPipeline.instance.recordResult(result);
        }
        return;
      }

      final text = event['text'] as String?;
      ScanResult? smishing;
      if (text != null && text.isNotEmpty) {
        smishing = await ScanPipeline.instance.handleText(
          text,
          source,
          bodyText: text,
        );
      } else if (url != null && url.isNotEmpty) {
        smishing = await ScanPipeline.instance.checkUrl(url, source);
      }

      if (smishing != null && smishing.isDangerous) {
        final sticky = source != UrlSource.browser;
        await showWarningOverlay(
          smishing.url,
          smishing.message,
          sticky: sticky,
          source: source,
          bodyText: smishing.bodyText,
          senderTitle: smishing.senderTitle,
        );
      }
    });
  }

  UrlSource _parseSource(String? name) => UrlSource.fromWire(name);

  Future<String> getAndroidId() async {
    final id = await _method.invokeMethod<String>('getAndroidId');
    return id?.trim() ?? '';
  }

  /// 오버레이 「탐지 결과 자세히 보기」 후 타임라인 이동 요청
  Future<bool> consumeOpenTimelineRequest() async {
    final v = await _method.invokeMethod<bool>('consumeOpenTimeline');
    return v == true;
  }

  Future<Map<String, dynamic>> getPermissionStatus() async {
    final result = await _method.invokeMethod('getPermissionStatus');
    if (result is Map) {
      return result.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }

  Future<Map<String, dynamic>> requestRuntimePermissions() async {
    final result = await _method.invokeMethod('requestRuntimePermissions');
    if (result is Map) {
      return result.map((k, v) => MapEntry(k.toString(), v));
    }
    return {};
  }

  Future<void> startProtection() async {
    await _method.invokeMethod('startProtection');
  }

  Future<void> stopProtection() async {
    await _method.invokeMethod('stopProtection');
  }

  Future<void> showWarningOverlay(
    String url,
    String reason, {
    bool sticky = false,
    UrlSource source = UrlSource.manual,
    String? bodyText,
    String? senderTitle,
  }) async {
    await _method.invokeMethod('showWarningOverlay', {
      'url': url,
      'reason': reason,
      'sticky': sticky,
      'source': _sourceWire(source),
      if (bodyText != null && bodyText.isNotEmpty) 'bodyText': bodyText,
      if (senderTitle != null && senderTitle.isNotEmpty)
        'senderTitle': senderTitle,
      'appLabel': source.displayName,
    });
  }

  String _sourceWire(UrlSource source) => switch (source) {
        UrlSource.sms => 'sms',
        UrlSource.smsNotif => 'sms_notif',
        UrlSource.kakao => 'kakao',
        UrlSource.telegram => 'telegram',
        UrlSource.line => 'line',
        UrlSource.browser => 'browser',
        UrlSource.notif => 'notif',
        UrlSource.manual => 'manual',
      };

  Future<void> openNotificationAccessSettings() async {
    await _method.invokeMethod('openNotificationAccessSettings');
  }

  Future<void> openAccessibilitySettings() async {
    await _method.invokeMethod('openAccessibilitySettings');
  }

  Future<void> openOverlaySettings() async {
    await _method.invokeMethod('openOverlaySettings');
  }

  Future<void> openBatterySettings() async {
    await _method.invokeMethod('openBatterySettings');
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
