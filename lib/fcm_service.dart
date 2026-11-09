
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FCMService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize({
    required void Function(RemoteMessage, String) onMessage,
  }) async {
    // Request notification permission
    final settings = await _messaging.requestPermission();

    debugPrint(
      'Notification permission: ${settings.authorizationStatus}',
    );

    // Get FCM token
    final token = await _messaging.getToken();
    debugPrint('FCM token (development only): $token');

    // Listen for token updates
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('FCM token refreshed');
    });

    // Foreground messages
    FirebaseMessaging.onMessage.listen((message) {
      debugPrint('FCM received: ${message.messageId}');
      debugPrint('FCM data: ${message.data}');

      onMessage(message, 'onMessage');
    });

    // Message opened from background
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      debugPrint('FCM opened from background: ${message.messageId}');
      debugPrint('FCM data: ${message.data}');

      onMessage(message, 'onMessageOpenedApp');
    });

    // Message opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();

    if (initialMessage != null) {
      debugPrint('FCM initial message: ${initialMessage.messageId}');
      debugPrint('FCM data: ${initialMessage.data}');

      onMessage(initialMessage, 'getInitialMessage');
    }
  }
}
