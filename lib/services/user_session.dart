import 'package:shared_preferences/shared_preferences.dart';

import '../core/smishing_api_client.dart';
import '../core/scan_pipeline.dart';
import 'native_bridge.dart';

class UserSession {
  UserSession._();
  static final UserSession instance = UserSession._();

  /// 로딩 화면: userid 확보. 실패 시 false (호출측에서 종료 다이얼로그).
  Future<bool> bootstrap() async {
    final prefs = await SharedPreferences.getInstance();
    final mock = prefs.getBool('mock_mode') ?? false;
    final baseUrl = prefs.getString('api_base_url') ??
        SmishingApiClient.defaultBaseUrl;

    if (mock) {
      final userid = prefs.getString('api_userid');
      final effective = (userid != null && userid.isNotEmpty)
          ? userid
          : 'mock-dev-user';
      await prefs.setString('api_userid', effective);
      await ScanPipeline.instance.applyConfig(
        baseUrl: baseUrl,
        userId: effective,
        mockMode: true,
      );
      return true;
    }

    var userid = prefs.getString('api_userid')?.trim() ?? '';
    if (userid.isNotEmpty) {
      await ScanPipeline.instance.applyConfig(
        baseUrl: baseUrl,
        userId: userid,
        mockMode: false,
      );
      return true;
    }

    final androidId = await NativeBridge.instance.getAndroidId();
    if (androidId.isEmpty) {
      return false;
    }

    try {
      final client = SmishingApiClient(
        baseUrl: baseUrl,
        userId: '',
        mockMode: false,
      );
      userid = await client.issueUserId(androidId);
      await prefs.setString('api_userid', userid);
      await prefs.setString('android_id', androidId);
      await ScanPipeline.instance.applyConfig(
        baseUrl: baseUrl,
        userId: userid,
        mockMode: false,
      );
      return true;
    } on SmishingServiceUnavailableException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
