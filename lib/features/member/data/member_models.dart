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
  });

  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String status;

  factory MemberProfile.fromJson(Map<String, dynamic> json) {
    return MemberProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? '',
      phoneNumber: _toString(json['phoneNumber']),
      email: _toString(json['email']),
      status: json['status']?.toString() ?? '',
    );
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
