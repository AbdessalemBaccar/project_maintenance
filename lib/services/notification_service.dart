import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  // ── Initialize ─────────────────────────────────────────────────────────────
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Africa/Tunis'));

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permission (Android 13+)
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    _initialized = true;
    debugPrint('NotificationService: initialized');
  }

  // ── Schedule Weekly Saturday 6PM ───────────────────────────────────────────
  Future<void> scheduleWeeklyReminder() async {
    await initialize();
    await _plugin.cancel(1);

    const androidDetails = AndroidNotificationDetails(
      'weekly_km_reminder',
      'Weekly KM Reminder',
      channelDescription: 'Weekly reminder to update your vehicle mileage',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF00D4AA),
      enableLights: true,
      enableVibration: true,
      playSound: true,
    );

    const details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      1,
      '🚗 Time to update your mileage!',
      'How many km did you drive this week? Tap to update your vehicle.',
      _nextSaturday6PM(),
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );

    debugPrint('NotificationService: scheduled for Saturdays at 18:00');
  }

  // ── Cancel All ─────────────────────────────────────────────────────────────
  Future<void> cancelAll() async => await _plugin.cancelAll();

  // ── Next Saturday 18:00 Tunis Time ────────────────────────────────────────
  tz.TZDateTime _nextSaturday6PM() {
    final tunis = tz.getLocation('Africa/Tunis');
    final now = tz.TZDateTime.now(tunis);

    var scheduled = tz.TZDateTime(tunis, now.year, now.month, now.day, 18, 0);

    while (scheduled.weekday != DateTime.saturday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }

    debugPrint('Next reminder: $scheduled');
    return scheduled;
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('Notification tapped');
  }
}
