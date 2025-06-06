import 'firestore_service.dart';

class OverviewCacheService {
  static final OverviewCacheService _instance =
      OverviewCacheService._internal();
  factory OverviewCacheService() => _instance;
  OverviewCacheService._internal();

  // Cache storage
  Map<String, dynamic>? _cachedGlucoseData;
  Map<String, dynamic>? _cachedUserData;
  DateTime? _lastGlucoseFetchTime;
  DateTime? _lastUserDataFetchTime;
  bool _isFetchingGlucose = false;
  bool _isFetchingUserData = false;

  // Cache configuration
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  static const Duration _backgroundRefreshThreshold = Duration(minutes: 2);

  // Getters for glucose data
  Map<String, dynamic>? get cachedGlucoseData => _cachedGlucoseData;
  bool get hasGlucoseData => _cachedGlucoseData != null;
  bool get isGlucoseCacheValid =>
      _lastGlucoseFetchTime != null &&
      DateTime.now().difference(_lastGlucoseFetchTime!) < _cacheValidDuration;
  bool get shouldBackgroundRefreshGlucose =>
      _lastGlucoseFetchTime != null &&
      DateTime.now().difference(_lastGlucoseFetchTime!) >
          _backgroundRefreshThreshold;

  // Getters for user data
  Map<String, dynamic>? get cachedUserData => _cachedUserData;
  bool get hasUserData => _cachedUserData != null;
  bool get isUserDataCacheValid =>
      _lastUserDataFetchTime != null &&
      DateTime.now().difference(_lastUserDataFetchTime!) < _cacheValidDuration;
  bool get shouldBackgroundRefreshUserData =>
      _lastUserDataFetchTime != null &&
      DateTime.now().difference(_lastUserDataFetchTime!) >
          _backgroundRefreshThreshold;

  /// Get cached glucose data immediately if available (synchronous)
  Map<String, dynamic>? getCachedGlucoseDataSync() {
    return _cachedGlucoseData;
  }

  /// Get cached user data immediately if available (synchronous)
  Map<String, dynamic>? getCachedUserDataSync() {
    return _cachedUserData;
  }

  /// Get glucose data with caching strategy
  Future<Map<String, dynamic>> getGlucoseData({
    bool forceRefresh = false,
  }) async {
    // If we have valid cached data and not forcing refresh, return it
    if (!forceRefresh && hasGlucoseData && isGlucoseCacheValid) {
      // Check if we should fetch in background
      if (shouldBackgroundRefreshGlucose && !_isFetchingGlucose) {
        _fetchGlucoseDataInBackground();
      }
      return _cachedGlucoseData!;
    }

    // If we have cached data but it's stale, return it while fetching fresh data
    if (!forceRefresh &&
        hasGlucoseData &&
        !isGlucoseCacheValid &&
        !_isFetchingGlucose) {
      _fetchGlucoseDataInBackground();
      return _cachedGlucoseData!;
    }

    // No cached data or force refresh - fetch fresh data
    return await _fetchFreshGlucoseData();
  }

  /// Get user data with caching strategy
  Future<Map<String, dynamic>?> getUserData({bool forceRefresh = false}) async {
    // If we have valid cached data and not forcing refresh, return it
    if (!forceRefresh && hasUserData && isUserDataCacheValid) {
      // Check if we should fetch in background
      if (shouldBackgroundRefreshUserData && !_isFetchingUserData) {
        _fetchUserDataInBackground();
      }
      return _cachedUserData!;
    }

    // If we have cached data but it's stale, return it while fetching fresh data
    if (!forceRefresh &&
        hasUserData &&
        !isUserDataCacheValid &&
        !_isFetchingUserData) {
      _fetchUserDataInBackground();
      return _cachedUserData!;
    }

    // No cached data or force refresh - fetch fresh data
    return await _fetchFreshUserData();
  }

  /// Fetch fresh glucose data and update cache
  Future<Map<String, dynamic>> _fetchFreshGlucoseData() async {
    _isFetchingGlucose = true;
    try {
      final glucoseData = await _loadGlucoseDataFromFirestore();
      _updateGlucoseCache(glucoseData);
      return glucoseData;
    } finally {
      _isFetchingGlucose = false;
    }
  }

  /// Fetch fresh user data and update cache
  Future<Map<String, dynamic>?> _fetchFreshUserData() async {
    _isFetchingUserData = true;
    try {
      final userData = await FirestoreService.getUserData();
      _updateUserDataCache(userData);
      return userData;
    } finally {
      _isFetchingUserData = false;
    }
  }

  /// Fetch glucose data in background
  Future<void> _fetchGlucoseDataInBackground() async {
    _isFetchingGlucose = true;
    try {
      final newGlucoseData = await _loadGlucoseDataFromFirestore();

      // Check if data has changed
      if (_hasGlucoseDataChanged(newGlucoseData)) {
        _updateGlucoseCache(newGlucoseData);
        // Notify listeners that glucose data has changed
        _notifyGlucoseDataChanged?.call(newGlucoseData);
      }
    } catch (e) {
      print('Background glucose fetch failed: $e');
    } finally {
      _isFetchingGlucose = false;
    }
  }

