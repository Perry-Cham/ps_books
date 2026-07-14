import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/dbServices/target.dart';
import 'package:ps_books/state/connectivity_provider.dart';
import 'package:ps_books/models/target.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> syncTargetsIfSignedIn() async {
  if (!await hasInternet()) return;
  final prefs = await SharedPreferences.getInstance();
  final isSignedIn = prefs.getBool('ps_signed_in') ?? false;
  if (isSignedIn) {
    await TargetSyncingService().sync();
  }
}

class TargetSyncingService {
  final String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');
  final Dio _dio = Dio();
  final TargetService _dbService = TargetService();

  TargetSyncingService();

  Future<void> sync() async {
    try {
      await _pullTargets();
      await _pushTargets();
    } catch (e) {
      print('Target sync failed: $e');
    }
  }

  Future<void> _pullTargets() async {
    final db = DBProvider().db;
    final subjects = await db.select(db.targetSubjects).get();

    DateTime? latestSyncedAt;
    for (final s in subjects) {
      if (s.syncedAt != null && (latestSyncedAt == null || s.syncedAt!.isAfter(latestSyncedAt))) {
        latestSyncedAt = s.syncedAt;
      }
    }

    final timestamp = latestSyncedAt?.toIso8601String() ?? '';
    final response = await _dio.get('$baseUrl/get_targets', queryParameters: {
      if (timestamp.isNotEmpty) 'timestamp': timestamp,
    });

    if (response.statusCode == 200 && response.data is List) {
      final remoteSubjects = (response.data as List)
          .map((j) => TargetSubjectSync.fromJson(j))
          .toList();

      for (final remote in remoteSubjects) {
        final localSubject = subjects.where((s) => s.uuid == remote.uuid).firstOrNull;

        int subjectId;
        if (localSubject != null) {
          await (db.update(db.targetSubjects)..where((s) => s.id.equals(localSubject.id))).write(
            TargetSubjectsCompanion(
              name: Value(remote.name),
              syncedAt: Value(remote.syncedAt),
            ),
          );
          subjectId = localSubject.id;
        } else {
          subjectId = await db.into(db.targetSubjects).insert(
            TargetSubjectsCompanion(
              uuid: Value(remote.uuid),
              name: Value(remote.name),
              syncedAt: Value(remote.syncedAt),
            ),
          );
        }

        for (final topic in remote.topics) {
          final existingTopic = await (db.select(db.targetTopics)
            ..where((t) => t.uuid.equals(topic.uuid)))
            .getSingleOrNull();

          if (existingTopic != null) {
            await (db.update(db.targetTopics)..where((t) => t.uuid.equals(topic.uuid))).write(
              TargetTopicsCompanion(
                name: Value(topic.name),
                isCompleted: Value(topic.isCompleted),
                lastModified: Value(topic.lastModified),
              ),
            );
          } else {
            await db.into(db.targetTopics).insert(
              TargetTopicsCompanion(
                uuid: Value(topic.uuid),
                name: Value(topic.name),
                isCompleted: Value(topic.isCompleted),
                lastModified: Value(topic.lastModified),
                subjectId: Value(subjectId),
              ),
            );
          }
        }
      }
    }
  }

  Future<void> _pushTargets() async {
    final db = DBProvider().db;
    final subjects = await db.select(db.targetSubjects).get();

    final subjectsToSync = <TargetSubjectSync>[];

    for (final subject in subjects) {
      final syncedAt = subject.syncedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final topics = await (db.select(db.targetTopics)
        ..where((t) => t.subjectId.equals(subject.id))
        ..where((t) => t.lastModified.isBiggerThanValue(syncedAt)))
        .get();

      if (topics.isNotEmpty) {
        subjectsToSync.add(
          TargetSubjectSync(
            uuid: subject.uuid,
            name: subject.name,
            syncedAt: subject.syncedAt,
            topics: topics.map((t) => TargetTopicSync(
              uuid: t.uuid,
              name: t.name,
              isCompleted: t.isCompleted,
              lastModified: t.lastModified,
            )).toList(),
          ),
        );
      }
    }

    if (subjectsToSync.isNotEmpty) {
      await _dio.post('$baseUrl/sync_targets', data: subjectsToSync.map((s) => s.toJson()).toList());
    }
  }
}
