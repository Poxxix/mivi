import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class WebNotificationService {
  static final WebNotificationService _instance = WebNotificationService._internal();
  factory WebNotificationService() => _instance;
  WebNotificationService._internal();

  FirebaseMessaging? _messaging;
  bool _isInitialized = false;

  // Initialize Firebase and FCM for web
  Future<void> initialize() async {
    if (!kIsWeb || _isInitialized) return;

    try {
      // Initialize Firebase (you'll need to add your config)
      await Firebase.initializeApp(
        options: const FirebaseOptions(
          apiKey: "your-api-key",
          authDomain: "your-project.firebaseapp.com",
          projectId: "your-project-id",
          storageBucket: "your-project.appspot.com",
          messagingSenderId: "your-sender-id",
          appId: "your-app-id",
        ),
      );

      _messaging = FirebaseMessaging.instance;

      // Request permission for notifications
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: false,
        provisional: false,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('User granted permission for web notifications');
        
        // Get FCM token
        String? token = await _messaging!.getToken(
          vapidKey: "your-vapid-key", // Add your VAPID key here
        );
        print('FCM Token: $token');

        // Listen to foreground messages
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          _showWebNotification(message);
        });

        // Handle notification clicks
        FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
          _handleNotificationClick(message);
        });

        _isInitialized = true;
      } else {
        print('User declined or has not accepted permission');
      }
    } catch (e) {
      print('Error initializing web notifications: $e');
    }
  }

  // Show notification using browser API
  void _showWebNotification(RemoteMessage message) {
    if (!kIsWeb) return;

    final notification = message.notification;
    if (notification != null) {
      // Use browser's Notification API
      showBrowserNotification(
        title: notification.title ?? 'New Notification',
        body: notification.body ?? '',
        icon: '/icons/Icon-192.png',
        data: message.data,
      );
    }
  }

  // Handle notification click
  void _handleNotificationClick(RemoteMessage message) {
    print('Notification clicked: ${message.data}');
    // Handle navigation or other actions
  }

  // Show browser notification (requires service worker setup)
  void showBrowserNotification({
    required String title,
    required String body,
    String? icon,
    Map<String, dynamic>? data,
  }) {
    if (!kIsWeb) return;
    
    // This requires proper service worker setup
    // The actual implementation depends on your service worker
  }

  // Send a local notification for web (alternative approach)
  Future<void> showLocalWebNotification({
    required String title,
    required String body,
    String? icon,
  }) async {
    if (!kIsWeb) return;

    // Check if browser supports notifications
    if (!_isBrowserNotificationSupported()) {
      print('Browser notifications not supported');
      return;
    }

    // This would typically show an overlay notification
    // since actual browser notifications require service worker
    _showOverlayNotification(title, body, icon);
  }

  bool _isBrowserNotificationSupported() {
    // Check if running in web and Notification API is available
    return kIsWeb; // Simplified check
  }

  void _showOverlayNotification(String title, String body, String? icon) {
    // Show a custom overlay notification in the app
    // This could be a snackbar, dialog, or custom widget
    print('Overlay notification: $title - $body');
  }

  // Get FCM token for web
  Future<String?> getToken() async {
    if (!kIsWeb || !_isInitialized) return null;
    return await _messaging?.getToken(vapidKey: "your-vapid-key");
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    if (!kIsWeb || !_isInitialized) return;
    await _messaging?.subscribeToTopic(topic);
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    if (!kIsWeb || !_isInitialized) return;
    await _messaging?.unsubscribeFromTopic(topic);
  }
} 