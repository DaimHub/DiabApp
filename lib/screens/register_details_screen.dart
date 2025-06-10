import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../services/firestore_service.dart';

class RegisterDetailsScreen extends StatefulWidget {
  final String firstName;
  final String lastName;
  final String email;
  final String password;

  const RegisterDetailsScreen({
    super.key,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  @override
  State<RegisterDetailsScreen> createState() => _RegisterDetailsScreenState();
}

class _RegisterDetailsScreenState extends State<RegisterDetailsScreen> {
  bool _isLoading = false;
  String? _selectedDiabetesType;
  List<String> diabetesTypes = ['Type 1', 'Type 2', 'Gestational', 'Other'];

  String? _selectedHealthComponent;
  List<String> healthComponents = [
    'Blood Glucose',
    'Weight',
    'Activity',
    'Medication',
  ];

  Future<void> _completeRegistration() async {
    if (_selectedDiabetesType == null) {
      _showToast('Please select your diabetes type', ToastificationType.error);
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Save user profile data to Firestore
      final userData = {
        'firstName': widget.firstName,
        'lastName': widget.lastName,
        'email': widget.email,
        'diabetesType': _selectedDiabetesType!,
        'primaryHealthFocus': _selectedHealthComponent,
        'createdAt': FieldValue.serverTimestamp(),
        // Add default values for other settings
        'notificationsEnabled': true,
        'bloodSugarCheckNotifications': false,
        'medicationReminders': false,
        'glucoseUnit': 'mg/dL',
        'carbohydrateUnit': 'g',
        'targetGlucoseMin': 80,
        'targetGlucoseMax': 180,
      };

      final success = await FirestoreService.saveUserData(userData);

      if (!success) {
        throw Exception('Failed to save user profile data');
      }

      // Show success message
      _showToast(
        'Welcome to your diabetes journey!',
        ToastificationType.success,
      );

      // Wait a moment for the toast to show, then navigate to dashboard
      await Future.delayed(const Duration(milliseconds: 800));

      // Navigate to dashboard
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          '/dashboard',
          (route) => false,
        );
      }
    } catch (e) {
      _showToast(
        'An error occurred while setting up your profile. Please try again.',
        ToastificationType.error,
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showToast(String message, ToastificationType type) {
    final theme = Theme.of(context);

    String title;
    String description;
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ToastificationType.success:
        title = 'Profile Complete!';
        description = message;
        iconData = Icons.check_circle_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case ToastificationType.error:
        title = 'Profile Setup Failed';
        description = message;
        iconData = Icons.error_outline;
        iconColor = Colors.red[600]!;
        break;
      default:
        title = 'Notification';
        description = message;
        iconData = Icons.info_outline;
        iconColor = theme.colorScheme.primary;
    }

    toastification.show(
      context: context,
      type: type,
      style: ToastificationStyle.flat,
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
      description: Text(
        description,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: theme.brightness == Brightness.dark
              ? Colors.grey[300]
              : Colors.black54,
        ),
      ),
      alignment: Alignment.topCenter,
      autoCloseDuration: const Duration(seconds: 3),
      showProgressBar: false,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 50),
      borderRadius: SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 0.6),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      foregroundColor: theme.colorScheme.primary,
      borderSide: BorderSide(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF2A2A2A)
            : const Color(0xFFF0F1F7),
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
      icon: Icon(iconData, color: iconColor, size: 24),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    Container(
                      width: 44,
                      height: 44,
                      decoration: ShapeDecoration(
                        color: theme.brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0F1F7),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 14,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/dashboard',
                              (route) => false,
                            );
                          },
                          customBorder: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 14,
                              cornerSmoothing: 0.6,
                            ),
                          ),
                          child: const Center(
                            child: FaIcon(FontAwesomeIcons.xmark, size: 20),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    'Almost There! 🎯',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Text(
                    'Let\'s personalize your diabetes journey',
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What type of diabetes do you have?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 12),

                // Diabetes Type Selector Card
                _buildDiabetesTypeSelector(theme),

                const SizedBox(height: 30),
                const Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'What would you like to focus on?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose what matters most to you right now',
                  style: TextStyle(
                    fontSize: 14,
                    color: theme.textTheme.bodyMedium?.color,
                  ),
                ),
                const SizedBox(height: 12),

                // Health Focus Selector Card
                _buildHealthFocusSelector(theme),

                const SizedBox(height: 50),
                Container(
                  width: double.infinity,
                  height: 56,
                  decoration: ShapeDecoration(
                    color: theme.colorScheme.primary,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 16,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                    shadows: [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: _isLoading ? null : _completeRegistration,
                      customBorder: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                      child: Center(
                        child: _isLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text(
                                'Let\'s Get Started!',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDiabetesTypeSelector(ThemeData theme) {
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showDiabetesTypeDialog,
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
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 14,
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
                      _getIconForDiabetesType(_selectedDiabetesType),
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
                        'Diabetes Type',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedDiabetesType ?? 'Select your type',
                        style: TextStyle(
                          fontSize: 18,
                          color: _selectedDiabetesType != null
                              ? theme.textTheme.bodyLarge?.color
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForDiabetesType(String? type) {
    switch (type) {
      case 'Type 1':
        return FontAwesomeIcons.syringe;
      case 'Type 2':
        return FontAwesomeIcons.appleWhole;
      case 'Gestational':
        return FontAwesomeIcons.baby;
      case 'Other':
        return FontAwesomeIcons.stethoscope;
      default:
        return FontAwesomeIcons.pills;
    }
  }

  void _showDiabetesTypeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
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
                          child: const Center(
                            child: Icon(Icons.close, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Large diabetes type icon
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
                  child: const Center(
                    child: Icon(
                      Icons.medical_information,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Select Diabetes Type',
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
                  'Choose the type that best describes your diabetes diagnosis',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                ...diabetesTypes.map(
                  (type) => Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: ShapeDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF2A2A2A)
                              : const Color(0xFFF0F1F7),
                          shape: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 14,
                              cornerSmoothing: 0.6,
                            ),
                          ),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () {
                              setState(() {
                                _selectedDiabetesType = type;
                              });
                              Navigator.pop(context);
                            },
                            customBorder: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 14,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    height: 44,
                                    width: 44,
                                    decoration: ShapeDecoration(
                                      color:
                                          Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF3A3A3A)
                                          : Colors.white,
                                      shape: SmoothRectangleBorder(
                                        borderRadius: SmoothBorderRadius(
                                          cornerRadius: 12,
                                          cornerSmoothing: 0.6,
                                        ),
                                      ),
                                    ),
                                    child: Center(
                                      child: FaIcon(
                                        _getIconForDiabetesType(type),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      type,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHealthFocusSelector(ThemeData theme) {
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
            color: Colors.black.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _showHealthFocusDialog,
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
                  height: 50,
                  width: 50,
                  decoration: ShapeDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : Colors.white,
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 14,
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
                      _getIconForHealthFocus(_selectedHealthComponent),
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
                        'Health Focus',
                        style: TextStyle(
                          fontSize: 16,
                          color: theme.colorScheme.primary.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _selectedHealthComponent ??
                            'Pick your focus (optional)',
                        style: TextStyle(
                          fontSize: 18,
                          color: _selectedHealthComponent != null
                              ? theme.textTheme.bodyLarge?.color
                              : theme.textTheme.bodyMedium?.color,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: theme.textTheme.bodyMedium?.color?.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForHealthFocus(String? focus) {
    switch (focus) {
      case 'Blood Glucose':
        return FontAwesomeIcons.droplet;
      case 'Weight':
        return FontAwesomeIcons.scaleBalanced;
      case 'Activity':
        return FontAwesomeIcons.personRunning;
      case 'Medication':
        return FontAwesomeIcons.pills;
      default:
        return FontAwesomeIcons.bullseye;
    }
  }

  void _showHealthFocusDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: ShapeDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
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
                          child: const Center(
                            child: Icon(Icons.close, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Large health focus icon
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
                  child: const Center(
                    child: Icon(
                      Icons.health_and_safety,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Title
                Text(
                  'Choose Health Focus',
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
                  'Select the area you\'d like to focus on most (optional)',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 32),

                ...healthComponents
                    .map(
                      (component) => Column(
                        children: [
                          Container(
                            width: double.infinity,
                            decoration: ShapeDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF0F1F7),
                              shape: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 14,
                                  cornerSmoothing: 0.6,
                                ),
                              ),
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  setState(() {
                                    _selectedHealthComponent = component;
                                  });
                                  Navigator.pop(context);
                                },
                                customBorder: SmoothRectangleBorder(
                                  borderRadius: SmoothBorderRadius(
                                    cornerRadius: 14,
                                    cornerSmoothing: 0.6,
                                  ),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    children: [
                                      Container(
                                        height: 44,
                                        width: 44,
                                        decoration: ShapeDecoration(
                                          color:
                                              Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? const Color(0xFF3A3A3A)
                                              : Colors.white,
                                          shape: SmoothRectangleBorder(
                                            borderRadius: SmoothBorderRadius(
                                              cornerRadius: 12,
                                              cornerSmoothing: 0.6,
                                            ),
                                          ),
                                        ),
                                        child: Center(
                                          child: FaIcon(
                                            _getIconForHealthFocus(component),
                                            color: Theme.of(
                                              context,
                                            ).colorScheme.primary,
                                            size: 18,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Text(
                                          component,
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                            color: Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                      ),
                    )
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }
}
