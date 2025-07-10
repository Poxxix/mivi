import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/repositories/movie_repository.dart';
import 'package:mivi/presentation/widgets/movie_detail_header.dart';
import 'package:mivi/presentation/widgets/movie_info_section.dart';
import 'package:mivi/presentation/widgets/horizontal_cast_scroller.dart';
import 'package:mivi/presentation/widgets/horizontal_movie_scroller.dart';
import 'package:mivi/presentation/widgets/movie_quotes_section.dart';
import 'package:mivi/core/services/view_analytics_service.dart';
import 'package:mivi/core/utils/toast_utils.dart';
import 'package:mivi/core/utils/haptic_utils.dart';

import 'VideoPlayerScreen.dart';
import 'enhanced_trailer_player_screen.dart';

class MovieDetailScreen extends StatefulWidget {
  final Movie movie;
  const MovieDetailScreen({super.key, required this.movie});

  @override
  State<MovieDetailScreen> createState() => _MovieDetailScreenState();
}

class _MovieDetailScreenState extends State<MovieDetailScreen> {
  late Movie _movie;
  final MovieRepository _movieRepository = MovieRepository();
  final ViewAnalyticsService _analyticsService = ViewAnalyticsService.instance;

  bool _isLoading = true;
  String? _error;
  String? _viewSessionId;

  @override
  void initState() {
    super.initState();
    _movie = widget.movie;
    _fetchMovieDetail();
    _startViewSession();
  }

  @override
  void dispose() {
    _endViewSession();
    super.dispose();
  }

  Future<void> _startViewSession() async {
    _viewSessionId = await _analyticsService.startViewSession(
      movieId: _movie.id,
      movieTitle: _movie.title,
      viewType: 'detail',
    );
  }

  Future<void> _endViewSession() async {
    if (_viewSessionId != null) {
      await _analyticsService.endViewSession(_viewSessionId!);
    }
  }

  Future<void> _fetchMovieDetail() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final movie = await _movieRepository.getMovieWithCredits(
        _movie.id,
        isFavorite: _movie.isFavorite,
      );
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
    // Add haptic feedback
    HapticUtils.favorite(isFavorite: !_movie.isFavorite);
    
    setState(() {
      _movie = _movie.copyWith(isFavorite: !_movie.isFavorite);
      if (_movie.isFavorite) {
        MockMovies.addToFavorites(_movie);
        ToastUtils.showSuccess(
          context,
          '${_movie.title} added to favorites',
          icon: Icons.favorite,
        );
      } else {
        MockMovies.removeFromFavorites(_movie);
        ToastUtils.showInfo(
          context,
          '${_movie.title} removed from favorites',
          icon: Icons.favorite_border,
        );
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
    // Add haptic feedback for primary action
    HapticUtils.buttonPress(isPrimary: true);
    
    // Track full movie view
    await _analyticsService.startViewSession(
      movieId: _movie.id,
      movieTitle: _movie.title,
      viewType: 'full_movie',
    );
    
    // Kiểm tra ID phim và điều hướng tới VideoPlayerScreen nếu đúng
    if (!mounted) return;
    
    if (_movie.id == 749170) {
      const supabaseVideoUrl =
          'https://rxjhrphnwelxufmtnldh.supabase.co/storage/v1/object/public/movies/Inception%20-%20Planning%20scene%20(HQ).mp4';
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoUrl: supabaseVideoUrl),
        ),
      );
    }
    //how to train to dragon
    else if (_movie.id == 1087192) {
      const supabaseVideoUrl =
          'https://rxjhrphnwelxufmtnldh.supabase.co/storage/v1/object/public/movies//videoplayback.mp4';
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoUrl: supabaseVideoUrl),
        ),
      );
    }
    //the godfather
    else if (_movie.id == 238) {
      const supabaseVideoUrl =
          'https://rxjhrphnwelxufmtnldh.supabase.co/storage/v1/object/public/movies//videoplayback%20(1).mp4';
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => VideoPlayerScreen(videoUrl: supabaseVideoUrl),
        ),
      );
    } else {
      if (mounted) {
        _showErrorSnackBar('❌ Chưa có video cho phim này!');
      }
    }
  }

  Future<void> _onWatchTrailerPressed() async {
    // Add haptic feedback
    HapticUtils.buttonPress();
    
    // Track trailer view
    await _analyticsService.startViewSession(
      movieId: _movie.id,
      movieTitle: _movie.title,
      viewType: 'trailer',
    );
    
    try {
      // Show loading indicator
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(color: Colors.red),
                  SizedBox(height: 16),
                  Text(
                    'Đang tìm trailer...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        );
      }

      // Get trailer YouTube key
      final youtubeKey = await _movieRepository.getTrailerYoutubeKey(_movie.id);

      // Hide loading indicator nếu vẫn còn mounted
      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (youtubeKey != null && mounted) {
        // Navigate to enhanced trailer player screen
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EnhancedTrailerPlayerScreen(
              youtubeKey: youtubeKey,
            ),
          ),
        );
      } else if (mounted) {
        _showErrorSnackBar('❌ Không tìm thấy trailer cho phim này');
      }
    } catch (e) {
      // Hide loading indicator nếu vẫn còn mounted
      if (mounted && Navigator.of(context, rootNavigator: true).canPop()) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (mounted) {
        _showErrorSnackBar(
          '⚠️ Lỗi khi tìm trailer: ${e.toString().contains('Exception:') ? e.toString().split('Exception: ')[1] : e.toString()}',
        );
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
      backgroundColor: Theme.of(context).colorScheme.background,
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
                SliverToBoxAdapter(
                  child: MovieQuotesSection(
                    movieId: _movie.id,
                    movieTitle: _movie.title,
                  ),
                ),
                if (_movie.cast.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: HorizontalCastScroller(
                        castMembers: _movie.cast,
                        title: 'Cast',
                        showNavigationButtons: true,
                      ),
                    ),
                  ),
                if (_movie.similarMovies.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      child: HorizontalMovieScroller(
                        movies: _movie.similarMovies,
                        title: 'Similar Movies',
                        showNavigationButtons: true,
                        isCompact: false,
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}
