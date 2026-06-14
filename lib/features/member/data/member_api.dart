import '../../../core/api/api_client.dart';
import 'member_models.dart';

class MemberApi {
  MemberApi(this._apiClient);

  final ApiClient _apiClient;

  Future<MemberDashboard> dashboard() async {
    final data = await _apiClient.get('/member/dashboard');
    return MemberDashboard.fromJson(data);
  }

  Future<MemberSubscription?> currentSubscription() async {
    final data = await _apiClient.get('/member/subscription/current');
    final subscription = data['subscription'];
    if (subscription is! Map<String, dynamic>) return null;
    return MemberSubscription.fromJson(subscription);
  }

  Future<List<MemberSubscription>> subscriptionHistory() async {
    final data = await _apiClient.get('/member/subscription/history');
    return (data['subscriptions'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MemberSubscription.fromJson)
        .toList();
  }

  Future<List<MembershipPlan>> plans() async {
    final data = await _apiClient.get('/member/plans');
    return (data['plans'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MembershipPlan.fromJson)
        .toList();
  }

  Future<MemberSubscription> upgrade({
    required String planId,
    DateTime? startDate,
  }) async {
    final data = await _apiClient.post(
      '/member/subscription/upgrade',
      body: {
        'planId': planId,
        if (startDate != null) 'startDate': startDate.toIso8601String(),
      },
    );
    return MemberSubscription.fromJson(
      data['subscription'] as Map<String, dynamic>,
    );
  }

  Future<MemberSubscription> renew({String? planId}) async {
    final data = await _apiClient.post(
      '/member/subscription/renew',
      body: {if (planId != null) 'planId': planId},
    );
    return MemberSubscription.fromJson(
      data['subscription'] as Map<String, dynamic>,
    );
  }

  Future<MemberPayment> initiateWaafiPayment({
    required String subscriptionId,
    required String provider,
    required String phoneNumber,
    required double amount,
    String currency = 'USD',
  }) async {
    final data = await _apiClient.post(
      '/member/payments/waafi/initiate',
      body: {
        'subscriptionId': subscriptionId,
        'provider': provider,
        'phoneNumber': phoneNumber,
        'amount': amount,
        'currency': currency,
      },
    );
    return MemberPayment.fromJson(data['payment'] as Map<String, dynamic>);
  }

  Future<MemberPayment> waafiPaymentStatus(String paymentId) async {
    final data = await _apiClient.get(
      '/member/payments/waafi/status/$paymentId',
    );
    return MemberPayment.fromJson(data['payment'] as Map<String, dynamic>);
  }

  Future<List<MemberPayment>> paymentHistory() async {
    final data = await _apiClient.get('/member/payments/history');
    return (data['payments'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MemberPayment.fromJson)
        .toList();
  }

  Future<List<MemberNotification>> notifications() async {
    final data = await _apiClient.get('/member/notifications');
    return (data['notifications'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(MemberNotification.fromJson)
        .toList();
  }

  Future<MemberNotification> markNotificationRead(String notificationId) async {
    final data = await _apiClient.patch(
      '/member/notifications/$notificationId/read',
    );
    return MemberNotification.fromJson(
      data['notification'] as Map<String, dynamic>,
    );
  }

  Future<int> markAllNotificationsRead() async {
    final data = await _apiClient.patch('/member/notifications/mark-all-read');
    return (data['updatedCount'] as num?)?.toInt() ?? 0;
  }

  Future<void> deleteNotification(String notificationId) async {
    await _apiClient.delete('/member/notifications/$notificationId');
  }
}