  /// Fetch user data in background
  Future<void> _fetchUserDataInBackground() async {
    _isFetchingUserData = true;
    try {
      final newUserData = await FirestoreService.getUserData();

      // Check if data has changed
      if (_hasUserDataChanged(newUserData)) {
        _updateUserDataCache(newUserData);
        // Notify listeners that user data has changed
        _notifyUserDataChanged?.call(newUserData);
      }
    } catch (e) {
      print('Background user data fetch failed: $e');
    } finally {
      _isFetchingUserData = false;
    }
  }

  /// Load glucose data from Firestore
  Future<Map<String, dynamic>> _loadGlucoseDataFromFirestore() async {
    final latestGlucose = await FirestoreService.getLatestGlucoseMeasurement();
    final weeklyAverage = await FirestoreService.getWeeklyGlucoseAverage();
    final previousWeekAverage =
        await FirestoreService.getPreviousWeekGlucoseAverage();
    final dailyAverages = await FirestoreService.getDailyGlucoseAverages();

    return {
      'latestGlucose': latestGlucose,
      'weeklyAverage': weeklyAverage,
      'previousWeekAverage': previousWeekAverage,
      'dailyAverages': dailyAverages,
    };
  }

  /// Update glucose cache with new data
  void _updateGlucoseCache(Map<String, dynamic> glucoseData) {
    _cachedGlucoseData = Map.from(glucoseData);
    _lastGlucoseFetchTime = DateTime.now();
  }

  /// Update user data cache with new data
  void _updateUserDataCache(Map<String, dynamic>? userData) {
    _cachedUserData = userData != null ? Map.from(userData) : null;
    _lastUserDataFetchTime = DateTime.now();
  }

  /// Check if glucose data has changed
  bool _hasGlucoseDataChanged(Map<String, dynamic> newData) {
    if (_cachedGlucoseData == null) return true;

    // Compare latest glucose measurement
    final oldLatest = _cachedGlucoseData!['latestGlucose'];
    final newLatest = newData['latestGlucose'];

    if (oldLatest != null && newLatest != null) {
      if (oldLatest['id'] != newLatest['id'] ||
          oldLatest['measure'] != newLatest['measure']) {
        return true;
      }
    } else if (oldLatest != newLatest) {
      return true;
    }

    // Compare averages
    if (_cachedGlucoseData!['weeklyAverage'] != newData['weeklyAverage'] ||
        _cachedGlucoseData!['previousWeekAverage'] !=
            newData['previousWeekAverage']) {
      return true;
    }

    return false;
  }

  /// Check if user data has changed
  bool _hasUserDataChanged(Map<String, dynamic>? newData) {
    if (_cachedUserData == null && newData == null) return false;
    if (_cachedUserData == null || newData == null) return true;

    // Simple comparison of key fields
    final oldMedications = _cachedUserData!['medications'];
    final newMedications = newData['medications'];

    if (oldMedications != newMedications) return true;

    return false;
  }

  /// Callbacks for when data changes
  Function(Map<String, dynamic>)? _notifyGlucoseDataChanged;
  Function(Map<String, dynamic>?)? _notifyUserDataChanged;

  /// Set callbacks for data changes
  void setGlucoseDataChangeCallback(Function(Map<String, dynamic>) callback) {
    _notifyGlucoseDataChanged = callback;
  }

  void setUserDataChangeCallback(Function(Map<String, dynamic>?) callback) {
    _notifyUserDataChanged = callback;
  }

  /// Clear callbacks
  void clearCallbacks() {
    _notifyGlucoseDataChanged = null;
    _notifyUserDataChanged = null;
  }

  /// Static method to globally invalidate cache (useful when logging new glucose data)
  static void invalidateCacheGlobally() {
    _instance.invalidateCache();
  }

  /// Invalidate cache (force fresh fetch on next request)
  void invalidateCache() {
    _cachedGlucoseData = null;
    _cachedUserData = null;
    _lastGlucoseFetchTime = null;
    _lastUserDataFetchTime = null;
  }

  /// Clear all cache data
  void clearCache() {
    _cachedGlucoseData = null;
    _cachedUserData = null;
    _lastGlucoseFetchTime = null;
    _lastUserDataFetchTime = null;
    _notifyGlucoseDataChanged = null;
    _notifyUserDataChanged = null;
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasGlucoseData': hasGlucoseData,
      'isGlucoseCacheValid': isGlucoseCacheValid,
      'shouldBackgroundRefreshGlucose': shouldBackgroundRefreshGlucose,
      'hasUserData': hasUserData,
      'isUserDataCacheValid': isUserDataCacheValid,
      'shouldBackgroundRefreshUserData': shouldBackgroundRefreshUserData,
      'lastGlucoseFetchTime': _lastGlucoseFetchTime?.toString(),
      'lastUserDataFetchTime': _lastUserDataFetchTime?.toString(),
      'isFetchingGlucose': _isFetchingGlucose,
      'isFetchingUserData': _isFetchingUserData,
    };
  }
}
