import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/presentation/widgets/movie_detail_header.dart';
import 'package:mivi/presentation/widgets/movie_info_section.dart';
import 'package:mivi/presentation/widgets/cast_list.dart';
import 'package:mivi/presentation/widgets/movie_list.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie _movie;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
  }

  void _onFavoriteToggle() {
    setState(() {
      _movie = _movie.copyWith(isFavorite: !_movie.isFavorite);
      if (_movie.isFavorite) {
        MockMovies.addToFavorites(_movie);
      } else {
        MockMovies.removeFromFavorites(_movie);
      }
    });
  }

  void _onCastMemberTap(CastMember castMember) {
    // TODO: Navigate to cast member details
  }

  void _onSimilarMovieTap(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: MovieDetailHeader(
              movie: _movie,
              onBackPressed: () => context.pop(),
              onFavoriteToggle: _onFavoriteToggle,
            ),
          ),
          SliverToBoxAdapter(child: MovieInfoSection(movie: _movie)),
          if (_movie.cast.isNotEmpty)
            SliverToBoxAdapter(
              child: CastList(
                title: 'Cast',
                cast: _movie.cast,
                onCastMemberTap: _onCastMemberTap,
              ),
            ),
          if (_movie.similarMovies.isNotEmpty)
            SliverToBoxAdapter(
              child: MovieList(
                title: 'Similar Movies',
                movies: _movie.similarMovies,
                onMovieTap: _onSimilarMovieTap,
              ),
            ),
        ],
      ),
    );
  }
} 