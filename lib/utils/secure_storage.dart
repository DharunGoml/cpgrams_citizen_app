import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static const _storage = FlutterSecureStorage();

  // Simple storage methods like cookies.set and cookies.get
  static Future<void> set(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  static Future<String?> get(String key) async {
    return await _storage.read(key: key);
  }

  static Future<void> remove(String key) async {
    await _storage.delete(key: key);
  }

  static Future<void> clear() async {
    await _storage.deleteAll();
    debugPrint('SecureStorage cleared successfully.');
  }

  // Public getters for accessing stored auth data
  static Future<String?> get accessToken => get('access_token');
  static Future<String?> get refreshToken => get('refresh_token');
  static Future<String?> get guestId => get('guest_id');
  static Future<String?> get userId => get('user_id');
  static Future<String?> get userDetails => get('user_details');
  static Future<bool> get isGuest async {
    final value = await get('is_guest');
    return value == 'true';
  }
}
