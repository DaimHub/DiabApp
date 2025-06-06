import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:toastification/toastification.dart';
import '../services/firestore_service.dart';
import '../providers/glucose_data_provider.dart';
import '../providers/glucose_trend_data_provider.dart';
import '../providers/log_history_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// This is a placeholder screen for the Log tab
// We'll actually be using a bottom sheet that opens when the Log tab is pressed
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  int _selectedSegment = 0;
  DateTime _selectedDateTime = DateTime.now();

  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  @override
  void dispose() {
    _glucoseController.dispose();
    _carbsController.dispose();
    _foodController.dispose();
    _activityController.dispose();
    _durationController.dispose();
    _medicationController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // This screen should never be visible as we're using a bottom sheet instead
    return const Scaffold(body: SizedBox());
  }
}

class LogBottomSheet extends StatefulWidget {
  final ScrollController scrollController;

  const LogBottomSheet({super.key, required this.scrollController});

  @override
  State<LogBottomSheet> createState() => _LogBottomSheetState();
}

class _LogBottomSheetState extends State<LogBottomSheet> {
  int _selectedSegment = 0;
  DateTime _selectedDateTime = DateTime.now();

  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();

  @override
  void dispose() {
    _glucoseController.dispose();
    _carbsController.dispose();
    _foodController.dispose();
    _activityController.dispose();
    _durationController.dispose();
    _medicationController.dispose();
    _doseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: ListView(
        controller: widget.scrollController,
        children: [
          // Header with close button moved to the right
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Add Entry',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: theme.textTheme.headlineSmall?.color,
                ),
              ),
              Material(
                color: theme.brightness == Brightness.dark
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
                      color: theme.iconTheme.color,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Segmented Control
          CupertinoSlidingSegmentedControl<int>(
            backgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            thumbColor: theme.colorScheme.primary,
            children: {
              0: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Glucose',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedSegment == 0
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              1: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Meal',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedSegment == 1
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              2: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Activity',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedSegment == 2
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
              3: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  'Medication',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: _selectedSegment == 3
                        ? Colors.white
                        : theme.textTheme.bodyLarge?.color,
                  ),
                ),
              ),
            },
            onValueChanged: (int? value) {
              if (value != null) {
                setState(() {
                  _selectedSegment = value;
                });
              }
            },
            groupValue: _selectedSegment,
          ),
          const SizedBox(height: 30),

          // Date & Time Picker Section
          _buildDateTimePicker(),
          const SizedBox(height: 30),

          // Content based on selected segment
          _buildContent(),

          const SizedBox(height: 40),

          // Save Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () async {
                // Create event data based on selected segment
                Map<String, dynamic>? eventData;
                String entryType;

                switch (_selectedSegment) {
                  case 0: // Glucose
                    if (_glucoseController.text.trim().isEmpty) {
                      _showErrorToast('Please enter glucose value');
                      return;
                    }

                    final glucose = double.tryParse(_glucoseController.text);
                    if (glucose == null) {
                      _showErrorToast('Please enter a valid glucose value');
                      return;
                    }

                    eventData = {'type': 'glucose', 'measure': glucose};
                    entryType = 'Glucose';
                    break;

                  case 1: // Meal
                    if (_carbsController.text.trim().isEmpty &&
                        _foodController.text.trim().isEmpty) {
                      _showErrorToast('Please enter meal information');
                      return;
                    }

                    eventData = {'type': 'meal'};

                    if (_carbsController.text.trim().isNotEmpty) {
                      final carbs = double.tryParse(_carbsController.text);
                      if (carbs == null) {
                        _showErrorToast('Please enter a valid carbs value');
                        return;
                      }
                      eventData['carbs'] = carbs;
                    }

                    if (_foodController.text.trim().isNotEmpty) {
                      eventData['name'] = _foodController.text.trim();
                    }
                    entryType = 'Meal';
                    break;

                  case 2: // Activity
                    if (_activityController.text.trim().isEmpty) {
                      _showErrorToast('Please enter activity name');
                      return;
                    }

                    eventData = {
                      'type': 'activity',
                      'name': _activityController.text.trim(),
                    };

                    if (_durationController.text.trim().isNotEmpty) {
                      final duration = int.tryParse(_durationController.text);
                      if (duration == null) {
                        _showErrorToast('Please enter a valid duration');
                        return;
                      }
                      eventData['duration'] = duration;
                    }
                    entryType = 'Activity';
                    break;

                  case 3: // Medication
                    if (_medicationController.text.trim().isEmpty) {
                      _showErrorToast('Please enter medication name');
                      return;
                    }

                    eventData = {
                      'type': 'medication',
                      'name': _medicationController.text.trim(),
                    };

                    if (_doseController.text.trim().isNotEmpty) {
                      final dose = double.tryParse(_doseController.text);
                      if (dose == null) {
                        _showErrorToast('Please enter a valid dose');
                        return;
                      }
                      eventData['dose'] = dose;
                    }
                    entryType = 'Medication';
                    break;

                  default:
                    _showErrorToast('Please select an entry type');
                    return;
                }

                // Add the selected date/time to the event data
                eventData['date'] = Timestamp.fromDate(_selectedDateTime);

                // Save to Firestore
                final eventId = await FirestoreService.addEvent(eventData);

                if (eventId != null) {
                  // If glucose data was saved, refresh the glucose cache
                  if (_selectedSegment == 0) {
                    // Glucose

                    try {
                      await GlucoseDataProvider.invalidateAndRefreshGlobally(
                        context,
                      );
                      await GlucoseTrendDataProvider.invalidateAndRefreshGlobally(
                        context,
                      );
                    } catch (e) {}
                  }

                  // Refresh log history cache for any type of data

                  try {
                    await LogHistoryDataProvider.invalidateAndRefreshGlobally(
                      context,
                    );
                  } catch (e) {}

                  // Clear form fields
                  _clearAllFields();

                  // Show success toast
                  _showSuccessToast(entryType);

                  // Close the bottom sheet
                  Navigator.pop(context);
                } else {
                  _showErrorToast(
                    'Failed to save $entryType entry. Please try again.',
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Save',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_selectedSegment) {
      case 0: // Glucose
        return _buildGlucoseForm();
      case 1: // Meal
        return _buildMealForm();
      case 2: // Activity
        return _buildActivityForm();
      case 3: // Medication
        return _buildMedicationForm();
      default:
        return _buildGlucoseForm();
    }
  }

  Widget _buildGlucoseForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Glucose',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _glucoseController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'mg/dL',
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildMealForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Meal',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _carbsController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Carbs (g)',
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _foodController,
          decoration: InputDecoration(
            hintText: 'Food',
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _activityController,
          decoration: InputDecoration(
            hintText: 'Activity',
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Duration (min)',
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Medication',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _medicationController,
          decoration: InputDecoration(
            hintText: 'Medication',
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: _doseController,
          decoration: InputDecoration(
            hintText: 'Dose (units)',
            filled: true,
            fillColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : const Color(0xFFF0F1F7),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePicker() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When did this happen?',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            // Date Picker
            Expanded(
              flex: 3,
              child: Material(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _selectDate(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          _formatDate(_selectedDateTime),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Time Picker
            Expanded(
              flex: 2,
              child: Material(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                borderRadius: BorderRadius.circular(10),
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => _selectTime(),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: theme.colorScheme.primary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _formatTime(_selectedDateTime),
                          style: TextStyle(
                            fontSize: 16,
                            color: theme.textTheme.bodyLarge?.color,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Now Button
            Material(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () {
                  setState(() {
                    _selectedDateTime = DateTime.now();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                  child: Text(
                    'Now',
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final dateOnly = DateTime(date.year, date.month, date.day);

    if (dateOnly == today) {
      return 'Today';
    } else if (dateOnly == yesterday) {
      return 'Yesterday';
    } else {
      final months = [
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[date.month - 1]} ${date.day}';
    }
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _selectDate() async {
    final theme = Theme.of(context);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              onSurface: theme.textTheme.bodyLarge?.color ?? Colors.black,
              background: theme.brightness == Brightness.dark
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFF5F5F5),
            ),
            dialogBackgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.white,
            dialogTheme: DialogThemeData(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            datePickerTheme: DatePickerThemeData(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              headerBackgroundColor: theme.colorScheme.primary,
              headerForegroundColor: Colors.white,
              headerHeadlineStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              headerHelpStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.white,
              ),
              weekdayStyle: TextStyle(
                color: theme.textTheme.bodyMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              dayStyle: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              dayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                if (states.contains(MaterialState.disabled)) {
                  return theme.textTheme.bodyMedium?.color?.withOpacity(0.3);
                }
                return theme.textTheme.bodyLarge?.color;
              }),
              dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return theme.colorScheme.primary;
                }
                return Colors.transparent;
              }),
              dayOverlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return theme.colorScheme.primary.withOpacity(0.1);
                }
                if (states.contains(MaterialState.pressed)) {
                  return theme.colorScheme.primary.withOpacity(0.2);
                }
                return null;
              }),
              todayForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return theme.colorScheme.primary;
              }),
              todayBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return theme.colorScheme.primary;
                }
                return Colors.transparent;
              }),
              todayBorder: BorderSide(
                color: theme.colorScheme.primary,
                width: 1.5,
              ),
              yearStyle: TextStyle(
                color: theme.textTheme.bodyLarge?.color,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
              yearForegroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return Colors.white;
                }
                return theme.textTheme.bodyLarge?.color;
              }),
              yearBackgroundColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.selected)) {
                  return theme.colorScheme.primary;
                }
                return Colors.transparent;
              }),
              yearOverlayColor: MaterialStateProperty.resolveWith((states) {
                if (states.contains(MaterialState.hovered)) {
                  return theme.colorScheme.primary.withOpacity(0.1);
                }
                if (states.contains(MaterialState.pressed)) {
                  return theme.colorScheme.primary.withOpacity(0.2);
                }
                return null;
              }),
              rangePickerBackgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              rangePickerHeaderBackgroundColor: theme.colorScheme.primary,
              rangePickerHeaderForegroundColor: Colors.white,
              rangeSelectionBackgroundColor: theme.colorScheme.primary
                  .withOpacity(0.1),
              rangeSelectionOverlayColor: MaterialStateProperty.all(
                theme.colorScheme.primary.withOpacity(0.1),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: theme.brightness == Brightness.dark
                    ? const Color(0xFF3A3A3A)
                    : const Color(0xFFF0F1F7),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(
                    color: theme.colorScheme.primary,
                    width: 2,
                  ),
                ),
              ),
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          picked.year,
          picked.month,
          picked.day,
          _selectedDateTime.hour,
          _selectedDateTime.minute,
        );
      });
    }
  }

  Future<void> _selectTime() async {
    final theme = Theme.of(context);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: theme.copyWith(
            colorScheme: theme.colorScheme.copyWith(
              primary: theme.colorScheme.primary,
              onPrimary: Colors.white,
              surface: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              onSurface: theme.textTheme.bodyLarge?.color ?? Colors.black,
              background: theme.brightness == Brightness.dark
                  ? const Color(0xFF1A1A1A)
                  : const Color(0xFFF5F5F5),
              tertiary: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFFF0F1F7),
            ),
            dialogBackgroundColor: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.white,
            dialogTheme: DialogThemeData(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 8,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: theme.colorScheme.primary,
                textStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : Colors.white,
              hourMinuteTextColor: theme.textTheme.bodyLarge?.color,
              hourMinuteColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFFF0F1F7),
              dialHandColor: theme.colorScheme.primary,
              dialBackgroundColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFFF0F1F7),
              dialTextColor: theme.textTheme.bodyLarge?.color,
              entryModeIconColor: theme.colorScheme.primary,
              dayPeriodTextColor: theme.textTheme.bodyLarge?.color,
              dayPeriodColor: theme.brightness == Brightness.dark
                  ? const Color(0xFF3A3A3A)
                  : const Color(0xFFF0F1F7),
              dayPeriodBorderSide: BorderSide(
                color: theme.colorScheme.primary.withOpacity(0.2),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDateTime = DateTime(
          _selectedDateTime.year,
          _selectedDateTime.month,
          _selectedDateTime.day,
          picked.hour,
          picked.minute,
        );
      });
    }
  }

  void _showErrorToast(String message) {
    final theme = Theme.of(context);

    toastification.show(
      context: context,
      type: ToastificationType.error,
      style: ToastificationStyle.flat,
      title: Text(
        'Error',
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
      borderRadius: BorderRadius.circular(12),
      backgroundColor: theme.cardColor,
      foregroundColor: Colors.red[600],
      borderSide: BorderSide(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF3A3A3A)
            : Colors.grey[200]!,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      icon: Icon(Icons.error_outline, color: Colors.red[600], size: 24),
    );
  }

  void _showSuccessToast(String entryType) {
    final theme = Theme.of(context);

    toastification.show(
      context: context,
      type: ToastificationType.success,
      style: ToastificationStyle.flat,
      title: Text(
        '$entryType logged successfully!',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.brightness == Brightness.dark
              ? Colors.white
              : Colors.black87,
        ),
      ),
      description: Text(
        'Your $entryType entry has been saved.',
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
      borderRadius: BorderRadius.circular(12),
      backgroundColor: theme.cardColor,
      foregroundColor: theme.colorScheme.primary,
      borderSide: BorderSide(
        color: theme.brightness == Brightness.dark
            ? const Color(0xFF3A3A3A)
            : Colors.grey[200]!,
        width: 1,
      ),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.08),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
      icon: Icon(
        Icons.check_circle_outline,
        color: theme.colorScheme.primary,
        size: 24,
      ),
    );
  }

  void _clearAllFields() {
    _glucoseController.clear();
    _carbsController.clear();
    _foodController.clear();
    _activityController.clear();
    _durationController.clear();
    _medicationController.clear();
    _doseController.clear();
  }
}
