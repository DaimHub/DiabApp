import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
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
          backgroundColor: Theme.of(context).dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 24,
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    children: [
                      Text(
                        'Add Medication',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(
                            context,
                          ).textTheme.headlineMedium?.color,
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

                  // Medication name input
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: 'Medication Name',
                      hintText: 'Enter medication name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Time selector
                  Material(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(12),
                    elevation: 0,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
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
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color:
                                Theme.of(context).brightness == Brightness.dark
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
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A3A)
                                    : const Color(0xFFF0F1F7),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.access_time,
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
                  const SizedBox(height: 20),

                  // Days of the week selector
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF3A3A3A)
                            : Colors.grey[200]!,
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
                              decoration: BoxDecoration(
                                color:
                                    Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color(0xFF3A3A3A)
                                    : const Color(0xFFF0F1F7),
                                borderRadius: BorderRadius.circular(10),
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
                            TextButton(
                              onPressed: () {
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
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                overlayColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'All',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
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
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                overlayColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'Weekdays',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setDialogState(() {
                                  selectedDays = [];
                                });
                              },
                              style: TextButton.styleFrom(
                                foregroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                overlayColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withOpacity(0.1),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text(
                                'None',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Theme.of(context).colorScheme.primary,
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

                                return InkWell(
                                  onTap: () {
                                    setDialogState(() {
                                      if (isSelected) {
                                        selectedDays.remove(day);
                                      } else {
                                        selectedDays.add(day);
                                      }
                                    });
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Theme.of(
                                              context,
                                            ).colorScheme.primary
                                          : (Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF3A3A3A)
                                                : const Color(0xFFF0F1F7)),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Theme.of(
                                                context,
                                              ).colorScheme.primary
                                            : Colors.transparent,
                                      ),
                                    ),
                                    child: Text(
                                      dayAbbrev,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? Colors.white
                                            : Theme.of(
                                                context,
                                              ).textTheme.bodyMedium?.color,
                                      ),
                                    ),
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
                        child: TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Cancel'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {
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
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text('Add'),
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
          'Medication Reminders',
          style: TextStyle(
            color: theme.appBarTheme.foregroundColor,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.add,
              color: theme.appBarTheme.foregroundColor,
              size: 24,
            ),
            onPressed: _showAddMedicationDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _medications.isEmpty
          ? _buildEmptyState(theme)
          : _buildMedicationsList(theme),
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
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFF0F1F7),
                borderRadius: BorderRadius.circular(50),
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
            ElevatedButton.icon(
              onPressed: _showAddMedicationDialog,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: const Icon(Icons.add, size: 20),
              label: const Text(
                'Add Your First Medication',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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
          child: Material(
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
                    height: 50,
                    width: 50,
                    decoration: BoxDecoration(
                      color: medication['enabled']
                          ? theme.colorScheme.primary.withOpacity(0.1)
                          : theme.brightness == Brightness.dark
                          ? const Color(0xFF3A3A3A)
                          : const Color(0xFFF0F1F7),
                      borderRadius: BorderRadius.circular(12),
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
                  Material(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(8),
                      onTap: () => _showDeleteConfirmation(index),
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
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Delete Medication',
          style: TextStyle(
            color: Theme.of(context).textTheme.headlineMedium?.color,
          ),
        ),
        content: Text(
          'Are you sure you want to delete "${medication['name']}"?',
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteMedication(index);
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red[600]),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
