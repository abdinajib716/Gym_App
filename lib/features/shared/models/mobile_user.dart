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
  });

  final String id;
  final String accountId;
  final MobileRole role;
  final String name;
  final String? email;
  final String? phone;
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
      accountStatus: json['accountStatus']?.toString() ?? '',
      mustChangePassword: json['mustChangePassword'] == true,
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
      'accountStatus': accountStatus,
      'mustChangePassword': mustChangePassword,
    };
  }

  static MobileRole _parseRole(String? role) {
    return role == 'TRAINER' ? MobileRole.trainer : MobileRole.member;
  }
}
