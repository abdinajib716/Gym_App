import 'dart:typed_data';

import '../../../core/api/api_client.dart';
import '../../member/data/member_models.dart';
import '../../store/data/store_models.dart';
import '../../training/data/training_models.dart';
import 'trainer_models.dart';

class TrainerApi {
  TrainerApi(this._apiClient);

  final ApiClient _apiClient;

  Future<TrainerDashboard> dashboard() async {
    final data = await _apiClient.get('/trainer/dashboard');
    return TrainerDashboard.fromJson(data);
  }

  Future<TrainerProfile> profile() async {
    final data = await _apiClient.get('/trainer/profile');
    final trainer = data['trainer'] ?? data['profile'] ?? data;
    return TrainerProfile.fromJson(trainer as Map<String, dynamic>);
  }

  Future<TrainerProfile> updateProfile(TrainerProfile profile) async {
    final data = await _apiClient.put(
      '/trainer/profile',
      body: profile.toUpdateJson(),
    );
    final trainer = data['trainer'] ?? data['profile'] ?? data;
    return TrainerProfile.fromJson(trainer as Map<String, dynamic>);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await _apiClient.post(
      '/trainer/auth/change-password',
      body: {'currentPassword': currentPassword, 'newPassword': newPassword},
    );
  }

  Future<List<TrainerMember>> members({String? search}) async {
    final data = await _apiClient.get(
      '/trainer/members',
      query: {if (search != null && search.trim().isNotEmpty) 'search': search},
    );
    return _listFrom(data, const [
      'members',
      'assignedMembers',
      'assigned_members',
      'recent_members',
      'recentMembers',
      'data',
      'items',
    ]).whereType<Map<String, dynamic>>().map(TrainerMember.fromJson).toList();
  }

  Future<TrainerMemberDetail> memberDetail(String memberId) async {
    final data = await _apiClient.get('/trainer/members/$memberId');
    return TrainerMemberDetail.fromJson(data);
  }

  Future<MemberAttendance> memberAttendance(
    String memberId, {
    String period = 'monthly',
    DateTime? dateFrom,
    DateTime? dateTo,
    int? limit,
  }) async {
    final data = await _apiClient.get(
      '/trainer/members/$memberId/attendance',
      query: {
        'period': period,
        if (dateFrom != null) 'dateFrom': _dateOnly(dateFrom),
        if (dateTo != null) 'dateTo': _dateOnly(dateTo),
        if (limit != null) 'limit': limit,
      },
    );
    return MemberAttendance.fromJson(data);
  }

  Future<List<TrainingWorkout>> memberWorkouts(String memberId) async {
    final data = await _apiClient.get('/trainer/members/$memberId/workouts');
    return _workoutList(data);
  }

  Future<List<TrainingSchedule>> memberSchedules(String memberId) async {
    final data = await _apiClient.get('/trainer/members/$memberId/schedules');
    return _scheduleList(data);
  }

  Future<List<TrainerGroup>> groups() async {
    final data = await _apiClient.get('/trainer/groups');
    return _listFrom(data, const [
      'groups',
      'trainerGroups',
      'data',
      'items',
    ]).whereType<Map<String, dynamic>>().map(TrainerGroup.fromJson).toList();
  }

  Future<TrainerGroup> groupDetail(String groupId) async {
    final data = await _apiClient.get('/trainer/groups/$groupId');
    final group = data['group'] ?? data;
    return TrainerGroup.fromJson(group as Map<String, dynamic>);
  }

  Future<TrainerGroup> createGroup(Map<String, dynamic> body) async {
    final data = await _apiClient.post('/trainer/groups', body: body);
    final group = data['group'] ?? data;
    return TrainerGroup.fromJson(group as Map<String, dynamic>);
  }

  Future<TrainerGroup> updateGroup(
    String groupId,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.put('/trainer/groups/$groupId', body: body);
    final group = data['group'] ?? data;
    return TrainerGroup.fromJson(group as Map<String, dynamic>);
  }

  Future<void> deleteGroup(String groupId) async {
    await _apiClient.delete('/trainer/groups/$groupId');
  }

  Future<List<TrainerMember>> groupMembers(String groupId) async {
    final data = await _apiClient.get('/trainer/groups/$groupId/members');
    return _listFrom(data, const [
      'members',
      'groupMembers',
      'data',
      'items',
    ]).whereType<Map<String, dynamic>>().map(TrainerMember.fromJson).toList();
  }

  Future<void> addGroupMembers(String groupId, List<String> memberIds) async {
    await _apiClient.post(
      '/trainer/groups/$groupId/members',
      body: {'memberIds': memberIds},
    );
  }

  Future<void> removeGroupMember(String groupId, String memberId) async {
    await _apiClient.delete(
      '/trainer/groups/$groupId/members',
      body: {'memberId': memberId},
    );
  }

  Future<List<TrainingWorkout>> groupWorkouts(String groupId) async {
    final data = await _apiClient.get('/trainer/groups/$groupId/workouts');
    return _workoutList(data);
  }

  Future<List<TrainingSchedule>> groupSchedules(String groupId) async {
    final data = await _apiClient.get('/trainer/groups/$groupId/schedules');
    return _scheduleList(data);
  }

