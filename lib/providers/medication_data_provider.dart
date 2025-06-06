import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class MedicationDataProvider with ChangeNotifier {
  // Cached data
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _todaysMedications = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;
  String? _error;

  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Getters
  Map<String, dynamic>? get userData => _userData;
  List<Map<String, dynamic>> get todaysMedications => _todaysMedications;
  bool get isLoading => _isLoading;
  bool get hasData => _userData != null;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Check if cached data is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  /// Get medication data with caching strategy
  /// Returns cached data immediately if available, then fetches fresh data in background
  Future<List<Map<String, dynamic>>> getTodaysMedicationData({
    bool forceRefresh = false,
  }) async {
    // If we have cached data and not forcing refresh, return it immediately
    if (!forceRefresh && hasData && isCacheValid) {
      return _todaysMedications;
    }

    // If we have cached data but it might be stale, return it first then fetch fresh data
    if (!forceRefresh && hasData) {
      // Return cached data immediately
      final cachedData = _todaysMedications;

      // Fetch fresh data in background
      _fetchFreshDataInBackground();

      return cachedData;
    }

    // No cached data or force refresh - fetch fresh data and show loading
    return await _fetchFreshData(showLoading: true);
  }

  /// Fetch fresh data and update cache (with loading state)
  Future<List<Map<String, dynamic>>> _fetchFreshData({
    bool showLoading = false,
  }) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final userData = await FirestoreService.getUserData();

      // Update cache
      _userData = userData;
      _todaysMedications = _getTodaysMedications(userData);
      _lastFetchTime = DateTime.now();
      _error = null;

      if (showLoading) {
        _isLoading = false;
      }

      notifyListeners();
      return _todaysMedications;
    } catch (e) {
      _error = 'Failed to fetch medication data: $e';
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();

      return [];
    }
  }

  /// Fetch fresh data in background (without loading state)
  Future<void> _fetchFreshDataInBackground() async {
    try {
      final userData = await FirestoreService.getUserData();

      // Check if data has changed
      if (_hasDataChanged(userData)) {
        _userData = userData;
        _todaysMedications = _getTodaysMedications(userData);
        _lastFetchTime = DateTime.now();
        _error = null;
        notifyListeners();
      } else {}
    } catch (e) {
      // Don't update error state for background fetches
    }
  }

  /// Check if the new data is different from cached data
  bool _hasDataChanged(Map<String, dynamic>? newData) {
    if (_userData == null && newData == null) {
      return false;
    }
    if (_userData == null || newData == null) {
      return true;
    }

    final oldMedications = _userData!['medications'];
    final newMedications = newData['medications'];

    // Simple comparison of medications list
    final hasChanged = oldMedications != newMedications;

    return hasChanged;
  }

  /// Get today's medications from user data (same logic as overview screen)
  List<Map<String, dynamic>> _getTodaysMedications(
    Map<String, dynamic>? userData,
  ) {
    if (userData == null || userData['medications'] == null) {
      return [];
    }

    final medications = List<Map<String, dynamic>>.from(
      userData['medications'],
    );

    // First filter: only enabled medications
    final enabledMedications = medications
        .where((med) => med['enabled'] == true)
        .toList();

    if (enabledMedications.isEmpty) {
      return [];
    }

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Get today's day name
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    final todayDayName =
        weekdays[now.weekday -
            1]; // DateTime.weekday returns 1-7 (Monday-Sunday)

    List<Map<String, dynamic>> todaysMedications = [];

    for (final medication in enabledMedications) {
      final medicationName = medication['name'];
      final timeData = medication['time'];
      final medicationTime = TimeOfDay(
        hour: timeData['hour'],
        minute: timeData['minute'],
      );

      // Check if medication is scheduled for today
      final days = medication['days'] as List<dynamic>?;
      bool isScheduledToday = false;

      if (days == null || days.isEmpty) {
        // Old format - assume daily
        isScheduledToday = true;
      } else {
        // New format - check if today is included
        isScheduledToday = days.contains(todayDayName);
      }

      // Only add medications scheduled for today and that are enabled
      if (isScheduledToday) {
        // Calculate today's reminder time
        DateTime todayReminder = DateTime(
          now.year,
          now.month,
          now.day,
          medicationTime.hour,
          medicationTime.minute,
        );

        // Add to today's medications list
        todaysMedications.add({
          'name': medication['name'],
          'time': medicationTime,
          'reminderDateTime': todayReminder,
          'isPastDue': todayReminder.isBefore(now),
        });
      }
    }

    // Sort by time
    todaysMedications.sort(
      (a, b) => (a['reminderDateTime'] as DateTime).compareTo(
        b['reminderDateTime'] as DateTime,
      ),
    );

    return todaysMedications;
  }

  /// Force refresh data (useful when user adds/updates medications)
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
    _userData = null;
    _todaysMedications = [];
    _lastFetchTime = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Static method to invalidate cache globally (useful when medications are updated)
  static void invalidateCacheGlobally(BuildContext context) {
    final provider = Provider.of<MedicationDataProvider>(
      context,
      listen: false,
    );
    provider.invalidateCache();
  }

  /// Static method to refresh data globally (useful when medications are updated)
  static Future<void> refreshDataGlobally(BuildContext context) async {
    final provider = Provider.of<MedicationDataProvider>(
      context,
      listen: false,
    );

    // Force refresh to ensure we get the latest data immediately
    await provider.getTodaysMedicationData(forceRefresh: true);
  }

  /// Static method to invalidate and refresh data globally (immediate effect)
  static Future<void> invalidateAndRefreshGlobally(BuildContext context) async {
    final provider = Provider.of<MedicationDataProvider>(
      context,
      listen: false,
    );

    // First invalidate the cache
    provider.invalidateCache();

    // Then force refresh to get fresh data
    await provider.getTodaysMedicationData(forceRefresh: true);
  }
}
