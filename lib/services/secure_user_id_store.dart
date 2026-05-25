import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// userid 보관소.
///
/// Android Keystore 기반의 [FlutterSecureStorage]에 평문 대신 암호화된 값으로
/// 저장한다. 네이티브(UriCheckBridge, SmsInboxObserver 등 Kotlin 코드)는
/// `FlutterSharedPreferences`의 `flutter.api_userid` 키를 직접 읽어 서버 호출 시
/// `userid` 헤더로 보내야 하므로, **호환을 위해 SharedPreferences에도 동일 값을
/// 함께 저장**한다. SharedPreferences 값은 네이티브와의 IPC 경로용 캐시이며,
/// 사용자에게 노출되는 화면(설정 페이지 등)에서는 보안 보관소 값만 읽어 사용한다.
///
/// 운영 시 UI에서는 **Mock 모드일 때만** userid 원본을 노출한다.
class SecureUserIdStore {
  SecureUserIdStore._();
  static final SecureUserIdStore instance = SecureUserIdStore._();

  static const _secureKey = 'sg.api_userid';
  static const _prefsKey = 'api_userid';
  static const _nativeBridgeKey = 'flutter.api_userid';

  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  /// 보안 보관소에서 우선 조회. 없으면 (이전 빌드에서 평문 prefs에 저장된 값을)
  /// 마이그레이션 후 반환.
  Future<String> read() async {
    try {
      final v = await _secure.read(key: _secureKey);
      if (v != null && v.isNotEmpty) return v;
    } catch (_) {
    }
    final prefs = await SharedPreferences.getInstance();
    final legacy = prefs.getString(_prefsKey) ?? '';
    if (legacy.isNotEmpty) {
      try {
        await _secure.write(key: _secureKey, value: legacy);
      } catch (_) {}
    }
    return legacy;
  }

  /// 보안 보관소 + 네이티브 호환용 prefs 양쪽에 저장.
  Future<void> write(String userId) async {
    final v = userId.trim();
    try {
      if (v.isEmpty) {
        await _secure.delete(key: _secureKey);
      } else {
        await _secure.write(key: _secureKey, value: v);
      }
    } catch (_) {
    }
    final prefs = await SharedPreferences.getInstance();
    if (v.isEmpty) {
      await prefs.remove(_prefsKey);
    } else {
      await prefs.setString(_prefsKey, v);
    }
  }

  /// Mock 모드 ON 일 때만 UI에 표시. 평소엔 노출하지 않는다.
  Future<String> readForDisplay({required bool mockMode}) async {
    if (!mockMode) return '';
    return read();
  }

  /// 디버그용. 네이티브 채널이 SharedPreferences에서 직접 읽는 키 이름.
  String get nativeBridgeKey => _nativeBridgeKey;
}
