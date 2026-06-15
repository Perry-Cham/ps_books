class TimetableModel {
  final int version;
  final DateTime lastModified;
  final List<DayData> days;

  TimetableModel({
    required this.version,
    required this.lastModified,
    required this.days,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      version: json['version'] as int,
      lastModified: DateTime.parse(json['lastModified'] as String),
      days: (json['days'] as List).map((d) => DayData.fromJson(d)).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'version': version,
      'lastModified': lastModified.toIso8601String(),
      'days': days.map((d) => d.toJson()).toList(),
    };
  }
}

class DayData {
  final String day;
  final bool isBreakDay;
  final List<SessionData> sessions;

  DayData({
    required this.day,
    required this.isBreakDay,
    required this.sessions,
  });

  factory DayData.fromJson(Map<String, dynamic> json) {
    return DayData(
      day: json['day'] as String,
      isBreakDay: json['isBreakDay'] as bool,
      sessions: (json['sessions'] as List)
          .map((s) => SessionData.fromJson(s))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'isBreakDay': isBreakDay,
      'sessions': sessions.map((s) => s.toJson()).toList(),
    };
  }
}

class SessionData {
  final String start;
  final String end;
  final String subjects;

  SessionData({
    required this.start,
    required this.end,
    required this.subjects,
  });

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      start: json['start'] as String,
      end: json['end'] as String,
      subjects: json['subjects'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'start': start,
      'end': end,
      'subjects': subjects,
    };
  }
}
