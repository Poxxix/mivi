import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/core/services/watchlist_service.dart';
import 'package:mivi/presentation/widgets/movie_card.dart';
import 'package:mivi/core/utils/haptic_utils.dart';
import 'package:mivi/core/utils/toast_utils.dart';

class WatchlistScreen extends StatefulWidget {
  const WatchlistScreen({super.key});

  @override
  State<WatchlistScreen> createState() => _WatchlistScreenState();
}

class _WatchlistScreenState extends State<WatchlistScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  List<Movie> _watchlistMovies = [];
  String _sortBy = 'date'; // 'date' or 'title'
  bool _isLoading = true;

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
    
    _loadWatchlist();
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadWatchlist() async {
    await WatchlistService.instance.initialize();
    setState(() {
      _isLoading = false;
      _refreshWatchlist();
    });
  }

  void _refreshWatchlist() {
    setState(() {
      if (_sortBy == 'date') {
        _watchlistMovies = WatchlistService.instance.getWatchlistByDate();
      } else {
        _watchlistMovies = WatchlistService.instance.getWatchlistByTitle();
      }
    });
  }

  void _changeSortOrder() {
    HapticUtils.selection();
    setState(() {
      _sortBy = _sortBy == 'date' ? 'title' : 'date';
      _refreshWatchlist();
    });
  }

  Future<void> _clearAllWatchlist() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Watchlist'),
        content: const Text('Are you sure you want to remove all movies from your watchlist?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      HapticUtils.warning();
      final success = await WatchlistService.instance.clearWatchlist();
      if (success && mounted) {
        setState(() {
          _watchlistMovies.clear();
        });
        ToastUtils.showInfo(context, 'Watchlist cleared');
      }
    }
  }

  void _onMovieTap(Movie movie) {
    HapticUtils.movieTap();
    context.push('/movie/${movie.id}');
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      body: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: CustomScrollView(
                slivers: [
                  // App Bar
                  SliverAppBar(
                    expandedHeight: 120,
                    floating: false,
                    pinned: true,
                    backgroundColor: colorScheme.surface.withOpacity(0.95),
                    flexibleSpace: FlexibleSpaceBar(
                      title: Text(
                        'My Watchlist',
                        style: textTheme.headlineSmall?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      titlePadding: const EdgeInsets.only(left: 20, bottom: 16),
                    ),
                    actions: [
                      // Sort button
                      if (_watchlistMovies.isNotEmpty)
                        IconButton(
                          onPressed: _changeSortOrder,
                          icon: Icon(
                            _sortBy == 'date' ? Icons.access_time : Icons.sort_by_alpha,
                            color: colorScheme.primary,
                          ),
                          tooltip: _sortBy == 'date' ? 'Sort by Title' : 'Sort by Date Added',
                        ),
                      // Clear all button
                      if (_watchlistMovies.isNotEmpty)
                        IconButton(
                          onPressed: _clearAllWatchlist,
                          icon: Icon(
                            Icons.clear_all,
                            color: colorScheme.error,
                          ),
                          tooltip: 'Clear All',
                        ),
                      const SizedBox(width: 8),
                    ],
                  ),

                  // Content
                  if (_isLoading)
                    const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_watchlistMovies.isEmpty)
                    _buildEmptyState()
                  else
                    _buildWatchlistGrid(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bookmark_border,
                size: 64,
                color: colorScheme.onSurfaceVariant.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your watchlist is empty',
              style: textTheme.headlineSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Start adding movies you want to watch later by tapping the bookmark icon on movie cards',
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                  height: 1.4,
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => context.push('/search'),
              icon: const Icon(Icons.search),
              label: const Text('Browse Movies'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistGrid() {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with count and sort info
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceVariant.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.bookmark,
                    color: colorScheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${_watchlistMovies.length} movies',
                    style: textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Sorted by ${_sortBy == 'date' ? 'date added' : 'title'}',
                    style: textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Movies grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.6,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: _watchlistMovies.length,
              itemBuilder: (context, index) {
                final movie = _watchlistMovies[index];
                return _buildWatchlistMovieCard(movie);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWatchlistMovieCard(Movie movie) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final addedDate = WatchlistService.instance.getAddedDate(movie);

    return Column(
      children: [
        Expanded(
          child: MovieCard(
            movie: movie,
            onTap: () => _onMovieTap(movie),
            onFavoriteToggle: _refreshWatchlist,
          ),
        ),
        const SizedBox(height: 8),
        // Added date info
        if (addedDate != null)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Added ${_getTimeAgoString(addedDate)}',
              textAlign: TextAlign.center,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                fontSize: 11,
              ),
            ),
          ),
      ],
    );
  }

  String _getTimeAgoString(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'vừa xong';
    }
  }
} 