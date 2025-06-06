import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
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
  List<String> _diabetesTypes = ['Type 1', 'Type 2', 'Gestational', 'Other'];

  String? _selectedHealthComponent;
  List<String> _healthComponents = [
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
      borderRadius: BorderRadius.circular(10),
      backgroundColor: theme.cardColor,
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
                    IconButton(
                      icon: const FaIcon(FontAwesomeIcons.xmark, size: 24),
                      onPressed: () {
                        Navigator.pushNamedAndRemoveUntil(
                          context,
                          '/dashboard',
                          (route) => false,
                        );
                      },
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
                ElevatedButton(
                  onPressed: _isLoading ? null : _completeRegistration,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5D74FB),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Let\'s Get Started!',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
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
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _showDiabetesTypeDialog,
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
                  child: FaIcon(
                    _getIconForDiabetesType(_selectedDiabetesType),
                    color: theme.colorScheme.primary,
                    size: 18,
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
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedDiabetesType ?? 'Select your type',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDiabetesType != null
                            ? theme.textTheme.bodyLarge?.color
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
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
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                children: [
                  Text(
                    'Diabetes Type',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF0F1F7),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).iconTheme.color,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Diabetes type options
              _buildDiabetesTypeOption(
                'Type 1',
                'Insulin-dependent diabetes',
                FontAwesomeIcons.syringe,
              ),
              const SizedBox(height: 12),
              _buildDiabetesTypeOption(
                'Type 2',
                'Non-insulin-dependent diabetes',
                FontAwesomeIcons.appleWhole,
              ),
              const SizedBox(height: 12),
              _buildDiabetesTypeOption(
                'Gestational',
                'Diabetes during pregnancy',
                FontAwesomeIcons.baby,
              ),
              const SizedBox(height: 12),
              _buildDiabetesTypeOption(
                'Other',
                'Other type of diabetes',
                FontAwesomeIcons.stethoscope,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDiabetesTypeOption(
    String type,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedDiabetesType == type;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedDiabetesType = type;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
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
    );
  }

  Widget _buildHealthFocusSelector(ThemeData theme) {
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: _showHealthFocusDialog,
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
                  child: FaIcon(
                    _getIconForHealthFocus(_selectedHealthComponent),
                    color: theme.colorScheme.primary,
                    size: 18,
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
                        fontSize: 14,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedHealthComponent ?? 'Pick your focus (optional)',
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedHealthComponent != null
                            ? theme.textTheme.bodyLarge?.color
                            : theme.textTheme.bodyMedium?.color,
                        fontWeight: FontWeight.w500,
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
      builder: (context) => Dialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with close button
              Row(
                children: [
                  Text(
                    'Health Focus',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.headlineMedium?.color,
                    ),
                  ),
                  const Spacer(),
                  Material(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? const Color(0xFF2A2A2A)
                        : const Color(0xFFF0F1F7),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        child: Icon(
                          Icons.close,
                          color: Theme.of(context).iconTheme.color,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Health focus options
              _buildHealthFocusOption(
                'Blood Glucose',
                'Monitor and track your blood sugar levels',
                FontAwesomeIcons.droplet,
              ),
              const SizedBox(height: 12),
              _buildHealthFocusOption(
                'Weight',
                'Track your weight and body measurements',
                FontAwesomeIcons.scaleBalanced,
              ),
              const SizedBox(height: 12),
              _buildHealthFocusOption(
                'Activity',
                'Monitor physical activity and exercise',
                FontAwesomeIcons.personRunning,
              ),
              const SizedBox(height: 12),
              _buildHealthFocusOption(
                'Medication',
                'Track medications and treatment plans',
                FontAwesomeIcons.pills,
              ),
              const SizedBox(height: 16),

              // Clear selection option
              _buildClearSelectionOption(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthFocusOption(
    String focus,
    String description,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    final isSelected = _selectedHealthComponent == focus;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedHealthComponent = focus;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200]!,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isSelected
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: FaIcon(
                    icon,
                    color: isSelected
                        ? theme.colorScheme.primary
                        : theme.iconTheme.color,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      focus,
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
    );
  }

  Widget _buildClearSelectionOption() {
    final theme = Theme.of(context);
    final isCleared = _selectedHealthComponent == null;

    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          setState(() {
            _selectedHealthComponent = null;
          });
          Navigator.pop(context);
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isCleared
                  ? theme.colorScheme.primary
                  : theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : Colors.grey[200]!,
              width: isCleared ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: isCleared
                      ? theme.colorScheme.primary.withOpacity(0.1)
                      : theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.clear,
                    color: isCleared
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
                      'Skip for now',
                      style: TextStyle(
                        color: isCleared
                            ? theme.colorScheme.primary
                            : theme.textTheme.bodyLarge?.color,
                        fontWeight: isCleared
                            ? FontWeight.w600
                            : FontWeight.normal,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'You can set your focus later in settings',
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                  ],
                ),
              ),
              if (isCleared)
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
    );
  }
}
