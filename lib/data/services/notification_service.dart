import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'web_notification_service.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // For web platform, use Firebase FCM
    if (kIsWeb) {
      await WebNotificationService().initialize();
      _isInitialized = true;
      return;
    }

    // For mobile platforms, use flutter_local_notifications
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    // macOS specific settings
    const DarwinInitializationSettings initializationSettingsMacOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
      macOS: initializationSettingsMacOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _isInitialized = true;
  }

  void _onNotificationTap(NotificationResponse notificationResponse) {
    if (kDebugMode) {
      print('Notification tapped: ${notificationResponse.payload}');
    }
    // TODO: Handle notification tap (navigate to movie detail)
  }

  // Helper method to create NotificationDetails for all platforms
  NotificationDetails _createNotificationDetails({
    required String channelId,
    required String channelName,
    required String channelDescription,
    required Importance importance,
    required Priority priority,
    String? ticker,
    bool playSound = true,
  }) {
    final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: importance,
      priority: priority,
      ticker: ticker,
    );

    final DarwinNotificationDetails darwinDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: playSound,
    );

    return NotificationDetails(
      android: androidDetails,
      iOS: darwinDetails,
      macOS: darwinDetails,
    );
  }

  Future<bool> requestPermissions() async {
    if (!_isInitialized) await initialize();

    // For web platform
    if (kIsWeb) {
      // Web permissions are handled by WebNotificationService
      return true;
    }

    // For Android
    if (defaultTargetPlatform == TargetPlatform.android) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
      return result ?? false;
    }

    // For iOS and macOS
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    if (defaultTargetPlatform == TargetPlatform.macOS) {
      final bool? result = await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
        alert: true,
        badge: true,
        sound: true,
      );
      return result ?? false;
    }

    return false;
  }

  // Enhanced trending movie notification
  Future<void> showNewMovieNotification(Movie movie) async {
    if (!_isInitialized) await initialize();

    // For web platform
    if (kIsWeb) {
      await WebNotificationService().showLocalWebNotification(
        title: '🔥 Trending Now!',
        body: '${movie.title} • ${movie.voteAverage.toStringAsFixed(1)}/10 • ${movie.formattedDuration}',
        icon: '/icons/Icon-192.png',
      );
      return;
    }

    // For mobile platforms
    final NotificationDetails platformChannelSpecifics = _createNotificationDetails(
      channelId: 'movie_channel',
      channelName: 'Movie Notifications',
      channelDescription: 'Notifications for new trending movies',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'New Movie Alert',
    );

    await _flutterLocalNotificationsPlugin.show(
      movie.id.hashCode,
      '🔥 Trending Now!',
      '${movie.title} • ${movie.voteAverage.toStringAsFixed(1)}/10 • ${movie.formattedDuration}',
      platformChannelSpecifics,
      payload: movie.id.toString(),
    );
  }

  // New release notification
  Future<void> showNewReleaseNotification(Movie movie) async {
    if (!_isInitialized) await initialize();

    final NotificationDetails platformChannelSpecifics = _createNotificationDetails(
      channelId: 'new_release_channel',
      channelName: 'New Releases',
      channelDescription: 'Notifications for new movie releases',
      importance: Importance.high,
      priority: Priority.high,
      ticker: 'New Release Alert',
    );

    await _flutterLocalNotificationsPlugin.show(
      movie.id.hashCode + 1000,
      '🎬 New in Theaters!',
      '${movie.title} • ${movie.genresAsString} • ${movie.formattedDuration}',
      platformChannelSpecifics,
      payload: movie.id.toString(),
    );
  }

  // Personalized recommendation notification
  Future<void> showPersonalizedRecommendation(Movie movie, String reason) async {
    if (!_isInitialized) await initialize();

    final NotificationDetails platformChannelSpecifics = _createNotificationDetails(
      channelId: 'recommendation_channel',
      channelName: 'Personalized Recommendations',
      channelDescription: 'Personalized movie recommendations',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Movie Recommendation',
      playSound: false,
    );

    await _flutterLocalNotificationsPlugin.show(
      movie.id.hashCode + 2000,
      '💡 Perfect for You!',
      '${movie.title} • $reason • Rating: ${movie.voteAverage.toStringAsFixed(1)}/10',
      platformChannelSpecifics,
      payload: movie.id.toString(),
    );
  }

  // Weekly digest notification
  Future<void> showWeeklyDigest(int trendingCount, int newReleases, int genresExplored) async {
    if (!_isInitialized) await initialize();

    final NotificationDetails platformChannelSpecifics = _createNotificationDetails(
      channelId: 'weekly_digest_channel',
      channelName: 'Weekly Digest',
      channelDescription: 'Weekly movie activity summary',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
      ticker: 'Weekly Movie Digest',
      playSound: false,
    );

    await _flutterLocalNotificationsPlugin.show(
      999999, // Unique ID for weekly digest
      '📺 Your Movie Week',
      '🔥 $trendingCount trending • 🎬 $newReleases new releases • 🎭 $genresExplored genres explored',
      platformChannelSpecifics,
      payload: 'weekly_digest',
    );
  }

  // Enhanced trending movie checking with smart logic
  Future<void> checkAndNotifyNewMovies(List<Movie> currentTrendingMovies) async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotifiedMovies = prefs.getStringList('last_notified_movies') ?? [];
    final lastNotificationTime = prefs.getInt('last_notification_time') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Only notify once every 10 seconds (for testing)
    if (currentTime - lastNotificationTime < 10 * 1000) {
      return;
    }

    // Find new high-quality movies that weren't notified before
    final newMovies = currentTrendingMovies.where((movie) =>
        !lastNotifiedMovies.contains(movie.id.toString()) &&
        movie.voteAverage >= 4.0 && // Lower threshold for testing
        movie.releaseYear != 'N/A').toList();

    if (newMovies.isNotEmpty) {
      // Notify for the top 2 new trending movies
      final moviesToNotify = newMovies.take(2).toList();
      
      for (int i = 0; i < moviesToNotify.length; i++) {
        await Future.delayed(Duration(seconds: i * 3)); // Stagger notifications
        await showNewMovieNotification(moviesToNotify[i]);
      }

      // Update last notified movies and time
      await prefs.setStringList(
        'last_notified_movies',
        currentTrendingMovies.take(10).map((m) => m.id.toString()).toList(),
      );
      await prefs.setInt('last_notification_time', currentTime);
    }
  }

  // Check for new releases (now playing movies)
  Future<void> checkAndNotifyNewReleases(List<Movie> nowPlayingMovies) async {
    final prefs = await SharedPreferences.getInstance();
    final lastNotifiedReleases = prefs.getStringList('last_notified_releases') ?? [];

    final newReleases = nowPlayingMovies.where((movie) =>
        !lastNotifiedReleases.contains(movie.id.toString()) &&
        movie.voteAverage >= 3.0 && // Lower threshold for testing
        _isRecentRelease(movie.releaseDate)).toList();

    if (newReleases.isNotEmpty) {
      final releaseToNotify = newReleases.first;
      await showNewReleaseNotification(releaseToNotify);

      // Update last notified releases
      await prefs.setStringList(
        'last_notified_releases',
        nowPlayingMovies.take(20).map((m) => m.id.toString()).toList(),
      );
    }
  }

  // Generate personalized recommendations based on favorites
  Future<void> checkPersonalizedRecommendations(List<Movie> movies, List<Movie> favorites) async {
    if (favorites.isEmpty) return;

    final prefs = await SharedPreferences.getInstance();
    final lastRecommendationTime = prefs.getInt('last_recommendation_time') ?? 0;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Only recommend once every 15 seconds (for testing)
    if (currentTime - lastRecommendationTime < 15 * 1000) {
      return;
    }

    // Analyze favorite genres
    final favoriteGenres = <Genre>[];
    for (final movie in favorites) {
      favoriteGenres.addAll(movie.genres);
    }

    // Find most common genre
    final genreMap = <int, int>{};
    for (final genre in favoriteGenres) {
      genreMap[genre.id] = (genreMap[genre.id] ?? 0) + 1;
    }

    if (genreMap.isNotEmpty) {
      final mostPopularGenreId = genreMap.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;

      final recommendation = movies.where((movie) =>
          movie.genres.any((g) => g.id == mostPopularGenreId) &&
          movie.voteAverage >= 4.0 && // Lower threshold for testing
          !favorites.any((fav) => fav.id == movie.id)).firstOrNull;

      if (recommendation != null) {
        final genreName = recommendation.genres
            .firstWhere((g) => g.id == mostPopularGenreId)
            .name;
        await showPersonalizedRecommendation(
          recommendation,
          'Based on your love for $genreName movies',
        );

        await prefs.setInt('last_recommendation_time', currentTime);
      }
    }
  }

  // Check if release date is within last 30 days
  bool _isRecentRelease(String releaseDate) {
    try {
      final release = DateTime.parse(releaseDate);
      final now = DateTime.now();
      final difference = now.difference(release).inDays;
      return difference >= 0 && difference <= 30;
    } catch (e) {
      return false;
    }
  }

  // Settings methods
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  Future<bool> arePersonalizedNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('personalized_notifications_enabled') ?? true;
  }

  Future<void> setPersonalizedNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('personalized_notifications_enabled', enabled);
  }

  Future<void> cancelAllNotifications() async {
    await _flutterLocalNotificationsPlugin.cancelAll();
  }

  // Schedule weekly digest (call this from main app initialization)
  Future<void> scheduleWeeklyDigest() async {
    // This would typically use a background task or scheduled notifications
    // For demo purposes, we'll just store the schedule preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('weekly_digest_enabled', true);
  }
} 