import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mivi/data/models/movie_model.dart';

class ViewHistoryService {
  static const String _historyKey = 'view_history_movies';
  static const String _historyTimestampKey = 'view_history_timestamps';
  static const int _maxHistorySize = 50; // Keep last 50 viewed movies
  
  static ViewHistoryService? _instance;
  static ViewHistoryService get instance => _instance ??= ViewHistoryService._();
  ViewHistoryService._();

  final List<Movie> _viewHistory = [];
  final Map<int, DateTime> _viewTimestamps = {};
  bool _isInitialized = false;

  // Stream controller for history changes
  final _historyController = StreamController<List<Movie>>.broadcast();
  Stream<List<Movie>> get historyStream => _historyController.stream;

  // Getters
  List<Movie> get viewHistory => List.unmodifiable(_viewHistory);
  int get historyCount => _viewHistory.length;
  bool get isEmpty => _viewHistory.isEmpty;
  bool get isNotEmpty => _viewHistory.isNotEmpty;

  /// Initialize the service and load saved history
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load history movies
      final historyJson = prefs.getStringList(_historyKey) ?? [];
      _viewHistory.clear();
      
      for (String movieJson in historyJson) {
        try {
          final movieMap = jsonDecode(movieJson) as Map<String, dynamic>;
          final movie = Movie.fromJson(movieMap);
          _viewHistory.add(movie);
        } catch (e) {
          print('Error parsing history movie: $e');
        }
      }

      // Load timestamps
      final timestampJson = prefs.getString(_historyTimestampKey);
      if (timestampJson != null) {
        try {
          final timestampMap = jsonDecode(timestampJson) as Map<String, dynamic>;
          _viewTimestamps.clear();
          timestampMap.forEach((key, value) {
            _viewTimestamps[int.parse(key)] = DateTime.fromMillisecondsSinceEpoch(value);
          });
        } catch (e) {
          print('Error parsing history timestamps: $e');
        }
      }

      _isInitialized = true;
      _historyController.add(_viewHistory);
    } catch (e) {
      print('Error initializing ViewHistoryService: $e');
      _isInitialized = true; // Mark as initialized even if error occurred
    }
  }

  /// Add movie to view history (or update timestamp if already exists)
  Future<void> addToHistory(Movie movie) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Remove if already exists to avoid duplicates
      _viewHistory.removeWhere((m) => m.id == movie.id);
      
      // Add to beginning of list (most recent first)
      _viewHistory.insert(0, movie);
      _viewTimestamps[movie.id] = DateTime.now();
      
      // Limit history size
      if (_viewHistory.length > _maxHistorySize) {
        final removedMovie = _viewHistory.removeLast();
        _viewTimestamps.remove(removedMovie.id);
      }
      
      await _saveToPreferences();
      _historyController.add(_viewHistory);
    } catch (e) {
      print('Error adding to view history: $e');
    }
  }

  /// Get last viewed timestamp for a movie
  DateTime? getLastViewedTime(Movie movie) {
    return _viewTimestamps[movie.id];
  }

  /// Check if movie was viewed recently (within last 24 hours)
  bool wasViewedRecently(Movie movie, {Duration duration = const Duration(hours: 24)}) {
    final lastViewed = _viewTimestamps[movie.id];
    if (lastViewed == null) return false;
    
    return DateTime.now().difference(lastViewed) <= duration;
  }

  /// Get history filtered by date range
  List<Movie> getHistoryByDateRange(DateTime start, DateTime end) {
    return _viewHistory.where((movie) {
      final viewTime = _viewTimestamps[movie.id];
      if (viewTime == null) return false;
      return viewTime.isAfter(start) && viewTime.isBefore(end);
    }).toList();
  }

  /// Get today's viewed movies
  List<Movie> getTodayHistory() {
    final today = DateTime.now();
    final startOfDay = DateTime(today.year, today.month, today.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));
    
    return getHistoryByDateRange(startOfDay, endOfDay);
  }

  /// Get this week's viewed movies
  List<Movie> getWeekHistory() {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDay = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    
    return getHistoryByDateRange(startOfWeekDay, now);
  }

  /// Get movies viewed in last N days
  List<Movie> getRecentHistory({int days = 7}) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: days));
    
    return _viewHistory.where((movie) {
      final viewTime = _viewTimestamps[movie.id];
      if (viewTime == null) return false;
      return viewTime.isAfter(cutoffDate);
    }).toList();
  }

  /// Remove movie from history
  Future<bool> removeFromHistory(Movie movie) async {
    if (!_isInitialized) await initialize();
    
    try {
      final initialLength = _viewHistory.length;
      _viewHistory.removeWhere((m) => m.id == movie.id);
      
      if (_viewHistory.length < initialLength) {
        _viewTimestamps.remove(movie.id);
        await _saveToPreferences();
        _historyController.add(_viewHistory);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from history: $e');
      return false;
    }
  }

  /// Clear entire history
  Future<bool> clearHistory() async {
    try {
      _viewHistory.clear();
      _viewTimestamps.clear();
      await _saveToPreferences();
      _historyController.add(_viewHistory);
      return true;
    } catch (e) {
      print('Error clearing history: $e');
      return false;
    }
  }

  /// Clear old history (older than specified days)
  Future<void> clearOldHistory({int days = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: days));
      
      _viewHistory.removeWhere((movie) {
        final viewTime = _viewTimestamps[movie.id];
        if (viewTime == null) return true; // Remove if no timestamp
        
        if (viewTime.isBefore(cutoffDate)) {
          _viewTimestamps.remove(movie.id);
          return true; // Remove old movie
        }
        return false; // Keep recent movie
      });
      
      await _saveToPreferences();
      _historyController.add(_viewHistory);
    } catch (e) {
      print('Error clearing old history: $e');
    }
  }

  /// Get formatted time ago string
  String getTimeAgoString(Movie movie) {
    final viewTime = _viewTimestamps[movie.id];
    if (viewTime == null) return 'Unknown';
    
    final difference = DateTime.now().difference(viewTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xem';
    }
  }

  /// Save history to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save movies
      final movieJsonList = _viewHistory.map((movie) {
        return jsonEncode(movie.toJson());
      }).toList();
      await prefs.setStringList(_historyKey, movieJsonList);

      // Save timestamps
      final timestampMap = <String, int>{};
      _viewTimestamps.forEach((movieId, dateTime) {
        timestampMap[movieId.toString()] = dateTime.millisecondsSinceEpoch;
      });
      await prefs.setString(_historyTimestampKey, jsonEncode(timestampMap));
    } catch (e) {
      print('Error saving history to preferences: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _historyController.close();
  }
} 