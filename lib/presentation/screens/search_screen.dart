import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/repositories/movie_repository.dart';
import 'package:mivi/presentation/blocs/movie_bloc.dart';
import 'package:mivi/presentation/widgets/search_bar.dart' as custom;
import 'package:mivi/presentation/widgets/movie_list.dart';
import 'package:mivi/presentation/core/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _controller = TextEditingController();
  String _query = '';
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late MovieBloc _searchBloc;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );
    
    // Initialize search BLoC
    _searchBloc = MovieBloc(movieRepository: MovieRepository());
    
    _animationController.forward();
  }

  void _onMovieTap(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });

    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isNotEmpty) {
        _searchBloc.add(SearchMovies(value.trim()));
      }
    });
  }

  void _clearSearch() {
    setState(() {
      _query = '';
      _controller.clear();
    });
    _debounceTimer?.cancel();
  }

  @override
  void dispose() {
    _controller.dispose();
    _animationController.dispose();
    _searchBloc.close();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            children: [
              // Enhanced Search Header
              SlideTransition(
                position: _slideAnimation,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.background,
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.surface.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: AppColors.onBackground,
                              ),
                              onPressed: () => context.pop(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Search Movies',
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Enhanced Search Field
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.surfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppColors.surfaceVariant.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(color: AppColors.onBackground),
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search for movies...',
                            hintStyle: TextStyle(
                              color: AppColors.onBackground.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: AppColors.primary,
                              size: 24,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: AppColors.onBackground.withOpacity(0.7),
                                    ),
                                    onPressed: _clearSearch,
                                  )
                                : null,
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Search Results
              Expanded(
                child: _query.isEmpty
                    ? _buildEmptyState()
                    : _buildSearchResults(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return SlideTransition(
      position: _slideAnimation,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Search for Movies',
                style: TextStyle(
                  color: AppColors.onBackground,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Find your favorite movies by searching for titles, actors, or genres',
                style: TextStyle(
                  color: AppColors.onBackground.withOpacity(0.7),
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return BlocBuilder<MovieBloc, MovieState>(
      bloc: _searchBloc,
      builder: (context, state) {
        if (state is MovieLoading) {
          return _buildLoadingState();
        } else if (state is MovieLoaded) {
          if (state.movies.isEmpty) {
            return _buildNoResults();
          }
          return _buildResultsList(state.movies);
        } else if (state is MovieError) {
          return _buildErrorState(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Searching for "$_query"...',
            style: TextStyle(
              color: AppColors.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 5,
              itemBuilder: (context, index) {
                return Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    height: 120,
                    margin: const EdgeInsets.only(bottom: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoResults() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 48,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Try searching with different keywords or check your spelling',
              style: TextStyle(
                color: AppColors.onBackground.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(List<Movie> movies) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${movies.length} results for "$_query"',
            style: TextStyle(
              color: AppColors.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        movie.posterPath,
                        width: 60,
                        height: 90,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 90,
                            color: AppColors.surfaceVariant,
                            child: Icon(
                              Icons.movie,
                              color: AppColors.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
                    title: Text(
                      movie.title,
                      style: TextStyle(
                        color: AppColors.onBackground,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          movie.releaseYear,
                          style: TextStyle(
                            color: AppColors.onBackground.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              movie.voteAverage.toStringAsFixed(1),
                              style: TextStyle(
                                color: AppColors.onBackground.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    onTap: () => _onMovieTap(movie),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Search Error',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: AppColors.onBackground.withOpacity(0.7),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                if (_query.trim().isNotEmpty) {
                  _searchBloc.add(SearchMovies(_query.trim()));
                }
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
} 