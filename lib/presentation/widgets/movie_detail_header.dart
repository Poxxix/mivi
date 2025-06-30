import 'package:flutter/material.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class MovieDetailHeader extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onFavoriteToggle;
  final VoidCallback? onBackPressed;
  final VoidCallback? onPlayPressed;
  final VoidCallback? onWatchTrailerPressed;

  const MovieDetailHeader({
    super.key,
    required this.movie,
    this.onFavoriteToggle,
    this.onBackPressed,
    this.onPlayPressed,
    this.onWatchTrailerPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Backdrop Image
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.network(
            movie.backdropPath ?? 'https://via.placeholder.com/1200x300',
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: AppColors.surfaceVariant,
                child: const Icon(
                  Icons.movie,
                  size: 64,
                  color: AppColors.onSurfaceVariant,
                ),
              );
            },
          ),
        ),
        // Gradient Overlay
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.black.withOpacity(0.8),
                ],
              ),
            ),
          ),
        ),
        // Back Button
        if (onBackPressed != null)
          Positioned(
            top: 48,
            left: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBackPressed,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        // Favorite Button
        if (onFavoriteToggle != null)
          Positioned(
            top: 48,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onFavoriteToggle,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Icon(
                    movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: movie.isFavorite ? Colors.red : Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ),
        // Movie Info
        Positioned(
          left: 16,
          right: 16,
          bottom: 16,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                movie.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              if (movie.tagline?.isNotEmpty ?? false) ...[
                const SizedBox(height: 4),
                Text(
                  movie.tagline!,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
              const SizedBox(height: 8),
              // Thời lượng phim
              Text(
                'Thời lượng: ${movie.formattedDuration}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    movie.releaseDate.split('-')[0],
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (onWatchTrailerPressed != null)
                SizedBox(
                  width: 160,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white),
                    ),
                    onPressed: onWatchTrailerPressed,
                    icon: const Icon(Icons.ondemand_video, color: Colors.white),
                    label: const Text('Xem trailer'),
                  ),
                ),
            ],
          ),
        ),
        // Nút Play ở giữa poster
        if (onPlayPressed != null)
          Positioned.fill(
            child: Center(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: onPlayPressed,
                  borderRadius: BorderRadius.circular(40),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.85),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 16,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
} 