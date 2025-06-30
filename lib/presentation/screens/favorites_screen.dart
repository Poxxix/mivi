import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/widgets/movie_list.dart';
import 'package:mivi/presentation/core/app_colors.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
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

  void _onMovieTap(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  @override
  Widget build(BuildContext context) {
    final favorites = MockMovies.favoriteMovies;
    
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
                expandedHeight: 100,
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
                title: SlideTransition(
                  position: _slideAnimation,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.favorite,
                          color: AppColors.error,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Favorites',
                            style: TextStyle(
                              color: AppColors.onBackground,
                              fontWeight: FontWeight.bold,
                              fontSize: 24,
                              letterSpacing: 0.5,
                            ),
                          ),
                          if (favorites.isNotEmpty)
                            Text(
                              '${favorites.length} movie${favorites.length == 1 ? '' : 's'}',
                              style: TextStyle(
                                color: AppColors.onBackground.withOpacity(0.7),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
                elevation: 0,
              ),
              // Content
              favorites.isEmpty
                  ? SliverFillRemaining(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: _buildEmptyState(),
                      ),
                    )
                  : SliverToBoxAdapter(
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: MovieList(
                            title: '',
                            movies: favorites,
                            onMovieTap: _onMovieTap,
                          ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.favorite_border_outlined,
                size: 80,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'No Favorites Yet',
              style: TextStyle(
                color: AppColors.onBackground,
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Movies you love will appear here.\nStart exploring and add some favorites!',
              style: TextStyle(
                color: AppColors.onBackground.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.go('/'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.explore_outlined),
              label: const Text(
                'Explore Movies',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 