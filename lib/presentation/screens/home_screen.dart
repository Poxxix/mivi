import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/widgets/movie_list.dart';
import 'package:mivi/presentation/widgets/genre_list.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  Genre? _selectedGenre;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onGenreSelected(Genre? genre) {
    setState(() {
      _selectedGenre = genre;
    });
  }

  void _onMovieTap(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  void _onSearchTap() {
    context.push('/search');
  }

  List<Movie> _filterMoviesByGenre(List<Movie> movies) {
    if (_selectedGenre == null) return movies;
    return movies.where((movie) => movie.genres.contains(_selectedGenre)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              // Enhanced App Bar
              SliverAppBar(
                backgroundColor: AppColors.background,
                floating: true,
                expandedHeight: 80,
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.background,
                          AppColors.background.withOpacity(0.8),
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
                        color: AppColors.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.movie_creation_outlined,
                        color: AppColors.primary,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Flexible(
                      child: Text(
                        'Mivi',
                        style: TextStyle(
                          color: AppColors.onBackground,
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
                      color: AppColors.surfaceVariant.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.search_rounded,
                        color: AppColors.onBackground,
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
                          color: AppColors.onBackground.withOpacity(0.8),
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
                          color: AppColors.onBackground,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ) ?? const TextStyle(
                          color: AppColors.onBackground,
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
              // Genre Filter Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Browse by Genre',
                          style: TextStyle(
                            color: AppColors.onBackground,
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
              // Trending Movies Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 16),
                  child: MovieList(
                    title: '🔥 Trending Now',
                    movies: _filterMoviesByGenre(MockMovies.trendingMovies),
                    onMovieTap: _onMovieTap,
                  ),
                ),
              ),
              // Popular Movies Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: MovieList(
                    title: '⭐ Popular',
                    movies: _filterMoviesByGenre(MockMovies.popularMovies),
                    onMovieTap: _onMovieTap,
                  ),
                ),
              ),
              // Top Rated Movies Section
              SliverToBoxAdapter(
                child: Container(
                  margin: const EdgeInsets.only(top: 8),
                  child: MovieList(
                    title: '🏆 Top Rated',
                    movies: _filterMoviesByGenre(MockMovies.topRatedMovies),
                    onMovieTap: _onMovieTap,
                  ),
                ),
              ),
              // Bottom Spacing
              const SliverToBoxAdapter(
                child: SizedBox(height: 100),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 