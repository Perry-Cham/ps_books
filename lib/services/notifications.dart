import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/DB services/timetableToDB.dart';
 
final _db = TimetableToDb();

Future<dynamic> get() async {
  final l = DateTime.now();
  final d = DateFormat('EEEE').format(l);

  final data = await _db.getTimetableSessions(d.toLowerCase());

if(data.isNotEmpty){
}
  for(var session in data){
     scheduleNotifications(session);
  }
  
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
    'Timetable Alert',
    'Your class ${session.name} starts now!',
    _convertToTZDateTime(session.time), // Function to turn "10:00" into a timestamp
    notificationDetails:  NotificationDetails(
      android: AndroidNotificationDetails(
        'timetable_channel',
        'Timetable Notifications',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        // This allows it to fire even when the phone is in power-saving mode
        scheduledNotificationRepeatFrequency: ScheduledNotificationRepeatFrequency.daily,
      ),
    ),
    androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle, // CRITICAL for "off" state
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
  );
}
}

