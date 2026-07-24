import '../../../core/api/api_client.dart';
import '../../store/data/store_models.dart';
import '../../training/data/training_models.dart';
import 'member_models.dart';

class MemberApi {
  MemberApi(this._apiClient);

  final ApiClient _apiClient;

  Future<MemberDashboard> dashboard() async {
    final data = await _apiClient.get('/member/dashboard');
    return MemberDashboard.fromJson(data);
  }

  Future<MemberProfile> profile() async {
    final data = await _apiClient.get('/member/profile');
    final member = data['member'] ?? data['profile'] ?? data;
    return MemberProfile.fromJson(member as Map<String, dynamic>);
  }

  Future<MemberProfile> updateProfile(MemberProfile profile) async {
    final data = await _apiClient.put(
      '/member/profile',
      body: profile.toUpdateJson(),
    );
    final member = data['member'] ?? data['profile'] ?? data;
    return MemberProfile.fromJson(member as Map<String, dynamic>);
  }

  Future<MemberAttendance> attendance({
    String period = 'monthly',
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
  }) async {
    final data = await _apiClient.get(
      '/member/attendance',
      query: {
        'period': period,
        if (dateFrom != null) 'dateFrom': dateFrom.toIso8601String(),
        if (dateTo != null) 'dateTo': dateTo.toIso8601String(),
        if (limit != null) 'limit': limit,
      },
    );
    return MemberAttendance.fromJson(data);
  }

  Future<MemberProgress> progress({int days = 30}) async {
    final data = await _apiClient.get(
      '/member/progress',
      query: {'days': days},
    );
    return MemberProgress.fromJson(data);
  }

  Future<MemberSubscription?> currentSubscription() async {
    final data = await _apiClient.get('/member/subscription/current');
    final subscription = data['subscription'];
    if (subscription is! Map<String, dynamic>) return null;
    return MemberSubscription.fromJson(subscription);
  }

  Future<List<MemberSubscription>> subscriptionHistory({
    String? status,
    String? paymentStatus,
    String? planId,
    String? period,
    DateTime? dateFrom,
    DateTime? dateTo,
  }) async {
    final data = await _apiClient.get(
      '/member/subscription/history',
      query: {
        if (status != null && status.isNotEmpty) 'status': status,
        if (paymentStatus != null && paymentStatus.isNotEmpty)
          'paymentStatus': paymentStatus,
        if (planId != null && planId.isNotEmpty) 'planId': planId,
        if (period != null && period.isNotEmpty) 'period': period,
        if (dateFrom != null) 'dateFrom': _dateOnly(dateFrom),
        if (dateTo != null) 'dateTo': _dateOnly(dateTo),
      },
    );
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

  Future<List<TrainingWorkout>> workouts() async {
    final data = await _apiClient.get('/member/workouts');
    return (data['workouts'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TrainingWorkout.fromJson)
        .toList();
  }

  Future<List<TrainingWorkout>> todayWorkouts() async {
    final data = await _apiClient.get('/member/workouts/today');
    final list = data['today_workouts'] as List? ?? data['workouts'] as List?;
    return (list ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TrainingWorkout.fromJson)
        .toList();
  }

  Future<TrainingWorkout> workoutDetail(String workoutId) async {
    final data = await _apiClient.get('/member/workouts/$workoutId');
    final workout = data['workout'] ?? data;
    return TrainingWorkout.fromJson(workout as Map<String, dynamic>);
  }

  Future<List<TrainingSchedule>> schedules() async {
    final data = await _apiClient.get('/member/schedules');
    return (data['schedules'] as List? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TrainingSchedule.fromJson)
        .toList();
  }

  Future<List<TrainingSchedule>> todaySchedules() async {
    final data = await _apiClient.get('/member/schedules/today');
    final list = data['today_schedules'] as List? ?? data['schedules'] as List?;
    return (list ?? [])
        .whereType<Map<String, dynamic>>()
        .map(TrainingSchedule.fromJson)
        .toList();
  }

  Future<List<StoreProduct>> storeProducts() async {
    final data = await _apiClient.get('/member/store/products');
    return _storeProductList(data);
  }

  Future<StoreProduct> storeProductDetail(String productId) async {
    final data = await _apiClient.get('/member/store/products/$productId');
    final product = data['product'] ?? data;
    return StoreProduct.fromJson(product as Map<String, dynamic>);
  }

  Future<StorePurchaseResult> purchaseStoreProduct({
    required String productId,
    required int quantity,
    required String phoneNumber,
    required String provider,
    String currency = 'USD',
  }) async {
    final data = await _apiClient.post(
      '/member/store/products/$productId/purchase',
      timeout: const Duration(seconds: 95),
      body: {
        'quantity': quantity,
        'phoneNumber': phoneNumber,
        'provider': provider,
        'currency': currency,
      },
    );
    return StorePurchaseResult.fromJson(data);
  }

  Future<List<StoreOrder>> storeOrders() async {
    final data = await _apiClient.get('/member/store/orders');
    return _storeOrderList(data);
  }

  Future<StoreOrder> storeOrderDetail(String orderId) async {
    final data = await _apiClient.get('/member/store/orders/$orderId');
    final order = data['order'] ?? data;
    return StoreOrder.fromJson(order as Map<String, dynamic>);
  }
}

List<StoreProduct> _storeProductList(Map<String, dynamic> data) {
  return (data['products'] as List? ?? data['data'] as List? ?? [])
      .whereType<Map<String, dynamic>>()
      .map(StoreProduct.fromJson)
      .toList();
}

List<StoreOrder> _storeOrderList(Map<String, dynamic> data) {
  return (data['orders'] as List? ?? data['data'] as List? ?? [])
      .whereType<Map<String, dynamic>>()
      .map(StoreOrder.fromJson)
      .toList();
}

String _dateOnly(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
