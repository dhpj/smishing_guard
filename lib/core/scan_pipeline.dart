import 'package:shared_preferences/shared_preferences.dart';

import 'app_user_settings.dart';
import '../services/secure_user_id_store.dart';
import 'scan_result.dart';
import 'scan_stats.dart';
import 'smishing_api_client.dart';
import 'timeline_store.dart';
import 'url_extractor.dart';

typedef ScanListener = void Function(ScanResult result);

class ScanPipeline {
  ScanPipeline._();
  static final ScanPipeline instance = ScanPipeline._();

  final Map<String, ScanResult> _cache = {};
  final List<ScanListener> _listeners = [];

  SmishingApiClient? _client;
  final Map<String, DateTime> _lastChecked = {};

  void configure(SmishingApiClient client) {
    _client = client;
  }

  Future<void> applyConfig({
    required String baseUrl,
    required String userId,
    required bool mockMode,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('api_base_url', baseUrl);
    await prefs.setBool('mock_mode', mockMode);
    await SecureUserIdStore.instance.write(userId);
    configure(SmishingApiClient(baseUrl: baseUrl, userId: userId, mockMode: mockMode));
  }

  /// 네이티브에서 이미 검사·오버레이 완료 — 위험만 타임라인.
  /// `recordScan()` 은 `NativeBridge.startListening` 이 모든 결과(안전+위험)에
  /// 대해 이미 호출하므로 여기서는 차단 카운트만 증가시킨다.
  void recordResult(ScanResult result) {
    if (!result.isDangerous) return;
    _cache[result.url] = result;
    TimelineStore.instance.add(result);
    ScanStats.instance.recordBlocked();
    for (final l in _listeners) {
      l(result);
    }
  }

  void addListener(ScanListener listener) => _listeners.add(listener);

  Future<ScanResult?> handleText(
    String text,
    UrlSource source, {
    String? bodyText,
    String? senderTitle,
  }) async {
    final urls = UrlExtractor.extract(text);
    if (urls.isEmpty) return null;

    ScanResult? smishing;
    for (final url in urls) {
      final r = await checkUrl(
        url,
        source,
        bodyText: bodyText ?? text,
        senderTitle: senderTitle,
      );
      if (r != null && r.isDangerous) smishing = r;
    }
    return smishing;
  }

  Future<ScanResult?> checkUrl(
    String url,
    UrlSource source, {
    String? bodyText,
    String? senderTitle,
  }) async {
    final normalized = UrlExtractor.normalize(url);
    if (normalized == null) return null;
    final now = DateTime.now();
    final client = _client;
    if (client == null) return null;

    final debounce = source == UrlSource.browser
        ? const Duration(milliseconds: 400)
        : const Duration(seconds: 2);

    final last = _lastChecked[normalized];
    if (last != null && now.difference(last) < debounce) {
      return _cache[normalized];
    }
    _lastChecked[normalized] = now;

    if (source != UrlSource.browser) {
      final cached = _cache[normalized];
      if (cached != null &&
          now.difference(cached.checkedAt) < const Duration(hours: 1)) {
        return cached;
      }
    }

    try {
      final api = await client.checkUri(normalized);
      final result = ScanResult(
        url: normalized,
        source: source,
        code: api.code,
        message: api.message,
        checkedAt: now,
        bodyText: bodyText,
        senderTitle: senderTitle,
      );
      _cache[normalized] = result;
      await ScanStats.instance.recordScan();
      if (result.isDangerous) {
        final trusted = AppUserSettings.isTrustedUrl(
          normalized,
          await AppUserSettings.trustedDomains(),
        );
        if (!trusted) {
          await ScanStats.instance.recordBlocked();
          await TimelineStore.instance.add(result);
          for (final l in _listeners) {
            l(result);
          }
        }
      }
      return result;
    } on UriCheckException catch (e) {
      return ScanResult(
        url: normalized,
        source: source,
        code: e.code,
        message: e.message,
        checkedAt: now,
      );
    } catch (_) {
      return null;
    }
  }

  Future<SmishingApiClient?> get client async => _client;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final baseUrl = prefs.getString('api_base_url') ??
        SmishingApiClient.defaultBaseUrl;
    final userId = await SecureUserIdStore.instance.read();
    final mock = prefs.getBool('mock_mode') ?? false;
    if (userId.isEmpty && !mock) {
      configure(
        SmishingApiClient(baseUrl: baseUrl, userId: 'pending', mockMode: false),
      );
      return;
    }
    configure(
      SmishingApiClient(baseUrl: baseUrl, userId: userId, mockMode: mock),
    );
  }

  Future<void> saveSettings({
    required String baseUrl,
    required String userId,
    required bool mockMode,
  }) async {
    await applyConfig(baseUrl: baseUrl, userId: userId, mockMode: mockMode);
  }

  Future<List<AdImageResponse>> fetchAdImages() async {
    final client = _client;
    if (client == null) return [];
    return client.getAdImages();
  }
}
