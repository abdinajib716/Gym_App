import '../../training/data/training_models.dart';

double _toDouble(dynamic value) {
  if (value is num) return value.toDouble();
  return double.tryParse(value?.toString() ?? '') ?? 0;
}

DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

String? _toString(dynamic value) => value?.toString();

class MemberProfile {
  const MemberProfile({
    required this.id,
    required this.fullName,
    required this.status,
    this.phoneNumber,
    this.email,
    this.gender,
    this.address,
    this.dateOfBirth,
    this.emergencyContact,
    this.profileImage,
    this.account,
  });

  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? gender;
  final String? address;
  final DateTime? dateOfBirth;
  final String? emergencyContact;
  final String? profileImage;
  final Map<String, dynamic>? account;
  final String status;

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: _toString(json['phoneNumber']),
      email: _toString(json['email']),
      gender: _toString(json['gender']),
      address: _toString(json['address']),
      dateOfBirth: _toDate(json['dateOfBirth']),
      emergencyContact: _toString(json['emergencyContact']),
      profileImage: _toString(json['profileImage']),
      account: json['account'] is Map<String, dynamic>
          ? json['account'] as Map<String, dynamic>
          : null,
      status: json['status']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (gender != null) 'gender': gender,
      if (address != null) 'address': address,
      if (dateOfBirth != null)
        'dateOfBirth':
            '${dateOfBirth!.year}-${dateOfBirth!.month.toString().padLeft(2, '0')}-${dateOfBirth!.day.toString().padLeft(2, '0')}',
      if (emergencyContact != null) 'emergencyContact': emergencyContact,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }
}

class MemberAccount {
  const MemberAccount({
    required this.accountId,
    required this.mustChangePassword,
  });

  final String accountId;
  final bool mustChangePassword;

  factory MemberAccount.fromJson(Map<String, dynamic> json) {
    return MemberAccount(
      accountId: json['accountId']?.toString() ?? '',
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }
}

class MemberSummary {
  const MemberSummary({
    required this.hasActiveSubscription,
    required this.paymentCount,
    required this.unreadNotifications,
  });

  final bool hasActiveSubscription;
  final int paymentCount;
  final int unreadNotifications;

  factory MemberSummary.fromJson(Map<String, dynamic> json) {
    return MemberSummary(
      hasActiveSubscription: json['hasActiveSubscription'] == true,
      paymentCount: (json['paymentCount'] as num?)?.toInt() ?? 0,
      unreadNotifications: (json['unreadNotifications'] as num?)?.toInt() ?? 0,
    );
  }
}

class MembershipPlan {
  const MembershipPlan({
    required this.id,
    required this.name,
    required this.type,
    required this.durationDays,
    required this.price,
    required this.currency,
    required this.status,
    this.description,
  });

  final String id;
  final String name;
  final String type;
  final int durationDays;
  final double price;
  final String currency;
  final String? description;
  final String status;

  factory MembershipPlan.fromJson(Map<String, dynamic> json) {
    return MembershipPlan(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      durationDays: (json['durationDays'] as num?)?.toInt() ?? 0,
      price: _toDouble(json['price']),
      currency: json['currency']?.toString() ?? 'USD',
      description: _toString(json['description']),
      status: json['status']?.toString() ?? '',
    );
  }
}

class MemberSubscription {
  const MemberSubscription({
    required this.id,
    required this.status,
    required this.paymentStatus,
    this.plan,
    this.startDate,
    this.expiryDate,
    this.createdAt,
  });

  final String id;
  final MembershipPlan? plan;
  final DateTime? startDate;
  final DateTime? expiryDate;
  final String status;
  final String paymentStatus;
  final DateTime? createdAt;

