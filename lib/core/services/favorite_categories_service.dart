import 'package:shared_preferences/shared_preferences.dart';
import 'package:mivi/data/models/favorite_category.dart';
import 'package:mivi/data/models/movie_model.dart';

class FavoriteCategoriesService {
  static FavoriteCategoriesService? _instance;
  static FavoriteCategoriesService get instance => _instance ??= FavoriteCategoriesService._();
  FavoriteCategoriesService._();

  // Storage keys for each category
  static const String _wantToWatchKey = 'want_to_watch_movies';
  static const String _watchedKey = 'watched_movies';
  static const String _lovedKey = 'loved_movies';

  // In-memory storage for quick access
  final Map<FavoriteCategory, List<int>> _categorizedMovies = {
    FavoriteCategory.wantToWatch: [],
    FavoriteCategory.watched: [],
    FavoriteCategory.loved: [],
  };

  // Initialize service and load data
  Future<void> initialize() async {
    await _loadCategorizedMovies();
  }

  // Load categorized movies from SharedPreferences
  Future<void> _loadCategorizedMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _categorizedMovies[FavoriteCategory.wantToWatch] = 
          prefs.getStringList(_wantToWatchKey)?.map((id) => int.parse(id)).toList() ?? [];
      
      _categorizedMovies[FavoriteCategory.watched] = 
          prefs.getStringList(_watchedKey)?.map((id) => int.parse(id)).toList() ?? [];
      
      _categorizedMovies[FavoriteCategory.loved] = 
          prefs.getStringList(_lovedKey)?.map((id) => int.parse(id)).toList() ?? [];
    } catch (e) {
      // Initialize with empty lists if loading fails
      for (final category in FavoriteCategory.values) {
        _categorizedMovies[category] = [];
      }
    }
  }

  // Save categorized movies to SharedPreferences
  Future<void> _saveCategorizedMovies() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setStringList(
        _wantToWatchKey, 
        _categorizedMovies[FavoriteCategory.wantToWatch]!.map((id) => id.toString()).toList()
      );
      
      await prefs.setStringList(
        _watchedKey, 
        _categorizedMovies[FavoriteCategory.watched]!.map((id) => id.toString()).toList()
      );
      
      await prefs.setStringList(
        _lovedKey, 
        _categorizedMovies[FavoriteCategory.loved]!.map((id) => id.toString()).toList()
      );
    } catch (e) {
      // Handle save error silently
    }
  }

  // Add movie to a category
  Future<void> addToCategory(int movieId, FavoriteCategory category) async {
    // Remove from other categories first
    await removeFromAllCategories(movieId);
    
    // Add to the specified category
    _categorizedMovies[category]!.add(movieId);
    await _saveCategorizedMovies();
  }

  // Remove movie from specific category
  Future<void> removeFromCategory(int movieId, FavoriteCategory category) async {
    _categorizedMovies[category]!.remove(movieId);
    await _saveCategorizedMovies();
  }

  // Remove movie from all categories
  Future<void> removeFromAllCategories(int movieId) async {
    for (final category in FavoriteCategory.values) {
      _categorizedMovies[category]!.remove(movieId);
    }
    await _saveCategorizedMovies();
  }

  // Get category for a specific movie
  FavoriteCategory? getCategoryForMovie(int movieId) {
    for (final category in FavoriteCategory.values) {
      if (_categorizedMovies[category]!.contains(movieId)) {
        return category;
      }
    }
    return null;
  }

  // Check if movie is in any category
  bool isMovieInAnyCategory(int movieId) {
    return getCategoryForMovie(movieId) != null;
  }

  // Check if movie is in specific category
  bool isMovieInCategory(int movieId, FavoriteCategory category) {
    return _categorizedMovies[category]!.contains(movieId);
  }

  // Get all movies in a category
  List<int> getMoviesInCategory(FavoriteCategory category) {
    return List.unmodifiable(_categorizedMovies[category]!);
  }

  // Get count for each category
  Map<FavoriteCategory, int> getCategoryCounts() {
    return {
      for (final category in FavoriteCategory.values)
        category: _categorizedMovies[category]!.length,
    };
  }

  // Get total count of all categorized movies
  int getTotalCount() {
    return _categorizedMovies.values
        .map((list) => list.length)
        .fold(0, (sum, count) => sum + count);
  }

  // Move movie from one category to another
  Future<void> moveToCategory(int movieId, FavoriteCategory newCategory) async {
    await addToCategory(movieId, newCategory);
  }

  // Clear all movies from a category
  Future<void> clearCategory(FavoriteCategory category) async {
    _categorizedMovies[category]!.clear();
    await _saveCategorizedMovies();
  }

  // Clear all categories
  Future<void> clearAllCategories() async {
    for (final category in FavoriteCategory.values) {
      _categorizedMovies[category]!.clear();
    }
    await _saveCategorizedMovies();
  }

  // Get movies that are not in any category (uncategorized favorites)
  List<int> getUncategorizedMovies(List<Movie> allFavorites) {
    final categorizedIds = _categorizedMovies.values
        .expand((list) => list)
        .toSet();
    
    return allFavorites
        .where((movie) => !categorizedIds.contains(movie.id))
        .map((movie) => movie.id)
        .toList();
  }

  // Import existing favorites into "Want to Watch" category
  Future<void> importExistingFavorites(List<Movie> favorites) async {
    final uncategorized = getUncategorizedMovies(favorites);
    
    for (final movieId in uncategorized) {
      await addToCategory(movieId, FavoriteCategory.wantToWatch);
    }
  }
} 