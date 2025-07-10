import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/models/movie_model.dart';

class HorizontalMovieScroller extends StatefulWidget {
  final List<Movie> movies;
  final String title;
  final VoidCallback? onSeeAll;
  final bool showNavigationButtons;
  final bool isCompact;

  const HorizontalMovieScroller({
    super.key,
    required this.movies,
    required this.title,
    this.onSeeAll,
    this.showNavigationButtons = true,
    this.isCompact = false,
  });

  @override
  State<HorizontalMovieScroller> createState() => _HorizontalMovieScrollerState();
}

class _HorizontalMovieScrollerState extends State<HorizontalMovieScroller> {
  late ScrollController _scrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollButtons);
    
    // Check initial scroll state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (_scrollController.hasClients) {
      setState(() {
        _canScrollLeft = _scrollController.offset > 0;
        _canScrollRight = _scrollController.offset < _scrollController.position.maxScrollExtent;
      });
    }
  }

  void _scrollLeft() {
    const scrollAmount = 280.0; // Width of ~2 cards
    final targetOffset = (_scrollController.offset - scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollRight() {
    const scrollAmount = 280.0; // Width of ~2 cards
    final targetOffset = (_scrollController.offset + scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _onMovieTap(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (widget.movies.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and navigation
        if (!widget.isCompact) ...[
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (widget.showNavigationButtons) ...[
                  // Left arrow
                  Container(
                    decoration: BoxDecoration(
                      color: _canScrollLeft 
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_back_ios_rounded,
                        color: _canScrollLeft 
                            ? colorScheme.primary 
                            : colorScheme.onSurface.withOpacity(0.3),
                        size: 16,
                      ),
                      onPressed: _canScrollLeft ? _scrollLeft : null,
                      iconSize: 16,
                      constraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 32,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Right arrow
                  Container(
                    decoration: BoxDecoration(
                      color: _canScrollRight 
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: IconButton(
                      icon: Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _canScrollRight 
                            ? colorScheme.primary 
                            : colorScheme.onSurface.withOpacity(0.3),
                        size: 16,
                      ),
                      onPressed: _canScrollRight ? _scrollRight : null,
                      iconSize: 16,
                      constraints: const BoxConstraints(
                        minHeight: 32,
                        minWidth: 32,
                      ),
                    ),
                  ),
                ],
                if (widget.onSeeAll != null) ...[
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: widget.onSeeAll,
                    child: Text(
                      'See All',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Movies scroll view
        SizedBox(
          height: widget.isCompact ? 200 : 240,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) {
              final movie = widget.movies[index];
              return Container(
                width: widget.isCompact ? 120 : 140,
                margin: EdgeInsets.only(
                  right: index < widget.movies.length - 1 ? 12 : 0,
                ),
                child: _MovieCard(
                  movie: movie,
                  onTap: () => _onMovieTap(movie),
                  isCompact: widget.isCompact,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _MovieCard extends StatelessWidget {
  final Movie movie;
  final VoidCallback onTap;
  final bool isCompact;

  const _MovieCard({
    required this.movie,
    required this.onTap,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie Poster
            Expanded(
              flex: isCompact ? 3 : 4,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                  child: movie.posterPath.isNotEmpty
                      ? Image.network(
                          'https://image.tmdb.org/t/p/w300${movie.posterPath}',
                          fit: BoxFit.cover,
                          width: double.infinity,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildPlaceholder(context),
                        )
                      : _buildPlaceholder(context),
                ),
              ),
            ),
            
            // Movie Info
            Expanded(
              flex: isCompact ? 2 : 2,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      movie.title,
                      style: TextStyle(
                        color: colorScheme.onSurface,
                        fontSize: isCompact ? 12 : 13,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    
                    // Rating
                    Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: Colors.amber,
                          size: isCompact ? 12 : 14,
                        ),
                        const SizedBox(width: 2),
                        Text(
                          movie.voteAverage.toStringAsFixed(1),
                          style: TextStyle(
                            color: colorScheme.onSurface.withOpacity(0.7),
                            fontSize: isCompact ? 10 : 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
      child: Icon(
        Icons.movie_rounded,
        color: colorScheme.onSurface.withOpacity(0.3),
        size: 32,
      ),
    );
  }
} 