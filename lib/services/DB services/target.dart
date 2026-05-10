import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';

class TargetService{
  final AppDatabase db = DBProvider().db;

 // ── TARGETS ──

// watch all subjects with their topics
Stream<List<TargetSubject>> watchAllSubjects() {
  return db.select(db.targetSubjects).watch();
}

// watch topics for a specific subject
Stream<List<TargetTopic>> watchTopicsForSubject(int subjectId) {
  return (db.select(db.targetTopics)
        ..where((t) => t.subjectId.equals(subjectId)))
      .watch();
}

// insert a subject, returns its generated id
Future<int> addSubject(String name) {
  return db.into(db.targetSubjects).insert(
    TargetSubjectsCompanion.insert(name: name),
  );
}

// insert a topic under a subject
Future<int> addTopic(String name, int subjectId) {
  return db.into(db.targetTopics).insert(
    TargetTopicsCompanion.insert(
      name: name,
      isCompleted: false,
      subjectId: subjectId,
    ),
  );
}

// mark a topic complete
Future markComplete(int topicId, bool completed) {
  return (db.update(db.targetTopics)..where((t) => t.id.equals(topicId))).write(
    TargetTopicsCompanion(isCompleted: Value(completed)));
}

// delete a subject and all its topics
Future deleteSubject(int subjectId) async {
  await (db.delete(db.targetTopics)
        ..where((t) => t.subjectId.equals(subjectId)))
      .go();
  await (db.delete(db.targetSubjects)
        ..where((s) => s.id.equals(subjectId)))
      .go();
}

// delete a single topic
Future deleteTopic(int topicId) {
  return (db.delete(db.targetTopics)..where((t) => t.id.equals(topicId))).go();
}


}