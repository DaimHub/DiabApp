import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';
import 'package:figma_squircle/figma_squircle.dart';
import '../services/firestore_service.dart';
import '../services/blood_sugar_reminder_service.dart';
import '../providers/glucose_data_provider.dart';
import '../providers/glucose_trend_data_provider.dart';
import '../providers/log_history_data_provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

// This is a placeholder screen for the Log tab
// We'll actually be using a bottom sheet that opens when the Log tab is pressed
class LogScreen extends StatefulWidget {
  const LogScreen({super.key});

  @override
  State<LogScreen> createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final TextEditingController _glucoseController = TextEditingController();
  final TextEditingController _carbsController = TextEditingController();
  final TextEditingController _foodController = TextEditingController();
  final TextEditingController _activityController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _medicationController = TextEditingController();
  final TextEditingController _doseController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _glucoseController.dispose();
    _carbsController.dispose();
    _foodController.dispose();
    _activityController.dispose();
    _durationController.dispose();
    _medicationController.dispose();
    _doseController.dispose();
    _noteController.dispose();
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
  final TextEditingController _noteController = TextEditingController();

  @override
  void dispose() {
    _glucoseController.dispose();
    _carbsController.dispose();
    _foodController.dispose();
    _activityController.dispose();
    _durationController.dispose();
    _medicationController.dispose();
    _doseController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: ShapeDecoration(
        color: theme.scaffoldBackgroundColor,
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
          ),
        ),
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
              Container(
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
                  shadows: [
                    BoxShadow(
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 10,
                        cornerSmoothing: 0.6,
                      ),
                    ),
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
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Segmented Control
          SegmentedButton<int>(
            segments: const [
              ButtonSegment<int>(value: 0, label: Text('Glucose')),
              ButtonSegment<int>(value: 1, label: Text('Meal')),
              ButtonSegment<int>(value: 2, label: Text('Activity')),
              ButtonSegment<int>(value: 3, label: Text('Meds')),
              ButtonSegment<int>(value: 4, label: Text('Other')),
            ],
            selected: {_selectedSegment},
            onSelectionChanged: (Set<int> newSelection) {
              setState(() {
                _selectedSegment = newSelection.first;
              });
            },
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return theme.colorScheme.primary;
                }
                return theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7);
              }),
              foregroundColor: WidgetStateProperty.resolveWith<Color?>((
                Set<WidgetState> states,
              ) {
                if (states.contains(WidgetState.selected)) {
                  return Colors.white;
                }
                return theme.textTheme.bodyLarge?.color;
              }),
              side: WidgetStateProperty.resolveWith<BorderSide?>((
                Set<WidgetState> states,
              ) {
                return BorderSide(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey[200]!,
                  width: 1,
                );
              }),
              shape: WidgetStateProperty.all(
                SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 16,
                    cornerSmoothing: 0.6,
                  ),
                ),
              ),
              textStyle: WidgetStateProperty.all(
                const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
            ),
            showSelectedIcon: false,
          ),
          const SizedBox(height: 30),

          // Date & Time Picker Section
          _buildDateTimePicker(),
          const SizedBox(height: 30),

          // Content based on selected segment
          _buildContent(),

          const SizedBox(height: 40),

          // Save Button
          Container(
            width: double.infinity,
            height: 50,
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
                customBorder: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 16,
                    cornerSmoothing: 0.6,
                  ),
                ),
                onTap: () async {
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

                    case 4: // Other
                      if (_activityController.text.trim().isEmpty) {
                        _showErrorToast(
                          'Please enter a title for the other entry',
                        );
                        return;
                      }
                      if (_noteController.text.trim().isEmpty) {
                        _showErrorToast(
                          'Please enter a note for the other entry',
                        );
                        return;
                      }

                      eventData = {
                        'type': 'other',
                        'name': _activityController.text.trim(),
                      };
                      entryType = 'Other';
                      break;

                    default:
                      _showErrorToast('Please select an entry type');
                      return;
                  }

                  // Add the selected date/time to the event data
                  eventData['date'] = Timestamp.fromDate(_selectedDateTime);

                  // Add note if provided
                  if (_noteController.text.trim().isNotEmpty) {
                    eventData['note'] = _noteController.text.trim();
                  }

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

                        // Reschedule blood sugar reminder after new reading
                        BloodSugarReminderService.onGlucoseReadingLogged();
                      } catch (e) {
                        // Failed to refresh glucose data - this is non-critical
                      }
                    }

                    // Refresh log history cache for any type of data

                    try {
                      await LogHistoryDataProvider.invalidateAndRefreshGlobally(
                        context,
                      );
                    } catch (e) {
                      // Failed to refresh log history - this is non-critical
                    }

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
                child: const Center(
                  child: Text(
                    'Save',
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
      case 4: // Other
        return _buildOtherForm();
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
          'Blood Glucose',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _glucoseController,
          hintText: 'mg/dL',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildNoteField(),
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
        _buildTextField(
          controller: _carbsController,
          hintText: 'Carbs (g)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        _buildTextField(controller: _foodController, hintText: 'Food'),
        const SizedBox(height: 20),
        _buildNoteField(),
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
        _buildTextField(controller: _activityController, hintText: 'Activity'),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _durationController,
          hintText: 'Duration (minutes)',
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildNoteField(),
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
        _buildTextField(
          controller: _medicationController,
          hintText: 'Medication',
        ),
        const SizedBox(height: 16),
        _buildTextField(controller: _doseController, hintText: 'Dosage'),
        const SizedBox(height: 20),
        _buildNoteField(),
      ],
    );
  }

  Widget _buildOtherForm() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Other',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.titleLarge?.color,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Add any other health-related information.',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _activityController,
          hintText: 'Title (e.g., Sleep, Stress, Symptoms)',
        ),
        const SizedBox(height: 16),
        _buildNoteField(),
      ],
    );
  }

  Widget _buildNoteField() {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Note (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: theme.textTheme.titleMedium?.color,
          ),
        ),
        const SizedBox(height: 8),
        _buildTextField(
          controller: _noteController,
          hintText: 'Add any additional notes...',
          maxLines: 3,
        ),
      ],
    );
  }

  // Helper method for consistent text field styling with focus-aware borders
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    final theme = Theme.of(context);

    return Focus(
      child: Builder(
        builder: (context) {
          final isFocused = Focus.of(context).hasFocus;

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
                  color: isFocused
                      ? theme.colorScheme.primary.withOpacity(0.8)
                      : theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey[200]!,
                  width: isFocused ? 2 : 1,
                ),
              ),
              shadows: isFocused
                  ? [
                      BoxShadow(
                        color: theme.colorScheme.primary.withOpacity(0.1),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: theme.brightness == Brightness.dark
                            ? Colors.black.withOpacity(0.2)
                            : Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: ClipSmoothRect(
              radius: SmoothBorderRadius(
                cornerRadius: 16,
                cornerSmoothing: 0.6,
              ),
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyLarge?.color,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: theme.textTheme.bodyMedium?.color?.withOpacity(0.7),
                    fontSize: 16,
                  ),
                  filled: false,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  focusedErrorBorder: InputBorder.none,
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
            ),
          );
        },
      ),
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
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 16,
                        cornerSmoothing: 0.6,
                      ),
                    ),
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
            ),
            const SizedBox(width: 12),
            // Time Picker
            Expanded(
              flex: 2,
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
                      color: theme.brightness == Brightness.dark
                          ? Colors.black.withOpacity(0.2)
                          : Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    customBorder: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 16,
                        cornerSmoothing: 0.6,
                      ),
                    ),
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
            ),
            const SizedBox(width: 12),
            // Now Button
            Container(
              decoration: ShapeDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 16,
                    cornerSmoothing: 0.6,
                  ),
                  side: BorderSide(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                shadows: [
                  BoxShadow(
                    color: theme.brightness == Brightness.dark
                        ? Colors.black.withOpacity(0.2)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  customBorder: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 16,
                      cornerSmoothing: 0.6,
                    ),
                  ),
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
    final DateTime? picked = await showDialog<DateTime>(
      context: context,
      builder: (context) => _DatePickerDialog(initialDate: _selectedDateTime),
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
    final TimeOfDay? picked = await showDialog<TimeOfDay>(
      context: context,
      builder: (context) => _TimePickerDialog(
        initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      ),
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
      borderRadius: SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 0.6),
      backgroundColor: theme.scaffoldBackgroundColor,
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
      borderRadius: SmoothBorderRadius(cornerRadius: 12, cornerSmoothing: 0.6),
      backgroundColor: theme.scaffoldBackgroundColor,
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
    _noteController.clear();
  }
}

