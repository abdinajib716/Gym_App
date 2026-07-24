import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/storage/session_storage.dart';
import '../../shared/data/mobile_device_token_api.dart';
import '../../shared/models/mobile_user.dart';
import '../data/auth_service.dart';

enum AuthStatus { booting, signedOut, signedIn }

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required SessionStorage storage,
    MobileDeviceTokenRegistrar? deviceTokenRegistrar,
  }) : _authService = authService,
       _storage = storage,
       _deviceTokenRegistrar = deviceTokenRegistrar;

  final AuthService _authService;
  final SessionStorage _storage;
  final MobileDeviceTokenRegistrar? _deviceTokenRegistrar;

  AuthStatus status = AuthStatus.booting;
  MobileUser? user;
  String? errorMessage;
  bool isBusy = false;

  Future<String?> tokenProvider() => _storage.readToken();

  Future<void> restore() async {
    status = AuthStatus.booting;
    notifyListeners();

    final token = await _storage.readToken();
    final cachedUser = await _storage.readUser();

    if (token == null || cachedUser == null) {
      status = AuthStatus.signedOut;
      notifyListeners();
      return;
    }

    user = cachedUser;
    status = AuthStatus.signedIn;
    notifyListeners();
    await _registerDeviceToken();

    try {
      final refreshedUser = await _authService.me(cachedUser.role);
      user = refreshedUser;
      await _storage.saveUser(refreshedUser);
      notifyListeners();
    } catch (_) {
      // Keep the local session if the backend is temporarily unavailable.
    }
  }

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    isBusy = true;
    errorMessage = null;
    notifyListeners();

    try {
      final result = await _authService.login(
        identifier: identifier,
        password: password,
      );
      user = result.user;
      await _storage.saveSession(token: result.token, user: result.user);
      await _registerDeviceToken();
      status = AuthStatus.signedIn;
      return true;
    } on ApiException catch (error) {
      errorMessage = error.message;
      return false;
    } finally {
      isBusy = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    isBusy = true;
    notifyListeners();
    try {
      await _removeDeviceToken();
      await _authService.logout(user?.role ?? MobileRole.member);
    } catch (_) {
      // Local logout should always succeed.
    }

    await _storage.clear();
    user = null;
    status = AuthStatus.signedOut;
    isBusy = false;
    notifyListeners();
  }

  Future<void> markPasswordChanged() async {
    final currentUser = user;
    if (currentUser == null) return;

    final updatedUser = currentUser.copyWith(mustChangePassword: false);
    user = updatedUser;
    await _storage.saveUser(updatedUser);
    notifyListeners();
  }

  Future<void> _registerDeviceToken() async {
    try {
      await _deviceTokenRegistrar?.registerCurrentDevice();
    } catch (_) {
      // Push registration should not block sign-in.
    }
  }

  Future<void> _removeDeviceToken() async {
    try {
      await _deviceTokenRegistrar?.removeCurrentDevice();
    } catch (_) {
      // Local logout should not be blocked by push cleanup.
    }
  }
}
