import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _userKey  = 'user_email';

  // ── 토큰 저장 ──────────────────────────
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // ── 토큰 조회 ──────────────────────────
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // ── 로그인 여부 확인 ────────────────────
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    return token != null && token.isNotEmpty;
  }

  // ── Mock 로그인 ─────────────────────────
  // 백엔드 연동 전 임시 로그인
  // ID: test@test.com / PW: 1234
  Future<bool> mockLogin(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 800));
    if (email == 'test@test.com' && password == '1234') {
      await saveToken('mock_token_12345');
      await _storage.write(key: _userKey, value: email);
      return true;
    }
    return false;
  }

  // ── 로그아웃 ───────────────────────────
  Future<void> logout() async {
    await _storage.deleteAll();
  }

  // ── 유저 이메일 조회 ────────────────────
  Future<String?> getUserEmail() async {
    return await _storage.read(key: _userKey);
  }
}
