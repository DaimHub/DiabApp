import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';

class GlucoseTrendDataProvider with ChangeNotifier {
  // Cached data
  double? _weeklyAverage;
  double? _previousWeekAverage;
  List<Map<String, dynamic>> _dailyAverages = [];
  bool _isLoading = false;
  DateTime? _lastFetchTime;
  String? _error;

  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Getters
  double? get weeklyAverage => _weeklyAverage;
  double? get previousWeekAverage => _previousWeekAverage;
  List<Map<String, dynamic>> get dailyAverages => _dailyAverages;
  bool get isLoading => _isLoading;
  bool get hasData => _weeklyAverage != null || _dailyAverages.isNotEmpty;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Check if cached data is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  // Calculate percentage change
  String? get percentageChange {
    if (_weeklyAverage == null || _previousWeekAverage == null) {
      return null;
    }

    final change =
        ((_weeklyAverage! - _previousWeekAverage!) / _previousWeekAverage!) *
        100;
    final isPositive = change >= 0;
    final sign = isPositive ? '+' : '';

    return '$sign${change.toStringAsFixed(1)}%';
  }

  // Get percentage change color
  Color? getPercentageChangeColor(BuildContext context) {
    if (_weeklyAverage == null || _previousWeekAverage == null) {
      return null;
    }

    final change = _weeklyAverage! - _previousWeekAverage!;
    if (change > 0) {
      return Colors.red; // Higher glucose is generally not good
    } else if (change < 0) {
      return Colors.green; // Lower glucose is generally better
    } else {
      return Colors.grey; // No change
    }
  }

  /// Get glucose trend data with caching strategy
  /// Returns cached data immediately if available, then fetches fresh data in background
  Future<Map<String, dynamic>> getGlucoseTrendData({
    bool forceRefresh = false,
  }) async {
    // If we have cached data and not forcing refresh, return it immediately
    if (!forceRefresh && hasData && isCacheValid) {
      return _buildTrendDataMap();
    }

    // If we have cached data but it might be stale, return it first then fetch fresh data
    if (!forceRefresh && hasData) {
      // Return cached data immediately
      final cachedData = _buildTrendDataMap();

      // Fetch fresh data in background
      _fetchFreshDataInBackground();

      return cachedData;
    }

    // No cached data or force refresh - fetch fresh data and show loading
    return await _fetchFreshData(showLoading: true);
  }

  /// Build trend data map from current cached values
  Map<String, dynamic> _buildTrendDataMap() {
    return {
      'weeklyAverage': _weeklyAverage,
      'previousWeekAverage': _previousWeekAverage,
      'dailyAverages': _dailyAverages,
      'percentageChange': percentageChange,
    };
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
      final results = await Future.wait([
        FirestoreService.getWeeklyGlucoseAverage(),
        FirestoreService.getPreviousWeekGlucoseAverage(),
        FirestoreService.getDailyGlucoseAverages(),
      ]);

      // Update cache
      _weeklyAverage = results[0] as double?;
      _previousWeekAverage = results[1] as double?;
      _dailyAverages = List<Map<String, dynamic>>.from(results[2] as List);
      _lastFetchTime = DateTime.now();
      _error = null;

      if (showLoading) {
        _isLoading = false;
      }

      notifyListeners();
      return _buildTrendDataMap();
    } catch (e) {
      _error = 'Failed to fetch glucose trend data: $e';
      if (showLoading) {
        _isLoading = false;
      }
      notifyListeners();

      return _buildTrendDataMap();
    }
  }

  /// Fetch fresh data in background (without loading state)
  Future<void> _fetchFreshDataInBackground() async {
    try {
      final results = await Future.wait([
        FirestoreService.getWeeklyGlucoseAverage(),
        FirestoreService.getPreviousWeekGlucoseAverage(),
        FirestoreService.getDailyGlucoseAverages(),
      ]);

      final newWeeklyAverage = results[0] as double?;
      final newPreviousWeekAverage = results[1] as double?;
      final newDailyAverages = List<Map<String, dynamic>>.from(
        results[2] as List,
      );

      // Check if data has changed
      if (_hasDataChanged(
        newWeeklyAverage,
        newPreviousWeekAverage,
        newDailyAverages,
      )) {
        _weeklyAverage = newWeeklyAverage;
        _previousWeekAverage = newPreviousWeekAverage;
        _dailyAverages = newDailyAverages;
        _lastFetchTime = DateTime.now();
        _error = null;
        notifyListeners();
      } else {}
    } catch (e) {
      // Don't update error state for background fetches
    }
  }

  /// Check if the new data is different from cached data
  bool _hasDataChanged(
    double? newWeeklyAverage,
    double? newPreviousWeekAverage,
    List<Map<String, dynamic>> newDailyAverages,
  ) {
    // Compare weekly averages
    if (_weeklyAverage != newWeeklyAverage ||
        _previousWeekAverage != newPreviousWeekAverage) {
      return true;
    }

    // Compare daily averages length
    if (_dailyAverages.length != newDailyAverages.length) {
      return true;
    }

    // Compare daily averages content
    for (int i = 0; i < _dailyAverages.length; i++) {
      if (_dailyAverages[i]['average'] != newDailyAverages[i]['average']) {
        return true;
      }
    }

    return false;
  }

  /// Get formatted weekly average string
  String getWeeklyAverageString() {
    if (_weeklyAverage == null) return 'No data';
    return '${_weeklyAverage!.toInt()} mg/dL';
  }

  /// Check if we have chart data
  bool get hasChartData {
    return _dailyAverages.isNotEmpty &&
        _dailyAverages.any((day) => day['average'] != null);
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
    _weeklyAverage = null;
    _previousWeekAverage = null;
    _dailyAverages = [];
    _lastFetchTime = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Static method to invalidate cache globally (useful when glucose data is logged)
  static void invalidateCacheGlobally(BuildContext context) {
    final provider = Provider.of<GlucoseTrendDataProvider>(
      context,
      listen: false,
    );
    provider.invalidateCache();
  }

  /// Static method to refresh data globally (useful when glucose data is logged)
  static Future<void> refreshDataGlobally(BuildContext context) async {
    final provider = Provider.of<GlucoseTrendDataProvider>(
      context,
      listen: false,
    );

    // Force refresh to ensure we get the latest data immediately
    await provider.getGlucoseTrendData(forceRefresh: true);
  }

  /// Static method to invalidate and refresh data globally (immediate effect)
  static Future<void> invalidateAndRefreshGlobally(BuildContext context) async {
    final provider = Provider.of<GlucoseTrendDataProvider>(
      context,
      listen: false,
    );

    // First invalidate the cache
    provider.invalidateCache();

    // Then force refresh to get fresh data
    await provider.getGlucoseTrendData(forceRefresh: true);
  }
}
