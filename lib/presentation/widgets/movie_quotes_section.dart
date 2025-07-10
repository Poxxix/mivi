import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:mivi/core/services/movie_quotes_service.dart';
import 'package:mivi/core/utils/haptic_utils.dart';
import 'package:mivi/core/utils/toast_utils.dart';

class MovieQuotesSection extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const MovieQuotesSection({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<MovieQuotesSection> createState() => _MovieQuotesSectionState();
}

class _MovieQuotesSectionState extends State<MovieQuotesSection>
    with SingleTickerProviderStateMixin {
  final MovieQuotesService _quotesService = MovieQuotesService.instance;
  final PageController _pageController = PageController();
  
  List<MovieQuote> _quotes = [];
  bool _isLoading = true;
  bool _hasError = false;
  int _currentQuoteIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadQuotes();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadQuotes() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final quotes = await _quotesService.getMovieQuotes(widget.movieId);
      setState(() {
        _quotes = quotes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  void _nextQuote() {
    if (_quotes.isEmpty) return;
    
    HapticUtils.selection();
    final nextIndex = (_currentQuoteIndex + 1) % _quotes.length;
    _pageController.animateToPage(
      nextIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousQuote() {
    if (_quotes.isEmpty) return;
    
    HapticUtils.selection();
    final prevIndex = (_currentQuoteIndex - 1 + _quotes.length) % _quotes.length;
    _pageController.animateToPage(
      prevIndex,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _shareQuote(MovieQuote quote) {
    HapticUtils.light();
    // In real app, implement sharing functionality
    ToastUtils.showInfo(
      context,
      'Quote shared!',
      icon: Icons.share,
    );
  }

  void _copyQuote(MovieQuote quote) {
    HapticUtils.light();
    // In real app, copy to clipboard
    ToastUtils.showSuccess(
      context,
      'Quote copied to clipboard',
      icon: Icons.copy,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_isLoading) {
      return _buildLoadingState(colorScheme);
    }

    if (_hasError || _quotes.isEmpty) {
      return _buildEmptyState(colorScheme);
    }

    return _buildQuotesSection(colorScheme);
  }

  Widget _buildLoadingState(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Movie Quotes',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading quotes...',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.format_quote,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Movie Quotes',
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Icon(
            Icons.format_quote_outlined,
            size: 48,
            color: colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No quotes available for this movie',
            style: TextStyle(
              color: colorScheme.onSurface.withOpacity(0.6),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: _loadQuotes,
            child: const Text('Try again'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuotesSection(ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(
                  Icons.format_quote,
                  color: colorScheme.primary,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Movie Quotes',
                        style: TextStyle(
                          color: colorScheme.onSurface,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_quotes.length} quote${_quotes.length != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (_quotes.length > 1) ...[
                  Text(
                    '${_currentQuoteIndex + 1} / ${_quotes.length}',
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          
          // Quote Content
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQuoteIndex = index;
                });
              },
              itemCount: _quotes.length,
              itemBuilder: (context, index) {
                final quote = _quotes[index];
                return _buildQuoteCard(quote, colorScheme);
              },
            ),
          ),
          
          // Navigation Controls
          if (_quotes.length > 1)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _previousQuote,
                    icon: Icon(
                      Icons.arrow_back_ios,
                      color: colorScheme.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceVariant,
                      shape: const CircleBorder(),
                    ),
                  ),
                  
                  // Quote dots indicator
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(
                      _quotes.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index == _currentQuoteIndex
                              ? colorScheme.primary
                              : colorScheme.onSurface.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  
                  IconButton(
                    onPressed: _nextQuote,
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      color: colorScheme.onSurface,
                    ),
                    style: IconButton.styleFrom(
                      backgroundColor: colorScheme.surfaceVariant,
                      shape: const CircleBorder(),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1);
  }

  Widget _buildQuoteCard(MovieQuote quote, ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quote text
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: colorScheme.primary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Center(
                child: Text(
                  '"${quote.quote}"',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Character and Actor info
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '— ${quote.character}',
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (quote.actor.isNotEmpty && quote.actor != 'Various')
                      Text(
                        quote.actor,
                        style: TextStyle(
                          color: colorScheme.onSurface.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Action buttons
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => _copyQuote(quote),
                    icon: Icon(
                      Icons.copy,
                      size: 20,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _shareQuote(quote),
                    icon: Icon(
                      Icons.share,
                      size: 20,
                      color: colorScheme.onSurface.withOpacity(0.7),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
} 