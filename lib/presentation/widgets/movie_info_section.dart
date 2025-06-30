import 'package:flutter/material.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/core/app_colors.dart';
import 'package:mivi/presentation/widgets/genre_chip.dart';

class MovieInfoSection extends StatelessWidget {
  final Movie movie;

  const MovieInfoSection({
    super.key,
    required this.movie,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overview
          const Text(
            'Overview',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            movie.overview,
            style: TextStyle(
              fontSize: 14,
              color: AppColors.onSurface.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          // Genres
          const Text(
            'Genres',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: movie.genres.map((genre) {
              return GenreChip(genre: genre);
            }).toList(),
          ),
          const SizedBox(height: 16),
          // Additional Info
          const Text(
            'Additional Info',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          _buildInfoRow('Status', movie.status ?? 'Unknown'),
          _buildInfoRow(
            'Original Language',
            movie.originalLanguage?.toUpperCase() ?? 'Unknown',
          ),
          _buildInfoRow('Budget', movie.formattedBudget),
          _buildInfoRow('Revenue', movie.formattedRevenue),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.onSurface.withOpacity(0.7),
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 