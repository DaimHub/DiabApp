import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:toastification/toastification.dart';
import '../services/firestore_service.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  String _selectedDiabetesType = 'Type 1';
  final TextEditingController _glucoseMinController = TextEditingController();
  final TextEditingController _glucoseMaxController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _glucoseMinController.dispose();
    _glucoseMaxController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  void _loadUserData() async {
    try {
      final userData = await FirestoreService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          // Charger les données personnelles
          _firstNameController.text = userData['firstName'] ?? '';
          _lastNameController.text = userData['lastName'] ?? '';
          _selectedDiabetesType = userData['diabetesType'] ?? 'Type 1';

          // Charger les objectifs de glucose
          _glucoseMinController.text =
              userData['targetGlucoseMin']?.toString() ?? '80';
          _glucoseMaxController.text =
              userData['targetGlucoseMax']?.toString() ?? '180';
        });
      } else {
        setState(() {
          // Fallback vers les données Firebase Auth si pas de données Firestore
          final user = FirebaseAuth.instance.currentUser;
          if (user?.displayName != null) {
            final nameParts = user!.displayName!.split(' ');
            _firstNameController.text = nameParts.isNotEmpty
                ? nameParts[0]
                : '';
            _lastNameController.text = nameParts.length > 1
                ? nameParts.sublist(1).join(' ')
                : '';
          }

          // Valeurs par défaut
          _glucoseMinController.text = '80';
          _glucoseMaxController.text = '180';
        });
      }
    } catch (e) {
      setState(() {
        // Valeurs par défaut en cas d'erreur
        _glucoseMinController.text = '80';
        _glucoseMaxController.text = '180';
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Valider les données
      final glucoseMin = int.tryParse(_glucoseMinController.text);
      final glucoseMax = int.tryParse(_glucoseMaxController.text);

      if (glucoseMin == null || glucoseMax == null) {
        throw Exception('Valeurs de glucose invalides');
      }

      if (glucoseMin >= glucoseMax) {
        throw Exception('Le minimum doit être inférieur au maximum');
      }

      // Préparer les données à sauvegarder
      final updateData = {
        'firstName': _firstNameController.text.trim(),
        'lastName': _lastNameController.text.trim(),
        'diabetesType': _selectedDiabetesType,
        'targetGlucoseMin': glucoseMin,
        'targetGlucoseMax': glucoseMax,
      };

      // Sauvegarder dans Firestore
      final success = await FirestoreService.saveUserData(updateData);

      if (!success) {
        throw Exception('Échec de la sauvegarde');
      }

      if (mounted) {
        _showToast('Profile updated successfully!', ToastificationType.success);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        _showToast(
          'Error: ${e.toString().replaceAll('Exception: ', '')}',
          ToastificationType.error,
        );
      }
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
        title = 'Success';
        description = message;
        iconData = Icons.check_circle_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case ToastificationType.error:
        title = 'Error';
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
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: theme.appBarTheme.foregroundColor,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Edit Profile',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),

              // Profile Picture Section
              Center(
                child: Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    color: theme.brightness == Brightness.dark
                        ? const Color(0xFF3A3A3A)
                        : const Color(0xFFF0F1F7),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.user,
                      color: theme.colorScheme.primary,
                      size: 40,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Personal Information Section
              Text(
                'Personal Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineMedium?.color,
                ),
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 30),

              // Health Information Section
              Text(
                'Health Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineMedium?.color,
                ),
              ),
              const SizedBox(height: 16),

              _buildDiabetesTypeSelector(),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _glucoseMinController,
                label: 'Target Glucose Min (mg/dL)',
                icon: FontAwesomeIcons.droplet,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),

              _buildInputField(
                controller: _glucoseMaxController,
                label: 'Target Glucose Max (mg/dL)',
                icon: FontAwesomeIcons.droplet,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    return Material(
      color: theme.cardColor,
      borderRadius: BorderRadius.circular(12),
      elevation: 0,
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
                child: icon == FontAwesomeIcons.droplet
                    ? FaIcon(icon, color: theme.colorScheme.primary, size: 18)
                    : Icon(icon, color: theme.colorScheme.primary, size: 20),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    constraints: const BoxConstraints(minHeight: 40),
                    child: TextField(
                      controller: controller,
                      keyboardType: keyboardType,
                      style: TextStyle(
                        color: theme.textTheme.bodyLarge?.color,
                        fontSize: 16,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        isDense: false,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDiabetesTypeSelector() {
    final theme = Theme.of(context);
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
                    FontAwesomeIcons.pills,
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
                      _selectedDiabetesType,
                      style: TextStyle(
                        fontSize: 16,
                        color: theme.textTheme.bodyLarge?.color,
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
}
