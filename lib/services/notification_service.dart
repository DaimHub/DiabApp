import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'firestore_service.dart';

class NotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;
  static final List<StreamSubscription> _subscriptions = [];

  /// Initialize the notification service
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialize timezone data
      tz.initializeTimeZones();

      // Request permissions
      await _requestPermissions();

      // Initialize local notifications
      await _initializeLocalNotifications();

      // Initialize FCM
      await _initializeFCM();

      _isInitialized = true;
      print('✅ Notification service initialized successfully');
    } catch (e) {
      print('❌ Failed to initialize notification service: $e');
    }
  }

  /// Request notification permissions
  static Future<void> _requestPermissions() async {
    // Request FCM permissions
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    print('FCM permission status: ${settings.authorizationStatus}');

    // Request local notification permissions for Android 13+
    if (Platform.isAndroid) {
      final localSettings = await _localNotifications
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >()
          ?.requestNotificationsPermission();
      print('Local notifications permission: $localSettings');
    }
  }

  /// Initialize local notifications
  static Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      settings,
      onDidReceiveNotificationResponse: _onLocalNotificationTap,
    );
  }

  /// Initialize Firebase Cloud Messaging
  static Future<void> _initializeFCM() async {
    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');

    // Save token to Firestore
    if (token != null) {
      await _saveFCMToken(token);
    }

    // Listen for token refresh
    _subscriptions.add(_messaging.onTokenRefresh.listen(_saveFCMToken));

    // Handle foreground messages
    _subscriptions.add(
      FirebaseMessaging.onMessage.listen(_handleForegroundMessage),
    );

    // Handle background message taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

    // Handle app launch from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      _handleMessageOpenedApp(initialMessage);
    }
  }

  /// Save FCM token to Firestore
  static Future<void> _saveFCMToken(String token) async {
    try {
      await FirestoreService.saveUserData({
        'fcmToken': token,
        'fcmTokenUpdatedAt': DateTime.now().toIso8601String(),
      });
      print('✅ FCM token saved to Firestore');
    } catch (e) {
      print('❌ Failed to save FCM token: $e');
    }
  }

  /// Handle foreground messages
  static void _handleForegroundMessage(RemoteMessage message) {
    print('Received foreground message: ${message.messageId}');

    // Show local notification for foreground messages
    _showLocalNotification(
      title: message.notification?.title ?? 'DiabApp',
      body: message.notification?.body ?? '',
      payload: jsonEncode(message.data),
    );
  }

  /// Handle message opened app (from background or terminated)
  static void _handleMessageOpenedApp(RemoteMessage message) {
    print('Message opened app: ${message.messageId}');

    // Handle navigation based on message data
    final data = message.data;
    if (data.containsKey('type')) {
      _handleNotificationAction(data);
    }
  }

  /// Handle local notification tap
  static void _onLocalNotificationTap(NotificationResponse response) {
    print('Local notification tapped: ${response.payload}');

    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        _handleNotificationAction(data);
      } catch (e) {
        print('Failed to parse notification payload: $e');
      }
    }
  }

  /// Handle notification actions (navigation, etc.)
  static void _handleNotificationAction(Map<String, dynamic> data) {
    final type = data['type'] as String?;

    switch (type) {
      case 'medication_reminder':
        // Navigate to medication reminders screen
        // You can implement navigation logic here
        print('Navigate to medication reminders');
        break;
      case 'blood_sugar_reminder':
        // Navigate to log screen
        print('Navigate to blood sugar log');
        break;
      default:
        // Navigate to dashboard
        print('Navigate to dashboard');
    }
  }

  /// Show local notification
  static Future<void> _showLocalNotification({
    required String title,
    required String body,
    String? payload,
    int? id,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      'diabapp_channel',
      'DiabApp Notifications',
      channelDescription:
          'Notifications for medication reminders and health tracking',
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
      enableVibration: true,
      playSound: true,
      icon: '@mipmap/ic_launcher',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      id ?? DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title,
      body,
      details,
      payload: payload,
    );
  }

  /// Schedule blood sugar check reminder
  static Future<void> scheduleBloodSugarReminder({
    required int hoursAfterLastReading,
    DateTime? lastReadingTime,
  }) async {
    try {
      if (!_isInitialized) {
        print(
          '❌ NotificationService not initialized, attempting to initialize...',
        );
        await initialize();
      }

      // Cancel any existing blood sugar reminders
      await cancelBloodSugarReminders();

      // Calculate next reminder time
      final now = DateTime.now();
      final lastReading =
          lastReadingTime ??
          now.subtract(Duration(hours: hoursAfterLastReading));
      final nextReminderTime = lastReading.add(
        Duration(hours: hoursAfterLastReading),
      );

      // Only schedule if the reminder time is in the future
      if (nextReminderTime.isAfter(now)) {
        const id = 999999; // Fixed ID for blood sugar reminders
        final tzDateTime = tz.TZDateTime.from(nextReminderTime, tz.local);

        print('📅 Scheduling blood sugar reminder:');
        print('   - ID: $id');
        print('   - Hours after last reading: $hoursAfterLastReading');
        print('   - Last reading: $lastReading');
        print('   - Next reminder: $nextReminderTime');
        print('   - TZ DateTime: $tzDateTime');

        const androidDetails = AndroidNotificationDetails(
          'blood_sugar_reminders',
          'Blood Sugar Reminders',
          channelDescription:
              'Notifications to remind you to check blood sugar',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          icon: '@mipmap/ic_launcher',
        );

        const iosDetails = DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        );

        const details = NotificationDetails(
          android: androidDetails,
          iOS: iosDetails,
        );

        await _localNotifications.zonedSchedule(
          id,
          'Blood Sugar Check Reminder',
          'It\'s been $hoursAfterLastReading hours since your last glucose reading. Time to check your blood sugar!',
          tzDateTime,
          details,
          payload: jsonEncode({
            'type': 'blood_sugar_reminder',
            'hoursAfterLastReading': hoursAfterLastReading,
          }),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );

        print('✅ Successfully scheduled blood sugar reminder');
      } else {
        print('⏰ Blood sugar reminder time is in the past, not scheduling');
      }
    } catch (e) {
      print('❌ Failed to schedule blood sugar reminder: $e');
      rethrow;
    }
  }

  /// Cancel blood sugar reminders
  static Future<void> cancelBloodSugarReminders() async {
    const id = 999999; // Fixed ID for blood sugar reminders
    await _localNotifications.cancel(id);
    print('🗑️ Cancelled blood sugar reminders');
  }

  /// Reschedule blood sugar reminder after a new reading
  static Future<void> rescheduleBloodSugarReminderAfterReading({
    required int hoursInterval,
  }) async {
    try {
      // Get user's notification settings
      final userData = await FirestoreService.getUserData();
      final notificationsEnabled = userData?['notificationsEnabled'] ?? false;
      final bloodSugarCheckEnabled =
          userData?['bloodSugarCheckNotifications'] ?? false;

      if (!notificationsEnabled || !bloodSugarCheckEnabled) {
        print('🔕 Blood sugar notifications disabled, not rescheduling');
        return;
      }

      // Schedule next reminder
      await scheduleBloodSugarReminder(
        hoursAfterLastReading: hoursInterval,
        lastReadingTime: DateTime.now(),
      );
    } catch (e) {
      print('❌ Failed to reschedule blood sugar reminder: $e');
    }
  }

  /// Schedule a medication reminder notification
  static Future<void> scheduleMedicationReminder({
    required String medicationName,
    required String dosage,
    required DateTime scheduledTime,
    required String medicationId,
  }) async {
    try {
      if (!_isInitialized) {
        print(
          '❌ NotificationService not initialized, attempting to initialize...',
        );
        await initialize();
      }

      final id = medicationId.hashCode;
      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      print('📅 Scheduling notification:');
      print('   - ID: $id');
      print('   - Medication: $medicationName');
      print('   - Dosage: $dosage');
      print('   - Scheduled for: $scheduledTime');
      print('   - TZ DateTime: $tzDateTime');

      const androidDetails = AndroidNotificationDetails(
        'medication_reminders',
        'Medication Reminders',
        channelDescription: 'Notifications for medication reminders',
        importance: Importance.high,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        icon: '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _localNotifications.zonedSchedule(
        id,
        'Medication Reminder',
        'Time to take your $medicationName ($dosage)',
        tzDateTime,
        details,
        payload: jsonEncode({
          'type': 'medication_reminder',
          'medicationId': medicationId,
          'medicationName': medicationName,
        }),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );

      print('✅ Successfully scheduled notification for $medicationName');
    } catch (e) {
      print('❌ Failed to schedule notification for $medicationName: $e');
      rethrow;
    }
  }

  /// Cancel a medication reminder
  static Future<void> cancelMedicationReminder(String medicationId) async {
    final id = medicationId.hashCode;
    await _localNotifications.cancel(id);
  }

  /// Cancel all notifications
  static Future<void> cancelAllNotifications() async {
    await _localNotifications.cancelAll();
  }

  /// Check if notifications are enabled
  static Future<bool> areNotificationsEnabled() async {
    final settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus == AuthorizationStatus.authorized;
  }

  /// Get FCM token
  static Future<String?> getFCMToken() async {
    return await _messaging.getToken();
  }

  /// Get pending notifications (for debugging)
  static Future<void> debugPendingNotifications() async {
    try {
      final pendingNotifications = await _localNotifications
          .pendingNotificationRequests();
      print('🔍 === PENDING NOTIFICATIONS DEBUG ===');
      print('📊 Total pending notifications: ${pendingNotifications.length}');

      for (final notification in pendingNotifications) {
        print('📅 Notification ID: ${notification.id}');
        print('   - Title: ${notification.title}');
        print('   - Body: ${notification.body}');
        print('   - Payload: ${notification.payload}');
      }

      print('🔍 === END PENDING NOTIFICATIONS ===');
    } catch (e) {
      print('❌ Failed to get pending notifications: $e');
    }
  }

  /// Dispose resources
  static void dispose() {
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    _subscriptions.clear();
    _isInitialized = false;
  }
}

/// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('Background message received: ${message.messageId}');

  // Handle background message
  // Note: You can't show local notifications from background handler on iOS
  // The system will show the notification automatically
}
