import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'notification_service.dart';
import '../providers/medication_data_provider.dart';
import '../providers/settings_data_provider.dart';

class MedicationNotificationManager {
  /// Debug function to check notification status
  static Future<void> debugNotificationStatus(BuildContext context) async {
    print('🔍 === NOTIFICATION DEBUG STATUS ===');

    try {
      // Check if notifications are enabled at system level
      final systemEnabled = await NotificationService.areNotificationsEnabled();
      print('📱 System notifications enabled: $systemEnabled');

      // Get medication data
      final medicationProvider = Provider.of<MedicationDataProvider>(
        context,
        listen: false,
      );
      final medications = await medicationProvider.getMedicationData();
      print('💊 Total medications: ${medications.length}');

      // Get notification settings
      final settingsProvider = Provider.of<SettingsDataProvider>(
        context,
        listen: false,
      );
      final settingsData = await settingsProvider.getUserSettingsData();

      final notificationsEnabled =
          settingsData?['notificationsEnabled'] ?? true;
      final medicationReminders = settingsData?['medicationReminders'] ?? true;

      print('⚙️ App notifications enabled: $notificationsEnabled');
      print('💊 Medication reminders enabled: $medicationReminders');

      // Check each medication
      int enabledCount = 0;
      for (int i = 0; i < medications.length; i++) {
        final medication = medications[i];
        final enabled = medication['enabled'] ?? false;
        final name = medication['name'] ?? 'Unknown';
        final timeData = medication['time'] as Map<String, dynamic>?;
        final days = medication['days'] as List<dynamic>? ?? [];

        if (enabled) enabledCount++;

        print('💊 Medication $i: $name');
        print('   - Enabled: $enabled');
        print('   - Time: ${timeData?['hour']}:${timeData?['minute']}');
        print('   - Days: $days');
      }

      print('✅ Enabled medications: $enabledCount');

      // Check if we should be scheduling notifications
      final shouldSchedule =
          systemEnabled &&
          notificationsEnabled &&
          medicationReminders &&
          enabledCount > 0;
      print('🎯 Should schedule notifications: $shouldSchedule');

      // Check pending notifications
      await NotificationService.debugPendingNotifications();
    } catch (e) {
      print('❌ Debug error: $e');
    }

    print('🔍 === END DEBUG STATUS ===');
  }

