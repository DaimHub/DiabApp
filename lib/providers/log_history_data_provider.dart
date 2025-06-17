import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../services/firestore_service.dart';
import '../models/log_entry.dart'; // Import LogEntry model

class LogHistoryDataProvider with ChangeNotifier {
  // Cached data
  Map<DateTime, List<LogEntry>> _events = {};
  List<LogEntry> _allEvents = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;
  String? _error;

  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Getters
  Map<DateTime, List<LogEntry>> get events => _events;
  List<LogEntry> get allEvents => _allEvents;
  bool get isLoading => _isLoading;
  bool get hasData => _allEvents.isNotEmpty;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Check if cached data is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  /// Get log history data with caching strategy
  /// Returns cached data immediately if available, then fetches fresh data in background
  Future<Map<String, dynamic>> getLogHistoryData({
    bool forceRefresh = false,
  }) async {
    // If we have cached data and not forcing refresh, return it immediately
    if (!forceRefresh && hasData && isCacheValid) {
      return _buildLogHistoryDataMap();
    }

    // If we have cached data but it might be stale, return it first then fetch fresh data
    if (!forceRefresh && hasData) {
      // Return cached data immediately
      final cachedData = _buildLogHistoryDataMap();

      // Fetch fresh data in background
      _fetchFreshDataInBackground();

      return cachedData;
    }

    // No cached data or force refresh - fetch fresh data and show loading
    return await _fetchFreshData(showLoading: true);
  }

  /// Build log history data map from current cached values
  Map<String, dynamic> _buildLogHistoryDataMap() {
    return {'events': _events, 'allEvents': _allEvents};
  }

