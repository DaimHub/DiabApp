import 'firestore_service.dart';

class EventsCacheService {
  static final EventsCacheService _instance = EventsCacheService._internal();
  factory EventsCacheService() => _instance;
  EventsCacheService._internal();

  // Cache storage
  List<Map<String, dynamic>>? _cachedEvents;
  DateTime? _lastFetchTime;
  bool _isFetching = false;

  // Cache configuration
  static const Duration _cacheValidDuration = Duration(minutes: 5);
  static const Duration _backgroundRefreshThreshold = Duration(minutes: 2);

  // Getters
  List<Map<String, dynamic>>? get cachedEvents => _cachedEvents;
  bool get hasCachedData => _cachedEvents != null;
  bool get isCacheValid =>
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  bool get shouldBackgroundRefresh =>
      _lastFetchTime != null &&
      DateTime.now().difference(_lastFetchTime!) > _backgroundRefreshThreshold;

  /// Get cached data immediately if available (synchronous)
  List<Map<String, dynamic>>? getCachedDataSync() {
    return _cachedEvents;
  }

  /// Get events with caching strategy
  /// Returns cached data immediately if available, and optionally fetches fresh data
  Future<List<Map<String, dynamic>>> getEvents({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
    bool forceRefresh = false,
  }) async {
    // If we have valid cached data and not forcing refresh, return it
    if (!forceRefresh && hasCachedData && isCacheValid) {
      // Check if we should fetch in background
      if (shouldBackgroundRefresh && !_isFetching) {
        _fetchInBackground(
          startDate: startDate,
          endDate: endDate,
          limit: limit,
        );
      }
      return _cachedEvents!;
    }

    // If we have cached data but it's stale, return it while fetching fresh data
    if (!forceRefresh && hasCachedData && !isCacheValid && !_isFetching) {
      _fetchInBackground(startDate: startDate, endDate: endDate, limit: limit);
      return _cachedEvents!;
    }

    // No cached data or force refresh - fetch fresh data
    return await _fetchFreshData(
      startDate: startDate,
      endDate: endDate,
      limit: limit,
    );
  }

  /// Fetch fresh data and update cache
  Future<List<Map<String, dynamic>>> _fetchFreshData({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
  }) async {
    _isFetching = true;
    try {
      final events = await FirestoreService.getEvents(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      _updateCache(events);
      return events;
    } finally {
      _isFetching = false;
    }
  }

  /// Fetch data in background and update cache if there are changes
  Future<void> _fetchInBackground({
    required DateTime startDate,
    required DateTime endDate,
    int limit = 100,
  }) async {
    _isFetching = true;
    try {
      final newEvents = await FirestoreService.getEvents(
        startDate: startDate,
        endDate: endDate,
        limit: limit,
      );

      // Check if data has changed
      if (_hasDataChanged(newEvents)) {
        _updateCache(newEvents);
        // Notify listeners that data has changed
        _notifyDataChanged?.call(newEvents);
      }
    } catch (e) {
      print('Background fetch failed: $e');
    } finally {
      _isFetching = false;
    }
  }

  /// Update the cache with new data
  void _updateCache(List<Map<String, dynamic>> events) {
    _cachedEvents = List.from(events);
    _lastFetchTime = DateTime.now();
  }

  /// Check if new data is different from cached data
  bool _hasDataChanged(List<Map<String, dynamic>> newEvents) {
    if (_cachedEvents == null) return true;
    if (_cachedEvents!.length != newEvents.length) return true;

    // Simple comparison - you could make this more sophisticated
    for (int i = 0; i < newEvents.length; i++) {
      final newEvent = newEvents[i];
      final cachedEvent = _cachedEvents![i];

      if (newEvent['id'] != cachedEvent['id'] ||
          newEvent['date'] != cachedEvent['date'] ||
          newEvent['type'] != cachedEvent['type']) {
        return true;
      }
    }
    return false;
  }

  /// Callback for when data changes
  Function(List<Map<String, dynamic>>)? _notifyDataChanged;

  /// Set callback for data changes
  void setDataChangeCallback(Function(List<Map<String, dynamic>>) callback) {
    _notifyDataChanged = callback;
  }

  /// Clear callback
  void clearDataChangeCallback() {
    _notifyDataChanged = null;
  }

  /// Invalidate cache (force fresh fetch on next request)
  void invalidateCache() {
    _cachedEvents = null;
    _lastFetchTime = null;
  }

  /// Clear all cache data
  void clearCache() {
    _cachedEvents = null;
    _lastFetchTime = null;
    _notifyDataChanged = null;
  }

  /// Get cache info for debugging
  Map<String, dynamic> getCacheInfo() {
    return {
      'hasCachedData': hasCachedData,
      'isCacheValid': isCacheValid,
      'shouldBackgroundRefresh': shouldBackgroundRefresh,
      'cachedEventsCount': _cachedEvents?.length ?? 0,
      'lastFetchTime': _lastFetchTime?.toString(),
      'isFetching': _isFetching,
    };
  }

  /// Static method to invalidate cache globally (useful when logging new data)
  static void invalidateCacheGlobally() {
    _instance.invalidateCache();
  }

  /// Static method to add a new event to cache immediately (optimistic update)
  static void addEventToCache(Map<String, dynamic> newEvent) {
    final instance = _instance;
    if (instance._cachedEvents != null) {
      // Add new event to the beginning of cached events (most recent first)
      instance._cachedEvents!.insert(0, newEvent);
      // Update last fetch time to keep cache valid
      instance._lastFetchTime = DateTime.now();

      // Notify listeners about the optimistic update
      instance._notifyDataChanged?.call(instance._cachedEvents!);
    }
  }
}
