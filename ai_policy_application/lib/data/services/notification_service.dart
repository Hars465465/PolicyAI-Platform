import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'api_service.dart';
import 'device_service.dart';

class NotificationService {
  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final ApiService _api = ApiService();

  Future<void> initialize() async {
    // Request permission
    NotificationSettings settings = await _fcm.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      debugPrint('✅ FCM Permission granted');
      
      // Get FCM token
      String? token = await _fcm.getToken();
      debugPrint('📱 FCM Token: $token');
      
      // Send token to backend
      if (token != null) {
        await _sendTokenToBackend(token);
      }
    }

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      debugPrint('📬 Foreground notification: ${message.notification?.title}');
      debugPrint('📬 Body: ${message.notification?.body}');
    });

    // Handle notification tap when app in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      debugPrint('📬 Notification tapped: ${message.data}');
    });
  }

  Future<void> _sendTokenToBackend(String fcmToken) async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      await _api.updateFcmToken(deviceId, fcmToken);
      debugPrint('✅ FCM token sent to backend successfully!');
    } catch (e) {
      debugPrint('❌ Error sending FCM token to backend: $e');
    }
  }
}