  Future<TrainerAttendanceSummary> attendanceSummary(String period) async {
    final data = await _apiClient.get('/trainer/attendance/$period');
    return TrainerAttendanceSummary.fromJson(data);
  }

  Future<TrainerUpload> uploadImage({
    required Uint8List bytes,
    required String fileName,
  }) async {
    final data = await _apiClient.multipartPostBytes(
      '/trainer/uploads/image',
      fieldName: 'file',
      fileName: fileName,
      bytes: bytes,
    );
    return TrainerUpload.fromJson(data);
  }

  Future<List<TrainingWorkout>> workouts() async {
    final data = await _apiClient.get('/trainer/workouts');
    return _workoutList(data);
  }

  Future<TrainingWorkout> createWorkout(Map<String, dynamic> body) async {
    final data = await _apiClient.post('/trainer/workouts', body: body);
    return _workoutFromResponse(data);
  }

  Future<TrainingWorkout> workoutDetail(String workoutId) async {
    final data = await _apiClient.get('/trainer/workouts/$workoutId');
    return _workoutFromResponse(data);
  }

  Future<TrainingWorkout> updateWorkout(
    String workoutId,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.put(
      '/trainer/workouts/$workoutId',
      body: body,
    );
    return _workoutFromResponse(data);
  }

  Future<void> deleteWorkout(String workoutId) async {
    await _apiClient.delete('/trainer/workouts/$workoutId');
  }

  Future<void> assignWorkoutToMember(String workoutId, String memberId) async {
    await _apiClient.post(
      '/trainer/workouts/$workoutId/assign-member',
      body: {'memberId': memberId},
    );
  }

  Future<void> assignWorkoutToGroup(String workoutId, String groupId) async {
    await _apiClient.post(
      '/trainer/workouts/$workoutId/assign-group',
      body: {'groupId': groupId},
    );
  }

  Future<List<TrainingSchedule>> schedules({String? date}) async {
    final data = await _apiClient.get(
      '/trainer/schedules',
      query: {if (date != null && date.isNotEmpty) 'date': date},
    );
    return _scheduleList(data);
  }

  Future<TrainingSchedule> createSchedule(Map<String, dynamic> body) async {
    final data = await _apiClient.post('/trainer/schedules', body: body);
    return _scheduleFromResponse(data);
  }

  Future<TrainingSchedule> scheduleDetail(String scheduleId) async {
    final data = await _apiClient.get('/trainer/schedules/$scheduleId');
    return _scheduleFromResponse(data);
  }

  Future<TrainingSchedule> updateSchedule(
    String scheduleId,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.put(
      '/trainer/schedules/$scheduleId',
      body: body,
    );
    return _scheduleFromResponse(data);
  }

  Future<void> deleteSchedule(String scheduleId) async {
    await _apiClient.delete('/trainer/schedules/$scheduleId');
  }

  Future<void> completeSchedule(String scheduleId) async {
    await _apiClient.post('/trainer/schedules/$scheduleId/complete');
  }

  Future<void> cancelSchedule(String scheduleId) async {
    await _apiClient.post('/trainer/schedules/$scheduleId/cancel');
  }

  Future<List<StoreProduct>> storeProducts() async {
    final data = await _apiClient.get('/trainer/store/products');
    return _storeProductList(data);
  }

  Future<StoreProduct> storeProductDetail(String productId) async {
    final data = await _apiClient.get('/trainer/store/products/$productId');
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
      '/trainer/store/products/$productId/purchase',
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
    final data = await _apiClient.get('/trainer/store/orders');
    return _storeOrderList(data);
  }

  Future<StoreOrder> storeOrderDetail(String orderId) async {
    final data = await _apiClient.get('/trainer/store/orders/$orderId');
    final order = data['order'] ?? data;
    return StoreOrder.fromJson(order as Map<String, dynamic>);
  }

  TrainingWorkout _workoutFromResponse(Map<String, dynamic> data) {
    final workout = data['workout'] ?? data;
    return TrainingWorkout.fromJson(workout as Map<String, dynamic>);
  }

  TrainingSchedule _scheduleFromResponse(Map<String, dynamic> data) {
    final schedule = data['schedule'] ?? data;
    return TrainingSchedule.fromJson(schedule as Map<String, dynamic>);
  }

  List<TrainingWorkout> _workoutList(Map<String, dynamic> data) {
    return _listFrom(data, const [
      'workouts',
      'recentWorkouts',
      'memberWorkouts',
      'groupWorkouts',
      'data',
      'items',
    ]).whereType<Map<String, dynamic>>().map(TrainingWorkout.fromJson).toList();
  }

  List<TrainingSchedule> _scheduleList(Map<String, dynamic> data) {
    return _listFrom(data, const [
          'schedules',
          'today_schedule',
          'todaySchedule',
          'recentSchedules',
          'memberSchedules',
          'groupSchedules',
          'data',
          'items',
        ])
        .whereType<Map<String, dynamic>>()
        .map(TrainingSchedule.fromJson)
        .toList();
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

List<dynamic> _listFrom(Map<String, dynamic> data, List<String> keys) {
  for (final key in keys) {
    final value = data[key];
    if (value is List) return value;
  }
  return const [];
}

String _dateOnly(DateTime date) {
  return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
}
