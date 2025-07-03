import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mivi/data/models/movie_model.dart';

class FavoritesService {
  static const String _favoritesKey = 'favorite_movies';

  // Get all favorite movies
  Future<List<Movie>> getFavoriteMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson
          .map((json) => Movie.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error getting favorite movies: $e');
      return [];
    }
  }

  // Add movie to favorites
  Future<bool> addToFavorites(Movie movie) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      // Check if movie is already in favorites
      final movieIds = favoritesJson
          .map((json) => Movie.fromJson(jsonDecode(json)).id)
          .toList();

      if (movieIds.contains(movie.id)) {
        return false; // Already in favorites
      }

      // Add movie to favorites
      final movieWithFavorite = movie.copyWith(isFavorite: true);
      favoritesJson.add(jsonEncode(movieWithFavorite.toJson()));

      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error adding movie to favorites: $e');
      return false;
    }
  }

  // Remove movie from favorites
  Future<bool> removeFromFavorites(int movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      // Remove movie from favorites
      favoritesJson.removeWhere((json) {
        final movie = Movie.fromJson(jsonDecode(json));
        return movie.id == movieId;
      });

      await prefs.setStringList(_favoritesKey, favoritesJson);
      return true;
    } catch (e) {
      print('Error removing movie from favorites: $e');
      return false;
    }
  }

  // Check if movie is in favorites
  Future<bool> isFavorite(int movieId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final favoritesJson = prefs.getStringList(_favoritesKey) ?? [];

      return favoritesJson.any((json) {
        final movie = Movie.fromJson(jsonDecode(json));
        return movie.id == movieId;
      });
    } catch (e) {
      print('Error checking if movie is favorite: $e');
      return false;
    }
  }

  // Toggle favorite status
  Future<bool> toggleFavorite(Movie movie) async {
    try {
      final isCurrentlyFavorite = await isFavorite(movie.id);

      if (isCurrentlyFavorite) {
        return await removeFromFavorites(movie.id);
      } else {
        return await addToFavorites(movie);
      }
    } catch (e) {
      print('Error toggling favorite: $e');
      return false;
    }
  }

  // Clear all favorites
  Future<bool> clearFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
      return true;
    } catch (e) {
      print('Error clearing favorites: $e');
      return false;
    }
  }
}
