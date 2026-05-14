import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/DB services/timetableToDB.dart';
import 'package:timezone/timezone.dart';
import 'package:workmanager/workmanager.dart';

final _db = TimetableToDb();

@pragma('vm:entry-point')
void registerStudyNotifications() async {
  Workmanager().executeTask((name, input) async {
    final l = DateTime.now();
    final d = DateFormat('EEEE').format(l);

    final data = await _db.getTimetableSessions(d.toLowerCase());
    final notifs = Notifications();
    await notifs.init();

    if (data.isNotEmpty) {
      for (var session in data) {
        await notifs.scheduleNotification(session);
      }
    }
    return Future.value(true);
  });
}

class Notifications {
  final flutterNotifs = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // 1. Android-specific settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 2. Combine settings
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    // 3. Initialize the plugin
    await flutterNotifs.initialize(settings: initializationSettings);
  }

  Future<void> scheduleNotification(TimetableSession session) async {
    await flutterNotifs.zonedSchedule(
      id: session.id, // Unique ID for each notification
      title: 'Timetable Alert',
      body: 'Your study session for  ${session.start} starts now!',
      scheduledDate: _convertToTZDateTime(
        session.start,
      ), // Function to turn "10:00" into a timestamp
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          'timetable_channel',
          'Timetable Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
          // This allows it to fire even when the phone is in power-saving mode
          //   scheduledNotificationRepeatFrequency: ScheduledNotificationRepeatFrequency.daily,
        ),
      ),
      androidScheduleMode:
          AndroidScheduleMode.exactAllowWhileIdle, // CRITICAL for "off" state
    );
  }
}

TZDateTime _convertToTZDateTime(String t) {
  final timeString = t.split(':');
  final time = TimeOfDay(
    hour: int.parse(timeString[0]),
    minute: int.parse(timeString[1]),
  );
  final loc = local;
  final now = TZDateTime.now(loc);
  final scheduled = TZDateTime(
    local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );

  return scheduled;
}
