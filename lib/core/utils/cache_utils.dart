import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mivi/data/models/movie_model.dart';

/// Cache utility for storing and retrieving data to improve performance
class CacheUtils {
  static const Duration _defaultCacheDuration = Duration(hours: 1);
  static const String _cachePrefix = 'mivi_cache_';
  static const String _timestampSuffix = '_timestamp';

  /// Cache movie list with expiration
  static Future<void> cacheMovies(String key, List<Movie> movies, {Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final movieJsonList = movies.map((movie) => movie.toJson()).toList();
      final jsonString = jsonEncode(movieJsonList);
      
      // Store data and timestamp
      await prefs.setString('$_cachePrefix$key', jsonString);
      await prefs.setInt('$_cachePrefix$key$_timestampSuffix', 
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching movies: $e');
    }
  }

  /// Get cached movies if not expired
  static Future<List<Movie>?> getCachedMovies(String key, {Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_cachePrefix$key');
      final timestamp = prefs.getInt('$_cachePrefix$key$_timestampSuffix');
      
      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final cacheDuration = duration ?? _defaultCacheDuration;
      
      if (DateTime.now().difference(cacheTime) > cacheDuration) {
        // Remove expired cache
        await removeCachedData(key);
        return null;
      }

      // Parse cached data
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Movie.fromJson(json)).toList();
    } catch (e) {
      print('Error retrieving cached movies: $e');
      return null;
    }
  }

  /// Cache single movie
  static Future<void> cacheMovie(String movieId, Movie movie, {Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(movie.toJson());
      
      await prefs.setString('$_cachePrefix$movieId', jsonString);
      await prefs.setInt('$_cachePrefix$movieId$_timestampSuffix', 
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching movie: $e');
    }
  }

  /// Get cached single movie
  static Future<Movie?> getCachedMovie(String movieId, {Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('$_cachePrefix$movieId');
      final timestamp = prefs.getInt('$_cachePrefix$movieId$_timestampSuffix');
      
      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final cacheDuration = duration ?? _defaultCacheDuration;
      
      if (DateTime.now().difference(cacheTime) > cacheDuration) {
        await removeCachedData(movieId);
        return null;
      }

      return Movie.fromJson(jsonDecode(jsonString));
    } catch (e) {
      print('Error retrieving cached movie: $e');
      return null;
    }
  }

  /// Cache genres
  static Future<void> cacheGenres(List<Genre> genres, {Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final genreJsonList = genres.map((genre) => genre.toJson()).toList();
      final jsonString = jsonEncode(genreJsonList);
      
      await prefs.setString('${_cachePrefix}genres', jsonString);
      await prefs.setInt('${_cachePrefix}genres$_timestampSuffix', 
          DateTime.now().millisecondsSinceEpoch);
    } catch (e) {
      print('Error caching genres: $e');
    }
  }

  /// Get cached genres
  static Future<List<Genre>?> getCachedGenres({Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('${_cachePrefix}genres');
      final timestamp = prefs.getInt('${_cachePrefix}genres$_timestampSuffix');
      
      if (jsonString == null || timestamp == null) {
        return null;
      }

      // Check if cache is expired
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final cacheDuration = duration ?? Duration(hours: 24); // Genres change less frequently
      
      if (DateTime.now().difference(cacheTime) > cacheDuration) {
        await removeCachedData('genres');
        return null;
      }

      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Genre.fromJson(json)).toList();
    } catch (e) {
      print('Error retrieving cached genres: $e');
      return null;
    }
  }

  /// Remove specific cached data
  static Future<void> removeCachedData(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_cachePrefix$key');
      await prefs.remove('$_cachePrefix$key$_timestampSuffix');
    } catch (e) {
      print('Error removing cached data: $e');
    }
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      for (final key in keys) {
        await prefs.remove(key);
      }
    } catch (e) {
      print('Error clearing cache: $e');
    }
  }

  /// Get cache size information
  static Future<Map<String, int>> getCacheInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => key.startsWith(_cachePrefix));
      int totalSize = 0;
      int itemCount = 0;

      for (final key in keys) {
        if (!key.endsWith(_timestampSuffix)) {
          final value = prefs.getString(key);
          if (value != null) {
            totalSize += value.length;
            itemCount++;
          }
        }
      }

      return {
        'totalSize': totalSize,
        'itemCount': itemCount,
      };
    } catch (e) {
      return {'totalSize': 0, 'itemCount': 0};
    }
  }

  /// Check if data is cached and not expired
  static Future<bool> isCached(String key, {Duration? duration}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt('$_cachePrefix$key$_timestampSuffix');
      
      if (timestamp == null) return false;

      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final cacheDuration = duration ?? _defaultCacheDuration;
      
      return DateTime.now().difference(cacheTime) <= cacheDuration;
    } catch (e) {
      return false;
    }
  }
} 