class _DatePickerDialog extends StatefulWidget {
  final DateTime initialDate;

  const _DatePickerDialog({required this.initialDate});

  @override
  State<_DatePickerDialog> createState() => _DatePickerDialogState();
}

class _DatePickerDialogState extends State<_DatePickerDialog> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
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
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Date',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                      ),
                    ),
                  ),
                  Container(
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
                        onTap: () => Navigator.pop(context),
                        customBorder: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.close,
                            color: theme.iconTheme.color,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Date Picker
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: ShapeDecoration(
                  color: theme.scaffoldBackgroundColor,
                  shape: SmoothRectangleBorder(
                    borderRadius: SmoothBorderRadius(
                      cornerRadius: 16,
                      cornerSmoothing: 0.6,
                    ),
                  ),
                ),
                child: SfDateRangePicker(
                  backgroundColor: theme.scaffoldBackgroundColor,
                  view: DateRangePickerView.month,
                  selectionMode: DateRangePickerSelectionMode.single,
                  initialSelectedDate: _selectedDate,
                  minDate: DateTime.now().subtract(const Duration(days: 365)),
                  maxDate: DateTime.now().add(const Duration(days: 1)),
                  onSelectionChanged:
                      (DateRangePickerSelectionChangedArgs args) {
                        if (args.value is DateTime) {
                          setState(() {
                            _selectedDate = args.value;
                          });
                        }
                      },
                  monthViewSettings: DateRangePickerMonthViewSettings(
                    firstDayOfWeek: 1, // Monday
                    dayFormat: 'EEE',
                    viewHeaderStyle: DateRangePickerViewHeaderStyle(
                      backgroundColor: theme.scaffoldBackgroundColor,
                      textStyle: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: theme.textTheme.bodyMedium?.color?.withOpacity(
                          0.7,
                        ),
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                  yearCellStyle: DateRangePickerYearCellStyle(
                    textStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    todayTextStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  monthCellStyle: DateRangePickerMonthCellStyle(
                    textStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    todayTextStyle: TextStyle(
                      color: theme.colorScheme.primary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    disabledDatesTextStyle: TextStyle(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.3,
                      ),
                      fontSize: 16,
                    ),
                    weekendTextStyle: TextStyle(
                      color: theme.textTheme.bodyLarge?.color,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  selectionTextStyle: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  selectionColor: theme.colorScheme.primary,
                  todayHighlightColor: theme.colorScheme.primary.withOpacity(
                    0.3,
                  ),
                  headerStyle: DateRangePickerHeaderStyle(
                    backgroundColor: theme.scaffoldBackgroundColor,
                    textAlign: TextAlign.center,
                    textStyle: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.headlineSmall?.color,
                    ),
                  ),
                  navigationDirection:
                      DateRangePickerNavigationDirection.horizontal,
                  allowViewNavigation: true,
                  enablePastDates: true,
                  showNavigationArrow: true,
                  navigationMode: DateRangePickerNavigationMode.snap,
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedDate);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 16,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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

class _TimePickerDialog extends StatefulWidget {
  final TimeOfDay initialTime;

  const _TimePickerDialog({required this.initialTime});

  @override
  State<_TimePickerDialog> createState() => _TimePickerDialogState();
}

class _TimePickerDialogState extends State<_TimePickerDialog> {
  late TimeOfDay _selectedTime;
  late int _selectedHour;
  late int _selectedMinute;

  @override
  void initState() {
    super.initState();
    _selectedTime = widget.initialTime;
    _selectedHour = _selectedTime.hour; // Use 24-hour format
    _selectedMinute = _selectedTime.minute;
  }

  void _updateSelectedTime() {
    _selectedTime = TimeOfDay(hour: _selectedHour, minute: _selectedMinute);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
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
              color: Colors.black.withOpacity(0.2),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Select Time',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.headlineSmall?.color,
                      ),
                    ),
                  ),
                  Container(
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
                        onTap: () => Navigator.pop(context),
                        customBorder: SmoothRectangleBorder(
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 10,
                            cornerSmoothing: 0.6,
                          ),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          child: Icon(
                            Icons.close,
                            color: theme.iconTheme.color,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Time Display (24-hour format)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: theme.colorScheme.primary.withOpacity(0.1),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 16,
                    cornerSmoothing: 0.6,
                  ),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_selectedHour.toString().padLeft(2, '0')}:${_selectedMinute.toString().padLeft(2, '0')}',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Time Pickers
            Expanded(
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    // Hour Picker (24-hour format)
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Hour',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _buildScrollPicker(
                              itemCount: 24, // 0-23 hours
                              selectedIndex: _selectedHour,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedHour = index;
                                  _updateSelectedTime();
                                });
                              },
                              itemBuilder: (index) =>
                                  index.toString().padLeft(2, '0'),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 20),

                    // Minute Picker
                    Expanded(
                      child: Column(
                        children: [
                          Text(
                            'Minute',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: theme.textTheme.bodyMedium?.color
                                  ?.withOpacity(0.7),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Expanded(
                            child: _buildScrollPicker(
                              itemCount: 60,
                              selectedIndex: _selectedMinute,
                              onSelectedItemChanged: (index) {
                                setState(() {
                                  _selectedMinute = index;
                                  _updateSelectedTime();
                                });
                              },
                              itemBuilder: (index) =>
                                  index.toString().padLeft(2, '0'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Apply Button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, _selectedTime);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: SmoothRectangleBorder(
                      borderRadius: SmoothBorderRadius(
                        cornerRadius: 16,
                        cornerSmoothing: 0.6,
                      ),
                    ),
                  ),
                  child: const Text(
                    'Apply',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollPicker({
    required int itemCount,
    required int selectedIndex,
    required ValueChanged<int> onSelectedItemChanged,
    required String Function(int) itemBuilder,
  }) {
    final theme = Theme.of(context);

    return Container(
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
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        perspective: 0.005,
        diameterRatio: 1.2,
        physics: const FixedExtentScrollPhysics(),
        controller: FixedExtentScrollController(initialItem: selectedIndex),
        onSelectedItemChanged: onSelectedItemChanged,
        childDelegate: ListWheelChildBuilderDelegate(
          childCount: itemCount,
          builder: (context, index) {
            final isSelected = index == selectedIndex;
            return Container(
              alignment: Alignment.center,
              child: Text(
                itemBuilder(index),
                style: TextStyle(
                  fontSize: isSelected ? 20 : 16,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? theme.colorScheme.primary
                      : theme.textTheme.bodyLarge?.color?.withOpacity(0.7),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
