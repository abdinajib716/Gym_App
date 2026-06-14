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
    final data = await _apiClient.post(
      '/auth/login',
      body: {
        'identifier': normalizeSomaliaPhone(identifier),
        'password': password,
      },
    );

    return LoginResult(
      token: data['token']?.toString() ?? '',
      user: MobileUser.fromJson(data['user'] as Map<String, dynamic>),
    );
  }

  Future<MobileUser> me() async {
    final data = await _apiClient.get('/auth/me');
    return MobileUser.fromJson(data['user'] as Map<String, dynamic>);
  }

  Future<void> logout() async {
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
}
