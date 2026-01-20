import 'package:hive_flutter/hive_flutter.dart';

/// Service for managing search history
/// Uses Hive for persistent storage
class SearchHistoryService {
  static const String _boxName = 'search_history';
  static const String _historyKey = 'queries';
  static const int _maxHistorySize = 50;

  Box<dynamic>? _box;

  /// Initialize the search history service
  Future<void> init() async {
    _box = await Hive.openBox(_boxName);
  }

  /// Add a search query to history
  /// Removes duplicates and maintains max size
  Future<void> addQuery(String query) async {
    if (query.trim().isEmpty) return;

    final normalizedQuery = query.trim();
    final history = await getHistory();

    // Remove if already exists (to move to top)
    history.remove(normalizedQuery);

    // Add to beginning
    history.insert(0, normalizedQuery);

    // Limit size
    if (history.length > _maxHistorySize) {
      history.removeRange(_maxHistorySize, history.length);
    }

    // Save
    await _box?.put(_historyKey, history);
  }

  /// Get all search history (most recent first)
  Future<List<String>> getHistory({int? limit}) async {
    final List<dynamic> stored = _box?.get(_historyKey, defaultValue: []) ?? [];
    final history = stored.cast<String>().toList();

    if (limit != null && history.length > limit) {
      return history.sublist(0, limit);
    }

    return history;
  }

  /// Remove a specific query from history
  Future<void> removeQuery(String query) async {
    final history = await getHistory();
    history.remove(query);
    await _box?.put(_historyKey, history);
  }

  /// Clear all search history
  Future<void> clearHistory() async {
    await _box?.put(_historyKey, []);
  }

  /// Get recent searches (last 10)
  Future<List<String>> getRecentSearches() async {
    return await getHistory(limit: 10);
  }

  /// Check if a query exists in history
  Future<bool> hasQuery(String query) async {
    final history = await getHistory();
    return history.contains(query.trim());
  }

  /// Get search suggestions based on history
  Future<List<String>> getSuggestions(String query) async {
    if (query.trim().isEmpty) {
      return await getRecentSearches();
    }

    final history = await getHistory();
    final lowerQuery = query.toLowerCase();

    // Filter history that matches the query
    return history
        .where((h) => h.toLowerCase().contains(lowerQuery))
        .take(10)
        .toList();
  }

  /// Close the box
  Future<void> close() async {
    await _box?.close();
  }
}
