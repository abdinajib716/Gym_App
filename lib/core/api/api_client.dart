import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import 'api_exception.dart';

typedef TokenProvider = Future<String?> Function();

class ApiClient {
  ApiClient({
    http.Client? httpClient,
    TokenProvider? tokenProvider,
    this.timeout = const Duration(seconds: 25),
  }) : _httpClient = httpClient ?? http.Client(),
       _tokenProvider = tokenProvider;

  final http.Client _httpClient;
  final TokenProvider? _tokenProvider;
  final Duration timeout;

  Future<Map<String, dynamic>> get(String path) => _send('GET', path);

  Future<Map<String, dynamic>> post(String path, {Object? body}) {
    return _send('POST', path, body: body);
  }

  Future<Map<String, dynamic>> patch(String path, {Object? body}) {
    return _send('PATCH', path, body: body);
  }

  Future<Map<String, dynamic>> delete(String path, {Object? body}) {
    return _send('DELETE', path, body: body);
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Object? body,
  }) async {
    final token = await _tokenProvider?.call();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final uri = AppConfig.mobileUri(path);
    final requestBody = body == null ? null : jsonEncode(body);

    try {
      final response = await switch (method) {
        'GET' => _httpClient.get(uri, headers: headers).timeout(timeout),
        'POST' =>
          _httpClient
              .post(uri, headers: headers, body: requestBody)
              .timeout(timeout),
        'PATCH' =>
          _httpClient
              .patch(uri, headers: headers, body: requestBody)
              .timeout(timeout),
        'DELETE' =>
          _httpClient
              .delete(uri, headers: headers, body: requestBody)
              .timeout(timeout),
        _ => throw ApiException('Unsupported request method: $method'),
      };

      return _decode(response);
    } on TimeoutException {
      throw const ApiException('Request timed out. Please try again.');
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException('Unable to connect to the gym server.');
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    final decoded = response.body.isEmpty
        ? <String, dynamic>{}
        : jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final error = decoded['error']?.toString();
    throw ApiException(
      error == null || error.isEmpty ? 'Something went wrong.' : error,
      statusCode: response.statusCode,
    );
  }
}
