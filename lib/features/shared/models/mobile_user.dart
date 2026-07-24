enum MobileRole { member, trainer }

class MobileUser {
  const MobileUser({
    required this.id,
    required this.accountId,
    required this.role,
    required this.name,
    required this.accountStatus,
    required this.mustChangePassword,
    this.email,
    this.phone,
    this.profileImage,
  });

  final String id;
  final String accountId;
  final MobileRole role;
  final String name;
  final String? email;
  final String? phone;
  final String? profileImage;
  final String accountStatus;
  final bool mustChangePassword;

  factory MobileUser.fromJson(Map<String, dynamic> json) {
    return MobileUser(
      id: json['id']?.toString() ?? '',
      accountId: json['accountId']?.toString() ?? '',
      role: _parseRole(json['role']?.toString()),
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      accountStatus: json['accountStatus']?.toString() ?? '',
      mustChangePassword: json['mustChangePassword'] == true,
    );
  }

  factory MobileUser.trainerFromJson(
    Map<String, dynamic> json, {
    String? accountId,
    String? accountStatus,
    bool mustChangePassword = false,
  }) {
    return MobileUser(
      id: json['id']?.toString() ?? '',
      accountId: accountId ?? json['accountId']?.toString() ?? '',
      role: MobileRole.trainer,
      name: json['name']?.toString() ?? json['fullName']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString() ?? json['phoneNumber']?.toString(),
      profileImage: json['profileImage']?.toString(),
      accountStatus:
          accountStatus ?? json['accountStatus']?.toString() ?? 'ACTIVE',
      mustChangePassword:
          mustChangePassword || json['mustChangePassword'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'accountId': accountId,
      'role': role.name.toUpperCase(),
      'name': name,
      'email': email,
      'phone': phone,
      'profileImage': profileImage,
      'accountStatus': accountStatus,
      'mustChangePassword': mustChangePassword,
    };
  }

  MobileUser copyWith({
    String? id,
    String? accountId,
    MobileRole? role,
    String? name,
    String? email,
    String? phone,
    String? profileImage,
    String? accountStatus,
    bool? mustChangePassword,
  }) {
    return MobileUser(
      id: id ?? this.id,
      accountId: accountId ?? this.accountId,
      role: role ?? this.role,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      profileImage: profileImage ?? this.profileImage,
      accountStatus: accountStatus ?? this.accountStatus,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
    );
  }

  static MobileRole _parseRole(String? role) {
    return role == 'TRAINER' ? MobileRole.trainer : MobileRole.member;
  }
}
