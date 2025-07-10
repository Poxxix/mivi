import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryService {
  static const String _key = 'search_history';
  static const int _maxHistoryItems = 10;

  static SearchHistoryService? _instance;
  static SearchHistoryService get instance => _instance ??= SearchHistoryService._();
  SearchHistoryService._();

  List<String> _searchHistory = [];
  List<String> get searchHistory => List.unmodifiable(_searchHistory);

  // Initialize service and load search history
  Future<void> initialize() async {
    await _loadSearchHistory();
  }

  // Load search history from SharedPreferences
  Future<void> _loadSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final history = prefs.getStringList(_key) ?? [];
      _searchHistory = history;
    } catch (e) {
      _searchHistory = [];
    }
  }

  // Save search history to SharedPreferences
  Future<void> _saveSearchHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_key, _searchHistory);
    } catch (e) {
      // Handle save error silently
    }
  }

  // Add a search query to history
  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;
    
    final trimmedQuery = query.trim();
    
    // Remove if already exists to avoid duplicates
    _searchHistory.remove(trimmedQuery);
    
    // Add to the beginning of the list
    _searchHistory.insert(0, trimmedQuery);
    
    // Keep only the most recent searches
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.take(_maxHistoryItems).toList();
    }
    
    await _saveSearchHistory();
  }

  // Remove a specific search from history
  Future<void> removeSearch(String query) async {
    _searchHistory.remove(query);
    await _saveSearchHistory();
  }

  // Clear all search history
  Future<void> clearAll() async {
    _searchHistory.clear();
    await _saveSearchHistory();
  }

  // Get search suggestions based on input
  List<String> getSuggestions(String input) {
    if (input.trim().isEmpty) {
      return _searchHistory;
    }
    
    final lowercaseInput = input.toLowerCase();
    return _searchHistory
        .where((search) => search.toLowerCase().contains(lowercaseInput))
        .toList();
  }

  // Check if a query exists in history
  bool hasSearch(String query) {
    return _searchHistory.contains(query.trim());
  }

  // Get popular searches (for now, just return recent searches)
  List<String> getPopularSearches() {
    return _searchHistory.take(5).toList();
  }

  // Update search order (when user selects from suggestions)
  Future<void> updateSearchOrder(String query) async {
    await addSearch(query); // This will move it to the top
  }
} 