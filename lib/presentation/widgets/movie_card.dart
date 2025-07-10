import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mivi/data/models/movie_model.dart';

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
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _hoverController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
    
    _elevationAnimation = Tween<double>(begin: 4.0, end: 12.0).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );

    _rotationAnimation = Tween<double>(begin: 0.0, end: 0.02).animate(
      CurvedAnimation(parent: _hoverController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _hoverController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _hoverController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _hoverController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _hoverController.reverse();
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
      child: Container(
                width: 140,
                margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
        decoration: BoxDecoration(
                  color: colorScheme.surface,
                  borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                      color: colorScheme.primary.withOpacity(0.1),
                      blurRadius: _elevationAnimation.value,
                      offset: Offset(0, _elevationAnimation.value * 0.6),
                      spreadRadius: 1,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: _elevationAnimation.value * 0.5,
                      offset: Offset(0, _elevationAnimation.value * 0.3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    // Movie Poster với thiết kế cải thiện
            Stack(
              children: [
                ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: Hero(
                            tag: 'movie_${widget.movie.id}',
                            child: CachedNetworkImage(
                              imageUrl: widget.movie.posterPath,
                              height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                              placeholder: (context, url) => Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      colorScheme.surfaceVariant.withOpacity(0.3),
                                      colorScheme.surfaceVariant.withOpacity(0.1),
                                    ],
                                  ),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      CircularProgressIndicator(
                                        color: colorScheme.primary,
                                        strokeWidth: 2.5,
                                      ),
                                      const SizedBox(height: 12),
                                      Text(
                                        'Loading...',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => Container(
                                height: 200,
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
                                    Icon(
                                      Icons.movie_outlined,
                                      size: 40,
                                      color: colorScheme.onSurfaceVariant.withOpacity(0.6),
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
                              memCacheHeight: 200,
                            ),
                          ),
                        ),
                        
                        // Favorite button với thiết kế cải thiện
                        if (widget.showFavoriteButton)
                  Positioned(
                            top: 12,
                            right: 12,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                                onTap: widget.onFavoriteToggle,
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                                  padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.15),
                                      width: 1,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                  child: AnimatedSwitcher(
                                    duration: const Duration(milliseconds: 200),
                          child: Icon(
                                      widget.movie.isFavorite ? Icons.favorite : Icons.favorite_border,
                                      key: ValueKey(widget.movie.isFavorite),
                                      color: widget.movie.isFavorite ? Colors.red : Colors.white,
                                      size: 18,
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                        
                        // Rating overlay với thiết kế cải thiện
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                                  Colors.black.withOpacity(0.9),
                                  Colors.black.withOpacity(0.6),
                                  Colors.black.withOpacity(0.2),
                          Colors.transparent,
                        ],
                                stops: const [0.0, 0.5, 0.8, 1.0],
                      ),
                    ),
                    child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Rating với thiết kế đẹp hơn
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(12),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.amber.withOpacity(0.3),
                                        blurRadius: 4,
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
                                      const SizedBox(width: 3),
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
                                // Duration nếu có
                                if (widget.movie.runtime > 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.white.withOpacity(0.2),
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
                        
                        // Pressed overlay effect
                        if (_isPressed)
                          Positioned.fill(
                            child: Container(
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                  ),
                ),
              ],
            ),
                    
                    // Movie info section với thiết kế cải thiện
            Container(
              height: 80, // Fixed height để tránh overflow
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title với typography cải thiện
                  Expanded(
                    flex: 2,
                    child: Text(
                      widget.movie.title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                        height: 1.2,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  
                  const SizedBox(height: 6),
                  
                  // Release year và genre với thiết kế đẹp hơn
                  Expanded(
                    flex: 1,
                    child: Row(
                      children: [
                        // Release year
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: colorScheme.surfaceVariant.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            widget.movie.releaseYear,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Genre
                        if (widget.movie.genres.isNotEmpty)
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: colorScheme.primary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: colorScheme.primary.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Text(
                                widget.movie.genres.first.name,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w600,
                                  color: colorScheme.primary,
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