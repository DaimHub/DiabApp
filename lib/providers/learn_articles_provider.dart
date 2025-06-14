import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import '../models/article.dart';
import 'package:provider/provider.dart';

class LearnArticlesProvider with ChangeNotifier {
  // Cached data
  List<Article>? _articles;
  bool _isLoading = false;
  DateTime? _lastFetchTime;
  String? _error;

  // Cache duration (30 minutes for articles)
  static const Duration _cacheValidDuration = Duration(minutes: 30);

  // Getters
  List<Article>? get articles => _articles;
  bool get isLoading => _isLoading;
  bool get hasData => _articles != null && _articles!.isNotEmpty;
  String? get error => _error;
  DateTime? get lastFetchTime => _lastFetchTime;

  // Check if cached data is still valid
  bool get isCacheValid {
    if (_lastFetchTime == null) return false;
    return DateTime.now().difference(_lastFetchTime!) < _cacheValidDuration;
  }

  /// Get articles with caching strategy
  /// Returns cached data immediately if available, then fetches fresh data in background
  Future<List<Article>?> getArticles({bool forceRefresh = false}) async {
    // If we have cached data and not forcing refresh, return it immediately
    if (!forceRefresh && hasData && isCacheValid) {
      return _articles;
    }

    // If we have cached data but it might be stale, return it first then fetch fresh data
    if (!forceRefresh && hasData) {
      // Return cached data immediately
      final cachedData = _articles;

      // Fetch fresh data in background
      _fetchFreshDataInBackground();

      return cachedData;
    }

    // No cached data or force refresh - fetch fresh data and show loading
    return await _fetchFreshData(showLoading: true);
  }

  /// Fetch fresh data and update cache (with loading state)
  Future<List<Article>?> _fetchFreshData({bool showLoading = false}) async {
    if (showLoading) {
      _isLoading = true;
      _error = null;
      notifyListeners();
    }

    try {
      final articlesData = await FirestoreService.getLearnArticles();

      // Convert to Article objects
      final articles = articlesData
          .map((data) => Article.fromFirestore(data['id']!, data))
          .toList();

      // Update cache
      _articles = articles;
      _lastFetchTime = DateTime.now();
      _error = null;

      if (showLoading) {
        _isLoading = false;
      }

      notifyListeners();
      return articles;
    } catch (e) {
      print('❌ Provider error: $e');
      _error = 'Failed to fetch articles: $e';
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
      final articlesData = await FirestoreService.getLearnArticles();

      // Convert to Article objects
      final articles = articlesData
          .map((data) => Article.fromFirestore(data['id']!, data))
          .toList();

      // Check if data has changed
      if (_hasDataChanged(articles)) {
        _articles = articles;
        _lastFetchTime = DateTime.now();
        _error = null;
        notifyListeners();
      }
    } catch (e) {
      print('❌ Background fetch error: $e');
      // Don't update error state for background fetches
    }
  }

  /// Check if the new data is different from cached data
  bool _hasDataChanged(List<Article>? newArticles) {
    if (_articles == null && newArticles == null) {
      return false;
    }
    if (_articles == null || newArticles == null) {
      return true;
    }

    if (_articles!.length != newArticles.length) {
      return true;
    }

    // Check if any article has changed
    for (int i = 0; i < _articles!.length; i++) {
      final oldArticle = _articles![i];
      final newArticle = newArticles[i];

      if (oldArticle.id != newArticle.id ||
          oldArticle.title != newArticle.title ||
          oldArticle.updatedAt != newArticle.updatedAt) {
        return true;
      }
    }

    return false;
  }

  /// Force refresh data
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
    _articles = null;
    _lastFetchTime = null;
    _error = null;
    _isLoading = false;
    notifyListeners();
  }

  /// Get article by ID
  Article? getArticleById(String id) {
    if (_articles == null) return null;

    try {
      return _articles!.firstWhere((article) => article.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get articles by difficulty
  List<Article> getArticlesByDifficulty(String difficulty) {
    if (_articles == null) return [];

    return _articles!
        .where((article) => article.difficulty == difficulty)
        .toList();
  }

  /// Get articles by tag
  List<Article> getArticlesByTag(String tag) {
    if (_articles == null) return [];

    return _articles!.where((article) => article.tags.contains(tag)).toList();
  }

  /// Static method to invalidate cache globally
  static void invalidateCacheGlobally(BuildContext context) {
    final provider = Provider.of<LearnArticlesProvider>(context, listen: false);
    provider.invalidateCache();
  }

  /// Static method to refresh data globally
  static Future<void> refreshDataGlobally(BuildContext context) async {
    final provider = Provider.of<LearnArticlesProvider>(context, listen: false);
    await provider.getArticles(forceRefresh: true);
  }

  /// Static method to invalidate and refresh data globally (immediate effect)
  static Future<void> invalidateAndRefreshGlobally(BuildContext context) async {
    final provider = Provider.of<LearnArticlesProvider>(context, listen: false);
    provider.invalidateCache();
    await provider.refreshData();
  }
}
