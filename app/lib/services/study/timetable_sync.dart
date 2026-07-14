import 'package:dio/dio.dart';
import 'package:ps_books/models/timetable.dart';
import 'package:ps_books/services/dbServices/timetableToDB.dart';
import 'package:ps_books/state/connectivity_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ps_books/routes/studyRouteComp/timetable.dart' as tt;

Future<void> syncTimetableIfSignedIn() async {
  if (!await hasInternet()) return;
  final prefs = await SharedPreferences.getInstance();
  final isSignedIn = prefs.getBool('ps_signed_in') ?? false;
  if (isSignedIn) {
    await TimetableSyncingService().sync();
  }
}

class TimetableSyncingService {
  final String baseUrl = String.fromEnvironment('BASE_URL', defaultValue: 'http://localhost:8000');
  final Dio _dio = Dio();
  final TimetableToDb _dbService = TimetableToDb();

  TimetableSyncingService();

  Future<void> sync() async {
    try {
      final currentData = await _dbService.getTimeTable().single;

      final db = _dbService.getDb();
      final t = await (db.select(db.timetables)..limit(1)).getSingleOrNull();

      final version = t?.version ?? 0;
      final lastModified = t?.lastModified ?? DateTime.now();

      final timetableModel = TimetableModel(
        version: version,
        lastModified: lastModified,
        days:
            currentData.map((t) {
              return DayData(
                day: t.day.day,
                isBreakDay: t.day.isBreakDay,
                sessions:
                    t.session
                        .map(
                          (s) => SessionData(
                            start: s.start,
                            end: s.end,
                            subjects: s.subjects,
                          ),
                        )
                        .toList(),
              );
            }).toList(),
      );

      await _dio.post('$baseUrl/sync_timetable', data: timetableModel.toJson());
    } catch (e) {
      print('Sync failed: $e');
    }
  }

  Future<void> getTimetable() async {
    try {
      final response = await _dio.get('$baseUrl/get_timetable');
      if (response.statusCode == 200) {
        final received = TimetableModel.fromJson(response.data);

        final db = _dbService.getDb();
        final t = await (db.select(db.timetables)..limit(1)).getSingleOrNull();

        final localVersion = t?.version ?? 0;
        final localLastModified = t?.lastModified ?? DateTime.fromMillisecondsSinceEpoch(0);

        if (received.version > localVersion ||
            (received.version == localVersion &&
                received.lastModified.isAfter(localLastModified))) {
          await _dbService.deleteTimetable();

          final List<tt.Day> daysToInsert =
              received.days.map((d) {
                final day = tt.Day(day: d.day);
                day.isBreak = d.isBreakDay;
                day.sessions =
                    d.sessions.map((s) {
                      final session = tt.Session(start: s.start, end: s.end);
                      session.subjects =
                          s.subjects.split(',').map((sub) => sub.trim()).toList();
                      return session;
                    }).toList();
                return day;
              }).toList();

          await _dbService.insertTimetable(
            daysToInsert,
            version: received.version,
            lastModified: received.lastModified,
          );
        }
      }
    } catch (e) {
      print('Get timetable failed: $e');
    }
  }
}
