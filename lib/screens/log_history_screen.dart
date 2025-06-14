import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:toastification/toastification.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:provider/provider.dart';
import 'package:figma_squircle/figma_squircle.dart';
import 'package:liquid_pull_to_refresh/liquid_pull_to_refresh.dart';
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

  // Search functionality
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _selectedDay = DateTime.now();
    _loadData();

    // Listen to search changes
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text.toLowerCase();
      });
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
            // Clear search when switching to calendar view
            if (widget.isCalendarView && _searchQuery.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _searchController.clear();
              });
            }

            return LiquidPullToRefresh(
              onRefresh: () => logHistoryProvider.refreshData(),
              color: theme.colorScheme.primary,
              backgroundColor: theme.scaffoldBackgroundColor,
              height: 80,
              animSpeedFactor: 6,
              showChildOpacityTransition: false,
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
                          Focus(
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
                                            ? theme.colorScheme.primary
                                                  .withOpacity(0.8)
                                            : theme.brightness ==
                                                  Brightness.dark
                                            ? const Color(0xFF3A3A3A)
                                            : Colors.grey[200]!,
                                        width: isFocused ? 2 : 1,
                                      ),
                                    ),
                                    shadows: isFocused
                                        ? [
                                            BoxShadow(
                                              color: theme.colorScheme.primary
                                                  .withOpacity(0.1),
                                              blurRadius: 12,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : [
                                            BoxShadow(
                                              color: Colors.black.withOpacity(
                                                0.03,
                                              ),
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
                                      controller: _searchController,
                                      style: TextStyle(
                                        color:
                                            theme.textTheme.bodyMedium?.color,
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        hintText: 'Search events...',
                                        hintStyle: TextStyle(
                                          color: theme.colorScheme.primary
                                              .withOpacity(0.7),
                                          fontSize: 16,
                                        ),
                                        prefixIcon: Icon(
                                          Icons.search,
                                          color: theme.colorScheme.primary,
                                          size: 24,
                                        ),
                                        suffixIcon: _searchQuery.isNotEmpty
                                            ? IconButton(
                                                icon: Icon(
                                                  Icons.clear,
                                                  color: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.color
                                                      ?.withOpacity(0.6),
                                                  size: 20,
                                                ),
                                                onPressed: () {
                                                  _searchController.clear();
                                                },
                                              )
                                            : null,
                                        border: InputBorder.none,
                                        focusedBorder: InputBorder.none,
                                        enabledBorder: InputBorder.none,
                                        errorBorder: InputBorder.none,
                                        focusedErrorBorder: InputBorder.none,
                                        disabledBorder: InputBorder.none,
                                        filled: false,
                                        fillColor: Colors.transparent,
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                      ),
                                    ),
                                  ),
                                );
                              },
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

                          // Search results count (only show when searching)
                          if (_searchQuery.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              child: Text(
                                () {
                                  final filteredEvents = logHistoryProvider
                                      .getFilteredEvents(_selectedFilters);
                                  final searchResults = filteredEvents.where((
                                    event,
                                  ) {
                                    final searchLower = _searchQuery
                                        .toLowerCase();
                                    return event.title.toLowerCase().contains(
                                          searchLower,
                                        ) ||
                                        event.value.toLowerCase().contains(
                                          searchLower,
                                        ) ||
                                        event.time.toLowerCase().contains(
                                          searchLower,
                                        );
                                  }).length;
                                  return searchResults == 1
                                      ? '1 result found'
                                      : '$searchResults results found';
                                }(),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: theme.textTheme.bodyMedium?.color
                                      ?.withOpacity(0.7),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],

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
      decoration: ShapeDecoration(
        color: theme.scaffoldBackgroundColor,
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
      child: ClipSmoothRect(
        radius: SmoothBorderRadius(cornerRadius: 16, cornerSmoothing: 0.6),
        child: TableCalendar<LogEntry>(
          firstDay: DateTime.utc(2020, 1, 1),
          lastDay: DateTime.utc(2030, 12, 31),
          focusedDay: _focusedDay,
          selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
          eventLoader: (day) => provider.getEventsForDay(day),
          startingDayOfWeek: StartingDayOfWeek.monday,
          calendarBuilders: CalendarBuilders(
            // Custom event marker builder
            markerBuilder: (context, day, events) {
              if (events.isEmpty) return null;

              // Group events by type and show up to 4 different colored dots
              final eventTypes = events
                  .map((e) => (e as LogEntry).title)
                  .toSet()
                  .take(4)
                  .toList();

              return Positioned(
                bottom: 1,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: eventTypes.map((type) {
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 0.5),
                      height: 6,
                      width: 6,
                      decoration: BoxDecoration(
                        color: _getCalendarMarkerColor(type),
                        shape: BoxShape.circle,
                      ),
                    );
                  }).toList(),
                ),
              );
            },
          ),
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

            // Navigation arrows with squircle design
            leftChevronIcon: Container(
              padding: const EdgeInsets.all(8),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.chevron_left,
                color: theme.colorScheme.primary,
                size: 20,
              ),
            ),
            rightChevronIcon: Container(
              padding: const EdgeInsets.all(8),
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
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
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
                ? () {
                    // Get events for the selected day
                    final dayEvents = provider.getEventsForDay(_selectedDay!);

                    // Apply search filtering if search query exists
                    final filteredDayEvents = _searchQuery.isEmpty
                        ? dayEvents
                        : dayEvents.where((event) {
                            final searchLower = _searchQuery.toLowerCase();
                            return event.title.toLowerCase().contains(
                                  searchLower,
                                ) ||
                                event.value.toLowerCase().contains(
                                  searchLower,
                                ) ||
                                event.time.toLowerCase().contains(searchLower);
                          }).toList();

                    return filteredDayEvents.isNotEmpty
                        ? ListView.separated(
                            itemCount: filteredDayEvents.length,
                            separatorBuilder: (context, index) =>
                                const SizedBox(height: 12),
                            itemBuilder: (context, index) {
                              return _buildLogEntryCard(
                                filteredDayEvents[index],
                              );
                            },
                          )
                        : Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    _searchQuery.isNotEmpty
                                        ? Icons.search_off
                                        : Icons.calendar_today_outlined,
                                    size: 64,
                                    color: Colors.grey[400],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'No matching events for this day'
                                        : 'No events for this day',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    _searchQuery.isNotEmpty
                                        ? 'Try adjusting your search terms.'
                                        : 'Try selecting a different date or log some activities.',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey[500],
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                          );
                  }()
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

    // Get filtered events based on selected filters
    final filteredEvents = provider.getFilteredEvents(_selectedFilters);

    // Apply search filtering
    final searchFilteredEvents = _searchQuery.isEmpty
        ? filteredEvents
        : filteredEvents.where((event) {
            final searchLower = _searchQuery.toLowerCase();
            return event.title.toLowerCase().contains(searchLower) ||
                event.value.toLowerCase().contains(searchLower) ||
                event.time.toLowerCase().contains(searchLower);
          }).toList();

    // Show "no events" only when not loading and no data
    if (searchFilteredEvents.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _searchQuery.isNotEmpty ? Icons.search_off : Icons.event_note,
                size: 64,
                color: Colors.grey,
              ),
              const SizedBox(height: 16),
              Text(
                _searchQuery.isNotEmpty
                    ? 'No matching events found'
                    : 'No events found',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _searchQuery.isNotEmpty
                    ? 'Try adjusting your search terms or filters.'
                    : 'Try logging some activities or adjusting your filters.',
                style: const TextStyle(fontSize: 14, color: Colors.grey),
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
        itemCount: searchFilteredEvents.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          return _buildLogEntryCard(searchFilteredEvents[index]);
        },
      ),
    );
  }

  Widget _buildLogEntryCard(LogEntry entry) {
    final theme = Theme.of(context);

    return Container(
      decoration: ShapeDecoration(
        color: theme.scaffoldBackgroundColor,
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
          borderRadius: BorderRadius.circular(16),
          splashColor: _getEventColor(
            context,
            entry.title.toLowerCase(),
          ).withOpacity(0.2),
          highlightColor: _getEventColor(
            context,
            entry.title.toLowerCase(),
          ).withOpacity(0.1),
          onTap: () => _showEventDetailsBottomSheet(entry),
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  height: 50,
                  width: 50,
                  decoration: _getIconContainerDecoration(
                    context,
                    entry.title.toLowerCase(),
                  ),
                  child: Center(
                    child: FaIcon(
                      entry.icon,
                      color: _getEventColor(context, entry.title.toLowerCase()),
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
                        entry.title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: theme.textTheme.titleMedium?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          color: _getEventColor(context, entry.title),
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
      ),
    );
  }

  void _showEventDetailsBottomSheet(LogEntry entry) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      shape: const SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius.only(
          topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
          topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
        ),
      ),
      builder: (context) =>
          EventDetailsBottomSheet(entry: entry, onDataChanged: _loadData),
    );
  }

  Widget _buildMaterialFilterChip(String label) {
    final theme = Theme.of(context);
    final isSelected = _selectedFilters.contains(label);
    final chipColor = label == 'All'
        ? theme.colorScheme.primary
        : _getEventColor(context, label);

    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : theme.textTheme.bodyLarge?.color,
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
      ),
      selected: isSelected,
      showCheckmark: false,
      onSelected: (bool value) {
        setState(() {
          if (label == 'All') {
            if (isSelected) {
              // If "All" is selected, deselect everything
              _selectedFilters.clear();
            } else {
              // If "All" is not selected, select everything
              _selectedFilters = {
                'All',
                'Glucose',
                'Meal',
                'Activity',
                'Medication',
              };
            }
          } else {
            // For other filters
            if (isSelected) {
              _selectedFilters.remove(label);
              // If we deselect a specific filter, also deselect "All"
              _selectedFilters.remove('All');
              // If no filters are selected, we should show no filter state
            } else {
              _selectedFilters.add(label);
              // Check if all individual filters are now selected
              if (_selectedFilters.contains('Glucose') &&
                  _selectedFilters.contains('Meal') &&
                  _selectedFilters.contains('Activity') &&
                  _selectedFilters.contains('Medication')) {
                _selectedFilters.add('All');
              }
            }
          }
        });
      },
      shape: SmoothRectangleBorder(
        borderRadius: SmoothBorderRadius(
          cornerRadius: 10,
          cornerSmoothing: 0.6,
        ),
        side: BorderSide(
          color: isSelected
              ? chipColor
              : theme.brightness == Brightness.dark
              ? const Color(0xFF4A4A4A)
              : Colors.grey[300]!,
          width: 1,
        ),
      ),
      backgroundColor: isSelected
          ? chipColor
          : theme.brightness == Brightness.dark
          ? const Color(0xFF2A2A2A)
          : Colors.white,
      selectedColor: chipColor,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: VisualDensity.compact,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    );
  }

  // Helper function to get color for each event type with subtle differentiation
  Color _getEventColor(BuildContext context, String eventType) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;

    // Use different opacity levels for subtle differentiation
    switch (eventType.toLowerCase()) {
      case 'glucose':
        return baseColor; // 100% opacity - most important
      case 'meal':
        return baseColor.withOpacity(0.85); // 85% opacity
      case 'activity':
        return baseColor.withOpacity(0.75); // 75% opacity
      case 'medication':
        return baseColor.withOpacity(0.65); // 65% opacity
      default:
        return baseColor;
    }
  }

  // Helper function to get distinct colors for calendar markers
  Color _getCalendarMarkerColor(String eventType) {
    switch (eventType.toLowerCase()) {
      case 'glucose':
        return Colors.red[400]!.withOpacity(0.3); // Red for glucose
      case 'meal':
        return Colors.orange[400]!.withOpacity(0.3); // Orange for meals
      case 'activity':
        return Colors.green[400]!.withOpacity(0.3); // Green for activity
      case 'medication':
        return Colors.blue[400]!.withOpacity(0.3); // Blue for medication
      default:
        return Colors.grey[400]!.withOpacity(0.3);
    }
  }

  // Helper function to get icon container decoration for each event type
  Decoration _getIconContainerDecoration(
    BuildContext context,
    String eventType,
  ) {
    final theme = Theme.of(context);

    switch (eventType.toLowerCase()) {
      case 'glucose':
        // Red border for glucose - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.red[400]!.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.red.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'meal':
        // Orange border for meals - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.orange[400]!.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'activity':
        // Green border for activity - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.green[400]!.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.green.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'medication':
        // Blue border for medication - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.blue[400]!.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      default:
        return ShapeDecoration(
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
        );
    }
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

  // Helper function to get color for each event type with subtle differentiation
  Color _getEventColor(BuildContext context, String eventType) {
    final theme = Theme.of(context);
    final baseColor = theme.colorScheme.primary;

    // Use different opacity levels for subtle differentiation
    switch (eventType.toLowerCase()) {
      case 'glucose':
        return baseColor; // 100% opacity - most important
      case 'meal':
        return baseColor.withOpacity(0.85); // 85% opacity
      case 'activity':
        return baseColor.withOpacity(0.75); // 75% opacity
      case 'medication':
        return baseColor.withOpacity(0.65); // 65% opacity
      default:
        return baseColor;
    }
  }

  // Helper function to get icon container decoration for each event type
  Decoration _getIconContainerDecoration(
    BuildContext context,
    String eventType,
  ) {
    final theme = Theme.of(context);

    switch (eventType.toLowerCase()) {
      case 'glucose':
        // Light red/pink background for glucose
        return ShapeDecoration(
          color: const Color(0xFFFFEBEE), // Light red background
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.red.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'meal':
        // Light orange background for meals
        return ShapeDecoration(
          color: const Color(0xFFFFF3E0), // Light orange background
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'activity':
        // Light green background for activity
        return ShapeDecoration(
          color: const Color(0xFFE8F5E8), // Light green background
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.green.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'medication':
        // Light blue background for medication
        return ShapeDecoration(
          color: const Color(0xFFE3F2FD), // Light blue background
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 14,
              cornerSmoothing: 0.6,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      default:
        return ShapeDecoration(
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
        );
    }
  }

  // Helper function for detail sheet with larger corner radius
  Decoration _getIconContainerDecorationForDetail(
    BuildContext context,
    String eventType,
  ) {
    final theme = Theme.of(context);

    switch (eventType.toLowerCase()) {
      case 'glucose':
        // Red border for glucose - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 18,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.red[400]!.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.red.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'meal':
        // Orange border for meals - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 18,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.orange[400]!.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.orange.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'activity':
        // Green border for activity - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 18,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.green[400]!.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.green.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      case 'medication':
        // Blue border for medication - more subtle
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
              ? const Color(0xFF3A3A3A)
              : Colors.white,
          shape: SmoothRectangleBorder(
            borderRadius: SmoothBorderRadius(
              cornerRadius: 18,
              cornerSmoothing: 0.6,
            ),
            side: BorderSide(
              color: Colors.blue[400]!.withOpacity(0.25),
              width: 1.5,
            ),
          ),
          shadows: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
      default:
        return ShapeDecoration(
          color: theme.brightness == Brightness.dark
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
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: ShapeDecoration(
        color: theme.scaffoldBackgroundColor,
        shape: const SmoothRectangleBorder(
          borderRadius: SmoothBorderRadius.only(
            topLeft: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
            topRight: SmoothRadius(cornerRadius: 20, cornerSmoothing: 0.6),
          ),
        ),
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
                // Delete icon button
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
                        color: Colors.black.withOpacity(0.05),
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
                      onTap: () {
                        Navigator.pop(context);
                        _showDeleteConfirmation(context, entry);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red[500],
                          size: 18,
                        ),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                // Close button
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
                        color: Colors.black.withOpacity(0.05),
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
            const SizedBox(height: 20),

            // Event details card - clean without any buttons
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: ShapeDecoration(
                color: theme.brightness == Brightness.dark
                    ? const Color(0xFF2A2A2A)
                    : const Color(0xFFF0F1F7),
                shape: SmoothRectangleBorder(
                  borderRadius: SmoothBorderRadius(
                    cornerRadius: 16,
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
              child: Column(
                children: [
                  // Icon
                  Container(
                    height: 60,
                    width: 60,
                    decoration: _getIconContainerDecorationForDetail(
                      context,
                      entry.title.toLowerCase(),
                    ),
                    child: Center(
                      child: FaIcon(
                        entry.icon,
                        color: _getEventColor(
                          context,
                          entry.title.toLowerCase(),
                        ),
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
                      color: _getEventColor(context, entry.title),
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

  void _showDeleteConfirmation(BuildContext context, LogEntry entry) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => Dialog(
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
                'Delete Entry',
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
                'Are you sure you want to delete this ${entry.title.toLowerCase()} entry?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: theme.textTheme.bodyMedium?.color,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Delete button (full width)
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
                    onTap: () async {
                      // Capture the parent context before popping the dialog
                      final parentContext = Navigator.of(context).context;
                      Navigator.pop(context);

                      final success = await FirestoreService.deleteEvent(
                        entry.id,
                      );
                      if (success) {
                        // Refresh local data via callback
                        onDataChanged?.call();

                        // If glucose data was deleted, refresh the glucose and trend caches
                        if (entry.title == 'Glucose') {
                          try {
                            await GlucoseDataProvider.invalidateAndRefreshGlobally(
                              parentContext,
                            );
                            await GlucoseTrendDataProvider.invalidateAndRefreshGlobally(
                              parentContext,
                            );
                          } catch (e) {}
                        }

                        // Refresh log history cache for any type of data
                        try {
                          await LogHistoryDataProvider.invalidateAndRefreshGlobally(
                            parentContext,
                          );
                        } catch (e) {}

                        toastification.show(
                          context: parentContext,
                          type: ToastificationType.success,
                          style: ToastificationStyle.flat,
                          title: Text(
                            'Success',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          description: Text('${entry.title} entry deleted'),
                          alignment: Alignment.topCenter,
                          autoCloseDuration: const Duration(seconds: 3),
                          backgroundColor: Theme.of(parentContext).cardColor,
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 0.6,
                          ),
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
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          description: Text(
                            'Failed to delete ${entry.title} entry',
                          ),
                          alignment: Alignment.topCenter,
                          autoCloseDuration: const Duration(seconds: 3),
                          backgroundColor: Theme.of(parentContext).cardColor,
                          borderRadius: SmoothBorderRadius(
                            cornerRadius: 12,
                            cornerSmoothing: 0.6,
                          ),
                          icon: Icon(
                            Icons.error_outline,
                            color: Colors.red[600],
                          ),
                        );
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
            ],
          ),
        ),
      ),
    );
  }
}
