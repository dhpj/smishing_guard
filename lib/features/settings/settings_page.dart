import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/scan_result.dart';
import '../../core/smishing_api_client.dart';
import '../../core/scan_pipeline.dart';
import '../../services/native_bridge.dart';
import '../../utils/korean_date_format.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final _baseUrlController = TextEditingController();
  final _userIdController = TextEditingController();
  bool _mockMode = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  static String _readBaseUrl(SharedPreferences prefs) {
    final stored = prefs.getString('api_base_url');
    if (stored != null && stored.isNotEmpty) return stored;

    final legacy = prefs.getString('api_endpoint');
    if (legacy != null && legacy.isNotEmpty) {
      if (legacy.endsWith('/check_uri')) {
        return legacy.substring(0, legacy.length - '/check_uri'.length);
      }
      return legacy;
    }
    return SmishingApiClient.defaultBaseUrl;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _baseUrlController.text = _readBaseUrl(prefs);
      _userIdController.text = prefs.getString('api_userid') ?? '';
      _mockMode = prefs.getBool('mock_mode') ?? false;
    });
  }

  Future<void> _save() async {
    await ScanPipeline.instance.saveSettings(
      baseUrl: _baseUrlController.text.trim(),
      userId: _userIdController.text.trim(),
      mockMode: _mockMode,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _baseUrlController,
            decoration: const InputDecoration(
              labelText: 'API 서버 주소',
              hintText: SmishingApiClient.defaultBaseUrl,
              helperText: '예: http://210.114.225.58:8087',
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _userIdController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'userid (자동 발급)',
              helperText: '앱 최초 실행 시 서버에서 발급됩니다',
            ),
          ),
          SwitchListTile(
            title: const Text('Mock 모드'),
            subtitle: const Text(
              '오프라인 테스트: 위험 키워드·테스트 페이지 URL은 스미싱 주의로 응답합니다',
            ),
            value: _mockMode,
            onChanged: (v) => setState(() => _mockMode = v),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Text(
              '서버 판정: 안전(0000) · 스미싱 주의(0001)',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          FilledButton(onPressed: _save, child: const Text('저장')),
          const SizedBox(height: 24),
          FilledButton.tonal(
            onPressed: () async {
              await NativeBridge.instance.runTestSmishingCheck();
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    '테스트 링크 검사 요청함 — 빨간 오버레이 또는 시스템 알림을 확인하세요',
                  ),
                ),
              );
            },
            child: const Text('스미싱 테스트 링크 검사 (앱 내부)'),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () {
              final now = DateTime.now();
              NativeBridge.instance.showWarningOverlay(
                'https://bit.ly/ui-test-${now.millisecondsSinceEpoch}',
                '실시간 스미싱 URL 탐지 결과입니다.',
                sticky: true,
                source: UrlSource.kakao,
                senderTitle: 'UI 테스트',
                bodyText:
                    '[지금 받은 메시지 미리보기 · ${formatKoreanDateTime(now)}] '
                    '의심 링크가 포함된 알림입니다. bit.ly/ui-test',
              );
            },
            child: const Text('경고 오버레이 UI 테스트'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    _userIdController.dispose();
    super.dispose();
  }
}
