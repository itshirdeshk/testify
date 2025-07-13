import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:testify/utils/constants.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  Future<void> initialize(BuildContext context) async {
    if (_initialized) return;

    try {
      await _requestPermission(context);
      await _setupFlutterNotifications();

      // Use post-frame callback to ensure context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          try {
            await _setupMessageHandlers(context);
          } catch (e) {
            if (kDebugMode) {
              print('Error setting up message handlers: $e');
            }
          }
        }
      });

      await _sendTokenToBackend();
      _initialized = true;
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing notification service: $e');
      }
      // Don't mark as initialized if there was an error
    }
  }

  Future<void> _requestPermission(BuildContext context) async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    if (settings.authorizationStatus == AuthorizationStatus.denied) {
      // Use a post-frame callback to ensure Material context is ready
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) {
          try {
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                    'Notification permission is required to receive important updates. Please enable it in app settings.'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    child: const Text('OK'),
                  ),
                ],
              ),
            );
          } catch (e) {
            // If dialog fails, just log the error instead of crashing
            if (kDebugMode) {
              print('Could not show permission dialog: $e');
            }
          }
        }
      });
    }
  }

  Future<void> _setupFlutterNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings();
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);
    if (Platform.isAndroid) {
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel',
        'High Importance Notifications',
        description: 'This channel is used for important notifications.',
        importance: Importance.max,
      );
      await _localNotifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);
    }
  }

  Future<void> _setupMessageHandlers(BuildContext context) async {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      _showNotification(message);
    });
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // Handle navigation or data when notification is tapped
    });
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Handle notification which opened the app
    }
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }

  static Future<void> firebaseMessagingBackgroundHandler(
      RemoteMessage message) async {
    await NotificationService.instance._showNotification(message);
  }

  Future<void> _showNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    if (notification != null) {
      final details = NotificationDetails(
        android: AndroidNotificationDetails(
          'high_importance_channel',
          'High Importance Notifications',
          channelDescription:
              'This channel is used for important notifications.',
          importance: Importance.max,
          priority: Priority.high,
          icon: android?.smallIcon ?? '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      );
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        details,
      );
    }
  }

  Future<void> _sendTokenToBackend() async {
    final token = await _messaging.getToken();
    if (token == null) return;
    final prefs = await SharedPreferences.getInstance();
    final jwt = prefs.getString('token');
    const baseUrl = Constants.baseUrl;
    if (jwt == null) return;
    try {
      final dio = Dio();
      await dio.post(
        '$baseUrl/user/save-device-token',
        data: {'deviceToken': token},
        options: Options(headers: {'Authorization': 'Bearer $jwt'}),
      );
    } catch (e) {
      // Handle error
      if (kDebugMode) {
        print('Error sending device token: $e');
      }
    }
  }

  Future<void> sendTokenIfNeeded() async {
    await _sendTokenToBackend();
  }
}

// Add this to your main.dart:
// FirebaseMessaging.onBackgroundMessage(NotificationService._firebaseMessagingBackgroundHandler);
