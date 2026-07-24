import '../../member/data/member_models.dart';
import '../../training/data/training_models.dart';

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _toString(dynamic value) => value?.toString();

class TrainerProfile {
  const TrainerProfile({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.gender,
    this.specialty,
    this.availability,
    this.profileImage,
    this.status,
  });

  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? gender;
  final String? specialty;
  final String? availability;
  final String? profileImage;
  final String? status;

  factory TrainerProfile.fromJson(Map<String, dynamic> json) {
    return TrainerProfile(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      phoneNumber: _toString(json['phoneNumber'] ?? json['phone']),
      email: _toString(json['email']),
      gender: _toString(json['gender']),
      specialty: _toString(json['specialty']),
      availability: _toString(json['availability']),
      profileImage: _toString(json['profileImage']),
      status: _toString(json['status']),
    );
  }

  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (email != null) 'email': email,
      if (gender != null) 'gender': gender,
      if (specialty != null) 'specialty': specialty,
      if (availability != null) 'availability': availability,
      if (profileImage != null) 'profileImage': profileImage,
    };
  }
}

class TrainerKpis {
  const TrainerKpis({
    required this.totalMembers,
    required this.totalGroups,
    required this.todaySessions,
    required this.upcomingSessions,
    required this.completedSessions,
    required this.missedSessions,
  });

  final int totalMembers;
  final int totalGroups;
  final int todaySessions;
  final int upcomingSessions;
  final int completedSessions;
  final int missedSessions;

  factory TrainerKpis.fromJson(Map<String, dynamic> json) {
    return TrainerKpis(
      totalMembers: _toInt(json['total_members'] ?? json['totalMembers']),
      totalGroups: _toInt(json['total_groups'] ?? json['totalGroups']),
      todaySessions: _toInt(json['today_sessions'] ?? json['todaySessions']),
      upcomingSessions: _toInt(
        json['upcoming_sessions'] ?? json['upcomingSessions'],
      ),
      completedSessions: _toInt(
        json['completed_sessions'] ?? json['completedSessions'],
      ),
      missedSessions: _toInt(json['missed_sessions'] ?? json['missedSessions']),
    );
  }
}

class TrainerMember {
  const TrainerMember({
    required this.id,
    required this.fullName,
    this.phoneNumber,
    this.email,
    this.profileImage,
    this.status,
  });

  final String id;
  final String fullName;
  final String? phoneNumber;
  final String? email;
  final String? profileImage;
  final String? status;

  factory TrainerMember.fromJson(Map<String, dynamic> json) {
    return TrainerMember(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      phoneNumber: _toString(json['phoneNumber'] ?? json['phone']),
      email: _toString(json['email']),
      profileImage: _toString(json['profileImage']),
      status: _toString(json['status']),
    );
  }
}

class TrainerMemberDetail {
  const TrainerMemberDetail({
    required this.member,
    this.progress,
    this.subscriptionHistory = const [],
    this.recentAttendance = const [],
    this.recentWorkouts = const [],
    this.recentSchedules = const [],
    this.groupMemberships = const [],
  });

  final TrainerMember member;
  final MemberProgress? progress;
  final List<Map<String, dynamic>> subscriptionHistory;
  final List<Map<String, dynamic>> recentAttendance;
  final List<TrainingWorkout> recentWorkouts;
  final List<TrainingSchedule> recentSchedules;
  final List<TrainerGroup> groupMemberships;

