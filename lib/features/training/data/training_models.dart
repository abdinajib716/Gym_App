DateTime? _toDate(dynamic value) {
  if (value == null) return null;
  return DateTime.tryParse(value.toString());
}

int _toInt(dynamic value) {
  if (value is num) return value.toInt();
  return int.tryParse(value?.toString() ?? '') ?? 0;
}

String? _toString(dynamic value) => value?.toString();

class MobileTrainerSummary {
  const MobileTrainerSummary({required this.id, required this.fullName});

  final String id;
  final String fullName;

  factory MobileTrainerSummary.fromJson(Map<String, dynamic> json) {
    return MobileTrainerSummary(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
    );
  }
}

class TrainingSchedule {
  const TrainingSchedule({
    required this.id,
    required this.status,
    this.date,
    this.startTime,
    this.endTime,
    this.notes,
    this.workout,
    this.trainer,
    this.targetName,
  });

  final String id;
  final DateTime? date;
  final String? startTime;
  final String? endTime;
  final String? notes;
  final String status;
  final TrainingWorkout? workout;
  final MobileTrainerSummary? trainer;
  final String? targetName;

  factory TrainingSchedule.fromJson(Map<String, dynamic> json) {
    final workoutJson = json['workout'];
    final trainerJson = json['trainer'];
    final memberJson = json['member'];
    final groupJson = json['group'];

    return TrainingSchedule(
      id: json['id']?.toString() ?? '',
      date: _toDate(json['date']),
      startTime: _toString(json['startTime'] ?? json['start_time']),
      endTime: _toString(json['endTime'] ?? json['end_time']),
      notes: _toString(json['notes']),
      status: json['status']?.toString() ?? '',
      workout: workoutJson is Map<String, dynamic>
          ? TrainingWorkout.fromJson(workoutJson)
          : null,
      trainer: trainerJson is Map<String, dynamic>
          ? MobileTrainerSummary.fromJson(trainerJson)
          : null,
      targetName: _targetName(memberJson, groupJson),
    );
  }
}

class TrainingWorkout {
  const TrainingWorkout({
    required this.id,
    required this.title,
    this.description,
    this.image,
    this.sets,
    this.reps,
    this.durationMinutes,
    this.difficulty,
    this.category,
    this.status,
    this.schedule,
    this.trainer,
    this.targetName,
  });

  final String id;
  final String title;
  final String? description;
  final String? image;
  final int? sets;
  final int? reps;
  final int? durationMinutes;
  final String? difficulty;
  final String? category;
  final String? status;
  final TrainingSchedule? schedule;
  final MobileTrainerSummary? trainer;
  final String? targetName;

  factory TrainingWorkout.fromJson(Map<String, dynamic> json) {
    final scheduleJson = json['schedule'];
    final trainerJson = json['trainer'];
    final memberJson = json['member'];
    final groupJson = json['group'];

    return TrainingWorkout(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      description: _toString(json['description']),
      image: _toString(json['image']),
      sets: json.containsKey('sets') ? _toInt(json['sets']) : null,
      reps: json.containsKey('reps') ? _toInt(json['reps']) : null,
      durationMinutes:
          json.containsKey('durationMinutes') ||
              json.containsKey('duration_minutes')
          ? _toInt(json['durationMinutes'] ?? json['duration_minutes'])
          : null,
      difficulty: _toString(json['difficulty']),
      category: _toString(json['category']),
      status: _toString(json['status']),
      schedule: scheduleJson is Map<String, dynamic>
          ? TrainingSchedule.fromJson(scheduleJson)
          : null,
      trainer: trainerJson is Map<String, dynamic>
          ? MobileTrainerSummary.fromJson(trainerJson)
          : null,
      targetName: _targetName(memberJson, groupJson),
    );
  }
}

String? _targetName(dynamic memberJson, dynamic groupJson) {
  if (memberJson is Map<String, dynamic>) {
    return memberJson['fullName']?.toString() ?? memberJson['name']?.toString();
  }

  if (groupJson is Map<String, dynamic>) {
    return groupJson['name']?.toString() ?? groupJson['title']?.toString();
  }

  return null;
}
