import 'package:flutter_test/flutter_test.dart';
import 'package:ps_books/models/target.dart';

void main() {
  group('TargetSyncModel serialization', () {
    test('TargetTopicSync toJson and fromJson roundtrip', () {
      final now = DateTime.now();
      final original = TargetTopicSync(
        uuid: 'test-uuid-123',
        name: 'Integration by Parts',
        isCompleted: true,
        lastModified: now,
      );

      final json = original.toJson();
      final restored = TargetTopicSync.fromJson(json);

      expect(restored.uuid, original.uuid);
      expect(restored.name, original.name);
      expect(restored.isCompleted, original.isCompleted);
      expect(
        restored.lastModified.toIso8601String(),
        original.lastModified.toIso8601String(),
      );
    });

    test('TargetTopicSync fromJson parses server response correctly', () {
      final json = {
        'uuid': 'server-uuid-1',
        'name': 'Calculus',
        'isCompleted': false,
        'lastModified': '2026-06-22T10:00:00.000',
      };

      final model = TargetTopicSync.fromJson(json);
      expect(model.uuid, 'server-uuid-1');
      expect(model.name, 'Calculus');
      expect(model.isCompleted, false);
      expect(model.lastModified.year, 2026);
    });

    test('TargetSubjectSync toJson and fromJson roundtrip', () {
      final now = DateTime.now();
      final original = TargetSubjectSync(
        uuid: 'subject-uuid-1',
        name: 'Mathematics',
        syncedAt: now,
        topics: [
          TargetTopicSync(
            uuid: 'topic-uuid-1',
            name: 'Algebra',
            isCompleted: false,
            lastModified: now,
          ),
        ],
      );

      final json = original.toJson();
      final restored = TargetSubjectSync.fromJson(json);

      expect(restored.uuid, original.uuid);
      expect(restored.name, original.name);
      expect(
        restored.syncedAt?.toIso8601String(),
        original.syncedAt?.toIso8601String(),
      );
      expect(restored.topics.length, 1);
      expect(restored.topics[0].name, 'Algebra');
    });

    test('TargetSubjectSync with null syncedAt', () {
      final now = DateTime.now();
      final original = TargetSubjectSync(
        uuid: 'subject-uuid-2',
        name: 'Physics',
        syncedAt: null,
        topics: [
          TargetTopicSync(
            uuid: 'topic-uuid-2',
            name: 'Kinematics',
            isCompleted: true,
            lastModified: now,
          ),
        ],
      );

      final json = original.toJson();
      final restored = TargetSubjectSync.fromJson(json);

      expect(restored.syncedAt, isNull);
      expect(restored.topics.length, 1);
    });

    test('Empty topics list', () {
      final subject = TargetSubjectSync(
        uuid: 'empty-subject',
        name: 'Empty',
        syncedAt: DateTime.now(),
        topics: [],
      );

      final json = subject.toJson();
      final restored = TargetSubjectSync.fromJson(json);

      expect(restored.topics, isEmpty);
    });
  });

  group('TargetSyncModel JSON structure', () {
    test('toJson produces correct keys for topic', () {
      final topic = TargetTopicSync(
        uuid: 'u1',
        name: 'Topic 1',
        isCompleted: true,
        lastModified: DateTime(2026, 6, 22),
      );

      final json = topic.toJson();
      expect(json.containsKey('uuid'), true);
      expect(json.containsKey('name'), true);
      expect(json.containsKey('isCompleted'), true);
      expect(json.containsKey('lastModified'), true);
      expect(json['isCompleted'], true);
    });

    test('toJson produces correct keys for subject', () {
      final subject = TargetSubjectSync(
        uuid: 's1',
        name: 'Subject 1',
        syncedAt: DateTime(2026, 6, 22),
        topics: [],
      );

      final json = subject.toJson();
      expect(json.containsKey('uuid'), true);
      expect(json.containsKey('name'), true);
      expect(json.containsKey('syncedAt'), true);
      expect(json.containsKey('topics'), true);
      expect(json['topics'] is List, true);
    });
  });
}
