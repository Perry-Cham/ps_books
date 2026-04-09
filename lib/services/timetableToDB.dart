import 'package:drift/drift.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/dbs/initdb.dart';
import 'package:ps_books/routes/study%20route%20comp/timetable.dart';

class Timetabletodb {
  final _db = DBProvider();
  List<Day>? Timetable;

  insertTimetable(List<Day> timetable) async {
    List<Day> data = timetable;
    for (var day in timetable) {
      int dayId = await (_db.db
          .into(_db.db.timetableDays)
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
        await (_db.db
            .into(_db.db.timetableSessions)
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

  Stream<List<TimeTable>> getTimeTable()  {
    //otherwise join the days and sessions then return the data
    var query = _db.db.select(_db.db.timetableDays).join([
      leftOuterJoin(
        _db.db.timetableSessions,
        _db.db.timetableSessions.dayId.equalsExp(_db.db.timetableDays.id),
      ),
    ]);

    return query.watch().map((List<TypedResult> rows) {
      var results = <TimetableDay, List<TimetableSession>>{};
      for (var row in rows) {
        var day = row.readTable(_db.db.timetableDays);
        var session = row.readTableOrNull(_db.db.timetableSessions);

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

  Future<bool> isTimeTableEmpty() async {
    // 1. Create a count expression
    final countExp = _db.db.timetableDays.id.count();

    // 2. Select the count from the table
    final query = _db.db.selectOnly(_db.db.timetableDays)
      ..addColumns([countExp]);

    // 3. Get the first result (the total count)
    final result = await query.map((row) => row.read(countExp)).getSingle();

    // 4. If count is 0, it's empty
    return result == 0;
  }
}

class TimeTable {
  TimeTable({required this.day, required this.session});
  TimetableDay day;
  List<TimetableSession> session;
}
