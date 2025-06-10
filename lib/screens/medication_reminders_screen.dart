import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../services/firestore_service.dart';
import '../providers/medication_data_provider.dart';

class MedicationRemindersScreen extends StatefulWidget {
  const MedicationRemindersScreen({super.key});

  @override
  State<MedicationRemindersScreen> createState() =>
      _MedicationRemindersScreenState();
}

class _MedicationRemindersScreenState extends State<MedicationRemindersScreen> {
  List<Map<String, dynamic>> _medications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userData = await FirestoreService.getUserData();
      if (userData != null && mounted) {
        setState(() {
          _medications = List<Map<String, dynamic>>.from(
            userData['medications'] ?? [],
          );
        });
      }
    } catch (e) {
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveMedications() async {
    try {
      await FirestoreService.saveUserData({'medications': _medications});

      // Refresh medication cache

      try {
        await MedicationDataProvider.invalidateAndRefreshGlobally(context);
      } catch (e) {}

      _showToast(
        'Medications updated successfully!',
        ToastificationType.success,
      );
    } catch (e) {
      _showToast('Failed to save medications', ToastificationType.error);
    }
  }

  Future<void> _saveMedicationsSilently() async {
    try {
      await FirestoreService.saveUserData({'medications': _medications});

      // Update medication reminders enabled status based on active medications
      final hasActiveMedications = _medications.any(
        (med) => med['enabled'] == true,
      );
      await FirestoreService.updateNotificationSettings(
        medicationReminders: hasActiveMedications,
      );

      // Refresh medication cache silently

      try {
        await MedicationDataProvider.invalidateAndRefreshGlobally(context);
      } catch (e) {}
    } catch (e) {}
  }

  void _showAddMedicationDialog() {
    final nameController = TextEditingController();
    TimeOfDay selectedTime = TimeOfDay.now();
    List<String> selectedDays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ]; // Default: all days

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
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
            child: SingleChildScrollView(
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

                  // Large medication icon
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
                      child: FaIcon(
                        FontAwesomeIcons.pills,
                        color: Colors.white,
                        size: 36,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    'Add Medication',
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
                    'Set up a reminder for your medication',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Medication name input
                  Focus(
                    child: Builder(
                      builder: (context) {
                        final isFocused = Focus.of(context).hasFocus;

                        return Container(
                          decoration: ShapeDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF0F1F7),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 16,
                                cornerSmoothing: 0.6,
                              ),
                              side: BorderSide(
                                color: isFocused
                                    ? Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.8)
                                    : Theme.of(context).brightness ==
                                          Brightness.dark
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.grey[200]!,
                                width: isFocused ? 2 : 1,
                              ),
                            ),
                            shadows: isFocused
                                ? [
                                    BoxShadow(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary.withOpacity(0.1),
                                      blurRadius: 10,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.02),
                                      blurRadius: 6,
                                      offset: const Offset(0, 1),
                                    ),
                                  ],
                          ),
                          child: ClipSmoothRect(
                            radius: SmoothBorderRadius(
                              cornerRadius: 16,
                              cornerSmoothing: 0.6,
                            ),
                            child: TextField(
                              controller: nameController,
                              style: TextStyle(
                                fontSize: 16,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                              decoration: InputDecoration(
                                labelText: 'Medication Name',
                                hintText: 'Enter medication name',
                                hintStyle: TextStyle(
                                  color: const Color(
                                    0xFF5C5FC1,
                                  ).withOpacity(0.7),
                                  fontSize: 16,
                                ),
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                errorBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                                contentPadding: const EdgeInsets.all(16),
                                filled: false,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time selector
                  Container(
                    decoration: ShapeDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0F1F7),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 0.6,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF3A3A3A)
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: selectedTime,
                          );
                          if (time != null) {
                            setDialogState(() {
                              selectedTime = time;
                            });
                          }
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
                                height: 40,
                                width: 40,
                                decoration: ShapeDecoration(
                                  color:
                                      Theme.of(context).brightness ==
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
                                child: Center(
                                  child: Icon(
                                    Icons.access_time,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
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
                                      'Reminder Time',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium?.color,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      selectedTime.format(context),
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Theme.of(
                                          context,
                                        ).textTheme.bodyLarge?.color,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyMedium?.color?.withOpacity(0.5),
                                size: 14,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Days of the week selector
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: ShapeDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF2A2A2A)
                          : const Color(0xFFF0F1F7),
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 16,
                          cornerSmoothing: 0.6,
                        ),
                        side: BorderSide(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF3A3A3A)
                              : Colors.grey[200]!,
                          width: 1,
                        ),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 40,
                              width: 40,
                              decoration: ShapeDecoration(
                                color:
                                    Theme.of(context).brightness ==
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
                              child: Center(
                                child: Icon(
                                  Icons.calendar_today,
                                  color: Theme.of(context).colorScheme.primary,
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
                                    'Days of the Week',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyMedium?.color,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    selectedDays.length == 7
                                        ? 'Every day'
                                        : selectedDays.length == 0
                                        ? 'No days selected'
                                        : '${selectedDays.length} day${selectedDays.length == 1 ? '' : 's'} selected',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(
                                        context,
                                      ).textTheme.bodyLarge?.color,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        // Quick select buttons - moved above the days
                        Row(
                          children: [
                            Container(
                              decoration: ShapeDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
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
                                  onTap: () {
                                    setDialogState(() {
                                      selectedDays = [
                                        'Monday',
                                        'Tuesday',
                                        'Wednesday',
                                        'Thursday',
                                        'Friday',
                                        'Saturday',
                                        'Sunday',
                                      ];
                                    });
                                  },
                                  customBorder: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 10,
                                      cornerSmoothing: 0.6,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'All',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: ShapeDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
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
                                  onTap: () {
                                    setDialogState(() {
                                      selectedDays = [
                                        'Monday',
                                        'Tuesday',
                                        'Wednesday',
                                        'Thursday',
                                        'Friday',
                                      ];
                                    });
                                  },
                                  customBorder: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 10,
                                      cornerSmoothing: 0.6,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'Weekdays',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: ShapeDecoration(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
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
                                  onTap: () {
                                    setDialogState(() {
                                      selectedDays = [];
                                    });
                                  },
                                  customBorder: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 10,
                                      cornerSmoothing: 0.6,
                                    ),
                                  ),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    child: Text(
                                      'None',
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.primary,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Days checkboxes
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children:
                              [
                                'Monday',
                                'Tuesday',
                                'Wednesday',
                                'Thursday',
                                'Friday',
                                'Saturday',
                                'Sunday',
                              ].map((day) {
                                final isSelected = selectedDays.contains(day);
                                final dayAbbrev = day.substring(0, 3);

                                return FilterChip(
                                  selected: isSelected,
                                  onSelected: (selected) {
                                    setDialogState(() {
                                      if (selected) {
                                        selectedDays.add(day);
                                      } else {
                                        selectedDays.remove(day);
                                      }
                                    });
                                  },
                                  label: Text(
                                    dayAbbrev,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Theme.of(
                                              context,
                                            ).textTheme.bodyLarge?.color,
                                    ),
                                  ),
                                  shape: SmoothRectangleBorder(
                                    borderRadius: SmoothBorderRadius(
                                      cornerRadius: 10,
                                      cornerSmoothing: 0.6,
                                    ),
                                    side: BorderSide(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : Theme.of(context).brightness ==
                                                Brightness.dark
                                          ? const Color(0xFF4A4A4A)
                                          : Colors.grey[300]!,
                                      width: 1,
                                    ),
                                  ),
                                  backgroundColor: isSelected
                                      ? Theme.of(context).colorScheme.primary
                                      : Theme.of(context).brightness ==
                                            Brightness.dark
                                      ? const Color(0xFF2A2A2A)
                                      : Colors.white,
                                  selectedColor: Theme.of(
                                    context,
                                  ).colorScheme.primary,
                                  checkmarkColor: Colors.white,
                                  showCheckmark: false,
                                  materialTapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                  visualDensity: VisualDensity.compact,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                );
                              }).toList(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Buttons
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: ShapeDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF2A2A2A)
                                : const Color(0xFFF0F1F7),
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 14,
                                cornerSmoothing: 0.6,
                              ),
                              side: BorderSide(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A3A)
                                    : Colors.grey[200]!,
                                width: 1,
                              ),
                            ),
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => Navigator.pop(context),
                              customBorder: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 14,
                                  cornerSmoothing: 0.6,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          height: 48,
                          decoration: ShapeDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            shape: SmoothRectangleBorder(
                              borderRadius: SmoothBorderRadius(
                                cornerRadius: 14,
                                cornerSmoothing: 0.6,
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.3),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                if (nameController.text.trim().isNotEmpty &&
                                    selectedDays.isNotEmpty) {
                                  setState(() {
                                    _medications.add({
                                      'name': nameController.text.trim(),
                                      'time': {
                                        'hour': selectedTime.hour,
                                        'minute': selectedTime.minute,
                                      },
                                      'days': selectedDays,
                                      'enabled': true,
                                    });
                                  });
                                  _saveMedications();
                                  Navigator.pop(context);
                                }
                              },
                              customBorder: SmoothRectangleBorder(
                                borderRadius: SmoothBorderRadius(
                                  cornerRadius: 14,
                                  cornerSmoothing: 0.6,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  'Add',
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
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
    _saveMedicationsSilently();
  }

  void _toggleMedication(int index, bool enabled) {
    setState(() {
      _medications[index]['enabled'] = enabled;
    });
    _saveMedicationsSilently();
  }

  void _showToast(String message, ToastificationType type) {
    final theme = Theme.of(context);

    String title;
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ToastificationType.success:
        title = 'Success';
        iconData = Icons.check_circle_outline;
        iconColor = theme.colorScheme.primary;
        break;
      case ToastificationType.error:
        title = 'Error';
        iconData = Icons.error_outline;
        iconColor = Colors.red[600]!;
        break;
      default:
        title = 'Notification';
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
        message,
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
                      'Medication Reminders',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.headlineMedium?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Add Button
                  Container(
                    decoration: ShapeDecoration(
                      color: theme.colorScheme.primary,
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
                        onTap: _showAddMedicationDialog,
                        customBorder: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _medications.isEmpty
                  ? _buildEmptyState(theme)
                  : _buildMedicationsList(theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 100,
              width: 100,
              decoration: ShapeDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFF0F1F7),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 30,
                    cornerSmoothing: 0.6,
                  ),
                ),
              ),
              child: Center(
                child: FaIcon(
                  FontAwesomeIcons.pills,
                  color: theme.colorScheme.primary,
                  size: 40,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Medications Yet',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: theme.textTheme.headlineMedium?.color,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add your medications to set up personalized reminders',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: theme.textTheme.bodyMedium?.color,
              ),
            ),
            const SizedBox(height: 32),
            Container(
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
                  onTap: _showAddMedicationDialog,
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 16,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.add, size: 20, color: Colors.white),
                        const SizedBox(width: 8),
                        const Text(
                          'Add Your First Medication',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
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

  Widget _buildMedicationsList(ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(20),
      itemCount: _medications.length,
      itemBuilder: (context, index) {
        final medication = _medications[index];
        final time = TimeOfDay(
          hour: medication['time']['hour'],
          minute: medication['time']['minute'],
        );

        // Handle days - support both old and new format
        final days = medication['days'] as List<dynamic>?;
        String daysText;
        if (days == null || days.isEmpty) {
          daysText = 'Daily at ${time.format(context)}';
        } else if (days.length == 7) {
          daysText = 'Daily at ${time.format(context)}';
        } else if (days.length == 5 &&
            days.contains('Monday') &&
            days.contains('Tuesday') &&
            days.contains('Wednesday') &&
            days.contains('Thursday') &&
            days.contains('Friday')) {
          daysText = 'Weekdays at ${time.format(context)}';
        } else if (days.length == 2 &&
            days.contains('Saturday') &&
            days.contains('Sunday')) {
          daysText = 'Weekends at ${time.format(context)}';
        } else {
          // Show abbreviated days
          final dayAbbreviations = days
              .map((day) => day.toString().substring(0, 3))
              .join(', ');
          daysText = '$dayAbbreviations at ${time.format(context)}';
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Container(
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
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    height: 50,
                    width: 50,
                    decoration: ShapeDecoration(
                      color: medication['enabled']
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.brightness == Brightness.dark
                          ? const Color(0xFF3A3A3A)
                          : Colors.white,
                      shape: SmoothRectangleBorder(
                        borderRadius: SmoothBorderRadius(
                          cornerRadius: 14,
                          cornerSmoothing: 0.6,
                        ),
                      ),
                    ),
                    child: Center(
                      child: FaIcon(
                        FontAwesomeIcons.pills,
                        color: medication['enabled']
                            ? theme.colorScheme.primary
                            : theme.iconTheme.color?.withOpacity(0.5),
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
                          medication['name'],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: medication['enabled']
                                ? theme.textTheme.titleMedium?.color
                                : theme.textTheme.titleMedium?.color
                                      ?.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          daysText,
                          style: TextStyle(
                            fontSize: 14,
                            color: medication['enabled']
                                ? theme.textTheme.bodyMedium?.color
                                : theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: medication['enabled'],
                    onChanged: (value) => _toggleMedication(index, value),
                    activeColor: Colors.white,
                    activeTrackColor: theme.colorScheme.primary,
                    inactiveThumbColor: Colors.white,
                    inactiveTrackColor: Colors.grey[300],
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: ShapeDecoration(
                      color: Colors.red.withOpacity(0.1),
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
                        onTap: () => _showDeleteConfirmation(index),
                        customBorder: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          child: Icon(
                            Icons.delete_outline,
                            color: Colors.red[600],
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(int index) {
    final medication = _medications[index];

    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                        child: const Center(child: Icon(Icons.close, size: 18)),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Large delete icon
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
                  child: Icon(Icons.delete, color: Colors.white, size: 36),
                ),
              ),
              const SizedBox(height: 24),

              // Title
              Text(
                'Delete Medication',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.headlineMedium?.color,
                ),
              ),
              const SizedBox(height: 8),

              // Content
              Text(
                'Are you sure you want to delete "${medication['name']}"?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 48,
                      decoration: ShapeDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF2A2A2A)
                            : const Color(0xFFF0F1F7),
                        shape: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 14,
                            cornerSmoothing: 0.6,
                          ),
                          side: BorderSide(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF3A3A3A)
                                : Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () => Navigator.pop(context),
                          customBorder: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 14,
                              cornerSmoothing: 0.6,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Cancel',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 48,
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
                          onTap: () {
                            _deleteMedication(index);
                            Navigator.pop(context);
                          },
                          customBorder: SmoothRectangleBorder(
                            borderRadius: SmoothBorderRadius(
                              cornerRadius: 14,
                              cornerSmoothing: 0.6,
                            ),
                          ),
                          child: const Center(
                            child: Text(
                              'Delete',
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
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
