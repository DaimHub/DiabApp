import 'dart:async';
import 'firestore_service.dart';
import 'notification_service.dart';

class BloodSugarReminderService {
  static const int _defaultReminderIntervalHours = 6; // Default 6 hours

  /// Initialize blood sugar reminders based on user settings
  static Future<void> initializeReminders() async {
    try {
      // Get user settings
      final userData = await FirestoreService.getUserData();
      final notificationsEnabled = userData?['notificationsEnabled'] ?? false;
      final bloodSugarCheckEnabled =
          userData?['bloodSugarCheckNotifications'] ?? false;
      final reminderInterval =
          userData?['bloodSugarReminderInterval'] ??
          _defaultReminderIntervalHours;

      if (!notificationsEnabled || !bloodSugarCheckEnabled) {
        print('🔕 Blood sugar reminders disabled in settings');
        await NotificationService.cancelBloodSugarReminders();
        return;
      }

      // Get last glucose reading
      final lastReading = await _getLastGlucoseReading();

      if (lastReading != null) {
        final lastReadingTime = lastReading['date'] as DateTime;
        await NotificationService.scheduleBloodSugarReminder(
          hoursAfterLastReading: reminderInterval,
          lastReadingTime: lastReadingTime,
        );
        print(
          '✅ Blood sugar reminders initialized with last reading: $lastReadingTime',
        );
      } else {
        // No previous readings, schedule first reminder
        await NotificationService.scheduleBloodSugarReminder(
          hoursAfterLastReading: reminderInterval,
        );
        print('✅ Blood sugar reminders initialized (no previous readings)');
      }
    } catch (e) {
      print('❌ Failed to initialize blood sugar reminders: $e');
    }
  }

  /// Called when a new glucose reading is logged
  static Future<void> onGlucoseReadingLogged() async {
    try {
      // Get user settings
      final userData = await FirestoreService.getUserData();
      final notificationsEnabled = userData?['notificationsEnabled'] ?? false;
      final bloodSugarCheckEnabled =
          userData?['bloodSugarCheckNotifications'] ?? false;
      final reminderInterval =
          userData?['bloodSugarReminderInterval'] ??
          _defaultReminderIntervalHours;

      if (!notificationsEnabled || !bloodSugarCheckEnabled) {
        print('🔕 Blood sugar reminders disabled, not rescheduling');
        return;
      }

      // Reschedule next reminder
      await NotificationService.rescheduleBloodSugarReminderAfterReading(
        hoursInterval: reminderInterval,
      );

      print(
        '✅ Blood sugar reminder rescheduled for $reminderInterval hours from now',
      );
    } catch (e) {
      print('❌ Failed to reschedule blood sugar reminder: $e');
    }
  }

  /// Update reminder settings
  static Future<void> updateReminderSettings({
    required bool enabled,
    int? intervalHours,
  }) async {
    try {
      if (!enabled) {
        // Cancel all blood sugar reminders
        await NotificationService.cancelBloodSugarReminders();
        print('🔕 Blood sugar reminders disabled');
        return;
      }

      // Save new interval to user settings if provided
      if (intervalHours != null) {
        await FirestoreService.saveUserData({
          'bloodSugarReminderInterval': intervalHours,
        });
      }

      // Reinitialize reminders with new settings
      await initializeReminders();
      print('✅ Blood sugar reminder settings updated');
    } catch (e) {
      print('❌ Failed to update blood sugar reminder settings: $e');
    }
  }

  /// Get the last glucose reading from Firestore
  static Future<Map<String, dynamic>?> _getLastGlucoseReading() async {
    try {
      final events = await FirestoreService.getEvents(
        type: 'glucose',
        limit: 1,
      );

      if (events.isNotEmpty) {
        return events.first;
      }
      return null;
    } catch (e) {
      print('❌ Failed to get last glucose reading: $e');
      return null;
    }
  }

  /// Get time since last glucose reading
  static Future<Duration?> getTimeSinceLastReading() async {
    try {
      final lastReading = await _getLastGlucoseReading();
      if (lastReading != null) {
        final lastReadingTime = lastReading['date'] as DateTime;
        return DateTime.now().difference(lastReadingTime);
      }
      return null;
    } catch (e) {
      print('❌ Failed to get time since last reading: $e');
      return null;
    }
  }

  /// Check if user should be reminded to check blood sugar
  static Future<bool> shouldRemindUser() async {
    try {
      final userData = await FirestoreService.getUserData();
      final notificationsEnabled = userData?['notificationsEnabled'] ?? false;
      final bloodSugarCheckEnabled =
          userData?['bloodSugarCheckNotifications'] ?? false;
      final reminderInterval =
          userData?['bloodSugarReminderInterval'] ??
          _defaultReminderIntervalHours;

      if (!notificationsEnabled || !bloodSugarCheckEnabled) {
        return false;
      }

      final timeSinceLastReading = await getTimeSinceLastReading();
      if (timeSinceLastReading == null) {
        return true; // No readings yet, should remind
      }

      return timeSinceLastReading.inHours >= reminderInterval;
    } catch (e) {
      print('❌ Failed to check if user should be reminded: $e');
      return false;
    }
  }
}
