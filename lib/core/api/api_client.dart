import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
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

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? query,
  }) => _send('GET', path, query: query);

  Future<Map<String, dynamic>> post(
    String path, {
    Object? body,
    Duration? timeout,
  }) {
    return _send('POST', path, body: body, requestTimeout: timeout);
  }

  Future<Map<String, dynamic>> put(String path, {Object? body}) {
    return _send('PUT', path, body: body);
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
    Map<String, dynamic>? query,
    Duration? requestTimeout,
  }) async {
    final token = await _tokenProvider?.call();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };

    final uri = AppConfig.mobileUri(path, query);
    final requestBody = body == null ? null : jsonEncode(body);
    final effectiveTimeout = requestTimeout ?? timeout;

    try {
      final response = await switch (method) {
        'GET' =>
          _httpClient.get(uri, headers: headers).timeout(effectiveTimeout),
        'POST' =>
          _httpClient
              .post(uri, headers: headers, body: requestBody)
              .timeout(effectiveTimeout),
        'PUT' =>
          _httpClient
              .put(uri, headers: headers, body: requestBody)
              .timeout(effectiveTimeout),
        'PATCH' =>
          _httpClient
              .patch(uri, headers: headers, body: requestBody)
              .timeout(effectiveTimeout),
        'DELETE' =>
          _httpClient
              .delete(uri, headers: headers, body: requestBody)
              .timeout(effectiveTimeout),
        _ => throw ApiException('Unsupported request method: $method'),
      };

      if (kDebugMode) {
        debugPrint('API $method ${uri.path} -> ${response.statusCode}');
      }
      return _decode(response);
    } on TimeoutException {
      if (kDebugMode) debugPrint('API $method ${uri.path} timed out');
      throw const ApiException(
        'Request timed out. Please try again.',
        type: ApiErrorType.timeout,
      );
    } on http.ClientException {
      if (kDebugMode) debugPrint('API $method ${uri.path} client exception');
      throw const ApiException(
        'Unable to reach the gym server. Check your connection and try again.',
        type: ApiErrorType.network,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      if (kDebugMode) debugPrint('API $method ${uri.path} network exception');
      throw const ApiException(
        'Unable to connect to the gym server.',
        type: ApiErrorType.network,
      );
    }
  }

  Future<Map<String, dynamic>> multipartPostBytes(
    String path, {
    required String fieldName,
    required String fileName,
    required Uint8List bytes,
    Map<String, String>? fields,
  }) async {
    final token = await _tokenProvider?.call();
    final request = http.MultipartRequest('POST', AppConfig.mobileUri(path));
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    });
    request.fields.addAll(fields ?? const {});
    request.files.add(
      http.MultipartFile.fromBytes(fieldName, bytes, filename: fileName),
    );

    try {
      final streamed = await request.send().timeout(timeout);
      final response = await http.Response.fromStream(streamed);
      return _decode(response);
    } on TimeoutException {
      throw const ApiException(
        'Request timed out. Please try again.',
        type: ApiErrorType.timeout,
      );
    } on http.ClientException {
      throw const ApiException(
        'Unable to reach the gym server. Check your connection and try again.',
        type: ApiErrorType.network,
      );
    } on ApiException {
      rethrow;
    } catch (_) {
      throw const ApiException(
        'Unable to connect to the gym server.',
        type: ApiErrorType.network,
      );
    }
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> decoded = <String, dynamic>{};
    if (response.body.isNotEmpty) {
      try {
        final parsed = jsonDecode(response.body);
        if (parsed is Map<String, dynamic>) decoded = parsed;
      } catch (_) {
        if (response.statusCode >= 200 && response.statusCode < 300) {
          throw ApiException(
            'Unexpected response from the gym server.',
            statusCode: response.statusCode,
            type: ApiErrorType.unexpectedResponse,
          );
        }
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final error =
        decoded['error']?.toString() ?? decoded['message']?.toString();
    if (kDebugMode) {
      debugPrint(
        'API error ${response.statusCode} ${response.request?.url.path ?? ''}: ${error ?? response.body}',
      );
    }
    throw ApiException(
      error == null || error.isEmpty
          ? _fallbackMessage(response.statusCode)
          : error,
      statusCode: response.statusCode,
      type: _errorType(response.statusCode),
    );
  }

  String _fallbackMessage(int statusCode) {
    return switch (statusCode) {
      400 || 422 => 'Please check the details and try again.',
      401 => 'Your session has expired. Please sign in again.',
      403 => 'You do not have access to this action.',
      404 => 'This mobile API is not available on the server.',
      >= 500 => 'The gym server had a problem. Please try again.',
      _ => 'Request failed. Please try again.',
    };
  }

  ApiErrorType _errorType(int statusCode) {
    return switch (statusCode) {
      400 || 422 => ApiErrorType.validation,
      401 => ApiErrorType.authentication,
      403 => ApiErrorType.authorization,
      404 => ApiErrorType.notFound,
      >= 500 => ApiErrorType.server,
      _ => ApiErrorType.unknown,
    };
  }
}