  /// Schedule notifications for all active medications
  static Future<void> scheduleAllMedications(
    BuildContext context, {
    bool silent = false,
  }) async {
    try {
      if (!silent) {
        print('🔄 Starting medication notification scheduling...');
      }

      // Get medication data
      final medicationProvider = Provider.of<MedicationDataProvider>(
        context,
        listen: false,
      );
      final medications = await medicationProvider.getMedicationData();

      // Get notification settings
      final settingsProvider = Provider.of<SettingsDataProvider>(
        context,
        listen: false,
      );
      final settingsData = await settingsProvider.getUserSettingsData();

      final notificationsEnabled =
          settingsData?['notificationsEnabled'] ?? true;
      final medicationReminders = settingsData?['medicationReminders'] ?? true;

      if (!silent) {
        print('📊 Found ${medications.length} medications');
        print('⚙️ Notifications enabled: $notificationsEnabled');
        print('💊 Medication reminders enabled: $medicationReminders');
      }

      // Don't schedule if notifications are disabled
      if (!notificationsEnabled || !medicationReminders) {
        if (!silent) {
          print('📱 Medication notifications are disabled in settings');
        }
        return;
      }

      // Check system permissions
      final systemEnabled = await NotificationService.areNotificationsEnabled();
      if (!systemEnabled) {
        if (!silent) {
          print('❌ System notifications are disabled');
        }
        return;
      }

      // Cancel all existing medication notifications first
      await NotificationService.cancelAllNotifications();
      if (!silent) {
        print('🗑️ Cancelled all existing notifications');
      }

      int scheduledCount = 0;
      final now = DateTime.now();

      // Schedule notifications for each active medication
      for (final medication in medications) {
        if (medication['enabled'] != true) continue;

        final medicationName = medication['name'] as String? ?? 'Medication';
        final dosage = medication['dosage'] as String? ?? '';
        final timeData = medication['time'] as Map<String, dynamic>?;
        final days = medication['days'] as List<dynamic>? ?? [];

        if (timeData == null) {
          if (!silent) {
            print('⚠️ Skipping $medicationName - no time data');
          }
          continue;
        }

        final hour = timeData['hour'] as int? ?? 9;
        final minute = timeData['minute'] as int? ?? 0;

        if (!silent) {
          print(
            '💊 Scheduling $medicationName at $hour:${minute.toString().padLeft(2, '0')} on days: $days',
          );
        }

        // Schedule for next 30 days (covers most app usage patterns)
        for (int dayOffset = 0; dayOffset < 30; dayOffset++) {
          final scheduledDate = now.add(Duration(days: dayOffset));
          final dayName = _getDayName(scheduledDate.weekday);

          // Check if medication should be taken on this day
          if (!days.contains(dayName)) continue;

          final scheduledDateTime = DateTime(
            scheduledDate.year,
            scheduledDate.month,
            scheduledDate.day,
            hour,
            minute,
          );

          // Don't schedule for past times
          if (scheduledDateTime.isBefore(now)) continue;

          // Create unique ID for this notification
          final medicationId =
              '${medicationName}_${hour}_${minute}_${scheduledDate.toString().split(' ')[0]}';

          try {
            await NotificationService.scheduleMedicationReminder(
              medicationName: medicationName,
              dosage: dosage.isNotEmpty ? dosage : 'Take your medication',
              scheduledTime: scheduledDateTime,
              medicationId: medicationId,
            );

            scheduledCount++;

            if (!silent && dayOffset < 3) {
              // Only log first few days to avoid spam
              print('📅 Scheduled for ${scheduledDateTime.toString()}');
            }
          } catch (e) {
            if (!silent) {
              print(
                '❌ Failed to schedule notification for $medicationName: $e',
              );
            }
          }
        }
      }

      if (!silent) {
        print(
          '✅ Successfully scheduled $scheduledCount medication notifications for ${medications.length} medications',
        );
      }
    } catch (e) {
      if (!silent) {
        print('❌ Failed to schedule medication notifications: $e');
      }
    }
  }

  /// Cancel notifications for a specific medication
  static Future<void> cancelMedicationNotifications(
    String medicationName,
  ) async {
    try {
      // Since we can't easily cancel specific medication notifications,
      // we'll need to reschedule all medications except the one being cancelled
      // This is handled by calling scheduleAllMedications after medication deletion
      print('📱 Medication notifications will be rescheduled');
    } catch (e) {
      print('❌ Failed to cancel medication notifications: $e');
    }
  }

  /// Send a test notification
  static Future<void> testMedicationNotification() async {
    try {
      final testTime = DateTime.now().add(const Duration(seconds: 5));

      await NotificationService.scheduleMedicationReminder(
        medicationName: 'Test Medication',
        dosage: '1 tablet',
        scheduledTime: testTime,
        medicationId:
            'test_notification_${DateTime.now().millisecondsSinceEpoch}',
      );

      print('✅ Test notification scheduled for 5 seconds from now');
    } catch (e) {
      print('❌ Failed to schedule test notification: $e');
    }
  }

  /// Get day name from weekday number (1 = Monday, 7 = Sunday)
  static String _getDayName(int weekday) {
    switch (weekday) {
      case 1:
        return 'Monday';
      case 2:
        return 'Tuesday';
      case 3:
        return 'Wednesday';
      case 4:
        return 'Thursday';
      case 5:
        return 'Friday';
      case 6:
        return 'Saturday';
      case 7:
        return 'Sunday';
      default:
        return 'Monday';
    }
  }
}
