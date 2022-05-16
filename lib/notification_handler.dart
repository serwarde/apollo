import 'package:awesome_poll_app/main.dart';
import 'package:awesome_poll_app/services/push_notifications/notifications.service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:math';

import 'package:awesome_poll_app/utils/commons.dart';
import 'package:awesome_poll_app/services/auth/auth.service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// This function is called, when a message is received but the app is in background.
/// It then shows a notification bar that a poll is active/closed, if the corresponding poll
/// is in a near location.
Future<bool> backgroundHandler(RemoteMessage message) async {

  // Load the last latitude and longitude of the device from the shared preferences storage.
  final prefs = await SharedPreferences.getInstance();
  final double? lastLatitude = prefs.getDouble('lastLatitude');
  final double? lastLongitude = prefs.getDouble('lastLongitude');

  if(lastLatitude==null || lastLongitude==null) return false;


  double poll_latitude = double.parse(message.data["latitude"]);
  double poll_longitude = double.parse(message.data["longitude"]);
  double poll_radius = double.parse(message.data["radius"]);
  const double earthPerimeter = 40030 * 1000; // in meters
  // Check whether the poll is close to the last location with a tolerance of factor 2.
  if(pow((lastLongitude - poll_longitude), 2) + pow((lastLatitude - poll_latitude), 2) < pow((poll_radius/earthPerimeter*360)*2, 2)) {
    NotificationsService.display(message);
    return true;
  }

  return false;

}

/// This class handles all incoming notification messages.
class NotificationHandler {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  String? userId;

  /// Constructor. Trigger an update of this handler when the user login status changes.
  NotificationHandler() {
    // Start listening for message, when the user has logged in.
    var auth = getIt.get<AuthService>();
    auth.uidChanges.listen((uid) {
      if(uid!=null) {
        userId = uid;
        messageSetup();
      }
    });
  }

  /// Store the current device location in the shared preferences storage 
  /// so that the background handler can retrieve them.
  static Future<void> updateLocation(lat, lon) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setDouble('lastLatitude', lat);
    await prefs.setDouble('lastLongitude', lon);
  }
  
  /// Initialize everything to listen for messages. (Subscribe them and define the handler methods.)
  Future<void> messageSetup() async {
    await FirebaseMessaging.instance.getInitialMessage().then((message) {
      if(message != null){
        _handleMessage(message);
      }
    });

    // Store the current registration token in the database, which leads to being addressed when a 
    // message is sent to users.
    if(userId!=null) {
      DatabaseReference root = await FirebaseDatabase(databaseURL: 'https://awesome-poll-app-default-rtdb.europe-west1.firebasedatabase.app/').ref();
      String? registrationToken = await _firebaseMessaging.getToken();
      if(registrationToken!=null) {
        await root.child("users/" + userId!).update({
          "registrationToken": registrationToken,
          "registrationTokenTimestamp": DateTime.now().millisecondsSinceEpoch
        });
      }

      // Define the message handlers.
      FirebaseMessaging.onMessage.listen(_handleMessage);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpened);
      FirebaseMessaging.onBackgroundMessage(backgroundHandler);
    }
    
  }

  /// Handle a message when the app is in foreground.
  Future<bool> _handleMessage(RemoteMessage message) async {
    // Load the last latitude and longitude of the device from the shared preferences storage.
    final prefs = await SharedPreferences.getInstance();
    final double? lastLatitude = prefs.getDouble('lastLatitude');
    final double? lastLongitude = prefs.getDouble('lastLongitude');

    if(lastLatitude==null || lastLongitude==null) return false;


    double poll_latitude = double.parse(message.data["latitude"]);
    double poll_longitude = double.parse(message.data["longitude"]);
    double poll_radius = double.parse(message.data["radius"]);
    const double earthPerimeter = 40030 * 1000; // in meters
    // Check whether the poll is close to the last location with a tolerance of factor 2.
    if(pow((lastLongitude - poll_longitude), 2) + pow((lastLatitude - poll_latitude), 2) < pow((poll_radius/earthPerimeter*360)*2, 2)) {
      NotificationsService.display(message);
      return true;
    }

    return false;
  }
  void _handleMessageOpened(RemoteMessage message){
    // never called
  }

}