import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fruit_hub/core/helpers/backend_endpoints.dart';
import 'package:fruit_hub/core/services/local_storage/app_preferences_service.dart';
import 'package:fruit_hub/core/services/notifications/notification_router.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  debugPrint('Handling background message: ${message.messageId}');
}

class NotificationService {
  NotificationService({
    required this.preferencesService,
    FirebaseMessaging? messaging,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
    FlutterLocalNotificationsPlugin? localNotifications,
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _localNotifications =
           localNotifications ?? FlutterLocalNotificationsPlugin();

  final AppPreferencesService preferencesService;
  final FirebaseMessaging _messaging;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;
  final FlutterLocalNotificationsPlugin _localNotifications;

  static const AndroidNotificationChannel _androidChannel =
      AndroidNotificationChannel(
        'fruit_hub_notifications',
        'Fruit Hub Notifications',
        description: 'Notifications for order status updates, delivery tracking, and reviews.',
        importance: Importance.high,
      );

  Future<void> init() async {
    // 1. Setup Local Notification Channel for Android (Fast & Local)
    await _setupLocalNotifications();

    // 2. Setup FCM permissions, token sync, and listeners in background
    _initPushNotifications();
  }

  void _initPushNotifications() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('FCM Notification permission granted.');
      await _saveFcmToken();
    }

    // 3. Token refresh listener
    _messaging.onTokenRefresh.listen((token) async {
      await _saveTokenToFirestore(token);
    });

    // 4. Foreground message listener (Shows heads-up banner via Local Notifications)
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint(
        'Foreground FCM message received: ${message.notification?.title}',
      );
      _showForegroundNotification(message);
    });

    // 5. Background notification tap listener
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message);
    });

    // 6. Terminated state notification tap listener
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleNotificationTap(initialMessage);
    }
  }

  Future<void> _setupLocalNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/launcher_icon');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _localNotifications.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          NotificationRouter.handleNotificationNavigation(payload);
        }
      },
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.createNotificationChannel(_androidChannel);
  }

  void _showForegroundNotification(RemoteMessage message) {
    final notification = message.notification;
    final android = message.notification?.android;

    if (notification != null && !kIsWeb) {
      final payload = message.data.isNotEmpty ? jsonEncode(message.data) : '';

      _localNotifications.show(
        id: notification.hashCode,
        title: notification.title,
        body: notification.body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            _androidChannel.id,
            _androidChannel.name,
            channelDescription: _androidChannel.description,
            importance: Importance.max,
            priority: Priority.high,
            icon: android?.smallIcon ?? '@mipmap/launcher_icon',
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: payload,
      );
    }
  }

  Future<void> _saveFcmToken() async {
    try {
      final token = await _messaging.getToken();
      if (token != null) {
        await _saveTokenToFirestore(token);
      }
    } catch (e) {
      debugPrint('Error getting FCM token: $e');
    }
  }

  Future<void> _saveTokenToFirestore(String token) async {
    final user = _auth.currentUser;
    if (user != null) {
      final language = preferencesService.getLanguage();
      await _firestore
          .collection(BackendEndpoints.usersCollection)
          .doc(user.uid)
          .set({
            'fcmToken': token,
            'languageCode': language,
            'lastTokenUpdate': FieldValue.serverTimestamp(),
          }, SetOptions(merge: true));
      debugPrint(
        'FCM Token & langCode ($language) saved to Firestore for user: ${user.uid}',
      );
    }
  }

  Future<void> updateLanguageCode(String languageCode) async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection(BackendEndpoints.usersCollection)
          .doc(user.uid)
          .set({'languageCode': languageCode}, SetOptions(merge: true));
      debugPrint(
        'Language code ($languageCode) updated in Firestore for user: ${user.uid}',
      );
    }
  }

  void _handleNotificationTap(RemoteMessage message) {
    if (message.data.isNotEmpty) {
      NotificationRouter.handleNotificationNavigation(message.data);
    }
  }
}
