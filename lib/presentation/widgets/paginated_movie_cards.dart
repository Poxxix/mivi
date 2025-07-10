import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/presentation/widgets/movie_card.dart';

class PaginatedMovieCards extends StatefulWidget {
  final List<Movie> movies;
  final String title;
  final int cardsPerPage;

  const PaginatedMovieCards({
    super.key,
    required this.movies,
    this.title = "Movies",
    this.cardsPerPage = 3,
  });

  @override
  State<PaginatedMovieCards> createState() => _PaginatedMovieCardsState();
}

class _PaginatedMovieCardsState extends State<PaginatedMovieCards> {
  int _currentPage = 0;

  int get _totalPages => 
      widget.movies.isEmpty ? 0 : ((widget.movies.length - 1) ~/ widget.cardsPerPage) + 1;

  List<Movie> get _currentMovies {
    if (widget.movies.isEmpty) return [];
    
    final startIndex = _currentPage * widget.cardsPerPage;
    final endIndex = (startIndex + widget.cardsPerPage).clamp(0, widget.movies.length);
    
    return widget.movies.sublist(startIndex, endIndex);
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      setState(() {
        _currentPage++;
      });
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      setState(() {
        _currentPage--;
      });
    }
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

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.outline.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(
                  Icons.movie_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (_totalPages > 1) ...[
                  Text(
                    '${_currentPage + 1}/$_totalPages',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Movie Cards
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: SizedBox(
              height: 270, // Further reduced height to prevent overflow
              child: Row(
                children: _currentMovies.asMap().entries.map((entry) {
                  final index = entry.key;
                  final movie = entry.value;
                  
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(
                        right: index < _currentMovies.length - 1 ? 12 : 0,
                      ),
                      child: MovieCard(
                        movie: movie,
                        onTap: () => _onMovieTap(movie),
                        showFavoriteButton: false, // Simplified for chat
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          // Pagination Controls
          if (_totalPages > 1)
            Container(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous Button
                  Container(
                    decoration: BoxDecoration(
                      color: _currentPage > 0 
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _currentPage > 0 
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: InkWell(
                      onTap: _currentPage > 0 ? _previousPage : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.arrow_back_ios_rounded,
                              size: 16,
                              color: _currentPage > 0 
                                  ? colorScheme.primary 
                                  : colorScheme.onSurface.withOpacity(0.3),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Previous',
                              style: TextStyle(
                                color: _currentPage > 0 
                                    ? colorScheme.primary 
                                    : colorScheme.onSurface.withOpacity(0.3),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  
                  // Page dots indicator
                  Row(
                    children: List.generate(_totalPages, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: index == _currentPage ? 12 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: index == _currentPage 
                              ? colorScheme.primary 
                              : colorScheme.outline.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  
                  // Next Button
                  Container(
                    decoration: BoxDecoration(
                      color: _currentPage < _totalPages - 1 
                          ? colorScheme.primary.withOpacity(0.1)
                          : colorScheme.surfaceVariant.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _currentPage < _totalPages - 1 
                            ? colorScheme.primary.withOpacity(0.3)
                            : colorScheme.outline.withOpacity(0.2),
                      ),
                    ),
                    child: InkWell(
                      onTap: _currentPage < _totalPages - 1 ? _nextPage : null,
                      borderRadius: BorderRadius.circular(8),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Next',
                              style: TextStyle(
                                color: _currentPage < _totalPages - 1 
                                    ? colorScheme.primary 
                                    : colorScheme.onSurface.withOpacity(0.3),
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(
                              Icons.arrow_forward_ios_rounded,
                              size: 16,
                              color: _currentPage < _totalPages - 1 
                                  ? colorScheme.primary 
                                  : colorScheme.onSurface.withOpacity(0.3),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
} 