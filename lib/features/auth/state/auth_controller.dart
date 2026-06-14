import 'package:flutter/foundation.dart';

import '../../../core/api/api_exception.dart';
import '../../../core/storage/session_storage.dart';
import '../../shared/models/mobile_user.dart';
import '../data/auth_service.dart';

enum AuthStatus { booting, signedOut, signedIn }

class AuthController extends ChangeNotifier {
  AuthController({
    required AuthService authService,
    required SessionStorage storage,
  }) : _authService = authService,
       _storage = storage;

  final AuthService _authService;
  final SessionStorage _storage;

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

    try {
      final refreshedUser = await _authService.me();
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
      await _authService.logout();
    } catch (_) {
      // Local logout should always succeed.
    }

    await _storage.clear();
    user = null;
    status = AuthStatus.signedOut;
    isBusy = false;
    notifyListeners();
  }
}
