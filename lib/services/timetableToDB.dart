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
      if (day.isBreak == false) continue;

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
}
