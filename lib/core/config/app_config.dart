class AppConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://gym.mrk.so',
  );

  static const mobileApiBasePath = '/api/mobile';

  static Uri mobileUri(String path, [Map<String, dynamic>? query]) {
    final base = Uri.parse(apiBaseUrl);
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    final queryParameters = query?.map(
      (key, value) => MapEntry(key, value?.toString() ?? ''),
    );

    return base.replace(
      path: '$mobileApiBasePath$normalizedPath',
      queryParameters: queryParameters,
    );
  }
}
