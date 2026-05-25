import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/scan_result.dart';
import '../../core/smishing_api_client.dart';
import '../../core/scan_pipeline.dart';
import '../../services/native_bridge.dart';
import '../../services/secure_user_id_store.dart';
import '../../utils/korean_date_format.dart';
import '../legal/legal_notice_page.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  static const _vibrateKey = 'vibrate_on_detect';

  final _baseUrlController = TextEditingController();
  String _maskedUserId = '****';
  String _plainUserId = '';
  bool _mockMode = false;
  bool _vibrateOnDetect = true;

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
    final mock = prefs.getBool('mock_mode') ?? false;
    final stored = await SecureUserIdStore.instance.read();
    setState(() {
      _baseUrlController.text = _readBaseUrl(prefs);
      _mockMode = mock;
      _plainUserId = stored;
      _maskedUserId = _maskUserId(stored);
      _vibrateOnDetect = prefs.getBool(_vibrateKey) ?? true;
    });
  }

  String _maskUserId(String id) {
    if (id.isEmpty) return '(미발급)';
    if (id.length <= 4) return '*' * id.length;
    return '${id.substring(0, 2)}${'*' * (id.length - 4)}${id.substring(id.length - 2)}';
  }

  Future<void> _save() async {
    await ScanPipeline.instance.saveSettings(
      baseUrl: _baseUrlController.text.trim(),
      userId: _plainUserId,
      mockMode: _mockMode,
    );
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_vibrateKey, _vibrateOnDetect);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('저장되었습니다')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
          _UserIdField(
            mockMode: _mockMode,
            maskedUserId: _maskedUserId,
            plainUserId: _plainUserId,
          ),
          SwitchListTile(
            title: const Text('Mock 모드'),
            subtitle: const Text(
              '오프라인 테스트: 위험 키워드·테스트 페이지 URL은 스미싱 주의로 응답합니다',
            ),
            value: _mockMode,
            onChanged: (v) => setState(() => _mockMode = v),
          ),
          SwitchListTile(
            title: const Text('스미싱 탐지 시 진동'),
            subtitle: const Text(
              '경고가 표시될 때 짧게 한 번 진동합니다 (약 60ms). 무음 환경에서도 알아챌 수 있어요.',
            ),
            value: _vibrateOnDetect,
            onChanged: (v) => setState(() => _vibrateOnDetect = v),
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
          const Divider(height: 40),
          ListTile(
            leading: const Icon(Icons.gavel_outlined),
            title: const Text('오탐·면책 안내'),
            subtitle: Text(
              '탐지 결과의 성격, 오탐 가능성, 운영사의 면책 범위를 확인하세요.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            contentPadding: EdgeInsets.zero,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const LegalNoticePage()),
              );
            },
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _baseUrlController.dispose();
    super.dispose();
  }
}

class _UserIdField extends StatelessWidget {
  const _UserIdField({
    required this.mockMode,
    required this.maskedUserId,
    required this.plainUserId,
  });

  final bool mockMode;
  final String maskedUserId;
  final String plainUserId;

  @override
  Widget build(BuildContext context) {
    final display = mockMode && plainUserId.isNotEmpty
        ? plainUserId
        : maskedUserId;
    final helper = mockMode
        ? 'Mock 모드 — 디버깅을 위해 userid 원본을 표시합니다.'
        : '운영 모드에서는 보안을 위해 일부만 표시됩니다. 실제 값은 보안 보관소(Keystore)에 암호화 저장됩니다.';
    return TextField(
      controller: TextEditingController(text: display),
      readOnly: true,
      decoration: InputDecoration(
        labelText: 'userid (자동 발급)',
        helperText: helper,
        helperMaxLines: 3,
      ),
    );
  }
}
