import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ViewSession {
  final String sessionId;
  final int movieId;
  final String movieTitle;
  final DateTime startTime;
  final DateTime? endTime;
  final int viewDurationSeconds;
  final String viewType; // 'detail', 'trailer', 'full_movie'

  const ViewSession({
    required this.sessionId,
    required this.movieId,
    required this.movieTitle,
    required this.startTime,
    this.endTime,
    required this.viewDurationSeconds,
    required this.viewType,
  });

  ViewSession copyWith({
    String? sessionId,
    int? movieId,
    String? movieTitle,
    DateTime? startTime,
    DateTime? endTime,
    int? viewDurationSeconds,
    String? viewType,
  }) {
    return ViewSession(
      sessionId: sessionId ?? this.sessionId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      viewDurationSeconds: viewDurationSeconds ?? this.viewDurationSeconds,
      viewType: viewType ?? this.viewType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'sessionId': sessionId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'startTime': startTime.millisecondsSinceEpoch,
      'endTime': endTime?.millisecondsSinceEpoch,
      'viewDurationSeconds': viewDurationSeconds,
      'viewType': viewType,
    };
  }

  factory ViewSession.fromJson(Map<String, dynamic> json) {
    return ViewSession(
      sessionId: json['sessionId'] as String,
      movieId: json['movieId'] as int,
      movieTitle: json['movieTitle'] as String,
      startTime: DateTime.fromMillisecondsSinceEpoch(json['startTime'] as int),
      endTime: json['endTime'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(json['endTime'] as int)
          : null,
      viewDurationSeconds: json['viewDurationSeconds'] as int,
      viewType: json['viewType'] as String,
    );
  }
}

class MovieViewStats {
  final int movieId;
  final String movieTitle;
  final int totalViews;
  final int totalViewTimeSeconds;
  final DateTime firstViewDate;
  final DateTime lastViewDate;
  final Map<String, int> viewsByType; // detail, trailer, full_movie
  final List<ViewSession> recentSessions;

  const MovieViewStats({
    required this.movieId,
    required this.movieTitle,
    required this.totalViews,
    required this.totalViewTimeSeconds,
    required this.firstViewDate,
    required this.lastViewDate,
    required this.viewsByType,
    required this.recentSessions,
  });

  String get totalViewTimeFormatted {
    final hours = totalViewTimeSeconds ~/ 3600;
    final minutes = (totalViewTimeSeconds % 3600) ~/ 60;
    final seconds = totalViewTimeSeconds % 60;

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    } else if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }

  double get averageViewTimeSeconds {
    return totalViews > 0 ? totalViewTimeSeconds / totalViews : 0.0;
  }

  String get averageViewTimeFormatted {
    final avgSeconds = averageViewTimeSeconds.round();
    final minutes = avgSeconds ~/ 60;
    final seconds = avgSeconds % 60;
    
    if (minutes > 0) {
      return '${minutes}m ${seconds}s';
    } else {
      return '${seconds}s';
    }
  }
}

class ViewAnalyticsService {
  static const String _viewSessionsKey = 'view_sessions';
  // ignore: unused_field
  static const String _movieStatsKey = 'movie_stats';
  // ignore: unused_field
  static const String _dailyStatsKey = 'daily_stats';
  static const int _maxSessions = 1000; // Keep last 1000 sessions
  
  static ViewAnalyticsService? _instance;
  static ViewAnalyticsService get instance => _instance ??= ViewAnalyticsService._();
  ViewAnalyticsService._();

  final List<ViewSession> _viewSessions = [];
  final Map<int, int> _movieViewCounts = {};
  final Map<int, int> _movieViewTimes = {};
  final Map<String, ViewSession?> _activeSessions = {}; // sessionId -> session

  // Initialize service and load data
  Future<void> initialize() async {
    await _loadViewData();
  }

