import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  final bool _isInitialized = false;

  bool get isInitialized => _isInitialized;
//INITIALIZE NOTIFICATION
  Future<void> initNotification() async {
    if (!_isInitialized) return;

    const initSettingAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const initSettings = InitializationSettings(android: initSettingAndroid);

    await notificationsPlugin.initialize(initSettings);
  }

// NOTIFICATION DETAIL SETUP
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
        android: AndroidNotificationDetails(
            'daily_channel_id', 'Daily Notifications',
            channelDescription: 'Daily Notifications',
            importance: Importance.max,
            priority: Priority.high));
  }

// SHOW NOTIFICATION
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    await notificationsPlugin.show(
        id, title, body, const NotificationDetails());
  }
// ON NOTI TAP
}
