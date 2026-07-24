import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym_app/core/api/api_client.dart';
import 'package:gym_app/features/member/data/member_api.dart';
import 'package:gym_app/features/shared/data/mobile_device_token_api.dart';
import 'package:gym_app/features/trainer/data/trainer_api.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

void main() {
  test(
    'ApiClient prefixes mobile paths and preserves query parameters',
    () async {
      Uri? capturedUri;

      final apiClient = ApiClient(
        httpClient: MockClient((request) async {
          capturedUri = request.url;
          return http.Response(jsonEncode({'success': true}), 200);
        }),
      );

      await apiClient.get('/trainer/schedules', query: {'date': '2026-07-01'});

      expect(capturedUri?.path, '/api/mobile/trainer/schedules');
      expect(capturedUri?.queryParameters['date'], '2026-07-01');
    },
  );

  test('TrainerApi changePassword uses trainer mobile endpoint', () async {
    http.Request? capturedRequest;
    Object? capturedBody;

    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        capturedRequest = request;
        capturedBody = jsonDecode(request.body);
        return http.Response(jsonEncode({'success': true}), 200);
      }),
    );

    await TrainerApi(apiClient).changePassword(
      currentPassword: 'old-password',
      newPassword: 'new-password',
    );

    expect(capturedRequest?.method, 'POST');
    expect(
      capturedRequest?.url.path,
      '/api/mobile/trainer/auth/change-password',
    );
    expect(capturedBody, {
      'currentPassword': 'old-password',
      'newPassword': 'new-password',
    });
  });

  test(
    'MemberApi attendance and progress use member mobile endpoints',
    () async {
      final requests = <http.Request>[];

      final apiClient = ApiClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          return http.Response(
            jsonEncode({
              'success': true,
              if (request.url.path.endsWith('/attendance'))
                'summary': {'total': 0, 'present': 0, 'cancelled': 0}
              else
                'progress': {
                  'attendance': {
                    'totalPresent': 0,
                    'presentInRange': 0,
                    'presentThisMonth': 0,
                    'rangeDays': 30,
                  },
                  'training': {
                    'activeWorkouts': 0,
                    'totalSchedules': 0,
                    'completedSchedules': 0,
                    'upcomingSchedules': 0,
                    'missedSchedules': 0,
                    'cancelledSchedules': 0,
                    'completionRate': 0,
                  },
                },
            }),
            200,
          );
        }),
      );

      final api = MemberApi(apiClient);
      await api.attendance(period: 'weekly', limit: 10);
      await api.progress(days: 30);

      expect(requests[0].url.path, '/api/mobile/member/attendance');
      expect(requests[0].url.queryParameters['period'], 'weekly');
      expect(requests[0].url.queryParameters['limit'], '10');
      expect(requests[1].url.path, '/api/mobile/member/progress');
      expect(requests[1].url.queryParameters['days'], '30');
    },
  );

  test(
    'MemberApi subscription filters and store use mobile endpoints',
    () async {
      final requests = <http.Request>[];

      final apiClient = ApiClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          final path = request.url.path;
          final payload = <String, dynamic>{'success': true};
          if (path.endsWith('/subscription/history')) {
            payload['subscriptions'] = [];
          } else if (path.endsWith('/store/products/product-id/purchase')) {
            payload
              ..['paymentStatus'] = 'FAILED'
              ..['message'] = 'Failed';
          } else if (path.endsWith('/store/products')) {
            payload['products'] = [];
          } else if (path.endsWith('/store/orders')) {
            payload['orders'] = [];
          } else {
            payload['product'] = {
              'id': 'product-id',
              'name': 'Protein Powder',
              'price': 25,
              'availableQuantity': 10,
            };
          }
          return http.Response(jsonEncode(payload), 200);
        }),
      );

      final api = MemberApi(apiClient);
      await api.subscriptionHistory(status: 'ACTIVE', period: 'month');
      await api.storeProducts();
      await api.purchaseStoreProduct(
        productId: 'product-id',
        quantity: 2,
        phoneNumber: '252612345678',
        provider: 'EVC_PLUS',
      );

      expect(requests[0].url.path, '/api/mobile/member/subscription/history');
      expect(requests[0].url.queryParameters['status'], 'ACTIVE');
      expect(requests[0].url.queryParameters['period'], 'month');
      expect(requests[1].url.path, '/api/mobile/member/store/products');
      expect(
        requests[2].url.path,
        '/api/mobile/member/store/products/product-id/purchase',
      );
      expect(
        requests.any(
          (request) => request.url.path.contains('/payments/waafi/initiate'),
        ),
        isFalse,
      );
    },
  );

  test(
    'TrainerApi groups store and member attendance filters use trainer endpoints',
    () async {
      final requests = <http.Request>[];

      final apiClient = ApiClient(
        httpClient: MockClient((request) async {
          requests.add(request);
          final path = request.url.path;
          final payload = <String, dynamic>{'success': true};
          if (path.endsWith('/attendance')) {
            payload
              ..['summary'] = {'total': 0, 'present': 0, 'cancelled': 0}
              ..['attendance'] = [];
          } else if (path.endsWith('/groups')) {
            payload['groups'] = [];
          } else if (path.endsWith('/store/products')) {
            payload['products'] = [];
          } else if (path.endsWith('/store/products/product-id/purchase')) {
            payload
              ..['paymentStatus'] = 'PENDING'
              ..['message'] = 'Payment prompt sent';
          } else {
            payload['orders'] = [];
          }
          return http.Response(jsonEncode(payload), 200);
        }),
      );

      final api = TrainerApi(apiClient);
      await api.memberAttendance('member-id', period: 'monthly', limit: 50);
      await api.groups();
      await api.storeProducts();
      await api.purchaseStoreProduct(
        productId: 'product-id',
        quantity: 2,
        phoneNumber: '252612345678',
        provider: 'EVC_PLUS',
      );
      await api.storeOrders();

      expect(
        requests[0].url.path,
        '/api/mobile/trainer/members/member-id/attendance',
      );
      expect(requests[0].url.queryParameters['period'], 'monthly');
      expect(requests[0].url.queryParameters['limit'], '50');
      expect(requests[1].url.path, '/api/mobile/trainer/groups');
      expect(requests[2].url.path, '/api/mobile/trainer/store/products');
      expect(
        requests[3].url.path,
        '/api/mobile/trainer/store/products/product-id/purchase',
      );
      expect(requests[4].url.path, '/api/mobile/trainer/store/orders');
      expect(
        requests.any(
          (request) => request.url.path.contains('/payments/waafi/initiate'),
        ),
        isFalse,
      );
    },
  );

  test('MobileDeviceTokenApi registers and removes device token', () async {
    final requests = <http.Request>[];

    final apiClient = ApiClient(
      httpClient: MockClient((request) async {
        requests.add(request);
        return http.Response(jsonEncode({'success': true}), 200);
      }),
    );

    final api = MobileDeviceTokenApi(apiClient);
    await api.register(
      token: 'fcm-token',
      platform: MobileDevicePlatform.android,
      deviceName: 'android',
    );
    await api.remove(token: 'fcm-token');

    expect(requests[0].method, 'POST');
    expect(requests[0].url.path, '/api/mobile/device-tokens');
    expect(jsonDecode(requests[0].body), {
      'token': 'fcm-token',
      'platform': 'ANDROID',
      'deviceName': 'android',
    });
    expect(requests[1].method, 'DELETE');
    expect(requests[1].url.path, '/api/mobile/device-tokens');
    expect(jsonDecode(requests[1].body), {'token': 'fcm-token'});
  });

  test('Flutter mobile code does not call admin api v1 routes', () {
    final libDirectory = Directory('lib');
    final offenders = <String>[];

    for (final file in libDirectory.listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final content = file.readAsStringSync();
      if (content.contains('/api/v1/')) offenders.add(file.path);
    }

    expect(offenders, isEmpty);
  });
}
