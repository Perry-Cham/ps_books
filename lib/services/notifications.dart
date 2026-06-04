import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:ps_books/dbs/database.dart';
import 'package:ps_books/services/DB services/timetableToDB.dart';
import 'package:ps_books/state/pomodoro_timer.dart';
import 'package:timezone/timezone.dart';
import 'package:workmanager/workmanager.dart';

final _db = TimetableToDb();
late final globalProviderContainer;
// Global reference pointer provider to hold the active main UI Riverpod container mapping


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

// FIX: This callback MUST be a top-level or static function to execute reliably from background/minimized states
@pragma('vm:entry-point')
void onNotificationTap(NotificationResponse response) {
  if (globalProviderContainer == null) {
    print("⚠️ App container reference not initialized yet.");
    return;
  }

  final notifier = globalProviderContainer!.read(pomodoroProvider.notifier);
print(response.actionId);
  switch (response.actionId) {
    case 'pause':
      notifier.pause();
      break;
    case 'resume':
      notifier.resume();
      break;
    case 'skip':
    // Implement your skip logic here if needed
      break;
  }
}

class Notifications {
  final flutterNotifs = FlutterLocalNotificationsPlugin();
  static const _channelId = "888";
  final _ongoingId = 999;
  static const _alertId = 777;

  Future<void> init() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const linux = LinuxInitializationSettings(
      defaultActionName: 'Open',
    );

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid, linux: linux);

    await flutterNotifs.initialize(
      settings: initializationSettings,
      // FIX: Reference the global callback handler entry point cleanly
      onDidReceiveNotificationResponse: onNotificationTap,
      onDidReceiveBackgroundNotificationResponse: onNotificationTap,
    );
  }

  final channel = AndroidNotificationChannel(
    _channelId,
    'Study Timer',
    description: 'Shows study session progress',
    importance: Importance.low,
  );

  Future<void> scheduleNotification(TimetableSession session) async {
    await flutterNotifs.zonedSchedule(
      id: session.id,
      title: 'Timetable Alert',
      body: 'Your study session for ${session.start} starts now!',
      scheduledDate: _convertToTZDateTime(session.start),
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'timetable_channel',
          'Timetable Notifications',
          importance: Importance.max,
          priority: Priority.high,
          showWhen: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
    );
  }

  Future<void> updateOngoing(PomodoroState snapshot) async {
    final remaining = _formatDuration(Duration(seconds: snapshot.secondsRemaining));
    final phaseName = snapshot.phase == PomodoroPhase.work ? 'Work' : 'Break';
    final title = snapshot.isRunning
        ? '$phaseName — $remaining remaining'
        : '$phaseName — Paused ($remaining)';

    final body = 'Cycle ${snapshot.currentCycle} of ${snapshot.cycles}';

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      'Study Timer',
      channelDescription: 'Study session progress',
      importance: Importance.low,
      priority: Priority.low,
      ongoing: true,
      onlyAlertOnce: true,
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
        LinuxNotificationAction(key: 'resume', label: 'Resume'),
      ],
    );

    await flutterNotifs.show(
      id: _ongoingId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(android: androidDetails, linux: linuxDetails),
    );
  }

  Future<void> showPhaseTransition({
    required PomodoroPhase previous,
    required PomodoroPhase next,
  }) async {
    final title = next == PomodoroPhase.work ? 'Back to work' : 'Break time';
    final body = switch (next) {
      PomodoroPhase.work => 'Your break is over — time to focus',
      PomodoroPhase.breakTime => 'Good work! Take a short break',
    };

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      'Study Timer',
      importance: Importance.high,
      priority: Priority.high,
    );

    const linuxDetails = LinuxNotificationDetails(
      urgency: LinuxNotificationUrgency.normal,
    );

    await flutterNotifs.show(
      id: _alertId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(android: androidDetails, linux: linuxDetails),
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
      body: 'You completed all your study cycles. Great work!',
      notificationDetails: const NotificationDetails(android: androidDetails),
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
} // Fixed bracket alignment error here

TZDateTime _convertToTZDateTime(String t) {
  final timeString = t.split(':');
  final time = TimeOfDay(
    hour: int.parse(timeString[0]),
    minute: int.parse(timeString[1]),
  );
  final loc = local;
  final now = TZDateTime.now(loc);
  return TZDateTime(
    loc,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  );
}