  factory TrainerMemberDetail.fromJson(Map<String, dynamic> json) {
    final memberJson = json['member'] is Map<String, dynamic>
        ? json['member'] as Map<String, dynamic>
        : json;
    final progressJson = json['progress'];

    return TrainerMemberDetail(
      member: TrainerMember.fromJson(memberJson),
      progress: progressJson is Map<String, dynamic>
          ? MemberProgress.fromJson(progressJson)
          : null,
      subscriptionHistory: _mapList(json['subscriptionHistory']),
      recentAttendance: _mapList(json['recentAttendance']),
      recentWorkouts: (json['recentWorkouts'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TrainingWorkout.fromJson)
          .toList(),
      recentSchedules: (json['recentSchedules'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TrainingSchedule.fromJson)
          .toList(),
      groupMemberships: (json['groupMemberships'] as List? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(TrainerGroup.fromJson)
          .toList(),
    );
  }
}

class TrainerGroup {
  const TrainerGroup({
    required this.id,
    required this.name,
    this.description,
    this.trainingDays,
    this.trainingTime,
    this.status,
    this.memberCount,
  });

  final String id;
  final String name;
  final String? description;
  final String? trainingDays;
  final String? trainingTime;
  final String? status;
  final int? memberCount;

  factory TrainerGroup.fromJson(Map<String, dynamic> json) {
    return TrainerGroup(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      description: _toString(json['description']),
      trainingDays: _toString(json['trainingDays'] ?? json['training_days']),
      trainingTime: _toString(json['trainingTime'] ?? json['training_time']),
      status: _toString(json['status']),
      memberCount: json.containsKey('memberCount')
          ? _toInt(json['memberCount'])
          : json.containsKey('_count') && json['_count'] is Map<String, dynamic>
          ? _toInt((json['_count'] as Map<String, dynamic>)['members'])
          : null,
    );
  }
}

class TrainerDashboard {
  const TrainerDashboard({
    required this.welcome,
    required this.trainer,
    required this.kpis,
    this.recentMembers = const [],
    this.todaySchedule = const [],
  });

  final String welcome;
  final TrainerProfile trainer;
  final TrainerKpis kpis;
  final List<TrainerMember> recentMembers;
  final List<TrainingSchedule> todaySchedule;

  factory TrainerDashboard.fromJson(Map<String, dynamic> json) {
    return TrainerDashboard(
      welcome: json['welcome']?.toString() ?? '',
      trainer: TrainerProfile.fromJson(
        json['trainer'] as Map<String, dynamic>? ?? const {},
      ),
      kpis: TrainerKpis.fromJson(
        json['kpis'] as Map<String, dynamic>? ?? const {},
      ),
      recentMembers:
          (json['recent_members'] as List? ??
                  json['recentMembers'] as List? ??
                  [])
              .whereType<Map<String, dynamic>>()
              .map(TrainerMember.fromJson)
              .toList(),
      todaySchedule:
          (json['today_schedule'] as List? ??
                  json['todaySchedule'] as List? ??
                  [])
              .whereType<Map<String, dynamic>>()
              .map(TrainingSchedule.fromJson)
              .toList(),
    );
  }
}

class TrainerAttendanceSummary {
  const TrainerAttendanceSummary({
    required this.period,
    required this.summary,
    required this.attendance,
  });

  final String period;
  final Map<String, dynamic> summary;
  final List<Map<String, dynamic>> attendance;

  factory TrainerAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return TrainerAttendanceSummary(
      period: json['period']?.toString() ?? '',
      summary: json['summary'] is Map<String, dynamic>
          ? json['summary'] as Map<String, dynamic>
          : const {},
      attendance: _mapList(json['attendance']),
    );
  }
}

class TrainerUpload {
  const TrainerUpload({required this.url, required this.fileName});

  final String url;
  final String fileName;

  factory TrainerUpload.fromJson(Map<String, dynamic> json) {
    return TrainerUpload(
      url: json['url']?.toString() ?? '',
      fileName:
          json['fileName']?.toString() ?? json['file_name']?.toString() ?? '',
    );
  }
}

Map<String, dynamic> workoutPayload({
  String? memberId,
  String? groupId,
  required String title,
  String? description,
  String? image,
  int? sets,
  int? reps,
  int? durationMinutes,
  String difficulty = 'BEGINNER',
  String? category,
  String status = 'ACTIVE',
}) {
  return {
    if (memberId != null) 'memberId': memberId,
    if (groupId != null) 'groupId': groupId,
    'title': title,
    if (description != null) 'description': description,
    if (image != null) 'image': image,
    if (sets != null) 'sets': sets,
    if (reps != null) 'reps': reps,
    if (durationMinutes != null) 'durationMinutes': durationMinutes,
    'difficulty': difficulty,
    if (category != null) 'category': category,
    'status': status,
  };
}

Map<String, dynamic> schedulePayload({
  String? memberId,
  String? groupId,
  required String workoutId,
  required String date,
  required String startTime,
  required String endTime,
  String? notes,
  String status = 'UPCOMING',
}) {
  return {
    if (memberId != null) 'memberId': memberId,
    if (groupId != null) 'groupId': groupId,
    'workoutId': workoutId,
    'date': date,
    'startTime': startTime,
    'endTime': endTime,
    if (notes != null) 'notes': notes,
    'status': status,
  };
}

List<Map<String, dynamic>> _mapList(dynamic value) {
  return (value as List? ?? []).whereType<Map<String, dynamic>>().toList();
}
