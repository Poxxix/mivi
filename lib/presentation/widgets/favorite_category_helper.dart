import 'package:flutter/material.dart';
import 'package:mivi/presentation/widgets/favorite_category_selector.dart';
import 'package:mivi/core/utils/haptic_utils.dart';

class FavoriteCategoryHelper {
  static Future<void> showCategorySelector(
    BuildContext context, {
    required int movieId,
    required String movieTitle,
    VoidCallback? onCategoryChanged,
  }) async {
    HapticUtils.medium();
    
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FavoriteCategorySelector(
        movieId: movieId,
        movieTitle: movieTitle,
        onCategoryChanged: onCategoryChanged,
      ),
    );
  }
} 