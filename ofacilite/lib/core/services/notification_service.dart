import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final _plugin = FlutterLocalNotificationsPlugin();

  static final _medicationDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'medication_channel',
      'Médicaments',
      channelDescription: 'Rappels de médicaments',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  static final _appointmentDetails = NotificationDetails(
    android: AndroidNotificationDetails(
      'appointment_channel',
      'Rendez-vous',
      channelDescription: 'Rappels de rendez-vous',
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<void> init() async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(DateTime.now().timeZoneName));
    } catch (_) {
      tz.setLocalLocation(tz.UTC);
    }

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: androidSettings));
  }

  Future<void> scheduleDaily(
    int id,
    String title,
    String body,
    TimeOfDay time,
  ) async {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        scheduled,
        _medicationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[Notifications] scheduleOnce failed: $e');
    }
  }

  Future<void> scheduleOnce(
    int id,
    String title,
    String body,
    DateTime dateTime,
  ) async {
    if (dateTime.isBefore(DateTime.now())) return;
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        tz.TZDateTime.from(dateTime, tz.local),
        _appointmentDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('[Notifications] scheduleOnce failed: $e');
    }
  }

  Future<void> cancel(int id) => _plugin.cancel(id);
}
