import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../features/shared/models/mobile_user.dart';

class SessionStorage {
  static const _tokenKey = 'mobile_token';
  static const _userKey = 'mobile_user';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> readToken() => _storage.read(key: _tokenKey);

  Future<MobileUser?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null || raw.isEmpty) return null;
    return MobileUser.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveSession({required String token, required MobileUser user}) {
    return Future.wait([
      _storage.write(key: _tokenKey, value: token),
      _storage.write(key: _userKey, value: jsonEncode(user.toJson())),
    ]);
  }

  Future<void> saveUser(MobileUser user) {
    return _storage.write(key: _userKey, value: jsonEncode(user.toJson()));
  }

  Future<void> clear() {
    return Future.wait([
      _storage.delete(key: _tokenKey),
      _storage.delete(key: _userKey),
    ]);
  }
}
