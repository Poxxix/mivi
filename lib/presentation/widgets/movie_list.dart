import 'package:flutter/material.dart';
import 'package:mivi/data/models/movie_model.dart';

import 'package:mivi/presentation/widgets/movie_card.dart';

class MovieList extends StatefulWidget {
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
  State<MovieList> createState() => _MovieListState();
}

class _MovieListState extends State<MovieList> 
    with SingleTickerProviderStateMixin {
  late ScrollController _scrollController;
  late AnimationController _animationController;
  double _scrollPosition = 0.0;
  
  // Constants for scroll behavior
  static const double _itemWidth = 140.0;
  static const double _itemSpacing = 16.0;
  static const double _totalItemWidth = _itemWidth + _itemSpacing;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Listen to scroll changes for indicators
    _scrollController.addListener(() {
      setState(() {
        _scrollPosition = _scrollController.offset;
      });
    });
    
    // Start animation when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _scrollToNext() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    final itemsPerPage = 2.5; // Show 2.5 items per screen
    final scrollAmount = _totalItemWidth * itemsPerPage;
    
    final targetScroll = (currentScroll + scrollAmount).clamp(0.0, maxScroll);
    
    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollToPrevious() {
    final currentScroll = _scrollController.offset;
    final itemsPerPage = 2.5; // Show 2.5 items per screen
    final scrollAmount = _totalItemWidth * itemsPerPage;
    
    final targetScroll = (currentScroll - scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
    
    _scrollController.animateTo(
      targetScroll,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    // Grid layout for filtered movies (when title is empty)
    if (widget.title.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.65,
            mainAxisSpacing: 16,
            crossAxisSpacing: 16,
          ),
          itemCount: widget.movies.length,
          shrinkWrap: true,
          physics: const AlwaysScrollableScrollPhysics(),
          itemBuilder: (context, index) {
            final movie = widget.movies[index];
            return MovieCard(
              movie: movie,
              showFavoriteButton: widget.showFavoriteButton,
              onTap: widget.onMovieTap != null ? () => widget.onMovieTap!(movie) : null,
            );
          },
        ),
      );
    }

    // Enhanced horizontal scroll layout
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section header with navigation controls
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 0),
          child: Row(
            children: [
              Expanded(
          child: Text(
                  widget.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onBackground,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
              // Navigation buttons
              if (widget.movies.length > 2) ...[
                _buildNavButton(
                  icon: Icons.chevron_left,
                  onPressed: _scrollToPrevious,
                ),
                const SizedBox(width: 8),
                _buildNavButton(
                  icon: Icons.chevron_right,
                  onPressed: _scrollToNext,
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Enhanced horizontal movie list
        SizedBox(
          height: 300,
          child: Stack(
            children: [
              // Movie list with enhanced scrolling
              Positioned.fill(
          child: ListView.builder(
                  controller: _scrollController,
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            physics: const BouncingScrollPhysics(),
                  itemCount: widget.movies.length,
            itemBuilder: (context, index) {
                    final movie = widget.movies[index];
                    
                    return AnimatedBuilder(
                      animation: _animationController,
                      builder: (context, child) {
                        // Stagger animation for each item
                        final animationDelay = (index * 0.1).clamp(0.0, 1.0);
                        final itemAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
                          CurvedAnimation(
                            parent: _animationController,
                            curve: Interval(
                              animationDelay,
                              (animationDelay + 0.5).clamp(0.0, 1.0),
                              curve: Curves.easeOutBack,
                            ),
                          ),
                        );
                        
                        return Transform.translate(
                          offset: Offset(0, 50 * (1 - itemAnimation.value)),
                          child: Opacity(
                            opacity: itemAnimation.value,
                            child: Container(
                              width: _itemWidth,
                              margin: const EdgeInsets.only(right: _itemSpacing),
                child: MovieCard(
                  movie: movie,
                                showFavoriteButton: widget.showFavoriteButton,
                                onTap: widget.onMovieTap != null 
                                    ? () => widget.onMovieTap!(movie) 
                                    : null,
                              ),
                            ),
                ),
              );
            },
                    );
                  },
                ),
              ),
              
              // Scroll position indicator
              if (widget.movies.length > 2)
                Positioned(
                  bottom: 8,
                  left: 16,
                  right: 16,
                  child: _buildScrollIndicator(),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNavButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: colorScheme.surfaceVariant.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.surfaceVariant.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPressed,
          child: Icon(
            icon,
            color: colorScheme.onBackground.withOpacity(0.7),
            size: 20,
          ),
        ),
      ),
    );
  }

  Widget _buildScrollIndicator() {
    if (!_scrollController.hasClients) return const SizedBox.shrink();
    
    final maxScroll = _scrollController.position.maxScrollExtent;
    if (maxScroll <= 0) return const SizedBox.shrink();
    
    final progress = (_scrollPosition / maxScroll).clamp(0.0, 1.0);
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedOpacity(
      opacity: _scrollPosition > 10 ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        height: 3,
        decoration: BoxDecoration(
          color: colorScheme.surfaceVariant.withOpacity(0.2),
          borderRadius: BorderRadius.circular(1.5),
        ),
        child: FractionallySizedBox(
          alignment: Alignment.centerLeft,
          widthFactor: progress,
          child: Container(
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.6),
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        ),
      ),
    );
  }
} 