  /// Fetch fresh data and update cache (with loading state)
  Future<Map<String, dynamic>> _fetchFreshData({
    bool showLoading = false,
  }) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      // Load events from the past 30 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final firestoreEvents = await FirestoreService.getEvents(
        startDate: startDate,
        endDate: endDate,
        limit: 100,
      );

      // Process the events data
      final processedData = _processEventsData(firestoreEvents);

      // Update cache
      _events = processedData['events'];
      _allEvents = processedData['allEvents'];
      _lastFetchTime = DateTime.now();
      _error = null;

      if (showLoading) {
        _isLoading = false;
      }

      notifyListeners();
      return _buildLogHistoryDataMap();
    } catch (e) {
      _error = 'Failed to fetch log history data: $e';
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();

      return _buildLogHistoryDataMap();
    }
  }

  /// Fetch fresh data in background (without loading state)
  Future<void> _fetchFreshDataInBackground() async {
    try {
      // Load events from the past 30 days
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(days: 30));

      final firestoreEvents = await FirestoreService.getEvents(
        startDate: startDate,
        endDate: endDate,
        limit: 100,
      );

      // Process the events data
      final processedData = _processEventsData(firestoreEvents);
      final newEvents = processedData['events'];
      final newAllEvents = processedData['allEvents'];

      // Check if data has changed
      if (_hasDataChanged(newEvents, newAllEvents)) {
        _events = newEvents;
        _allEvents = newAllEvents;
        _lastFetchTime = DateTime.now();
        _error = null;
        notifyListeners();
      } else {}
    } catch (e) {
      // Don't update error state for background fetches
    }
  }

  /// Process events data (moved from log history screen)
  Map<String, dynamic> _processEventsData(
    List<Map<String, dynamic>> firestoreEvents,
  ) {
    // Convert Firestore events to LogEntry objects and group by date
    final Map<DateTime, List<LogEntry>> eventsByDate = {};
    final List<LogEntry> allEvents = [];

    for (final eventData in firestoreEvents) {
      final logEntry = _convertFirestoreEventToLogEntry(eventData);
      if (logEntry != null) {
        allEvents.add(logEntry);

        final eventDate = eventData['date'] as DateTime;
        final dateKey = DateTime(
          eventDate.year,
          eventDate.month,
          eventDate.day,
        );

        if (!eventsByDate.containsKey(dateKey)) {
          eventsByDate[dateKey] = [];
        }
        eventsByDate[dateKey]!.add(logEntry);
      }
    }

    return {'events': eventsByDate, 'allEvents': allEvents};
  }

  /// Convert Firestore event to LogEntry (moved from log history screen)
  LogEntry? _convertFirestoreEventToLogEntry(Map<String, dynamic> eventData) {
    final type = eventData['type'] as String?;
    final date = eventData['date'] as DateTime?;
    final id = eventData['id'] as String?;

    if (type == null || date == null || id == null) return null;

    String title;
    String value;
    IconData icon;

    switch (type) {
      case 'glucose':
        title = 'Glucose';
        final measure = eventData['measure'];
        value = '${measure?.toStringAsFixed(0) ?? '0'} mg/dL';
        icon = FontAwesomeIcons.droplet;
        break;
      case 'meal':
        title = 'Meal';
        final name = eventData['name'] ?? 'Meal';
        final carbs = eventData['carbs'];
        if (carbs != null) {
          value = '$name (${carbs.toStringAsFixed(0)}g carbs)';
        } else {
          value = name;
        }
        icon = FontAwesomeIcons.utensils;
        break;
      case 'activity':
        title = 'Activity';
        final name = eventData['name'] ?? 'Activity';
        final duration = eventData['duration'];
        if (duration != null) {
          value = '$name (${duration}min)';
        } else {
          value = name;
        }
        icon = FontAwesomeIcons.personRunning;
        break;
      case 'medication':
        title = 'Medication';
        final name = eventData['name'] ?? 'Medication';
        final dose = eventData['dose'];
        if (dose != null) {
          value = '$name (${dose.toStringAsFixed(1)} units)';
        } else {
          value = name;
        }
        icon = FontAwesomeIcons.pills;
        break;
      case 'other':
        title = eventData['name'] as String? ?? 'Other';
        final note = eventData['note'] as String?;
        if (note != null && note.isNotEmpty) {
          // Show first 30 characters of the note as the value
          value = note.length > 30 ? '${note.substring(0, 30)}...' : note;
        } else {
          value = 'No additional notes';
        }
        icon = FontAwesomeIcons.question;
        break;
      default:
        return null;
    }

    // Format date and time for display in card
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final eventDate = DateTime(date.year, date.month, date.day);

    String dateTimeString;
    if (eventDate == today) {
      // Today - show only time
      dateTimeString =
          '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (eventDate == yesterday) {
      // Yesterday - show "Yesterday HH:mm"
      dateTimeString =
          'Yesterday ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else {
      // Other days - show "MMM d, HH:mm"
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
      dateTimeString =
          '${months[date.month - 1]} ${date.day}, ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }

    // Get note if available
    final note = eventData['note'] as String?;

    return LogEntry(title, value, dateTimeString, icon, id, date, note: note);
  }

  /// Check if the new data is different from cached data
  bool _hasDataChanged(
    Map<DateTime, List<LogEntry>> newEvents,
    List<LogEntry> newAllEvents,
  ) {
    // Compare total count first (quick check)
    if (_allEvents.length != newAllEvents.length) {
      return true;
    }

    // Compare event IDs (deeper check)
    final oldIds = _allEvents.map((e) => e.id).toSet();
    final newIds = newAllEvents.map((e) => e.id).toSet();

    if (oldIds.length != newIds.length) {
      return true;
    }

    // Check if any IDs are different
    for (final id in newIds) {
      if (!oldIds.contains(id)) {
        return true;
      }
    }

    return false;
  }

  /// Get events for a specific day
  List<LogEntry> getEventsForDay(DateTime day) {
    final dateKey = DateTime(day.year, day.month, day.day);
    return _events[dateKey] ?? [];
  }

  /// Get filtered events based on selected filters
  List<LogEntry> getFilteredEvents(Set<String> selectedFilters) {
    if (selectedFilters.contains('All')) {
      return _allEvents;
    }

    return _allEvents.where((event) {
      return selectedFilters.contains(event.title);
    }).toList();
  }

  /// Force refresh data (useful when user adds/updates/deletes events)
  Future<void> refreshData() async {
    await _fetchFreshData(showLoading: true);
  }

  /// Invalidate cache (force fresh fetch on next request)
  void invalidateCache() {
    _lastFetchTime = null;
    notifyListeners();
  }

  /// Clear all cached data
  void clearCache() {
    _events = {};
    _allEvents = [];
    _lastFetchTime = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Static method to invalidate cache globally (useful when events are added/updated/deleted)
  static void invalidateCacheGlobally(BuildContext context) {
    final provider = Provider.of<LogHistoryDataProvider>(
      context,
      listen: false,
    );
    provider.invalidateCache();
  }

  /// Static method to refresh data globally (useful when events are added/updated/deleted)
  static Future<void> refreshDataGlobally(BuildContext context) async {
    final provider = Provider.of<LogHistoryDataProvider>(
      context,
      listen: false,
    );

    // Force refresh to ensure we get the latest data immediately
    await provider.getLogHistoryData(forceRefresh: true);
  }

  /// Static method to invalidate and refresh data globally (immediate effect)
  static Future<void> invalidateAndRefreshGlobally(BuildContext context) async {
    final provider = Provider.of<LogHistoryDataProvider>(
      context,
      listen: false,
    );

    // First invalidate the cache
    provider.invalidateCache();

    // Then force refresh to get fresh data
    await provider.getLogHistoryData(forceRefresh: true);
  }
}
