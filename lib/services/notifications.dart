import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/DB services/timetableToDB.dart';
import 'package:ps_books/state/pomodoro_timer.dart';
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
  static const _channelId = "888";
  final _ongoingId = 999;
  static const _alertId = 777;

  Future<void> init() async {
    // 1. Android-specific settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Linux notifs
    const linux = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    // 2. Combine settings
    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid, linux: linux);

    // 3. Initialize the plugin
    await flutterNotifs.initialize(settings: initializationSettings);
  }

  final channel = AndroidNotificationChannel(
    "888",
    'Study Timer',
    description: 'Shows study session progress',
    importance: Importance.low, // low so it does not make sound on every tick
  );

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


 //Study Notifications


  // the persistent notification shown while the timer is running
  Future<void> updateOngoing(PomodoroState snapshot) async {
    final remaining = _formatDuration(Duration(seconds: snapshot.secondsRemaining));
    final title = snapshot.isRunning
        ? '${snapshot.phase} — $remaining remaining'
        : '${snapshot.phase} — Paused ($remaining)';

    final body =
        'Cycle ${snapshot.currentCycle} of ${snapshot.cycles}';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      'Study Timer',
      channelDescription: 'Study session progress',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,           // cannot be dismissed by swipe
      onlyAlertOnce: true,     // does not make sound on every update
      showProgress: true,
      actions: [
        AndroidNotificationAction(
          snapshot.isRunning ? 'pause' : 'resume',
          snapshot.isRunning ? 'Pause' : 'Resume',
        ),
        const AndroidNotificationAction('skip', 'Skip'),
      ],
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.low,
      actions: [
        LinuxNotificationAction(key: 'pause', label: 'Pause'),
        LinuxNotificationAction(key: 'skip', label: 'Skip'),
      ],
    );

    await flutterNotifs.show(
      id: _ongoingId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails, linux: linuxDetails),
    );
  }

  // alert shown when the phase changes — this one makes sound
  Future<void> showPhaseTransition({
    required PomodoroPhase previous,
    required PomodoroPhase next,
  }) async {
    final title = next == PomodoroPhase.work ? 'Back to work' : 'Break time';
    final body = switch (next) {
      PomodoroPhase.work => 'Your break is over — time to focus',
      PomodoroPhase.breakTime => 'Good work! Take a short break',
    /*TimerPhase.longBreak => 'Excellent session! Take a long break',*/
    };

     const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Study Timer',
      importance: Importance.high,
      priority: Priority.high,
      // this one does make sound — it is an alert not a status update
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );

    await flutterNotifs.show(
      id: _alertId,
      title:title,
      body: body,
     notificationDetails:  const NotificationDetails(android: androidDetails, linux: linuxDetails),
    );
  }

  Future<void> showSessionComplete() async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Study Timer',
      importance: Importance.high,
      priority: Priority.high,
    );

    await flutterNotifs.show(
     id: _alertId,
      title: 'Session complete',
     body:  'You completed all your study cycles. Great work!',
     notificationDetails:  const NotificationDetails(android: androidDetails),
    );
  }

  Future<void> cancelOngoing() async {
    await flutterNotifs.cancel(id: _ongoingId);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
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
