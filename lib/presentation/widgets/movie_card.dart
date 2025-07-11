import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/mock_data/mock_movies.dart';
import 'package:mivi/core/utils/toast_utils.dart';
import 'package:mivi/core/utils/haptic_utils.dart';
import 'package:mivi/presentation/widgets/favorite_category_helper.dart';
import 'package:mivi/core/services/watchlist_service.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;
  final bool showFavoriteButton;

  const MovieCard({
    super.key,
    required this.movie,
    this.onTap,
    this.onFavoriteToggle,
    this.showFavoriteButton = true,
  });

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _hoverController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _elevationAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _borderAnimation;
  bool _isPressed = false;
  // ignore: unused_field
  bool _isHovered = false;
  bool _isInWatchlist = false;


  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    
    _elevationAnimation = Tween<double>(begin: 6.0, end: 20.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.01).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _borderAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    // Check watchlist status
    _checkWatchlistStatus();
  }

  void _checkWatchlistStatus() {
    setState(() {
      _isInWatchlist = WatchlistService.instance.isInWatchlist(widget.movie);
    });
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
      _isHovered = true;
    });
    _hoverController.forward();
    HapticUtils.movieTap();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    // Keep hover effect for a moment before reversing
    Future.delayed(const Duration(milliseconds: 150), () {
      if (mounted) {
        setState(() {
          _isHovered = false;
        });
        _hoverController.reverse();
      }
    });
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
      _isHovered = false;
    });
    _hoverController.reverse();
  }

  void _handleFavoriteToggle() {
    // Add haptic feedback before the action
    HapticUtils.favorite(isFavorite: !widget.movie.isFavorite);
    
    setState(() {
      if (widget.movie.isFavorite) {
        MockMovies.removeFromFavorites(widget.movie);
        ToastUtils.showInfo(
          context,
          '${widget.movie.title} removed from favorites',
          icon: Icons.favorite_border,
        );
      } else {
        MockMovies.addToFavorites(widget.movie);
        ToastUtils.showSuccess(
          context,
          '${widget.movie.title} added to favorites',
          icon: Icons.favorite,
        );
      }
    });
    
    // Also call the optional callback if provided
    widget.onFavoriteToggle?.call();
  }

  void _handleWatchlistToggle() async {
    // Add haptic feedback
    HapticUtils.selection();
    
    final success = await WatchlistService.instance.toggleWatchlist(widget.movie);
    
    if (success && mounted) {
      setState(() {
        _isInWatchlist = WatchlistService.instance.isInWatchlist(widget.movie);
      });

      if (_isInWatchlist) {
        ToastUtils.showSuccess(
          context,
          '${widget.movie.title} added to watchlist',
          icon: Icons.bookmark,
        );
      } else {
        ToastUtils.showInfo(
          context,
          '${widget.movie.title} removed from watchlist',
          icon: Icons.bookmark_border,
        );
      }
    }
  }

  Future<void> _showCategorySelector() async {
    HapticUtils.longPress();
    
    await FavoriteCategoryHelper.showCategorySelector(
      context,
      movieId: widget.movie.id,
      movieTitle: widget.movie.title,
      onCategoryChanged: () {
        // Refresh the widget if needed
        setState(() {});
        widget.onFavoriteToggle?.call();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return AnimatedBuilder(
      animation: _hoverController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Transform.rotate(
            angle: _rotationAnimation.value,
            child: GestureDetector(
              onTapDown: _onTapDown,
              onTapUp: _onTapUp,
              onTapCancel: _onTapCancel,
              onLongPress: _showCategorySelector,
              child: Container(
                width: 140,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      colorScheme.surface,
                      colorScheme.surface.withOpacity(0.95),
                    ],
                  ),
                  border: Border.all(
                    color: colorScheme.primary.withOpacity(_borderAnimation.value * 0.3),
                    width: 2 * _borderAnimation.value,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.15 * _borderAnimation.value),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value * 0.5),
                      spreadRadius: 2 * _borderAnimation.value,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value * 0.5,
                      offset: Offset(0, _elevationAnimation.value * 0.3),
                    ),
                    // Add a subtle inner glow effect
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.05 * _borderAnimation.value),
                      blurRadius: 2,
                      offset: const Offset(0, 0),
                      spreadRadius: -1,
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Movie Poster với thiết kế nâng cao
                    Stack(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                          child: Hero(
                            tag: 'movie_${widget.movie.id}',
                            child: Stack(
                              children: [
                                CachedNetworkImage(
                                  imageUrl: widget.movie.posterPath,
                                  height: 180,
                                  width: double.infinity,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.primary.withOpacity(0.1),
                                          colorScheme.secondary.withOpacity(0.1),
                                        ],
                                      ),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(12),
                                            decoration: BoxDecoration(
                                              color: colorScheme.primary.withOpacity(0.1),
                                              shape: BoxShape.circle,
                                            ),
                                            child: CircularProgressIndicator(
                                              color: colorScheme.primary,
                                              strokeWidth: 2.5,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            'Loading...',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: colorScheme.primary.withOpacity(0.7),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) => Container(
                                    height: 180,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                        colors: [
                                          colorScheme.surfaceVariant,
                                          colorScheme.surfaceVariant.withOpacity(0.7),
                                        ],
                                      ),
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(12),
                                          decoration: BoxDecoration(
                                            color: colorScheme.surfaceVariant.withOpacity(0.3),
                                            shape: BoxShape.circle,
                                          ),
                                          child: Icon(
                                            Icons.movie_outlined,
                                            size: 32,
                                            color: colorScheme.onSurfaceVariant.withOpacity(0.6),
                                          ),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          'No Image',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  memCacheWidth: 140,
                                  memCacheHeight: 180,
                                ),
                                // Gradient overlay for better text readability
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                        colors: [
                                          Colors.transparent,
                                          Colors.transparent,
                                          Colors.black.withOpacity(0.3),
                                          Colors.black.withOpacity(0.7),
                                        ],
                                        stops: const [0.0, 0.4, 0.7, 1.0],
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Watchlist button
                        if (widget.showFavoriteButton)
                          Positioned(
                            top: 12,
                            left: 12,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleWatchlistToggle(),
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      _isInWatchlist ? Icons.bookmark : Icons.bookmark_border,
                                      key: ValueKey(_isInWatchlist),
                                      color: _isInWatchlist ? Colors.blue.shade400 : Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Favorite button với thiết kế nâng cao
                        if (widget.showFavoriteButton)
                          Positioned(
                            top: 12,
                            right: 12,
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () => _handleFavoriteToggle(),
                                borderRadius: BorderRadius.circular(25),
                                child: Container(
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.black.withOpacity(0.8),
                                        Colors.black.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.2),
                                      width: 1.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.4),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 300),
                                    child: Icon(
                                      widget.movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      key: ValueKey(widget.movie.isFavorite),
                                      color: widget.movie.isFavorite ? Colors.red.shade400 : Colors.white,
                                      size: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        
                        // Enhanced rating overlay
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [
                                  Colors.black87,
                                  Colors.black54,
                                  Colors.transparent,
                                ],
                                stops: [0.0, 0.6, 1.0],
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Enhanced rating badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        Colors.amber.shade600,
                                        Colors.amber.shade400,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(15),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.4),
                                        blurRadius: 6,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.star_rounded,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        widget.movie.voteAverage.toStringAsFixed(1),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                // Enhanced duration badge
                                if (widget.movie.runtime > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Colors.white.withOpacity(0.2),
                                          Colors.white.withOpacity(0.1),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(15),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.3),
                                        width: 1,
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.access_time_rounded,
                                          color: Colors.white.withOpacity(0.9),
                                          size: 12,
                                        ),
                                        const SizedBox(width: 3),
                                        Text(
                                          widget.movie.formattedDuration,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(0.9),
                                            fontSize: 10,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        
                        // Enhanced pressed overlay effect
                        if (_isPressed)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    colorScheme.primary.withOpacity(0.2),
                                    colorScheme.primary.withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                              ),
                            ),
                          ),
                      ],
                    ),
                    
                    // Enhanced movie info section
                    Container(
                      height: 75, // Further optimized height for pagination
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colorScheme.surface,
                            colorScheme.surface.withOpacity(0.95),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Enhanced title typography
                          Expanded(
                            flex: 2,
                            child: Text(
                              widget.movie.title,
                              style: TextStyle(
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: colorScheme.onSurface,
                                height: 1.2,
                                letterSpacing: 0.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          
                          const SizedBox(height: 8),
                          
                          // Enhanced release year và genre badges
                          Expanded(
                            flex: 1,
                            child: Row(
                              children: [
                                // Enhanced release year badge
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        colorScheme.surfaceVariant.withOpacity(0.8),
                                        colorScheme.surfaceVariant.withOpacity(0.6),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: colorScheme.outline.withOpacity(0.2),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    widget.movie.releaseYear,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Enhanced genre badge
                                if (widget.movie.genres.isNotEmpty)
                                  Expanded(
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [
                                            colorScheme.primary.withOpacity(0.15),
                                            colorScheme.primary.withOpacity(0.1),
                                          ],
                                        ),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: colorScheme.primary.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        widget.movie.genres.first.name,
                                        style: TextStyle(
                                          fontSize: 9.5,
                                          fontWeight: FontWeight.w700,
                                          color: colorScheme.primary,
                                          letterSpacing: 0.2,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
} 