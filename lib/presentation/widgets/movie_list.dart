import 'package:flutter/material.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/core/app_colors.dart';
import 'package:mivi/presentation/widgets/movie_card.dart';

class MovieList extends StatelessWidget {
  final String title;
  final List<Movie> movies;
  final bool showFavoriteButton;
  final Function(Movie)? onMovieTap;

  const MovieList({
    super.key,
    required this.title,
    required this.movies,
    this.showFavoriteButton = true,
    this.onMovieTap,
  });

  @override
  Widget build(BuildContext context) {
    if (movies.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Text(
            title,
            style: const TextStyle(
              color: AppColors.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
          height: 280,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: movies.length,
            itemBuilder: (context, index) {
              final movie = movies[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: MovieCard(
                  movie: movie,
                  showFavoriteButton: showFavoriteButton,
                  onTap: onMovieTap != null ? () => onMovieTap!(movie) : null,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
} 