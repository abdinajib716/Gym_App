import 'package:flutter/foundation.dart';

import '../../../core/api/api_client.dart';

enum MobileDevicePlatform { android, ios, web, unknown }

class MobileDeviceTokenApi {
  MobileDeviceTokenApi(this._apiClient);

  final ApiClient _apiClient;

  Future<void> register({
    required String token,
    required MobileDevicePlatform platform,
    String? deviceName,
  }) async {
    await _apiClient.post(
      '/device-tokens',
      body: {
        'token': token,
        'platform': platform.backendValue,
        if (deviceName != null && deviceName.trim().isNotEmpty)
          'deviceName': deviceName.trim(),
      },
    );
  }

  Future<void> remove({required String token}) async {
    await _apiClient.delete('/device-tokens', body: {'token': token});
  }
}

typedef DeviceTokenProvider = Future<String?> Function();

class MobileDeviceTokenRegistrar {
  const MobileDeviceTokenRegistrar({
    required MobileDeviceTokenApi api,
    required DeviceTokenProvider tokenProvider,
  }) : _api = api,
       _tokenProvider = tokenProvider;

  final MobileDeviceTokenApi _api;
  final DeviceTokenProvider _tokenProvider;

  Future<void> registerCurrentDevice() async {
    final token = await _tokenProvider();
    if (token == null || token.trim().isEmpty) return;

    await _api.register(
      token: token.trim(),
      platform: mobileDevicePlatform,
      deviceName: defaultTargetPlatform.name,
    );
  }

  Future<void> removeCurrentDevice() async {
    final token = await _tokenProvider();
    if (token == null || token.trim().isEmpty) return;

    await _api.remove(token: token.trim());
  }
}

MobileDevicePlatform get mobileDevicePlatform {
  if (kIsWeb) return MobileDevicePlatform.web;

  return switch (defaultTargetPlatform) {
    TargetPlatform.android => MobileDevicePlatform.android,
    TargetPlatform.iOS => MobileDevicePlatform.ios,
    _ => MobileDevicePlatform.unknown,
  };
}

extension MobileDevicePlatformBackendValue on MobileDevicePlatform {
  String get backendValue {
    return switch (this) {
      MobileDevicePlatform.android => 'ANDROID',
      MobileDevicePlatform.ios => 'IOS',
      MobileDevicePlatform.web => 'WEB',
      MobileDevicePlatform.unknown => 'UNKNOWN',
    };
  }
}
