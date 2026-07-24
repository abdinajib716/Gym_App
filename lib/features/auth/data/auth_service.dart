import '../../../core/api/api_exception.dart';
import '../../../core/api/api_client.dart';
import '../../../core/utils/mobile_phone.dart';
import '../../shared/models/mobile_user.dart';

class LoginResult {
  const LoginResult({required this.token, required this.user});

  final String token;
  final MobileUser user;
}

class AuthService {
  AuthService(this._apiClient);

  final ApiClient _apiClient;

  Future<LoginResult> login({
    required String identifier,
    required String password,
  }) async {
    final normalizedIdentifier = normalizeSomaliaPhone(identifier);

    try {
      final data = await _apiClient.post(
        '/auth/login',
        body: {'identifier': normalizedIdentifier, 'password': password},
      );
      return _loginResultFromJson(data);
    } on ApiException catch (sharedError) {
      try {
        final data = await _apiClient.post(
          '/trainer/auth/login',
          body: {'identifier': normalizedIdentifier, 'password': password},
        );
        return _loginResultFromJson(data);
      } on ApiException catch (trainerError) {
        if (trainerError.statusCode != 401 && trainerError.statusCode != 404) {
          rethrow;
        }
        throw sharedError;
      }
    }
  }

  Future<MobileUser> me(MobileRole role) async {
    try {
      final data = await _apiClient.get('/auth/me');
      return MobileUser.fromJson(data['user'] as Map<String, dynamic>);
    } on ApiException catch (sharedError) {
      if (role != MobileRole.trainer) rethrow;
      try {
        final data = await _apiClient.get('/trainer/profile');
        final trainer = data['trainer'] ?? data['profile'] ?? data;
        return MobileUser.trainerFromJson(trainer as Map<String, dynamic>);
      } on ApiException catch (trainerError) {
        if (trainerError.statusCode != 401 && trainerError.statusCode != 404) {
          rethrow;
        }
        throw sharedError;
      }
    }
  }

  Future<void> logout(MobileRole role) async {
    if (role == MobileRole.trainer) {
      try {
        await _apiClient.post('/trainer/auth/logout');
        return;
      } on ApiException catch (error) {
        if (error.statusCode != 404) rethrow;
      }
    }
    await _apiClient.post('/auth/logout');
  }

  Future<void> forgotPassword(String identifier) async {
    await _apiClient.post(
      '/auth/forgot-password',
      body: {'identifier': normalizeSomaliaPhone(identifier)},
    );
  }

  Future<void> resetPassword({
    required String identifier,
    required String code,
    required String password,
  }) async {
    await _apiClient.post(
      '/auth/reset-password',
      body: {
        'identifier': normalizeSomaliaPhone(identifier),
        'code': code.trim(),
        'password': password,
      },
    );
  }

  LoginResult _loginResultFromJson(Map<String, dynamic> data) {
    final userJson = data['user'];
    if (userJson is Map<String, dynamic>) {
      return LoginResult(
        token: data['token']?.toString() ?? '',
        user: MobileUser.fromJson(userJson),
      );
    }

    final trainerJson = data['trainer'];
    if (trainerJson is Map<String, dynamic>) {
      return LoginResult(
        token: data['token']?.toString() ?? '',
        user: MobileUser.trainerFromJson(
          trainerJson,
          accountId: data['accountId']?.toString(),
          accountStatus: data['accountStatus']?.toString(),
          mustChangePassword: data['mustChangePassword'] == true,
        ),
      );
    }

    throw const ApiException('Login response was missing account details.');
  }
}
