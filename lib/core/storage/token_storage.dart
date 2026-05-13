import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// JWT 토큰 저장소.
///
/// - Native (Android/iOS): flutter_secure_storage (EncryptedSharedPreferences/Keychain)
/// - Web (PWA): SharedPreferences (localStorage)
///   · flutter_secure_storage_web은 dart:html 기반이라 Safari ITP/캐시 정책에서
///     데이터 유실이 잦고, 일부 환경에서는 read 시 null check throw가 발생.
///   · web 환경은 어차피 브라우저 storage 보호 수준이라 localStorage로 단순화.
class TokenStorage {
  static const _key = 'auth_token';
  static const _secure = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<String?> read() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        return prefs.getString(_key);
      }
      return await _secure.read(key: _key);
    } catch (_) {
      return null;
    }
  }

  static Future<void> write(String token) async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_key, token);
        return;
      }
      await _secure.write(key: _key, value: token);
    } catch (_) {
      // 저장 실패해도 앱 흐름은 끊지 않음 — 토큰은 메모리(상태)에 보관됨
    }
  }

  static Future<void> clear() async {
    try {
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_key);
        return;
      }
      await _secure.delete(key: _key);
    } catch (_) {}
  }
}
