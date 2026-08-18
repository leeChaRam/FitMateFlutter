import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// 로그인 후 발급받은 JWT를 기기에 암호화하여 저장/조회/삭제하는 공통 저장소.
// 도메인(auth, body_composition 등) 상관없이 인증이 필요한 모든 api_service에서 사용.
class TokenStorage {
  TokenStorage._();

  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'auth_token';

  static Future<void> saveToken(String token) {
    return _storage.write(key: _tokenKey, value: token);
  }

  static Future<String?> getToken() {
    return _storage.read(key: _tokenKey);
  }

  static Future<void> clearToken() {
    return _storage.delete(key: _tokenKey);
  }
}
