import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/routes/study%20route%20comp/timetable.dart';

class Timetabletodb {
  final _db = DBProvider().db;
  List<Day>? Timetable;

  insertTimetable(List<Day> timetable) async {
    for (var day in timetable) {
      int dayId = await (_db
          .into(_db.timetableDays)
          .insert(
            TimetableDaysCompanion(
              day: Value(day.day),
              isBreakDay: Value(day.isBreak),
            ),
          ));
      print(day.isBreak);
      print('inserted day');
      if (day.isBreak == true) continue;

      for (var session in day.sessions) {
        print('inserting session');
        await (_db
            .into(_db.timetableSessions)
            .insert(
              TimetableSessionsCompanion(
                dayId: Value(dayId),
                start: Value(session.start!),
                end: Value(session.end!),
                subjects: Value(session.subjects.join(',')),
              ),
            ));
        print('inserted session');
      }
    }
  }

  Stream<List<TimeTable>> getTimeTable() {
    //otherwise join the days and sessions then return the data
    var query = _db.select(_db.timetableDays).join([
      leftOuterJoin(
        _db.timetableSessions,
        _db.timetableSessions.dayId.equalsExp(_db.timetableDays.id),
      ),
    ]);

    return query.watch().map((List<TypedResult> rows) {
      var results = <TimetableDay, List<TimetableSession>>{};
      for (var row in rows) {
        var day = row.readTable(_db.timetableDays);
        var session = row.readTableOrNull(_db.timetableSessions);

        var list = results.putIfAbsent(day, () => []);

        if (session != null) {
          list.add(session);
        }
        //   print(results);
      }

      return results.entries
          .map((entry) => TimeTable(day: entry.key, session: entry.value))
          .toList();
    });
  }

  Future<void> deleteTimetable() {
    return _db.transaction(() async {
      await _db.delete(_db.timetableDays).go();
      await _db.delete(_db.timetableSessions).go();
    });
  }

  Future<bool> isTimeTableEmpty() async {
    // 1. Create a count expression
    final countExp = _db.timetableDays.id.count();

    // 2. Select the count from the table
    final query = _db.selectOnly(_db.timetableDays)..addColumns([countExp]);

    // 3. Get the first result (the total count)
    final result = await query.map((row) => row.read(countExp)).getSingle();

    // 4. If count is 0, it's empty
    return result == 0;
  }

  //add a session
  Future<int> addSession({
    required int dayId,
    required String start,
    required String end,
    required String subjects,
  }) async {
    print("${dayId} ${start} ${end} ${subjects}");

TimetableDay day = await (_db.select(_db.timetableDays)..where((t) => t.id.equals(dayId))).getSingle();
if(day.isBreakDay) await (_db.update(_db.timetableDays)..where((t) => t.id.equals(dayId))).write(TimetableDaysCompanion(
  isBreakDay: Value(false)
));

    return await (_db
        .into(_db.timetableSessions)
        .insert(
          TimetableSessionsCompanion(
            dayId: Value(dayId),
            start: Value(start),
            end: Value(end),
            subjects: Value(subjects),
          ),
        ));
  }

  Future<int> deleteSession(int index) async {
    print("started");
    // Get the session to find its dayId
    final session = await (_db.select(_db.timetableSessions)..where((t) => t.id.equals(index))).getSingleOrNull();
    
    int id = await (_db.delete(
      _db.timetableSessions,
    )..where((t) => t.id.equals(index))).go();
    print("the id is ${id}");
    
    // Check if day has any remaining sessions
    if (session != null) {
      final remainingSessions = await (_db.select(_db.timetableSessions)..where((t) => t.dayId.equals(session.dayId))).get();
      
      // If no sessions remain, set day as breakday
      if (remainingSessions.isEmpty) {
        await (_db.update(_db.timetableDays)..where((t) => t.id.equals(session.dayId))).write(
          TimetableDaysCompanion(isBreakDay: Value(true)),
        );
        print("Day ${session.dayId} set as breakday");
      }
    }
    
    return id;
  }
  
  // Toggle breakday status - if setting to breakday, delete all sessions
  Future<void> toggleBreakDay(int dayId) async {
    TimetableDay day = await (_db.select(_db.timetableDays)..where((t) => t.id.equals(dayId))).getSingle();
    
    if (day.isBreakDay) {
      // If currently breakday, just unset it
      await (_db.update(_db.timetableDays)..where((t) => t.id.equals(dayId))).write(
        TimetableDaysCompanion(isBreakDay: Value(false)),
      );
      print("Day $dayId set as normal day");
    } else {
      // If currently normal day, delete all sessions and set as breakday
      await _db.transaction(() async {
        // Delete all sessions for this day
        await (_db.delete(_db.timetableSessions)..where((t) => t.dayId.equals(dayId))).go();
        // Set day as breakday
        await (_db.update(_db.timetableDays)..where((t) => t.id.equals(dayId))).write(
          TimetableDaysCompanion(isBreakDay: Value(true)),
        );
        print("Day $dayId set as breakday with all sessions deleted");
      });
    }
  }

  Future<void> editSession(
    int id, {
    required String start,
    required String end,
    required String subjects,
  }) {
    print("${id}, ${start}, ${end}, ${subjects}");
    return (_db.update(
      _db.timetableSessions,
    )..where((t) => t.id.equals(id))).write(
      TimetableSessionsCompanion(
        start: Value(start),
        end: Value(end),
        subjects: Value(subjects),
      ),
    );
  }
  
  // Get the number of sessions for a day
  Future<int> getSessionCountForDay(int dayId) async {
    final countExp = _db.timetableSessions.id.count();
    final query = _db.selectOnly(_db.timetableSessions)
      ..addColumns([countExp])
      ..where(_db.timetableSessions.dayId.equals(dayId));
    
    final result = await query.map((row) => row.read(countExp)).getSingle();
    return result ?? 0;
  }
}

class TimeTable {
  TimeTable({required this.day, required this.session});
  TimetableDay day;
  List<TimetableSession> session;
}
