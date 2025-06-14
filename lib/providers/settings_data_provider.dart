import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firestore_service.dart';

class SettingsDataProvider with ChangeNotifier {
  // Cached data
  Map<String, dynamic>? _userData;
  bool _isLoading = false;
  DateTime? _lastFetchTime;
  String? _error;

  // Cache duration (5 minutes)
  static const Duration _cacheValidDuration = Duration(minutes: 5);

  // Getters
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;
  bool get hasData => _userData != null;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Check if cached data is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  // Convenience getters for specific settings
  bool get notificationsEnabled => _userData?['notificationsEnabled'] ?? false;
  bool get bloodSugarCheckEnabled =>
      _userData?['bloodSugarCheckNotifications'] ?? false;
  bool get medicationRemindersEnabled {
    // First check if medication reminders are enabled in settings
    final settingEnabled = _userData?['medicationReminders'] ?? false;
    if (!settingEnabled) return false;

    // Then check if there are actually any enabled medications
    final medications = _userData?['medications'] as List<dynamic>?;
    if (medications == null || medications.isEmpty) return false;

    // Check if any medication is enabled
    final hasEnabledMedications = medications.any(
      (med) => med['enabled'] == true,
    );
    return hasEnabledMedications;
  }

  String get userDiabetesType => _userData?['diabetesType'] ?? 'Type 1';
  String get firstName => _userData?['firstName'] ?? '';
  String get lastName => _userData?['lastName'] ?? '';

  /// Get user settings data with caching strategy
  /// Returns cached data immediately if available, then fetches fresh data in background
  Future<Map<String, dynamic>?> getUserSettingsData({
    bool forceRefresh = false,
  }) async {
    // If we have cached data and not forcing refresh, return it immediately
    if (!forceRefresh && hasData && isCacheValid) {
      return _userData;
    }

    // If we have cached data but it might be stale, return it first then fetch fresh data
    if (!forceRefresh && hasData) {
      // Return cached data immediately
      final cachedData = _userData;

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
      final userData = await FirestoreService.getUserData();

      // Update cache
      _userData = userData;
      _lastFetchTime = DateTime.now();
      _error = null;

      if (showLoading) {
        _isLoading = false;
      }

      notifyListeners();
      return userData;
    } catch (e) {
      _error = 'Failed to fetch settings data: $e';
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
      final userData = await FirestoreService.getUserData();

      // Check if data has changed
      if (_hasDataChanged(userData)) {
        _userData = userData;
        _lastFetchTime = DateTime.now();
        _error = null;
        notifyListeners();
      }
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

    // Compare key settings fields
    final oldNotifications = _userData!['notificationsEnabled'] ?? false;
    final newNotifications = newData['notificationsEnabled'] ?? false;
    final oldBloodSugar = _userData!['bloodSugarCheckNotifications'] ?? false;
    final newBloodSugar = newData['bloodSugarCheckNotifications'] ?? false;
    final oldMedications = _userData!['medicationReminders'] ?? false;
    final newMedications = newData['medicationReminders'] ?? false;
    final oldDiabetesType = _userData!['diabetesType'] ?? 'Type 1';
    final newDiabetesType = newData['diabetesType'] ?? 'Type 1';
    final oldFirstName = _userData!['firstName'] ?? '';
    final newFirstName = newData['firstName'] ?? '';
    final oldLastName = _userData!['lastName'] ?? '';
    final newLastName = newData['lastName'] ?? '';

    // Also compare medication data since it affects medicationRemindersEnabled
    final oldMedicationData = _userData!['medications'];
    final newMedicationData = newData['medications'];

    return oldNotifications != newNotifications ||
        oldBloodSugar != newBloodSugar ||
        oldMedications != newMedications ||
        oldDiabetesType != newDiabetesType ||
        oldFirstName != newFirstName ||
        oldLastName != newLastName ||
        oldMedicationData != newMedicationData;
  }

  /// Update notification settings
  Future<void> updateNotificationSettings({
    bool? notificationsEnabled,
    bool? bloodSugarCheckNotifications,
    bool? medicationReminders,
  }) async {
    try {
      await FirestoreService.updateNotificationSettings(
        notificationsEnabled: notificationsEnabled,
        bloodSugarCheckNotifications: bloodSugarCheckNotifications,
        medicationReminders: medicationReminders,
      );

      // Update local cache
      if (_userData != null) {
        if (notificationsEnabled != null) {
          _userData!['notificationsEnabled'] = notificationsEnabled;
        }
        if (bloodSugarCheckNotifications != null) {
          _userData!['bloodSugarCheckNotifications'] =
              bloodSugarCheckNotifications;
        }
        if (medicationReminders != null) {
          _userData!['medicationReminders'] = medicationReminders;
        }
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to update notification settings: $e';
      notifyListeners();
      rethrow;
    }
  }

  /// Force refresh data (useful when user updates settings)
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
    _lastFetchTime = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get user display name
  String getUserDisplayName() {
    if (firstName.isNotEmpty && lastName.isNotEmpty) {
      return '$firstName $lastName';
    }
    return FirebaseAuth.instance.currentUser?.displayName ?? 'User';
  }

  /// Get user email
  String getUserEmail() {
    return FirebaseAuth.instance.currentUser?.email ?? 'No Email';
  }

  /// Static method to invalidate cache globally (useful when settings are updated)
  static void invalidateCacheGlobally(BuildContext context) {
    final provider = Provider.of<SettingsDataProvider>(context, listen: false);
    provider.invalidateCache();
  }

  /// Static method to refresh data globally (useful when settings are updated)
  static Future<void> refreshDataGlobally(BuildContext context) async {
    final provider = Provider.of<SettingsDataProvider>(context, listen: false);
    await provider.getUserSettingsData(forceRefresh: true);
  }

  /// Static method to invalidate and refresh data globally (immediate effect)
  static Future<void> invalidateAndRefreshGlobally(BuildContext context) async {
    final provider = Provider.of<SettingsDataProvider>(context, listen: false);
    provider.invalidateCache();
    await provider.getUserSettingsData(forceRefresh: true);
  }
}
