import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mivi/data/models/movie_model.dart';

class WatchlistService {
  static const String _watchlistKey = 'watchlist_movies';
  static const String _watchlistTimestampKey = 'watchlist_timestamps';
  
  static WatchlistService? _instance;
  static WatchlistService get instance => _instance ??= WatchlistService._();
  WatchlistService._();

  final List<Movie> _watchlist = [];
  final Map<int, DateTime> _addTimestamps = {};
  bool _isInitialized = false;

  // Stream controller for watchlist changes
  final _watchlistController = StreamController<List<Movie>>.broadcast();
  Stream<List<Movie>> get watchlistStream => _watchlistController.stream;

  // Getters
  List<Movie> get watchlist => List.unmodifiable(_watchlist);
  int get watchlistCount => _watchlist.length;
  bool get isEmpty => _watchlist.isEmpty;
  bool get isNotEmpty => _watchlist.isNotEmpty;

  /// Initialize the service and load saved watchlist
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load watchlist movies
      final watchlistJson = prefs.getStringList(_watchlistKey) ?? [];
      _watchlist.clear();
      
      for (String movieJson in watchlistJson) {
        try {
          final movieMap = jsonDecode(movieJson) as Map<String, dynamic>;
          final movie = Movie.fromJson(movieMap);
          _watchlist.add(movie);
        } catch (e) {
          print('Error parsing watchlist movie: $e');
        }
      }

      // Load timestamps
      final timestampJson = prefs.getString(_watchlistTimestampKey);
      if (timestampJson != null) {
        try {
          final timestampMap = jsonDecode(timestampJson) as Map<String, dynamic>;
          _addTimestamps.clear();
          timestampMap.forEach((key, value) {
            _addTimestamps[int.parse(key)] = DateTime.fromMillisecondsSinceEpoch(value);
          });
        } catch (e) {
          print('Error parsing watchlist timestamps: $e');
        }
      }

      _isInitialized = true;
      _watchlistController.add(_watchlist);
    } catch (e) {
      print('Error initializing WatchlistService: $e');
      _isInitialized = true; // Mark as initialized even if error occurred
    }
  }

  /// Check if a movie is in watchlist
  bool isInWatchlist(Movie movie) {
    return _watchlist.any((m) => m.id == movie.id);
  }

  /// Add movie to watchlist
  Future<bool> addToWatchlist(Movie movie) async {
    if (!_isInitialized) await initialize();
    
    try {
      // Check if already in watchlist
      if (isInWatchlist(movie)) {
        return false; // Already exists
      }

      _watchlist.add(movie);
      _addTimestamps[movie.id] = DateTime.now();
      
      await _saveToPreferences();
      _watchlistController.add(_watchlist);
      
      return true;
    } catch (e) {
      print('Error adding to watchlist: $e');
      return false;
    }
  }

  /// Remove movie from watchlist
  Future<bool> removeFromWatchlist(Movie movie) async {
    if (!_isInitialized) await initialize();
    
    try {
      final initialLength = _watchlist.length;
      _watchlist.removeWhere((m) => m.id == movie.id);
      
      if (_watchlist.length < initialLength) {
        _addTimestamps.remove(movie.id);
        await _saveToPreferences();
        _watchlistController.add(_watchlist);
        return true;
      }
      return false;
    } catch (e) {
      print('Error removing from watchlist: $e');
      return false;
    }
  }

  /// Toggle movie in watchlist
  Future<bool> toggleWatchlist(Movie movie) async {
    if (isInWatchlist(movie)) {
      return await removeFromWatchlist(movie);
    } else {
      return await addToWatchlist(movie);
    }
  }

  /// Get watchlist sorted by date added (newest first)
  List<Movie> getWatchlistByDate() {
    final sortedList = List<Movie>.from(_watchlist);
    sortedList.sort((a, b) {
      final timeA = _addTimestamps[a.id] ?? DateTime.now();
      final timeB = _addTimestamps[b.id] ?? DateTime.now();
      return timeB.compareTo(timeA); // Newest first
    });
    return sortedList;
  }

  /// Get watchlist sorted by movie title
  List<Movie> getWatchlistByTitle() {
    final sortedList = List<Movie>.from(_watchlist);
    sortedList.sort((a, b) => a.title.compareTo(b.title));
    return sortedList;
  }

  /// Get when movie was added to watchlist
  DateTime? getAddedDate(Movie movie) {
    return _addTimestamps[movie.id];
  }

  /// Clear entire watchlist
  Future<bool> clearWatchlist() async {
    try {
      _watchlist.clear();
      _addTimestamps.clear();
      await _saveToPreferences();
      _watchlistController.add(_watchlist);
      return true;
    } catch (e) {
      print('Error clearing watchlist: $e');
      return false;
    }
  }

  /// Save watchlist to SharedPreferences
  Future<void> _saveToPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save movies
      final movieJsonList = _watchlist.map((movie) {
        return jsonEncode(movie.toJson());
      }).toList();
      await prefs.setStringList(_watchlistKey, movieJsonList);

      // Save timestamps
      final timestampMap = <String, int>{};
      _addTimestamps.forEach((movieId, dateTime) {
        timestampMap[movieId.toString()] = dateTime.millisecondsSinceEpoch;
      });
      await prefs.setString(_watchlistTimestampKey, jsonEncode(timestampMap));
    } catch (e) {
      print('Error saving watchlist to preferences: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _watchlistController.close();
  }
} 