  factory MemberSubscription.fromJson(Map<String, dynamic> json) {
    final planJson = json['plan'];
    return MemberSubscription(
      id: json['id']?.toString() ?? '',
      plan: planJson is Map<String, dynamic>
          ? MembershipPlan.fromJson(planJson)
          : null,
      startDate: _toDate(json['startDate']),
      expiryDate: _toDate(json['expiryDate']),
      status: json['status']?.toString() ?? '',
      paymentStatus: json['paymentStatus']?.toString() ?? '',
      createdAt: _toDate(json['createdAt']),
    );
  }
}

class MemberPayment {
  const MemberPayment({
    required this.id,
    required this.amount,
    required this.method,
    required this.status,
    this.currency = 'USD',
    this.paymentType,
    this.provider,
    this.requestId,
    this.invoiceId,
    this.reference,
    this.responseMessage,
    this.failedReason,
    this.subscriptionId,
    this.paymentDate,
  });

  final String id;
  final double amount;
  final String currency;
  final String? paymentType;
  final String method;
  final String? provider;
  final String status;
  final String? requestId;
  final String? invoiceId;
  final String? reference;
  final String? responseMessage;
  final String? failedReason;
  final String? subscriptionId;
  final DateTime? paymentDate;

  factory MemberPayment.fromJson(Map<String, dynamic> json) {
    return MemberPayment(
      id: json['id']?.toString() ?? '',
      amount: _toDouble(json['amount']),
      currency: json['currency']?.toString() ?? 'USD',
      paymentType: _toString(json['paymentType']),
      method: json['method']?.toString() ?? '',
      provider: _toString(json['provider']),
      status: json['status']?.toString() ?? '',
      requestId: _toString(json['requestId']),
      invoiceId: _toString(json['invoiceId']),
      reference: _toString(json['reference']),
      responseMessage: _toString(json['responseMessage']),
      failedReason: _toString(json['failedReason']),
      subscriptionId: _toString(json['subscriptionId']),
      paymentDate: _toDate(json['paymentDate']),
    );
  }
}

class MemberNotification {
  const MemberNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.readStatus,
    this.createdAt,
  });

  final String id;
  final String title;
  final String message;
  final String type;
  final String readStatus;
  final DateTime? createdAt;

  factory MemberNotification.fromJson(Map<String, dynamic> json) {
    return MemberNotification(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      message: json['message']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      readStatus: json['readStatus']?.toString() ?? '',
      createdAt: _toDate(json['createdAt']),
    );
  }
}

class MemberDashboard {
  const MemberDashboard({
    required this.member,
    required this.account,
    required this.summary,
    this.currentSubscription,
    this.recentPayments = const [],
    this.latestNotifications = const [],
  });

  final MemberProfile member;
  final MemberAccount account;
  final MemberSummary summary;
  final MemberSubscription? currentSubscription;
  final List<MemberPayment> recentPayments;
  final List<MemberNotification> latestNotifications;

