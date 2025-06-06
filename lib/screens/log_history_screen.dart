import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toastification/toastification.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../providers/glucose_data_provider.dart';
import '../providers/glucose_trend_data_provider.dart';
import '../providers/log_history_data_provider.dart';
import '../models/log_entry.dart';
import 'dart:math' as math;

class LogHistoryScreen extends StatefulWidget {
  final bool isCalendarView;
  final Function(bool) onViewToggle;

  const LogHistoryScreen({
    super.key,
    required this.isCalendarView,
    required this.onViewToggle,
  });

  @override
  State<LogHistoryScreen> createState() => _LogHistoryScreenState();
}

class _LogHistoryScreenState extends State<LogHistoryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;

  // Filter chip selection state
  Set<String> _selectedFilters = {
    'All',
    'Glucose',
    'Meal',
    'Activity',
    'Medication',
  };

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadData();
  }

  Future<void> _loadData() async {
    // Use provider to load data
    final logHistoryProvider = Provider.of<LogHistoryDataProvider>(
      context,
      listen: false,
    );
    await logHistoryProvider.getLogHistoryData();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Consumer<LogHistoryDataProvider>(
          builder: (context, logHistoryProvider, child) {
            return RefreshIndicator(
              onRefresh: () => logHistoryProvider.refreshData(),
              child: Column(
                children: [
                  // Fixed header content
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),

                        // Search Bar - only show in list view
                        if (!widget.isCalendarView) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: theme.brightness == Brightness.dark
                                  ? const Color(0xFF2A2A2A)
                                  : const Color(0xFFF0F1F7),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons.search,
                                  color: theme.colorScheme.primary,
                                  size: 24,
                                ),
                                const SizedBox(width: 12),
                                Text(
                                  'Search',
                                  style: TextStyle(
                                    color: theme.textTheme.bodyMedium?.color,
                                    fontSize: 16,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Filter Buttons - only show in list view
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildMaterialFilterChip('All'),
                                const SizedBox(width: 12),
                                _buildMaterialFilterChip('Glucose'),
                                const SizedBox(width: 12),
                                _buildMaterialFilterChip('Meal'),
                                const SizedBox(width: 12),
                                _buildMaterialFilterChip('Activity'),
                                const SizedBox(width: 12),
                                _buildMaterialFilterChip('Medication'),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Calendar (fixed) - only show in calendar view
                        if (widget.isCalendarView) ...[
                          _buildFixedCalendar(theme, logHistoryProvider),
                          const SizedBox(height: 20),
                        ],
                      ],
                    ),
                  ),

                  // Scrollable content
                  Expanded(
                    child: widget.isCalendarView
                        ? _buildScrollableCalendarEvents(logHistoryProvider)
                        : _buildScrollableListView(logHistoryProvider),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFixedCalendar(ThemeData theme, LogHistoryDataProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.grey[200]!,
        ),
      ),
      child: TableCalendar<LogEntry>(
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        focusedDay: _focusedDay,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        eventLoader: (day) => provider.getEventsForDay(day),
        startingDayOfWeek: StartingDayOfWeek.monday,
        calendarStyle: CalendarStyle(
          outsideDaysVisible: false,

          // Default day styling
          defaultTextStyle: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),

          // Weekend styling
          weekendTextStyle: TextStyle(
            color: theme.textTheme.bodyLarge?.color,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),

          // Holiday styling
          holidayTextStyle: TextStyle(
            color: Colors.red[600],
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),

          // Selected day styling - use circle to avoid conflicts
          selectedDecoration: BoxDecoration(
            color: theme.colorScheme.primary,
            shape: BoxShape.circle,
          ),
          selectedTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),

          // Today styling - use circle to avoid conflicts
          todayDecoration: BoxDecoration(
            color: theme.colorScheme.primary.withOpacity(0.2),
            shape: BoxShape.circle,
            border: Border.all(color: theme.colorScheme.primary, width: 1.5),
          ),
          todayTextStyle: TextStyle(
            color: theme.colorScheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),

          // Event markers
          markerDecoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? Colors.grey[600]
                : Colors.grey[400],
            shape: BoxShape.circle,
          ),
          markersMaxCount: 3,
          markerSize: 4,
          markersOffset: const PositionedOffset(bottom: 8),

          // Cell styling to make circles appear more square-like
          cellMargin: const EdgeInsets.all(2),
          cellPadding: const EdgeInsets.all(2),

          // Outside days (disabled)
          disabledTextStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color?.withOpacity(0.3),
            fontSize: 14,
          ),

          // Row decoration
          rowDecoration: const BoxDecoration(),
          tableBorder: TableBorder.all(color: Colors.transparent),
        ),
        headerStyle: HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,

          // Header styling
          headerPadding: const EdgeInsets.symmetric(vertical: 16),
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.headlineSmall?.color,
          ),

          // Navigation arrows
          leftChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF0F1F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_left,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),
          rightChevronIcon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.brightness == Brightness.dark
                  ? const Color(0xFF2A2A2A)
                  : const Color(0xFFF0F1F7),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.primary,
              size: 20,
            ),
          ),

          // Header decoration
          decoration: BoxDecoration(color: Colors.transparent),
        ),
        daysOfWeekStyle: DaysOfWeekStyle(
          weekdayStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          weekendStyle: TextStyle(
            color: theme.textTheme.bodyMedium?.color,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
      ),
    );
  }

  Widget _buildScrollableCalendarEvents(LogHistoryDataProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Events header
          if (_selectedDay != null)
            Text(
              'Events for ${_selectedDay!.day}/${_selectedDay!.month}/${_selectedDay!.year}',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).textTheme.headlineSmall?.color,
              ),
            ),
          const SizedBox(height: 16),

          // Scrollable events list
          Expanded(
            child: provider.isLoading && !provider.hasData
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'Loading events...',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : _selectedDay != null &&
                      provider.getEventsForDay(_selectedDay!).isNotEmpty
                ? ListView.separated(
                    itemCount: provider.getEventsForDay(_selectedDay!).length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final entry = provider.getEventsForDay(
                        _selectedDay!,
                      )[index];
                      return _buildLogEntryCard(entry);
                    },
                  )
                : _selectedDay != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64,
                            color: Colors.grey[400],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No events for this day',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try selecting a different date or log some activities.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[500],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  )
                : Container(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildScrollableListView(LogHistoryDataProvider provider) {
    // Show loading spinner when loading and no data (first time)
    if (provider.isLoading && !provider.hasData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading your activity log...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    final filteredEvents = provider.getFilteredEvents(_selectedFilters);

    // Show "no events" only when not loading and no data
    if (filteredEvents.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_note, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No events found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Try logging some activities or adjusting your filters.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: ListView.separated(
        itemCount: filteredEvents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildLogEntryCard(filteredEvents[index]);
        },
      ),
    );
  }

  Widget _buildLogEntryCard(LogEntry entry) {
    final theme = Theme.of(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showEventDetailsBottomSheet(entry),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: theme.brightness == Brightness.dark
                ? const Color(0xFF2A2A2A)
                : Colors.grey[50],
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
                    entry.icon,
                    color: theme.colorScheme.primary,
                    size: 18,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.textTheme.titleMedium?.color,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      entry.value,
                      style: TextStyle(
                        fontSize: 14,
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                entry.time,
                style: TextStyle(
                  fontSize: 12,
                  color: theme.textTheme.bodySmall?.color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showEventDetailsBottomSheet(LogEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) =>
          EventDetailsBottomSheet(entry: entry, onDataChanged: _loadData),
    );
  }

  Widget _buildMaterialFilterChip(String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilters.contains(label);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (label == 'All') {
            if (isSelected) {
              // If "All" is selected, deselect it
              _selectedFilters.remove('All');
            } else {
              // If "All" is not selected, select it and deselect others
              _selectedFilters.clear();
              _selectedFilters.add('All');
            }
          } else {
            // For other filters
            if (isSelected) {
              _selectedFilters.remove(label);
              // If no other filters are selected, select "All"
              if (_selectedFilters.isEmpty) {
                _selectedFilters.add('All');
              }
            } else {
              // Remove "All" when selecting a specific filter
              _selectedFilters.remove('All');
              _selectedFilters.add(label);
            }
          }
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primary
              : (theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (theme.brightness == Brightness.dark
                      ? const Color(0xFF3A3A3A)
                      : Colors.grey[300]!),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (theme.brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

class EventDetailsBottomSheet extends StatelessWidget {
  final LogEntry entry;
  final VoidCallback? onDataChanged;

  const EventDetailsBottomSheet({
    super.key,
    required this.entry,
    this.onDataChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.bottomSheetTheme.backgroundColor ?? theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with action buttons
            Row(
              children: [
                Text(
                  'Event Details',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: theme.textTheme.headlineSmall?.color,
                  ),
                ),
                const SizedBox(width: 16),
                // Modify icon button
                Material(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.pop(context);
                      _showModifyDialog(context, entry);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.edit,
                        color: theme.colorScheme.primary,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Delete icon button
                Material(
                  color: theme.brightness == Brightness.dark
                      ? const Color(0xFF2A2A2A)
                      : const Color(0xFFF0F1F7),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(context, entry);
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.delete,
                        color: Colors.red[500],
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Close button
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

            // Event details card - clean without any buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Icon
                  Container(
                    height: 60,
                    width: 60,
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Center(
                      child: FaIcon(
                        entry.icon,
                        color: theme.colorScheme.primary,
                        size: 28,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Title
                  Text(
                    entry.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: theme.textTheme.titleLarge?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Value
                  Text(
                    entry.value,
                    style: TextStyle(
                      fontSize: 16,
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  // Time
                  Text(
                    entry.time,
                    style: TextStyle(
                      fontSize: 14,
                      color: theme.textTheme.bodyMedium?.color,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            // Add bottom padding for safe area
            SizedBox(height: MediaQuery.of(context).padding.bottom),
          ],
        ),
      ),
    );
  }

  void _showModifyDialog(BuildContext context, LogEntry entry) {
    final theme = Theme.of(context);

    // Create controllers and initialize with current values
    final controllers = <String, TextEditingController>{};

    // Parse current values based on entry type
    if (entry.title == 'Glucose') {
      final glucoseValue = entry.value.replaceAll(' mg/dL', '');
      controllers['measure'] = TextEditingController(text: glucoseValue);
    } else if (entry.title == 'Meal') {
      // Parse meal data
      final parts = entry.value.split(' (');
      controllers['name'] = TextEditingController(text: parts[0]);
      if (parts.length > 1) {
        final carbsText = parts[1].replaceAll('g carbs)', '');
        controllers['carbs'] = TextEditingController(text: carbsText);
      } else {
        controllers['carbs'] = TextEditingController();
      }
    } else if (entry.title == 'Activity') {
      final parts = entry.value.split(' (');
      controllers['name'] = TextEditingController(text: parts[0]);
      if (parts.length > 1) {
        final durationText = parts[1].replaceAll('min)', '');
        controllers['duration'] = TextEditingController(text: durationText);
      } else {
        controllers['duration'] = TextEditingController();
      }
    } else if (entry.title == 'Medication') {
      final parts = entry.value.split(' (');
      controllers['name'] = TextEditingController(text: parts[0]);
      if (parts.length > 1) {
        final doseText = parts[1].replaceAll(' units)', '');
        controllers['dose'] = TextEditingController(text: doseText);
      } else {
        controllers['dose'] = TextEditingController();
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Modify ${entry.title}',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.headlineMedium?.color,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: _buildModifyFields(entry.title, controllers),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // Dispose controllers
              controllers.values.forEach((controller) => controller.dispose());
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: theme.textTheme.bodyMedium?.color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await _saveModifiedEvent(context, entry, controllers);
              // Dispose controllers
              controllers.values.forEach((controller) => controller.dispose());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Save',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildModifyFields(
    String entryType,
    Map<String, TextEditingController> controllers,
  ) {
    switch (entryType) {
      case 'Glucose':
        return [
          TextField(
            controller: controllers['measure'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Glucose (mg/dL)',
              border: OutlineInputBorder(),
            ),
          ),
        ];
      case 'Meal':
        return [
          TextField(
            controller: controllers['name'],
            decoration: const InputDecoration(
              labelText: 'Meal Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controllers['carbs'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Carbs (g)',
              border: OutlineInputBorder(),
            ),
          ),
        ];
      case 'Activity':
        return [
          TextField(
            controller: controllers['name'],
            decoration: const InputDecoration(
              labelText: 'Activity Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controllers['duration'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Duration (min)',
              border: OutlineInputBorder(),
            ),
          ),
        ];
      case 'Medication':
        return [
          TextField(
            controller: controllers['name'],
            decoration: const InputDecoration(
              labelText: 'Medication Name',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: controllers['dose'],
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Dose (units)',
              border: OutlineInputBorder(),
            ),
          ),
        ];
      default:
        return [];
    }
  }

  Future<void> _saveModifiedEvent(
    BuildContext context,
    LogEntry entry,
    Map<String, TextEditingController> controllers,
  ) async {
    try {
      Map<String, dynamic> updates = {};

      switch (entry.title) {
        case 'Glucose':
          final measure = double.tryParse(controllers['measure']?.text ?? '');
          if (measure != null) {
            updates['measure'] = measure;
          }
          break;
        case 'Meal':
          final name = controllers['name']?.text.trim();
          if (name != null && name.isNotEmpty) {
            updates['name'] = name;
          }
          final carbs = double.tryParse(controllers['carbs']?.text ?? '');
          if (carbs != null) {
            updates['carbs'] = carbs;
          }
          break;
        case 'Activity':
          final name = controllers['name']?.text.trim();
          if (name != null && name.isNotEmpty) {
            updates['name'] = name;
          }
          final duration = int.tryParse(controllers['duration']?.text ?? '');
          if (duration != null) {
            updates['duration'] = duration;
          }
          break;
        case 'Medication':
          final name = controllers['name']?.text.trim();
          if (name != null && name.isNotEmpty) {
            updates['name'] = name;
          }
          final dose = double.tryParse(controllers['dose']?.text ?? '');
          if (dose != null) {
            updates['dose'] = dose;
          }
          break;
      }

      if (updates.isNotEmpty) {
        final success = await FirestoreService.updateEvent(entry.id, updates);
        if (success) {
          // Refresh local data via callback
          onDataChanged?.call();

          // If glucose data was updated, refresh the glucose and trend caches
          if (entry.title == 'Glucose') {
            print('🩸 Glucose data updated successfully, refreshing caches...');
            try {
              await GlucoseDataProvider.invalidateAndRefreshGlobally(context);
              await GlucoseTrendDataProvider.invalidateAndRefreshGlobally(
                context,
              );
              print('🩸 Caches refreshed successfully after update');
            } catch (e) {
              print('🩸 Failed to refresh caches after update: $e');
            }
          }

          // Refresh log history cache for any type of data
          print(
            '📚 Data updated successfully, refreshing log history cache...',
          );
          try {
            await LogHistoryDataProvider.invalidateAndRefreshGlobally(context);
            print('📚 Log history cache refreshed successfully after update');
          } catch (e) {
            print('📚 Failed to refresh log history cache after update: $e');
          }

          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(
              'Success',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            description: Text('${entry.title} updated successfully'),
            alignment: Alignment.topCenter,
            autoCloseDuration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).cardColor,
            icon: Icon(
              Icons.check_circle_outline,
              color: Theme.of(context).colorScheme.primary,
            ),
          );
        } else {
          toastification.show(
            context: context,
            type: ToastificationType.error,
            style: ToastificationStyle.flat,
            title: Text(
              'Error',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            description: Text('Failed to update ${entry.title}'),
            alignment: Alignment.topCenter,
            autoCloseDuration: const Duration(seconds: 3),
            backgroundColor: Theme.of(context).cardColor,
            icon: Icon(Icons.error_outline, color: Colors.red[600]),
          );
        }
      }
    } catch (e) {
      print('Error updating event: $e');
    }
  }

  void _showDeleteConfirmation(BuildContext context, LogEntry entry) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(
          'Delete Entry',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: theme.textTheme.headlineMedium?.color,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this ${entry.title.toLowerCase()} entry?',
          style: TextStyle(
            fontSize: 14,
            color: theme.textTheme.bodyMedium?.color,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: theme.textTheme.bodyMedium?.color,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              // Capture the parent context before popping the dialog
              final parentContext = Navigator.of(context).context;
              Navigator.pop(context);

              final success = await FirestoreService.deleteEvent(entry.id);
              if (success) {
                // Refresh local data via callback
                onDataChanged?.call();

                // If glucose data was deleted, refresh the glucose and trend caches
                if (entry.title == 'Glucose') {
                  print(
                    '🩸 Glucose data deleted successfully, refreshing caches...',
                  );
                  try {
                    await GlucoseDataProvider.invalidateAndRefreshGlobally(
                      parentContext,
                    );
                    await GlucoseTrendDataProvider.invalidateAndRefreshGlobally(
                      parentContext,
                    );
                    print('🩸 Caches refreshed successfully after deletion');
                  } catch (e) {
                    print('🩸 Failed to refresh caches after deletion: $e');
                  }
                }

                // Refresh log history cache for any type of data
                print(
                  '📚 Data deleted successfully, refreshing log history cache...',
                );
                try {
                  await LogHistoryDataProvider.invalidateAndRefreshGlobally(
                    parentContext,
                  );
                  print(
                    '📚 Log history cache refreshed successfully after deletion',
                  );
                } catch (e) {
                  print(
                    '📚 Failed to refresh log history cache after deletion: $e',
                  );
                }

                toastification.show(
                  context: parentContext,
                  type: ToastificationType.success,
                  style: ToastificationStyle.flat,
                  title: Text(
                    'Success',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  description: Text('${entry.title} entry deleted'),
                  alignment: Alignment.topCenter,
                  autoCloseDuration: const Duration(seconds: 3),
                  backgroundColor: Theme.of(parentContext).cardColor,
                  icon: Icon(
                    Icons.check_circle_outline,
                    color: Theme.of(parentContext).colorScheme.primary,
                  ),
                );
              } else {
                toastification.show(
                  context: parentContext,
                  type: ToastificationType.error,
                  style: ToastificationStyle.flat,
                  title: Text(
                    'Error',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  description: Text('Failed to delete ${entry.title} entry'),
                  alignment: Alignment.topCenter,
                  autoCloseDuration: const Duration(seconds: 3),
                  backgroundColor: Theme.of(parentContext).cardColor,
                  icon: Icon(Icons.error_outline, color: Colors.red[600]),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[500],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}