  // Load view data from SharedPreferences
  Future<void> _loadViewData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load view sessions
      final sessionsJson = prefs.getStringList(_viewSessionsKey) ?? [];
      _viewSessions.clear();
      _viewSessions.addAll(
        sessionsJson.map((json) => ViewSession.fromJson(jsonDecode(json))),
      );

      // Rebuild stats from sessions
      _rebuildStatsFromSessions();
    } catch (e) {
      print('Error loading view data: $e');
      _viewSessions.clear();
      _movieViewCounts.clear();
      _movieViewTimes.clear();
    }
  }

  // Save view data to SharedPreferences
  Future<void> _saveViewData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save sessions (keep only recent ones)
      final sessionsToSave = _viewSessions.take(_maxSessions).toList();
      final sessionsJson = sessionsToSave
          .map((session) => jsonEncode(session.toJson()))
          .toList();
      
      await prefs.setStringList(_viewSessionsKey, sessionsJson);
    } catch (e) {
      print('Error saving view data: $e');
    }
  }

  // Rebuild stats from sessions
  void _rebuildStatsFromSessions() {
    _movieViewCounts.clear();
    _movieViewTimes.clear();

    for (final session in _viewSessions) {
      _movieViewCounts[session.movieId] = 
          (_movieViewCounts[session.movieId] ?? 0) + 1;
      _movieViewTimes[session.movieId] = 
          (_movieViewTimes[session.movieId] ?? 0) + session.viewDurationSeconds;
    }
  }

  // Start a view session
  Future<String> startViewSession({
    required int movieId,
    required String movieTitle,
    required String viewType,
  }) async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = ViewSession(
      sessionId: sessionId,
      movieId: movieId,
      movieTitle: movieTitle,
      startTime: DateTime.now(),
      viewDurationSeconds: 0,
      viewType: viewType,
    );

    _activeSessions[sessionId] = session;
    return sessionId;
  }

  // End a view session
  Future<void> endViewSession(String sessionId) async {
    final activeSession = _activeSessions[sessionId];
    if (activeSession == null) return;

    final endTime = DateTime.now();
    final duration = endTime.difference(activeSession.startTime).inSeconds;
    
    final completedSession = activeSession.copyWith(
      endTime: endTime,
      viewDurationSeconds: duration,
    );

    // Add to sessions list
    _viewSessions.insert(0, completedSession);
    
    // Update stats
    _movieViewCounts[activeSession.movieId] = 
        (_movieViewCounts[activeSession.movieId] ?? 0) + 1;
    _movieViewTimes[activeSession.movieId] = 
        (_movieViewTimes[activeSession.movieId] ?? 0) + duration;

    // Remove from active sessions
    _activeSessions.remove(sessionId);

    // Save data
    await _saveViewData();
  }

  // Update view session duration (for active sessions)
  Future<void> updateViewSession({
    required String sessionId,
    int? additionalSeconds,
  }) async {
    final activeSession = _activeSessions[sessionId];
    if (activeSession == null) return;

    final currentDuration = DateTime.now().difference(activeSession.startTime).inSeconds;
    final updatedSession = activeSession.copyWith(
      viewDurationSeconds: currentDuration + (additionalSeconds ?? 0),
    );

    _activeSessions[sessionId] = updatedSession;
  }

  // Get movie view stats
  MovieViewStats? getMovieStats(int movieId) {
    final movieSessions = _viewSessions.where((s) => s.movieId == movieId).toList();
    if (movieSessions.isEmpty) return null;

    final viewsByType = <String, int>{};
    for (final session in movieSessions) {
      viewsByType[session.viewType] = (viewsByType[session.viewType] ?? 0) + 1;
    }

    return MovieViewStats(
      movieId: movieId,
      movieTitle: movieSessions.first.movieTitle,
      totalViews: _movieViewCounts[movieId] ?? 0,
      totalViewTimeSeconds: _movieViewTimes[movieId] ?? 0,
      firstViewDate: movieSessions.map((s) => s.startTime).reduce(
        (a, b) => a.isBefore(b) ? a : b,
      ),
      lastViewDate: movieSessions.map((s) => s.startTime).reduce(
        (a, b) => a.isAfter(b) ? a : b,
      ),
      viewsByType: viewsByType,
      recentSessions: movieSessions.take(10).toList(),
    );
  }

  // Get view count for a movie
  int getMovieViewCount(int movieId) {
    return _movieViewCounts[movieId] ?? 0;
  }

  // Get total view time for a movie
  int getMovieViewTimeSeconds(int movieId) {
    return _movieViewTimes[movieId] ?? 0;
  }

  // Get most viewed movies
  List<MapEntry<int, int>> getMostViewedMovies({int limit = 10}) {
    final sortedEntries = _movieViewCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(limit).toList();
  }

  // Get movies with most watch time
  List<MapEntry<int, int>> getMostWatchedMovies({int limit = 10}) {
    final sortedEntries = _movieViewTimes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sortedEntries.take(limit).toList();
  }

  // Get recent view sessions
  List<ViewSession> getRecentSessions({int limit = 20}) {
    return _viewSessions.take(limit).toList();
  }

  // Get viewing activity for a date range
  List<ViewSession> getViewingActivity({
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return _viewSessions.where((session) {
      if (startDate != null && session.startTime.isBefore(startDate)) {
        return false;
      }
      if (endDate != null && session.startTime.isAfter(endDate)) {
        return false;
      }
      return true;
    }).toList();
  }

  // Get daily stats
  Map<String, int> getDailyViewCounts({int days = 7}) {
    final result = <String, int>{};
    final now = DateTime.now();
    
    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      
      final viewsForDate = _viewSessions.where((session) {
        final sessionDate = session.startTime;
        return sessionDate.year == date.year &&
               sessionDate.month == date.month &&
               sessionDate.day == date.day;
      }).length;
      
      result[dateKey] = viewsForDate;
    }
    
    return result;
  }

  // Get total analytics
  Map<String, dynamic> getTotalAnalytics() {
    final totalViews = _viewSessions.length;
    final totalViewTime = _movieViewTimes.values.fold(0, (a, b) => a + b);
    final uniqueMoviesViewed = _movieViewCounts.keys.length;
    
    return {
      'totalViews': totalViews,
      'totalViewTimeSeconds': totalViewTime,
      'uniqueMoviesViewed': uniqueMoviesViewed,
      'averageViewTimeSeconds': totalViews > 0 ? totalViewTime / totalViews : 0,
      'viewsThisWeek': _getViewsInLastDays(7),
      'viewsThisMonth': _getViewsInLastDays(30),
    };
  }

  int _getViewsInLastDays(int days) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return _viewSessions.where((session) => session.startTime.isAfter(cutoff)).length;
  }

  // Clear all analytics data
  Future<void> clearAllData() async {
    _viewSessions.clear();
    _movieViewCounts.clear();
    _movieViewTimes.clear();
    _activeSessions.clear();
    await _saveViewData();
  }

  // Get analytics for view types
  Map<String, int> getViewTypeAnalytics() {
    final result = <String, int>{};
    for (final session in _viewSessions) {
      result[session.viewType] = (result[session.viewType] ?? 0) + 1;
    }
    return result;
  }

  // Check if movie has been viewed
  bool hasViewedMovie(int movieId) {
    return _movieViewCounts.containsKey(movieId) && _movieViewCounts[movieId]! > 0;
  }

  // Get viewing streak (consecutive days with views)
  int getCurrentViewingStreak() {
    if (_viewSessions.isEmpty) return 0;

    int streak = 0;
    final now = DateTime.now();
    
    for (int i = 0; i < 365; i++) { // Check up to a year
      final date = now.subtract(Duration(days: i));
      final hasViewsOnDate = _viewSessions.any((session) {
        final sessionDate = session.startTime;
        return sessionDate.year == date.year &&
               sessionDate.month == date.month &&
               sessionDate.day == date.day;
      });
      
      if (hasViewsOnDate) {
        streak++;
      } else {
        break;
      }
    }
    
    return streak;
  }
} 