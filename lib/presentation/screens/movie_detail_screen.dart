import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/repositories/movie_repository.dart';
import 'package:mivi/presentation/widgets/movie_detail_header.dart';
import 'package:mivi/presentation/widgets/movie_info_section.dart';
import 'package:mivi/presentation/widgets/cast_list.dart';
import 'package:mivi/presentation/widgets/movie_list.dart';
import 'package:mivi/presentation/core/app_colors.dart';
import 'trailer_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie _movie;
  final MovieRepository _movieRepository = MovieRepository();

  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _fetchMovieDetail();
  }

  Future<void> _fetchMovieDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movie = await _movieRepository.getMovieWithCredits(_movie.id, isFavorite: _movie.isFavorite);
      setState(() {
        _movie = movie;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Lỗi khi tải chi tiết phim: $e';
        _isLoading = false;
      });
    }
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

  Future<void> _onPlayPressed() async {
    // Nút play trên ảnh: Hiển thị thông báo chức năng đang phát triển
    _showErrorSnackBar('Chức năng đang phát triển');
  }

  Future<void> _onWatchTrailerPressed() async {
    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      // Get trailer YouTube key
      final youtubeKey = await _movieRepository.getTrailerYoutubeKey(_movie.id);

      // Hide loading indicator nếu vẫn còn mounted
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (youtubeKey != null && mounted) {
        // Chuyển sang màn TrailerPlayerScreen và chờ khi pop về
        await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TrailerPlayerScreen(youtubeKey: youtubeKey),
          ),
        );
      } else if (mounted) {
        _showErrorSnackBar('Không tìm thấy trailer cho phim này');
      }
    } catch (e) {
      // Hide loading indicator nếu vẫn còn mounted
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        _showErrorSnackBar('Lỗi khi tải trailer: $e');
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, color: Colors.red, size: 48),
                        const SizedBox(height: 16),
                        Text(
                          _error!,
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _fetchMovieDetail,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Thử lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(
                      child: MovieDetailHeader(
                        movie: _movie,
                        onBackPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go('/');
                          }
                        },
                        onFavoriteToggle: _onFavoriteToggle,
                        onPlayPressed: _onPlayPressed,
                        onWatchTrailerPressed: _onWatchTrailerPressed,
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
