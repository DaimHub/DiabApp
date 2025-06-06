import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'package:provider/provider.dart';

class GlucoseDataProvider with ChangeNotifier {
  // Cached data
  Map<String, dynamic>? _latestGlucose;
  bool _isLoading = false;
  DateTime? _lastFetchTime;
  String? _error;

  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Getters
  Map<String, dynamic>? get latestGlucose => _latestGlucose;
  bool get isLoading => _isLoading;
  bool get hasData => _latestGlucose != null;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Check if cached data is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  /// Get latest glucose data with caching strategy
  /// Returns cached data immediately if available, then fetches fresh data in background
  Future<Map<String, dynamic>?> getLatestGlucoseData({
    bool forceRefresh = false,
  }) async {
    // If we have cached data and not forcing refresh, return it immediately
    if (!forceRefresh && hasData && isCacheValid) {
      return _latestGlucose;
    }

    // If we have cached data but it might be stale, return it first then fetch fresh data
    if (!forceRefresh && hasData) {
      // Return cached data immediately
      final cachedData = _latestGlucose;

      // Fetch fresh data in background
      _fetchFreshDataInBackground();

      return cachedData;
    }

    // No cached data or force refresh - fetch fresh data and show loading
    return await _fetchFreshData(showLoading: true);
  }

  /// Fetch fresh data and update cache (with loading state)
  Future<Map<String, dynamic>?> _fetchFreshData({
    bool showLoading = false,
  }) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final latestGlucose =
          await FirestoreService.getLatestGlucoseMeasurement();

      // Update cache
      _latestGlucose = latestGlucose;
      _lastFetchTime = DateTime.now();
      _error = null;

      if (showLoading) {
        _isLoading = false;
      }

      notifyListeners();
      return latestGlucose;
    } catch (e) {
      _error = 'Failed to fetch glucose data: $e';
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();

      return null;
    }
  }

  /// Fetch fresh data in background (without loading state)
  Future<void> _fetchFreshDataInBackground() async {
    try {
      final latestGlucose =
          await FirestoreService.getLatestGlucoseMeasurement();

      // Check if data has changed
      if (_hasDataChanged(latestGlucose)) {
        _latestGlucose = latestGlucose;
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
    if (_latestGlucose == null && newData == null) {
      return false;
    }
    if (_latestGlucose == null || newData == null) {
      return true;
    }

    final oldId = _latestGlucose!['id'];
    final newId = newData['id'];
    final oldMeasure = _latestGlucose!['measure'];
    final newMeasure = newData['measure'];
    final oldDate = _latestGlucose!['date'];
    final newDate = newData['date'];

    final hasChanged =
        oldId != newId || oldMeasure != newMeasure || oldDate != newDate;

    return hasChanged;
  }

  /// Force refresh data (useful when user adds new glucose reading)
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
    _latestGlucose = null;
    _lastFetchTime = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get formatted time since last glucose reading
  String getTimeSinceLastReading() {
    if (_latestGlucose == null) return 'No data';

    final date = _latestGlucose!['date'] as DateTime?;
    if (date == null) return 'No date';

    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.isNegative) {
      return 'Just now';
    }

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return 'Last updated ${difference.inMinutes} min ago';
    } else if (difference.inHours < 24) {
      return 'Last updated ${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return 'Last updated ${difference.inDays}d ago';
    } else {
      return 'Last updated ${(difference.inDays / 7).floor()}w ago';
    }
  }

  /// Get glucose value as formatted string
  String getGlucoseValueString() {
    if (_latestGlucose == null) return 'No data';

    final measure = _latestGlucose!['measure'];
    if (measure == null) return 'No data';

    return '${(measure as num).toInt()} mg/dL';
  }

  /// Static method to invalidate cache globally (useful when new glucose data is logged)
  static void invalidateCacheGlobally(BuildContext context) {
    final provider = Provider.of<GlucoseDataProvider>(context, listen: false);
    provider.invalidateCache();
  }

  /// Static method to refresh data globally (useful when new glucose data is logged)
  static Future<void> refreshDataGlobally(BuildContext context) async {
    final provider = Provider.of<GlucoseDataProvider>(context, listen: false);

    // Force refresh to ensure we get the latest data immediately
    await provider.getLatestGlucoseData(forceRefresh: true);
  }

  /// Static method to invalidate and refresh data globally (immediate effect)
  static Future<void> invalidateAndRefreshGlobally(BuildContext context) async {
    final provider = Provider.of<GlucoseDataProvider>(context, listen: false);

    // First invalidate the cache
    provider.invalidateCache();

    // Then force refresh to get fresh data
    await provider.getLatestGlucoseData(forceRefresh: true);
  }
}