  factory MemberDashboard.fromJson(Map<String, dynamic> json) {
    final subscriptionJson = json['currentSubscription'];
    return MemberDashboard(
      member: MemberProfile.fromJson(json['member'] as Map<String, dynamic>),
      account: MemberAccount.fromJson(json['account'] as Map<String, dynamic>),
      summary: MemberSummary.fromJson(json['summary'] as Map<String, dynamic>),
      currentSubscription: subscriptionJson is Map<String, dynamic>
          ? MemberSubscription.fromJson(subscriptionJson)
          : null,
      recentPayments: (json['recentPayments'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MemberPayment.fromJson)
          .toList(),
      latestNotifications: (json['latestNotifications'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MemberNotification.fromJson)
          .toList(),
    );
  }
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

class MemberAttendanceRecord {
  const MemberAttendanceRecord({
    required this.id,
    required this.memberId,
    required this.method,
    required this.status,
    this.checkInDate,
    this.createdAt,
  });

  final String id;
  final String memberId;
  final DateTime? checkInDate;
  final String method;
  final String status;
  final DateTime? createdAt;

  factory MemberAttendanceRecord.fromJson(Map<String, dynamic> json) {
    return MemberAttendanceRecord(
      id: json['id']?.toString() ?? '',
      memberId: json['memberId']?.toString() ?? '',
      checkInDate: _toDate(json['checkInDate']),
      method: json['method']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      createdAt: _toDate(json['createdAt']),
    );
  }
}

class MemberAttendanceSummary {
  const MemberAttendanceSummary({
    required this.total,
    required this.present,
    required this.cancelled,
    this.lastCheckIn,
  });

  final int total;
  final int present;
  final int cancelled;
  final DateTime? lastCheckIn;

  factory MemberAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return MemberAttendanceSummary(
      total: _toInt(json['total']),
      present: _toInt(json['present']),
      cancelled: _toInt(json['cancelled']),
      lastCheckIn: _toDate(json['lastCheckIn']),
    );
  }
}

class MemberAttendance {
  const MemberAttendance({required this.summary, required this.records});

  final MemberAttendanceSummary summary;
  final List<MemberAttendanceRecord> records;

  factory MemberAttendance.fromJson(Map<String, dynamic> json) {
    return MemberAttendance(
      summary: MemberAttendanceSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? const {},
      ),
      records: (json['attendance'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(MemberAttendanceRecord.fromJson)
          .toList(),
    );
  }
}

class MemberProgress {
  const MemberProgress({
    this.subscription,
    required this.attendance,
    required this.training,
  });

  final MemberSubscription? subscription;
  final MemberProgressAttendance attendance;
  final MemberProgressTraining training;

  factory MemberProgress.fromJson(Map<String, dynamic> json) {
    final progress = json['progress'] as Map<String, dynamic>? ?? json;
    final subscriptionJson = progress['subscription'];

    return MemberProgress(
      subscription: subscriptionJson is Map<String, dynamic>
          ? MemberSubscription.fromJson(subscriptionJson)
          : null,
      attendance: MemberProgressAttendance.fromJson(
        progress['attendance'] as Map<String, dynamic>? ?? const {},
      ),
      training: MemberProgressTraining.fromJson(
        progress['training'] as Map<String, dynamic>? ?? const {},
      ),
    );
  }
}

class MemberProgressAttendance {
  const MemberProgressAttendance({
    required this.totalPresent,
    required this.presentInRange,
    required this.presentThisMonth,
    required this.rangeDays,
    this.lastCheckIn,
  });

  final int totalPresent;
  final int presentInRange;
  final int presentThisMonth;
  final int rangeDays;
  final MemberAttendanceRecord? lastCheckIn;

  factory MemberProgressAttendance.fromJson(Map<String, dynamic> json) {
    final lastCheckInJson = json['lastCheckIn'];

    return MemberProgressAttendance(
      totalPresent: _toInt(json['totalPresent']),
      presentInRange: _toInt(json['presentInRange']),
      presentThisMonth: _toInt(json['presentThisMonth']),
      rangeDays: _toInt(json['rangeDays']),
      lastCheckIn: lastCheckInJson is Map<String, dynamic>
          ? MemberAttendanceRecord.fromJson(lastCheckInJson)
          : null,
    );
  }
}

class MemberProgressTraining {
  const MemberProgressTraining({
    required this.activeWorkouts,
    required this.totalSchedules,
    required this.completedSchedules,
    required this.upcomingSchedules,
    required this.missedSchedules,
    required this.cancelledSchedules,
    required this.completionRate,
    this.recentCompletedSchedules = const [],
  });

  final int activeWorkouts;
  final int totalSchedules;
  final int completedSchedules;
  final int upcomingSchedules;
  final int missedSchedules;
  final int cancelledSchedules;
  final int completionRate;
  final List<TrainingSchedule> recentCompletedSchedules;

  factory MemberProgressTraining.fromJson(Map<String, dynamic> json) {
    return MemberProgressTraining(
      activeWorkouts: _toInt(json['activeWorkouts']),
      totalSchedules: _toInt(json['totalSchedules']),
      completedSchedules: _toInt(json['completedSchedules']),
      upcomingSchedules: _toInt(json['upcomingSchedules']),
      missedSchedules: _toInt(json['missedSchedules']),
      cancelledSchedules: _toInt(json['cancelledSchedules']),
      completionRate: _toInt(json['completionRate']),
      recentCompletedSchedules:
          (json['recentCompletedSchedules'] as List? ?? [])
              .whereType<Map<String, dynamic>>()
              .map(TrainingSchedule.fromJson)
              .toList(),
    );
  }
}
