import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';

import '../providers/auth_provider.dart' as auth;
import '../providers/glucose_data_provider.dart';
import '../providers/medication_data_provider.dart';
import '../providers/glucose_trend_data_provider.dart';
import '../providers/log_history_data_provider.dart';
import '../providers/settings_data_provider.dart';
import '../services/overview_cache_service.dart';
import '../services/events_cache_service.dart';
import '../services/blood_sugar_reminder_service.dart';
import 'export_data_screen.dart';
import 'profile_edit_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final settingsProvider = Provider.of<SettingsDataProvider>(
      context,
      listen: false,
    );
    await settingsProvider.getUserSettingsData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(color: theme.scaffoldBackgroundColor),
              child: Row(
                children: [
                  // Back Button
                  Container(
                    decoration: ShapeDecoration(
                      color: theme.brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0F1F7),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 12,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => Navigator.pop(context),
                        customBorder: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(Icons.arrow_back, size: 20),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Title
                  Expanded(
                    child: Text(
                      'Settings',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.headlineMedium?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 56),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Consumer<SettingsDataProvider>(
                builder: (context, settingsProvider, child) {
                  return settingsProvider.isLoading && !settingsProvider.hasData
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20.0,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 20),

                                // Profile card
                                _buildProfileCard(theme, settingsProvider),

                                const SizedBox(height: 30),

                                // Data Management Section
                                Text(
                                  'Data Management',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.textTheme.headlineMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildActionSettingItem(
                                  icon: Icons.download,
                                  title: 'Export Data',
                                  description:
                                      'Export your glucose readings and health data',
                                  isDestructive: false,
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const ExportDataScreen(),
                                      ),
                                    );
                                  },
                                ),

                                const SizedBox(height: 30),

                                // Notifications Section
                                Text(
                                  'Notifications',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.textTheme.headlineMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildToggleSettingItem(
                                  settingsProvider,
                                  icon: Icons.notifications,
                                  title: 'Notifications',
                                  description:
                                      'Receive notifications for blood sugar readings, medication',
                                  value: settingsProvider.notificationsEnabled,
                                  onChanged: (value) async {
                                    // Check if user has any enabled medications
                                    bool hasEnabledMedications = false;
                                    if (value) {
                                      final medications =
                                          settingsProvider
                                                  .userData?['medications']
                                              as List<dynamic>?;
                                      if (medications != null &&
                                          medications.isNotEmpty) {
                                        hasEnabledMedications = medications.any(
                                          (med) => med['enabled'] == true,
                                        );
                                      }
                                    }

                                    await settingsProvider.updateNotificationSettings(
                                      notificationsEnabled: value,
                                      bloodSugarCheckNotifications: value
                                          ? settingsProvider
                                                .bloodSugarCheckEnabled
                                          : false,
                                      // When disabling notifications, disable medication reminders
                                      // When enabling notifications, restore medication reminders if user has enabled medications
                                      medicationReminders: value
                                          ? hasEnabledMedications
                                          : false,
                                    );

                                    // Update blood sugar reminder service
                                    await BloodSugarReminderService.updateReminderSettings(
                                      enabled:
                                          value &&
                                          settingsProvider
                                              .bloodSugarCheckEnabled,
                                    );
                                  },
                                ),

                                const SizedBox(height: 12),

                                _buildToggleSettingItem(
                                  settingsProvider,
                                  icon: Icons.access_time,
                                  title: 'Blood Sugar Check',
                                  description:
                                      'Get reminders for checking your blood sugar levels every 6 hours.',
                                  value:
                                      settingsProvider.bloodSugarCheckEnabled,
                                  onChanged:
                                      settingsProvider.notificationsEnabled
                                      ? (value) async {
                                          await settingsProvider
                                              .updateNotificationSettings(
                                                bloodSugarCheckNotifications:
                                                    value,
                                              );

                                          // Update blood sugar reminder service
                                          await BloodSugarReminderService.updateReminderSettings(
                                            enabled: value,
                                          );
                                        }
                                      : null,
                                  isDisabled:
                                      !settingsProvider.notificationsEnabled,
                                ),

                                const SizedBox(height: 12),

                                _buildMedicationReminderItem(settingsProvider),

                                const SizedBox(height: 30),

                                // Account Section
                                Text(
                                  'Account',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color:
                                        theme.textTheme.headlineMedium?.color,
                                  ),
                                ),
                                const SizedBox(height: 16),

                                _buildActionSettingItem(
                                  icon: Icons.logout,
                                  title: 'Logout',
                                  description: 'Sign out from your account',
                                  isDestructive: true,
                                  onTap: () {
                                    showDialog(
                                      context: context,
                                      builder: (context) => _LogoutDialog(),
                                    );
                                  },
                                ),

                                const SizedBox(height: 100),
                              ],
                            ),
                          ),
                        );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileCard(
    ThemeData theme,
    SettingsDataProvider settingsProvider,
  ) {
    return Container(
      width: double.infinity,
      decoration: ShapeDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 20,
            cornerSmoothing: 0.6,
          ),
        ),
        shadows: [
          BoxShadow(
            color: theme.brightness == Brightness.dark
                ? Colors.black.withOpacity(0.3)
                : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ProfileEditScreen(),
              ),
            );
          },
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                // Large profile avatar
                Container(
                  height: 80,
                  width: 80,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.primary,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 24,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.user,
                      color: Colors.white,
                      size: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 20),

                // User info section
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User name
                      Text(
                        settingsProvider.getUserDisplayName(),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.headlineMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // User email
                      Text(
                        settingsProvider.getUserEmail(),
                        style: TextStyle(
                          fontSize: 15,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Diabetes type badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: ShapeDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: 0.1,
                          ),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 10,
                              cornerSmoothing: 0.6,
                            ),
                          ),
                        ),
                        child: Text(
                          settingsProvider.userDiabetesType,
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSettingItem(
    SettingsDataProvider settingsProvider, {
    required IconData icon,
    required String title,
    required String description,
    required bool value,
    required Function(bool)? onChanged,
    bool? isDisabled,
  }) {
    final theme = Theme.of(context);
    final disabled = isDisabled ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {}, // Empty onTap to enable ripple without action
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFF0F1F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: disabled
                          ? theme.iconTheme.color?.withOpacity(0.5)
                          : theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: disabled
                              ? theme.textTheme.titleMedium?.color?.withOpacity(
                                  0.6,
                                )
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: disabled
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                  0.5,
                                )
                              : (theme.brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: value,
                  onChanged: disabled ? null : onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: disabled
                      ? Colors.grey[400]
                      : Colors.grey[300],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationReminderItem(SettingsDataProvider settingsProvider) {
    final theme = Theme.of(context);
    final disabled = !settingsProvider.notificationsEnabled;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled
              ? null
              : () async {
                  await Navigator.pushNamed(context, '/medication-reminders');
                  // Invalidate settings cache to refresh medication reminders status
                  final settingsProvider = Provider.of<SettingsDataProvider>(
                    context,
                    listen: false,
                  );
                  settingsProvider.invalidateCache();
                  await _loadUserData();
                },
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFF0F1F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.pills,
                      color: disabled
                          ? theme.iconTheme.color?.withOpacity(0.5)
                          : theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Medication Reminders',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: disabled
                              ? theme.textTheme.titleMedium?.color?.withOpacity(
                                  0.6,
                                )
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage your medication schedule and reminders',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: disabled
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                  0.5,
                                )
                              : (theme.brightness == Brightness.dark
                                    ? Colors.white70
                                    : Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  settingsProvider.medicationRemindersEnabled
                      ? 'Enabled'
                      : 'Disabled',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: disabled
                        ? theme.textTheme.bodyMedium?.color?.withOpacity(0.5)
                        : settingsProvider.medicationRemindersEnabled
                        ? theme.colorScheme.primary
                        : (theme.brightness == Brightness.dark
                              ? Colors.white60
                              : Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionSettingItem({
    required IconData icon,
    required String title,
    required String description,
    required bool isDestructive,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : (theme.brightness == Brightness.dark
                              ? const Color(0xFF3A3A3A)
                              : const Color(0xFFF0F1F7)),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isDestructive
                          ? Colors.red[600]
                          : theme.colorScheme.primary,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: isDestructive
                              ? Colors.red[600]
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.brightness == Brightness.dark
                              ? Colors.white70
                              : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LogoutDialog extends StatefulWidget {
  @override
  State<_LogoutDialog> createState() => _LogoutDialogState();
}

class _LogoutDialogState extends State<_LogoutDialog> {
  bool _isLoading = false;

  Future<void> _logout() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Clear all cached data from providers
      final glucoseProvider = Provider.of<GlucoseDataProvider>(
        context,
        listen: false,
      );
      final medicationProvider = Provider.of<MedicationDataProvider>(
        context,
        listen: false,
      );
      final trendProvider = Provider.of<GlucoseTrendDataProvider>(
        context,
        listen: false,
      );
      final logHistoryProvider = Provider.of<LogHistoryDataProvider>(
        context,
        listen: false,
      );
      final settingsProvider = Provider.of<SettingsDataProvider>(
        context,
        listen: false,
      );

      // Clear all provider caches
      glucoseProvider.clearCache();
      medicationProvider.clearCache();
      trendProvider.clearCache();
      logHistoryProvider.clearCache();
      settingsProvider.clearCache();

      // Clear legacy cache services
      OverviewCacheService().clearCache();
      EventsCacheService().clearCache();

      // Sign out using AuthProvider
      final authProvider = Provider.of<auth.AuthProvider>(
        context,
        listen: false,
      );
      await authProvider.signOut();

      // Navigate back to welcome screen after logout
      if (mounted) {
        // Close the dialog and navigate back to main app (which will now show welcome screen)
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to logout. Please try again.'),
            backgroundColor: Colors.red[500],
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: ShapeDecoration(
          color: theme.scaffoldBackgroundColor,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 20,
              cornerSmoothing: 0.6,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with close button
            Row(
              children: [
                const Spacer(),
                Container(
                  width: 36,
                  height: 36,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF0F1F7),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : () => Navigator.pop(context),
                      customBorder: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 10,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      child: const Center(child: Icon(Icons.close, size: 18)),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Large logout icon
            Container(
              height: 80,
              width: 80,
              decoration: ShapeDecoration(
                color: Colors.red[500],
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 24,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Center(
                child: Icon(Icons.logout, color: Colors.white, size: 36),
              ),
            ),
            const SizedBox(height: 24),

            // Title
            Text(
              'Logout',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),

            // Content
            Text(
              'Are you sure you want to logout from your account?',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 32),

            // Logout button
            Container(
              width: double.infinity,
              height: 50,
              decoration: ShapeDecoration(
                color: Colors.red[500],
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 14,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _logout,
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 14,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          )
                        : const Text(
                            'Logout',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
