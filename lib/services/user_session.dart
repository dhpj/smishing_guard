import 'package:shared_preferences/shared_preferences.dart';

import '../core/smishing_api_client.dart';
import '../core/scan_pipeline.dart';
import 'native_bridge.dart';
import 'secure_user_id_store.dart';

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
      final stored = await SecureUserIdStore.instance.read();
      final effective = stored.isNotEmpty ? stored : 'mock-dev-user';
      await SecureUserIdStore.instance.write(effective);
      await ScanPipeline.instance.applyConfig(
        baseUrl: baseUrl,
        userId: effective,
        mockMode: true,
      );
      return true;
    }

    var userid = await SecureUserIdStore.instance.read();
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
      await SecureUserIdStore.instance.write(userid);
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
