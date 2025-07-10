import 'package:flutter/material.dart';

enum FavoriteCategory {
  wantToWatch,
  watched,
  loved;

  String get displayName {
    switch (this) {
      case FavoriteCategory.wantToWatch:
        return 'Want to Watch';
      case FavoriteCategory.watched:
        return 'Watched';
      case FavoriteCategory.loved:
        return 'Loved';
    }
  }

  String get description {
    switch (this) {
      case FavoriteCategory.wantToWatch:
        return 'Movies you plan to watch later';
      case FavoriteCategory.watched:
        return 'Movies you have already seen';
      case FavoriteCategory.loved:
        return 'Your absolute favorite movies';
    }
  }

  IconData get icon {
    switch (this) {
      case FavoriteCategory.wantToWatch:
        return Icons.bookmark_outline;
      case FavoriteCategory.watched:
        return Icons.check_circle_outline;
      case FavoriteCategory.loved:
        return Icons.favorite;
    }
  }

  IconData get filledIcon {
    switch (this) {
      case FavoriteCategory.wantToWatch:
        return Icons.bookmark;
      case FavoriteCategory.watched:
        return Icons.check_circle;
      case FavoriteCategory.loved:
        return Icons.favorite;
    }
  }

  Color get color {
    switch (this) {
      case FavoriteCategory.wantToWatch:
        return const Color(0xFF3B82F6); // Blue
      case FavoriteCategory.watched:
        return const Color(0xFF10B981); // Green
      case FavoriteCategory.loved:
        return const Color(0xFFEF4444); // Red
    }
  }

  String get storageKey {
    switch (this) {
      case FavoriteCategory.wantToWatch:
        return 'want_to_watch';
      case FavoriteCategory.watched:
        return 'watched';
      case FavoriteCategory.loved:
        return 'loved';
    }
  }

  static FavoriteCategory fromStorageKey(String key) {
    switch (key) {
      case 'want_to_watch':
        return FavoriteCategory.wantToWatch;
      case 'watched':
        return FavoriteCategory.watched;
      case 'loved':
        return FavoriteCategory.loved;
      default:
        return FavoriteCategory.wantToWatch;
    }
  }
}

class FavoriteCategoryExtensions {
  static List<FavoriteCategory> get allCategories => FavoriteCategory.values;
  
  static FavoriteCategory? getCategoryForMovie(int movieId) {
    // This will be implemented in the service
    return null;
  }
} 