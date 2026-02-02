import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

/// Handles daily Word of the Day reminder notifications.
class NotificationService {
  NotificationService._();

  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'word_of_the_day_reminder';
  static const String _channelName = 'Daily reminder';
  static const int _notificationId = 1;

  static const String _keyReminderHour = 'reminder_hour';
  static const String _keyReminderMinute = 'reminder_minute';
  static const String _keyPromptDismissed = 'reminder_prompt_dismissed';

  static bool _initialized = false;

  /// Call once before scheduling. Initializes timezone and the plugin.
  static Future<void> init() async {
    if (_initialized) return;

    tz_data.initializeTimeZones();
    final timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: false,
    );
    const initSettings = InitializationSettings(
      android: android,
      iOS: ios,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    await _createChannel();
    _initialized = true;
  }

  static void _onNotificationTapped(NotificationResponse response) {
    // User tapped the notification; app can open (handled by launcher).
  }

  static Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: 'Daily Word of the Day reminder',
      importance: Importance.defaultImportance,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Request notification permission (required on Android 13+ and iOS).
  static Future<bool> requestPermission() async {
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (android != null) {
      final granted = await android.requestNotificationsPermission();
      return granted ?? false;
    }
    final ios = _plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>();
    if (ios != null) {
      final granted = await ios.requestPermissions(
        alert: true,
        badge: false,
        sound: true,
      );
      return granted ?? false;
    }
    return true;
  }

  /// Whether the user has been prompted and dismissed without setting a reminder.
  static Future<bool> wasPromptDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPromptDismissed) ?? false;
  }

  /// Mark that the user dismissed the reminder prompt without enabling.
  static Future<void> setPromptDismissed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPromptDismissed, true);
  }

  /// Currently scheduled reminder time, or null if not set.
  static Future<TimeOfDay?> getScheduledReminderTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyReminderHour);
    final minute = prefs.getInt(_keyReminderMinute);
    if (hour == null || minute == null) return null;
    return TimeOfDay(hour: hour, minute: minute);
  }

  /// Schedule a daily notification at [time]. Requests permission if needed.
  static Future<bool> scheduleDailyReminder(TimeOfDay time) async {
    final granted = await requestPermission();
    if (!granted) return false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyReminderHour, time.hour);
    await prefs.setInt(_keyReminderMinute, time.minute);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduled.isBefore(now) || scheduled.isAtSameMomentAs(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Daily Word of the Day reminder',
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      _notificationId,
      "Sid's Word",
      "Your daily word is ready. Tap to expand your vocabulary.",
      scheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    return true;
  }

  /// Cancel the daily reminder and clear stored time.
  static Future<void> cancelReminder() async {
    await _plugin.cancel(_notificationId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyReminderHour);
    await prefs.remove(_keyReminderMinute);
  }

  /// Reschedule with a new time (cancels existing first).
  static Future<bool> updateReminderTime(TimeOfDay time) async {
    await _plugin.cancel(_notificationId);
    return scheduleDailyReminder(time);
  }
}
