import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../theme/theme_manager.dart';
import '../services/google_sign_in_service.dart';
import '../services/firestore_service.dart';
import '../providers/glucose_data_provider.dart';
import '../providers/medication_data_provider.dart';
import '../providers/glucose_trend_data_provider.dart';
import '../providers/log_history_data_provider.dart';
import '../services/overview_cache_service.dart';
import '../services/events_cache_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = false;
  bool _bloodSugarCheckEnabled = false;
  bool _medicationRemindersEnabled = false;

  // Unit preferences
  String _selectedBloodSugarUnit = 'mg/dL';
  String _selectedCarbohydrateUnit = 'grams';

  // User profile data
  String _userDiabetesType = 'Type 1';
  String _firstName = '';
  String _lastName = '';

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await FirestoreService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          // Notifications
          _notificationsEnabled = userData['notificationsEnabled'] ?? false;
          _bloodSugarCheckEnabled =
              userData['bloodSugarCheckNotifications'] ?? false;
          _medicationRemindersEnabled =
              userData['medicationReminders'] ?? false;

          // Units
          _selectedBloodSugarUnit = userData['glucoseUnit'] ?? 'mg/dL';
          // Convertir carbohydrateUnit de Firestore (g) vers l'interface (grams)
          final carbUnit = userData['carbohydrateUnit'] ?? 'g';
          _selectedCarbohydrateUnit = carbUnit == 'g' ? 'grams' : 'ounces';

          // Profile info
          _userDiabetesType = userData['diabetesType'] ?? 'Type 1';
          _firstName = userData['firstName'] ?? '';
          _lastName = userData['lastName'] ?? '';
        });
      } else {}
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                  const SizedBox(
                    width: 56,
                  ), // Same width as back button to center title
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),

                            // Profile Section
                            Text(
                              'Profile',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Profile card
                            Container(
                              decoration: ShapeDecoration(
                                color: theme.brightness == Brightness.dark
                                    ? const Color(0xFF2A2A2A)
                                    : const Color(0xFFF0F1F7),
                                shape: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 16,
                                    cornerSmoothing: 0.6,
                                  ),
                                  side: BorderSide(
                                    color: theme.brightness == Brightness.dark
                                        ? const Color(0xFF3A3A3A)
                                        : Colors.grey[200]!,
                                    width: 1,
                                  ),
                                ),
                                shadows: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.03),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () async {
                                    await Navigator.pushNamed(
                                      context,
                                      '/profile-edit',
                                    );
                                    await _loadUserData();
                                  },
                                  customBorder: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 16,
                                      cornerSmoothing: 0.6,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.all(20),
                                    child: Row(
                                      children: [
                                        // Profile image
                                        Container(
                                          height: 60,
                                          width: 60,
                                          decoration: ShapeDecoration(
                                            color:
                                                theme.brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF3A3A3A)
                                                : Colors.white,
                                            shape: SmoothRectangleBorder(
                                              borderRadius: SmoothBorderRadius(
                                                cornerRadius: 18,
                                                cornerSmoothing: 0.6,
                                              ),
                                            ),
                                            shadows: [
                                              BoxShadow(
                                                color: Colors.black.withOpacity(
                                                  0.05,
                                                ),
                                                blurRadius: 6,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: Center(
                                            child: FaIcon(
                                              FontAwesomeIcons.user,
                                              color: theme.colorScheme.primary,
                                              size: 24,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Profile info
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                _firstName.isNotEmpty &&
                                                        _lastName.isNotEmpty
                                                    ? '$_firstName $_lastName'
                                                    : FirebaseAuth
                                                              .instance
                                                              .currentUser
                                                              ?.displayName ??
                                                          'User',
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  fontWeight: FontWeight.bold,
                                                  color: theme
                                                      .textTheme
                                                      .titleLarge
                                                      ?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                FirebaseAuth
                                                        .instance
                                                        .currentUser
                                                        ?.email ??
                                                    'No Email',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color,
                                                ),
                                              ),
                                              const SizedBox(height: 8),
                                              Container(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4,
                                                    ),
                                                decoration: ShapeDecoration(
                                                  color: theme
                                                      .colorScheme
                                                      .primary
                                                      .withOpacity(0.1),
                                                  shape: SmoothRectangleBorder(
                                                    borderRadius:
                                                        SmoothBorderRadius(
                                                          cornerRadius: 8,
                                                          cornerSmoothing: 0.6,
                                                        ),
                                                  ),
                                                ),
                                                child: Text(
                                                  _userDiabetesType,
                                                  style: TextStyle(
                                                    color: theme
                                                        .colorScheme
                                                        .primary,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        // Edit profile button
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: ShapeDecoration(
                                            color:
                                                theme.brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF3A3A3A)
                                                : Colors.white,
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
                                              onTap: () async {
                                                await Navigator.pushNamed(
                                                  context,
                                                  '/profile-edit',
                                                );
                                                await _loadUserData();
                                              },
                                              customBorder:
                                                  SmoothRectangleBorder(
                                                    borderRadius:
                                                        SmoothBorderRadius(
                                                          cornerRadius: 10,
                                                          cornerSmoothing: 0.6,
                                                        ),
                                                  ),
                                              child: Center(
                                                child: FaIcon(
                                                  FontAwesomeIcons.penToSquare,
                                                  color:
                                                      theme.colorScheme.primary,
                                                  size: 16,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(height: 30),

                            // Appearance Section
                            Text(
                              'Appearance',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Consumer<ThemeManager>(
                              builder: (context, themeManager, child) {
                                return _buildValueSettingItem(
                                  icon: theme.brightness == Brightness.dark
                                      ? Icons.dark_mode
                                      : Icons.light_mode,
                                  title: 'Theme',
                                  description:
                                      'Choose between light, dark, or system theme',
                                  value: themeManager.currentThemeString,
                                  onTap: () {
                                    _showThemeSelectionDialog(
                                      context,
                                      themeManager,
                                    );
                                  },
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
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildToggleSettingItem(
                              icon: Icons.notifications,
                              title: 'Notifications',
                              description:
                                  'Receive notifications for blood sugar readings, medication',
                              value: _notificationsEnabled,
                              onChanged: (value) async {
                                setState(() {
                                  _notificationsEnabled = value;
                                  // Reset sub-notification settings when main notifications are disabled
                                  if (!value) {
                                    _bloodSugarCheckEnabled = false;
                                    _medicationRemindersEnabled = false;
                                  }
                                });

                                // Sauvegarder dans Firestore
                                await FirestoreService.updateNotificationSettings(
                                  notificationsEnabled: value,
                                  bloodSugarCheckNotifications: value
                                      ? _bloodSugarCheckEnabled
                                      : false,
                                  medicationReminders: value
                                      ? _medicationRemindersEnabled
                                      : false,
                                );
                              },
                            ),
                            const SizedBox(height: 12),

                            _buildToggleSettingItem(
                              icon: Icons.access_time,
                              title: 'Blood Sugar Check',
                              description:
                                  'Get reminders for checking your blood sugar levels.',
                              value: _bloodSugarCheckEnabled,
                              onChanged: _notificationsEnabled
                                  ? (value) async {
                                      setState(() {
                                        _bloodSugarCheckEnabled = value;
                                      });

                                      // Sauvegarder dans Firestore
                                      await FirestoreService.updateNotificationSettings(
                                        bloodSugarCheckNotifications: value,
                                      );
                                    }
                                  : null,
                              isDisabled: !_notificationsEnabled,
                            ),
                            const SizedBox(height: 12),

                            _buildMedicationReminderItem(),

                            const SizedBox(height: 30),

                            // Units Section
                            Text(
                              'Units',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildValueSettingItem(
                              icon: Icons.straighten,
                              title: 'Blood Sugar Units',
                              description:
                                  'Choose between mg/dL or mmol/L for blood sugar',
                              value: _selectedBloodSugarUnit,
                              onTap: () {
                                _showBloodSugarUnitsDialog();
                              },
                            ),
                            const SizedBox(height: 12),

                            _buildValueSettingItem(
                              icon: FontAwesomeIcons.scaleBalanced,
                              title: 'Carbohydrate Units',
                              description:
                                  'Select between grams or ounces for carbohydrate measurements.',
                              value: _selectedCarbohydrateUnit,
                              onTap: () {
                                _showCarbohydrateUnitsDialog();
                              },
                            ),

                            const SizedBox(height: 30),

                            // Connections Section
                            Text(
                              'Connections',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildDisabledSettingItem(
                              icon: Icons.bluetooth,
                              title: 'Device Connections',
                              description:
                                  'Connect with external devices like blood glucose meters.',
                              comingSoon: true,
                            ),
                            const SizedBox(height: 12),

                            _buildDisabledSettingItem(
                              icon: Icons.link,
                              title: 'App Integrations',
                              description:
                                  'Integrate with other health and fitness apps.',
                              comingSoon: true,
                            ),

                            const SizedBox(height: 30),

                            // Account Section
                            Text(
                              'Account',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.textTheme.headlineMedium?.color,
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
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeSelectionDialog(
    BuildContext context,
    ThemeManager themeManager,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: Theme.of(context).dialogBackgroundColor,
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
                      color: Theme.of(context).brightness == Brightness.dark
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
                        onTap: () => Navigator.pop(context),
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

              // Large theme icon
              Container(
                height: 80,
                width: 80,
                decoration: ShapeDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 24,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    Theme.of(context).brightness == Brightness.dark
                        ? Icons.dark_mode
                        : Icons.light_mode,
                    color: Colors.white,
                    size: 36,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Choose Theme',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
              const SizedBox(height: 8),

              // Description
              Text(
                'Select your preferred theme mode for the best experience',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Theme options
              _buildThemeOption(
                context,
                'Light',
                Icons.light_mode,
                themeManager.isLightMode,
                () => themeManager.setThemeMode(ThemeMode.light),
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context,
                'Dark',
                Icons.dark_mode,
                themeManager.isDarkMode,
                () => themeManager.setThemeMode(ThemeMode.dark),
              ),
              const SizedBox(height: 12),
              _buildThemeOption(
                context,
                'System',
                Icons.settings,
                themeManager.isSystemMode,
                () => themeManager.setThemeMode(ThemeMode.system),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(
    BuildContext context,
    String title,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            onTap();
            Navigator.pop(context);
          },
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: ShapeDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.iconTheme.color,
                      size: 20,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.textTheme.bodyLarge?.color,
                      fontWeight: isSelected
                          ? FontWeight.w600
                          : FontWeight.normal,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleSettingItem({
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
      decoration: ShapeDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                height: 44,
                width: 44,
                decoration: ShapeDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.white,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 12,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  shadows: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: icon is IconData
                      ? Icon(
                          icon,
                          color: disabled
                              ? theme.iconTheme.color?.withOpacity(0.5)
                              : theme.colorScheme.primary,
                          size: 22,
                        )
                      : FaIcon(
                          icon as IconData,
                          color: disabled
                              ? theme.iconTheme.color?.withOpacity(0.5)
                              : theme.colorScheme.primary,
                          size: 20,
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
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: disabled
                            ? theme.textTheme.titleMedium?.color?.withOpacity(
                                0.6,
                              )
                            : theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: disabled
                            ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                0.5,
                              )
                            : theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: value,
                  onChanged: disabled ? null : onChanged,
                  activeColor: Colors.white,
                  activeTrackColor: theme.colorScheme.primary,
                  inactiveThumbColor: Colors.white,
                  inactiveTrackColor: disabled
                      ? Colors.grey[400]
                      : Colors.grey[300],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildValueSettingItem({
    required IconData icon,
    required String title,
    required String description,
    required String value,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: icon is IconData
                        ? Icon(icon, color: theme.colorScheme.primary, size: 22)
                        : FaIcon(
                            icon as IconData,
                            color: theme.colorScheme.primary,
                            size: 20,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 8,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                      ),
                      child: Text(
                        value,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.5,
                      ),
                      size: 16,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisabledSettingItem({
    required IconData icon,
    required String title,
    required String description,
    required bool comingSoon,
  }) {
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              height: 44,
              width: 44,
              decoration: ShapeDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : Colors.white,
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 12,
                    cornerSmoothing: 0.6,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  icon,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  size: 22,
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
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleMedium?.color?.withOpacity(
                        0.6,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: ShapeDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 8,
                    cornerSmoothing: 0.6,
                  ),
                ),
              ),
              child: Text(
                comingSoon ? 'Coming Soon' : 'Disabled',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArrowSettingItem({
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200]!,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(icon, color: theme.colorScheme.primary, size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Icon(
                Icons.arrow_forward_ios,
                color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                size: 14,
              ),
            ],
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
      decoration: ShapeDecoration(
        color: isDestructive
            ? Colors.red.withOpacity(0.05)
            : theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: isDestructive
                ? Colors.red.withOpacity(0.3)
                : theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: ShapeDecoration(
                    color: isDestructive
                        ? Colors.red.withOpacity(0.1)
                        : theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      icon,
                      color: isDestructive
                          ? Colors.red[600]
                          : theme.colorScheme.primary,
                      size: 22,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: isDestructive
                              ? Colors.red[600]
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: theme.textTheme.bodyMedium?.color,
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

  Widget _buildLogoutSettingItem() {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _showLogoutConfirmation(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.red.withOpacity(0.3), width: 1.5),
            color: Colors.red.withOpacity(0.05),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(Icons.logout, color: Colors.red[600], size: 20),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Logout from the app',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context) {
    final theme = Theme.of(context);
    showDialog(context: context, builder: (context) => _LogoutDialog());
  }

  void _showBloodSugarUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: Theme.of(context).dialogBackgroundColor,
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
                  Text(
                    'Blood Sugar Units',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: ShapeDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
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
                        onTap: () => Navigator.pop(context),
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
              const SizedBox(height: 24),

              // Unit options
              _buildUnitOption(
                context,
                'mg/dL',
                'Milligrams per deciliter',
                Icons.straighten,
                _selectedBloodSugarUnit == 'mg/dL',
                () async {
                  setState(() {
                    _selectedBloodSugarUnit = 'mg/dL';
                  });

                  // Sauvegarder dans Firestore
                  await FirestoreService.updateUnits(glucoseUnit: 'mg/dL');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildUnitOption(
                context,
                'mmol/L',
                'Millimoles per liter',
                Icons.straighten,
                _selectedBloodSugarUnit == 'mmol/L',
                () async {
                  setState(() {
                    _selectedBloodSugarUnit = 'mmol/L';
                  });

                  // Sauvegarder dans Firestore
                  await FirestoreService.updateUnits(glucoseUnit: 'mmol/L');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUnitOption(
    BuildContext context,
    String value,
    String description,
    IconData icon,
    bool isSelected,
    VoidCallback onTap,
  ) {
    final theme = Theme.of(context);
    return Container(
      decoration: ShapeDecoration(
        color: isSelected
            ? theme.colorScheme.primary.withOpacity(0.1)
            : theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 14,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  height: 40,
                  width: 40,
                  decoration: ShapeDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withOpacity(0.1)
                        : theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: Center(
                    child: icon == FontAwesomeIcons.scaleBalanced
                        ? FaIcon(
                            icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                            size: 18,
                          )
                        : Icon(
                            icon,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.iconTheme.color,
                            size: 20,
                          ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        value,
                        style: TextStyle(
                          color: isSelected
                              ? theme.colorScheme.primary
                              : theme.textTheme.bodyLarge?.color,
                          fontWeight: isSelected
                              ? FontWeight.w600
                              : FontWeight.normal,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 13,
                          color: theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.check, color: Colors.white, size: 14),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCarbohydrateUnitsDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: ShapeDecoration(
            color: Theme.of(context).dialogBackgroundColor,
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
                  Text(
                    'Carbohydrate Units',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: ShapeDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
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
                        onTap: () => Navigator.pop(context),
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
              const SizedBox(height: 24),

              // Unit options
              _buildUnitOption(
                context,
                'grams',
                'Grams (g) - Standard metric unit',
                FontAwesomeIcons.scaleBalanced,
                _selectedCarbohydrateUnit == 'grams',
                () async {
                  setState(() {
                    _selectedCarbohydrateUnit = 'grams';
                  });

                  // Sauvegarder dans Firestore (convertir grams -> g)
                  await FirestoreService.updateUnits(carbohydrateUnit: 'g');
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildUnitOption(
                context,
                'ounces',
                'Ounces (oz) - Imperial unit',
                FontAwesomeIcons.scaleBalanced,
                _selectedCarbohydrateUnit == 'ounces',
                () async {
                  setState(() {
                    _selectedCarbohydrateUnit = 'ounces';
                  });

                  // Sauvegarder dans Firestore (convertir ounces -> oz)
                  await FirestoreService.updateUnits(carbohydrateUnit: 'oz');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMedicationReminderItem() {
    final theme = Theme.of(context);
    final disabled = !_notificationsEnabled;

    return Container(
      decoration: ShapeDecoration(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        shape: SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius(
            cornerRadius: 16,
            cornerSmoothing: 0.6,
          ),
          side: BorderSide(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF3A3A3A)
                : Colors.grey[200]!,
            width: 1,
          ),
        ),
        shadows: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: disabled
              ? null
              : () async {
                  await Navigator.pushNamed(context, '/medication-reminders');
                  // Recharger les données après modification des médicaments
                  await _loadUserData();
                },
          customBorder: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 16,
              cornerSmoothing: 0.6,
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 44,
                  width: 44,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 12,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.pills,
                      color: disabled
                          ? theme.iconTheme.color?.withOpacity(0.5)
                          : theme.colorScheme.primary,
                      size: 20,
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
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: disabled
                              ? theme.textTheme.titleMedium?.color?.withOpacity(
                                  0.6,
                                )
                              : theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Manage your medication schedule and reminders',
                        style: TextStyle(
                          fontSize: 14,
                          color: disabled
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                  0.5,
                                )
                              : theme.textTheme.bodyMedium?.color,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: ShapeDecoration(
                        color: disabled
                            ? Colors.grey.withOpacity(0.1)
                            : _medicationRemindersEnabled
                            ? theme.colorScheme.primary.withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 8,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                      ),
                      child: Text(
                        _medicationRemindersEnabled ? 'Enabled' : 'Disabled',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: disabled
                              ? theme.textTheme.bodyMedium?.color?.withOpacity(
                                  0.5,
                                )
                              : _medicationRemindersEnabled
                              ? theme.colorScheme.primary
                              : Colors.grey[600],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios,
                      color: disabled
                          ? theme.textTheme.bodyMedium?.color?.withOpacity(0.3)
                          : theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                      size: 16,
                    ),
                  ],
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
      // Clear all cached data from providers to prevent data leakage

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

      // Clear all provider caches
      glucoseProvider.clearCache();
      medicationProvider.clearCache();
      trendProvider.clearCache();
      logHistoryProvider.clearCache();

      // Also clear legacy cache services (if still in use)
      OverviewCacheService().clearCache();
      EventsCacheService().clearCache();

      // Use GoogleSignInService to handle logout from both Google and Firebase
      await GoogleSignInService.signOut();

      // Navigate to welcome screen and clear all previous routes
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
      }
    } catch (e) {
      // If logout fails, show error and close dialog
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to logout. Please try again.'),
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
          color: theme.dialogBackgroundColor,
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

            // Logout button (full width)
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
