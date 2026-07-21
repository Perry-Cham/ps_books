class TargetSubjectSync {
  final String uuid;
  final String name;
  final DateTime? syncedAt;
  final DateTime? deadline;
  final int? deadlineOriginalDays;
  final List<TargetTopicSync> topics;

  TargetSubjectSync({
    required this.uuid,
    required this.name,
    this.syncedAt,
    this.deadline,
    this.deadlineOriginalDays,
    required this.topics,
  });

  factory TargetSubjectSync.fromJson(Map<String, dynamic> json) {
    return TargetSubjectSync(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      syncedAt: json['syncedAt'] != null
          ? DateTime.parse(json['syncedAt'] as String)
          : null,
      deadline: json['deadline'] != null
          ? DateTime.parse(json['deadline'] as String)
          : null,
      deadlineOriginalDays: json['deadlineOriginalDays'] as int?,
      topics: (json['topics'] as List)
          .map((t) => TargetTopicSync.fromJson(t))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'syncedAt': syncedAt?.toIso8601String(),
      'deadline': deadline?.toIso8601String(),
      'deadlineOriginalDays': deadlineOriginalDays,
      'topics': topics.map((t) => t.toJson()).toList(),
    };
  }
}

class TargetTopicSync {
  final String uuid;
  final String name;
  final bool isCompleted;
  final DateTime lastModified;

  TargetTopicSync({
    required this.uuid,
    required this.name,
    required this.isCompleted,
    required this.lastModified,
  });

  factory TargetTopicSync.fromJson(Map<String, dynamic> json) {
    return TargetTopicSync(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      isCompleted: json['isCompleted'] as bool,
      lastModified: DateTime.parse(json['lastModified'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'isCompleted': isCompleted,
      'lastModified': lastModified.toIso8601String(),
    };
  }
}
