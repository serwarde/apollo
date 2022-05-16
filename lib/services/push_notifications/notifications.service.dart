import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationsService{
  static final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  static void initialize(){
    const InitializationSettings initializationSettings =
        InitializationSettings(android: AndroidInitializationSettings("@mipmap/launcher_icon"
          )
    );
    _notificationsPlugin.initialize(initializationSettings);
  }

  static void display(RemoteMessage message) async {
    
    // id has to be unique, otherwise notifications would be the same
    final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    const NotificationDetails notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        "poll_notification_channel", // channel Id
        "Poll Notifications", // channel name
        channelDescription: "Notifications for polls in your area",
        // Maximum importance and high priority ensure that the message will be shown
        importance: Importance.max,
        priority: Priority.high
      )
    );

    await _notificationsPlugin.show(
      id,
      "APOLLO", // title of notification
      message.data["body"] ?? "",
      notificationDetails,
      );
  }
}