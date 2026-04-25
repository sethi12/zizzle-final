import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  static const String chatChannelId = 'chat_channel';
  static const String chatChannelName = 'Chat Messages';

  Future<void> initFcm() async {
    // Request notification permission
    await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Initialize local notifications
    await _initializeLocalNotifications();

    if (Platform.isIOS) {
      String? apnsToken = await _firebaseMessaging.getAPNSToken();
      print("APNs Token: $apnsToken");

      while (apnsToken == null) {
        await Future.delayed(const Duration(milliseconds: 300));
        apnsToken = await _firebaseMessaging.getAPNSToken();
        print("Retry APNs Token: $apnsToken");
      }
    }

    final fcmToken = await _firebaseMessaging.getToken();
    print("FCM Token: $fcmToken");

    // Handle foreground notifications
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Foreground message: ${message.notification?.title}');
      _showLocalNotification(message);
    });

    // Handle notification when app is opened via notification
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Opened app with message: ${message.notification?.title}');
    });

    // Uncomment if you want to handle background notifications
    // FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidInitSettings =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    final DarwinInitializationSettings iosInitSettings =
        DarwinInitializationSettings(
      requestSoundPermission: true,
      requestBadgePermission: true,
      requestAlertPermission: true,
    );

    InitializationSettings initSettings = InitializationSettings(
      android: androidInitSettings,
      iOS: iosInitSettings, // ✅ This line fixes the error
    );

    await _localNotificationsPlugin.initialize(initSettings);
  }

  void _showLocalNotification(RemoteMessage message) {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      chatChannelId, // 👈 channelId you defined
      chatChannelName, // 👈 channelName you defined
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    _localNotificationsPlugin.show(
      message.hashCode,
      message.notification?.title ?? 'New Notification',
      message.notification?.body ?? '',
      notificationDetails,
    );
  }

  void listenForTokenRefresh(String username) {
    FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(username)
            .update({
          'fcmToken': newToken,
          'lastUpdatedfcmtoken': FieldValue.serverTimestamp(),
        });
        print("FCM Token Refreshed and Updated: $newToken");
      } catch (e) {
        print("Error updating refreshed FCM Token: $e");
      }
    });
  }
}

// OPTIONAL: background handler
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Background message: ${message.notification?.title}");
}
