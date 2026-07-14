import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/services/study/target_sync.dart';
import 'package:uuid/uuid.dart';

class TargetService{
  final AppDatabase db = DBProvider().db;
  final Uuid _uuid = const Uuid();

 // ── TARGETS ──

// watch all subjects with their topics
Stream<List<TargetSubject>> watchAllSubjects() {
  return db.select(db.targetSubjects).watch();
}

// Get all subjects as a one-shot list
Future<List<TargetSubject>> getAllSubjects() {
  return db.select(db.targetSubjects).get();
}

// Find a subject by uuid
Future<TargetSubject?> getSubjectByUuid(String uuid) {
  return (db.select(db.targetSubjects)
        ..where((t) => t.uuid.equals(uuid)))
      .getSingleOrNull();
}

// Insert a subject with a given uuid
Future<int> insertSubject({required String uuid, required String name, DateTime? syncedAt}) async {
  return db.into(db.targetSubjects).insert(
    TargetSubjectsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      syncedAt: Value(syncedAt),
    ),
  );
}

// Update a subject's name and syncedAt
Future<void> updateSubject(int id, String name, DateTime? syncedAt) async {
  await (db.update(db.targetSubjects)..where((s) => s.id.equals(id)))
    .write(TargetSubjectsCompanion(
      name: Value(name),
      syncedAt: Value(syncedAt),
    ));
}

// watch topics for a specific subject
Stream<List<TargetTopic>> watchTopicsForSubject(int subjectId) {
  return (db.select(db.targetTopics)
        ..where((t) => t.subjectId.equals(subjectId)))
      .watch();
}

// Get topics for a subject as a one-shot list
Future<List<TargetTopic>> getTopicsForSubject(int subjectId) {
  return (db.select(db.targetTopics)
        ..where((t) => t.subjectId.equals(subjectId)))
      .get();
}

// Find a topic by uuid
Future<TargetTopic?> getTopicByUuid(String uuid) {
  return (db.select(db.targetTopics)
        ..where((t) => t.uuid.equals(uuid)))
      .getSingleOrNull();
}

// Insert a topic with a given uuid and options
Future<int> insertTopic({required String uuid, required String name, required bool isCompleted, required DateTime lastModified, required int subjectId}) async {
  return db.into(db.targetTopics).insert(
    TargetTopicsCompanion(
      uuid: Value(uuid),
      name: Value(name),
      isCompleted: Value(isCompleted),
      lastModified: Value(lastModified),
      subjectId: Value(subjectId),
    ),
  );
}

// Update a topic's name, completion status, and lastModified
Future<void> updateTopic(int id, String name, bool isCompleted, DateTime lastModified) async {
  await (db.update(db.targetTopics)..where((t) => t.id.equals(id)))
    .write(TargetTopicsCompanion(
      name: Value(name),
      isCompleted: Value(isCompleted),
      lastModified: Value(lastModified),
    ));
}

// insert a subject, returns its generated id
Future<int> addSubject(String name) async {
  final id = await db.into(db.targetSubjects).insert(
    TargetSubjectsCompanion.insert(
      uuid: _uuid.v4(),
      name: name,
    ),
  );
  syncTargetsIfSignedIn();
  return id;
}

// insert a topic under a subject
Future<int> addTopic(String name, int subjectId) async {
  final now = DateTime.now();
  final id = await db.into(db.targetTopics).insert(
    TargetTopicsCompanion.insert(
      uuid: _uuid.v4(),
      name: name,
      isCompleted: false,
      lastModified: now,
      subjectId: subjectId,
    ),
  );
  await _touchSubjectSyncedAt(subjectId);
  syncTargetsIfSignedIn();
  return id;
}

// mark a topic complete
Future markComplete(int topicId, bool completed) async {
  await (db.update(db.targetTopics)..where((t) => t.id.equals(topicId))).write(
    TargetTopicsCompanion(
      isCompleted: Value(completed),
      lastModified: Value(DateTime.now()),
    ));
  final topic = await (db.select(db.targetTopics)..where((t) => t.id.equals(topicId))).getSingle();
  await _touchSubjectSyncedAt(topic.subjectId);
  syncTargetsIfSignedIn();
}

// delete a subject and all its topics
Future deleteSubject(int subjectId) async {
  await (db.delete(db.targetTopics)
        ..where((t) => t.subjectId.equals(subjectId)))
      .go();
  await (db.delete(db.targetSubjects)
        ..where((s) => s.id.equals(subjectId)))
      .go();
  syncTargetsIfSignedIn();
}

// delete a single topic
Future deleteTopic(int topicId) async {
  final topic = await (db.select(db.targetTopics)..where((t) => t.id.equals(topicId))).getSingle();
  final subjectId = topic.subjectId;
  await (db.delete(db.targetTopics)..where((t) => t.id.equals(topicId))).go();
  await _touchSubjectSyncedAt(subjectId);
  syncTargetsIfSignedIn();
}

Future _touchSubjectSyncedAt(int subjectId) async {
  await (db.update(db.targetSubjects)..where((s) => s.id.equals(subjectId)))
    .write(TargetSubjectsCompanion(syncedAt: Value(DateTime.now())));
}
}