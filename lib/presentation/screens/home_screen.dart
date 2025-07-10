import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/repositories/movie_repository.dart';
import 'package:mivi/presentation/blocs/movie_bloc.dart';

import 'package:mivi/presentation/widgets/horizontal_movie_scroller.dart';
import 'package:mivi/presentation/widgets/genre_list.dart';
import 'package:mivi/presentation/widgets/featured_movies_carousel.dart';

import 'package:mivi/presentation/widgets/skeleton_widgets.dart';
import 'package:mivi/core/utils/toast_utils.dart';
import 'package:mivi/core/utils/haptic_utils.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Genre? _selectedGenre;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  
  // BLoCs for different movie categories
  late MovieBloc _trendingBloc;
  late MovieBloc _popularBloc;
  late MovieBloc _topRatedBloc;
  late MovieBloc _nowPlayingBloc;
  late MovieBloc _genreBloc;

  // Thêm trạng thái loading genres
  bool _genresLoaded = false;
  late MovieRepository movieRepository;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Initialize MovieRepository
    movieRepository = MovieRepository();
    // Gọi fetchAndCacheGenres trước khi load phim
    _initGenresAndMovies();
    _animationController.forward();
  }

  Future<void> _initGenresAndMovies() async {
    await movieRepository.fetchAndCacheGenres();
    // Initialize BLoCs
    _trendingBloc = MovieBloc(movieRepository: movieRepository);
    _popularBloc = MovieBloc(movieRepository: movieRepository);
    _topRatedBloc = MovieBloc(movieRepository: movieRepository);
    _nowPlayingBloc = MovieBloc(movieRepository: movieRepository);
    _genreBloc = MovieBloc(movieRepository: movieRepository);
    // Load initial data
    _trendingBloc.add(const LoadTrendingMovies(checkForNotifications: true));
    _popularBloc.add(const LoadPopularMovies());
    _topRatedBloc.add(const LoadTopRatedMovies());
    _nowPlayingBloc.add(const LoadNowPlayingMovies());
    setState(() {
      _genresLoaded = true;
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _trendingBloc.close();
    _popularBloc.close();
    _topRatedBloc.close();
    _nowPlayingBloc.close();
    _genreBloc.close();
    super.dispose();
  }

  void _onGenreSelected(Genre? genre) {
    setState(() {
      _selectedGenre = genre;
    });
    if (genre != null) {
      _genreBloc.add(LoadMoviesByGenre(genre.id));
    }
  }

  void _onMovieTap(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  void _onSearchTap() {
    context.push('/search');
  }

  Future<void> _handleRefresh() async {
    // Add haptic feedback for refresh action
    HapticUtils.refresh();
    
    // Refresh all movie data
    _trendingBloc.add(const LoadTrendingMovies(checkForNotifications: true));
    _popularBloc.add(const LoadPopularMovies());
    _topRatedBloc.add(const LoadTopRatedMovies());
    _nowPlayingBloc.add(const LoadNowPlayingMovies());
    
    // Add a small delay to show the refresh indicator
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Show success toast
    if (mounted) {
      ToastUtils.showSuccess(
        context,
        'Movies refreshed!',
        icon: Icons.refresh,
        duration: const Duration(seconds: 2),
      );
    }
  }

  List<Movie> _filterMoviesByGenre(List<Movie> movies) {
    if (_selectedGenre == null) return movies;
    return movies.where((movie) => 
      movie.genres.any((genre) => genre.id == _selectedGenre!.id)
    ).toList();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: !_genresLoaded 
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                backgroundColor: colorScheme.surface,
                color: colorScheme.primary,
                child: CustomScrollView(
                slivers: [
                  // Enhanced App Bar
                  SliverAppBar(
                    backgroundColor: colorScheme.background,
                    floating: true,
                    expandedHeight: 80,
                    flexibleSpace: FlexibleSpaceBar(
                      background: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              colorScheme.background,
                              colorScheme.background.withOpacity(0.8),
                            ],
                          ),
                        ),
                      ),
                    ),
                    title: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            Icons.movie_creation_outlined,
                            color: colorScheme.primary,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Flexible(
                          child: Text(
                            'Mivi',
                            style: TextStyle(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    actions: [
                      Container(
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.search_rounded,
                            color: colorScheme.onBackground,
                            size: 24,
                          ),
                          onPressed: _onSearchTap,
                        ),
                      ),
                    ],
                    elevation: 0,
                  ),
                  // Welcome Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back!',
                            style: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.8),
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Discover amazing movies',
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: colorScheme.onBackground,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ) ?? TextStyle(
                              color: colorScheme.onBackground,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Featured Movies Carousel
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              '✨ Featured Movies',
                              style: TextStyle(
                                color: colorScheme.onBackground,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          BlocBuilder<MovieBloc, MovieState>(
                            bloc: _popularBloc,
                            builder: (context, state) {
                              if (state is MovieLoading) {
                                return SkeletonWidgets.featuredCarouselSkeleton(context);
                              } else if (state is MovieLoaded && state.movies.isNotEmpty) {
                                // Take top 5 movies for carousel
                                final featuredMovies = state.movies.take(5).toList();
                                return FeaturedMoviesCarousel(
                                  movies: featuredMovies,
                                  onMovieTap: _onMovieTap,
                                );
                              }
                              return const SizedBox(height: 280);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Genre Filter Section
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              'Browse by Genre',
                              style: TextStyle(
                                color: colorScheme.onBackground,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          GenreList(
                            genres: MockMovies.genres,
                            selectedGenre: _selectedGenre,
                            onGenreSelected: _onGenreSelected,
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Movies Sections
                  SliverToBoxAdapter(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          const SizedBox(height: 16),
                          _buildMovieSection(
                            '🔥 Trending Now',
                            'Most popular movies this week',
                            _trendingBloc,
                            Icons.trending_up,
                          ),
                          const SizedBox(height: 32),
                          _buildMovieSection(
                            '⭐ Popular',
                            'Movies everyone is talking about',
                            _popularBloc,
                            Icons.star,
                          ),
                          const SizedBox(height: 32),
                          _buildMovieSection(
                            '🎬 Now Playing',
                            'Currently in theaters',
                            _nowPlayingBloc,
                            Icons.play_circle,
                          ),
                          const SizedBox(height: 32),
                          _buildMovieSection(
                            '🏆 Top Rated',
                            'Highest rated movies of all time',
                            _topRatedBloc,
                            Icons.emoji_events,
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
                ),
        ),
      ),
    );
  }

  Widget _buildLoadingList() {
    return SkeletonWidgets.horizontalMovieListSkeleton(context, itemCount: 6);
  }

  Widget _buildEmptyState(String title) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.movie_outlined,
              size: 32,
              color: colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'No movies found',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.7),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String title, String message, VoidCallback onRetry) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.error.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            'Error loading $title',
            style: TextStyle(
              color: colorScheme.error,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            message,
            style: TextStyle(
              color: colorScheme.error.withOpacity(0.8),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh, size: 16),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieSection(String title, String subtitle, MovieBloc bloc, IconData icon) {
    final colorScheme = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: colorScheme.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: colorScheme.onBackground,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: colorScheme.onBackground.withOpacity(0.7),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        BlocBuilder<MovieBloc, MovieState>(
          bloc: bloc,
          builder: (context, state) {
            if (state is MovieLoading) {
              return _buildLoadingList();
            } else if (state is MovieLoaded) {
              final filteredMovies = _filterMoviesByGenre(state.movies);
              if (filteredMovies.isEmpty) {
                return _buildEmptyState(title);
              }
              return HorizontalMovieScroller(
                movies: filteredMovies,
                title: '',
                showNavigationButtons: true,
                isCompact: false,
              );
            } else if (state is MovieError) {
              return _buildErrorState(title, state.message, () {
                if (title.contains('Trending')) {
                  bloc.add(const LoadTrendingMovies());
                } else if (title.contains('Popular')) {
                  bloc.add(const LoadPopularMovies());
                } else if (title.contains('Top Rated')) {
                  bloc.add(const LoadTopRatedMovies());
                } else if (title.contains('Now Playing')) {
                  bloc.add(const LoadNowPlayingMovies());
                }
              });
            }
            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }
} 