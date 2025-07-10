import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/repositories/movie_repository.dart';
import 'package:mivi/presentation/blocs/movie_bloc.dart';

import 'package:mivi/presentation/widgets/skeleton_widgets.dart';
import 'package:mivi/core/services/search_history_service.dart';
import 'package:mivi/core/utils/haptic_utils.dart';

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
  List<String> _searchHistory = [];
  List<String> _searchSuggestions = [];

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
    
    // Initialize search history
    _initializeSearchHistory();
    
    _animationController.forward();
  }

  void _onMovieTap(Movie movie) {
    context.push('/movie/${movie.id}', extra: movie);
  }

  Future<void> _initializeSearchHistory() async {
    await SearchHistoryService.instance.initialize();
    setState(() {
      _searchHistory = SearchHistoryService.instance.searchHistory;
    });
  }

  void _updateSearchSuggestions(String query) {
    setState(() {
      _searchSuggestions = SearchHistoryService.instance.getSuggestions(query);
    });
  }

  Future<void> _addToSearchHistory(String query) async {
    await SearchHistoryService.instance.addSearch(query);
    setState(() {
      _searchHistory = SearchHistoryService.instance.searchHistory;
    });
  }

  Future<void> _removeFromSearchHistory(String query) async {
    await SearchHistoryService.instance.removeSearch(query);
    setState(() {
      _searchHistory = SearchHistoryService.instance.searchHistory;
      _searchSuggestions = SearchHistoryService.instance.getSuggestions(_query);
    });
  }

  Future<void> _clearSearchHistory() async {
    await SearchHistoryService.instance.clearAll();
    setState(() {
      _searchHistory = [];
      _searchSuggestions = [];
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });

    // Update search suggestions
    _updateSearchSuggestions(value);

    // Debounce search to avoid too many API calls
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (value.trim().isNotEmpty) {
        _searchBloc.add(SearchMovies(value.trim()));
        // Add to search history when actually searching
        _addToSearchHistory(value.trim());
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
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
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
                    color: colorScheme.background,
                    boxShadow: [
                      BoxShadow(
                        color: colorScheme.surface.withOpacity(0.1),
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
                              color: colorScheme.surfaceVariant.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.arrow_back_rounded,
                                color: colorScheme.onBackground,
                              ),
                              onPressed: () => context.pop(),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text(
                            'Search Movies',
                            style: TextStyle(
                              color: colorScheme.onBackground,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Enhanced Search Field with Suggestions
                      Stack(
                        children: [
                          Container(
                        decoration: BoxDecoration(
                          color: colorScheme.surfaceVariant.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: colorScheme.surfaceVariant.withOpacity(0.2),
                          ),
                        ),
                        child: TextField(
                          controller: _controller,
                          style: TextStyle(color: colorScheme.onBackground),
                          autofocus: true,
                          decoration: InputDecoration(
                            hintText: 'Search for movies...',
                            hintStyle: TextStyle(
                              color: colorScheme.onBackground.withOpacity(0.5),
                            ),
                            prefixIcon: Icon(
                              Icons.search_rounded,
                              color: colorScheme.primary,
                              size: 24,
                            ),
                            suffixIcon: _query.isNotEmpty
                                ? IconButton(
                                    icon: Icon(
                                      Icons.clear_rounded,
                                      color: colorScheme.onBackground.withOpacity(0.7),
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
                          // Search Suggestions Dropdown
                          if (_query.isNotEmpty && _searchSuggestions.isNotEmpty)
                            Positioned(
                              top: 60,
                              left: 0,
                              right: 0,
                              child: _buildSuggestionsDropdown(context),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // Search Results
              Expanded(
                child: _query.isEmpty
                    ? _buildEmptyState(context)
                    : _buildSearchResults(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SlideTransition(
      position: _slideAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
          child: Column(
            children: [
            const SizedBox(height: 40),
            // Search Icon with Animation
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.search_rounded,
                size: 64,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 32),
              Text(
              'Discover Amazing Movies',
                style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
              'Search for your favorite movies, actors, or genres\nand find something amazing to watch tonight.',
                style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.7),
                  fontSize: 16,
                height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            const SizedBox(height: 40),
            _buildRecentSearches(context),
            ],
        ),
      ),
    );
  }

  Widget _buildRecentSearches(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    // Show recent searches if available, otherwise show popular suggestions
    final searchItems = _searchHistory.isNotEmpty 
        ? _searchHistory
        : [
            'Marvel', 'DC Comics', 'Horror', 'Comedy', 'Action',
            'Drama', 'Sci-Fi', 'Romance', 'Thriller', 'Animation'
          ];
    
    final title = _searchHistory.isNotEmpty ? 'Recent Searches' : 'Popular Searches';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_searchHistory.isNotEmpty)
              TextButton(
                onPressed: _clearSearchHistory,
                child: Text(
                  'Clear All',
                  style: TextStyle(
                    color: colorScheme.primary,
                    fontSize: 14,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        if (searchItems.isEmpty)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: colorScheme.surfaceVariant.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'No recent searches',
                style: TextStyle(
                  color: colorScheme.onBackground.withOpacity(0.6),
                  fontSize: 14,
                ),
              ),
            ),
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: searchItems.map((search) {
              return GestureDetector(
                onTap: () {
                  HapticUtils.search();
                  _controller.text = search;
                  _onSearchChanged(search);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceVariant.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: colorScheme.surfaceVariant.withOpacity(0.2),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _searchHistory.contains(search) 
                            ? Icons.history 
                            : Icons.trending_up,
                        size: 14,
                        color: colorScheme.onBackground.withOpacity(0.6),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        search,
                        style: TextStyle(
                          color: colorScheme.onBackground,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (_searchHistory.contains(search)) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () {
                            HapticUtils.light();
                            _removeFromSearchHistory(search);
                          },
                          child: Icon(
                            Icons.close,
                            size: 14,
                            color: colorScheme.onBackground.withOpacity(0.5),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildSuggestionsDropdown(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: colorScheme.surfaceVariant.withOpacity(0.2),
        ),
      ),
      child: ListView.builder(
        padding: EdgeInsets.zero,
        shrinkWrap: true,
        itemCount: _searchSuggestions.length,
        itemBuilder: (context, index) {
          final suggestion = _searchSuggestions[index];
          
          return InkWell(
            onTap: () {
              HapticUtils.search();
              _controller.text = suggestion;
              _onSearchChanged(suggestion);
              setState(() {
                _searchSuggestions = [];
              });
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                border: index < _searchSuggestions.length - 1
                    ? Border(
                        bottom: BorderSide(
                          color: colorScheme.surfaceVariant.withOpacity(0.2),
                        ),
                      )
                    : null,
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.history,
                    size: 16,
                    color: colorScheme.onBackground.withOpacity(0.6),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        children: _buildHighlightedText(
                          suggestion,
                          _query,
                          colorScheme,
                        ),
                      ),
                    ),
                  ),
                  Icon(
                    Icons.north_west,
                    size: 16,
                    color: colorScheme.onBackground.withOpacity(0.4),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  List<TextSpan> _buildHighlightedText(
    String text,
    String query,
    ColorScheme colorScheme,
  ) {
    if (query.isEmpty) {
      return [
        TextSpan(
          text: text,
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 14,
          ),
        ),
      ];
    }

    final lowercaseText = text.toLowerCase();
    final lowercaseQuery = query.toLowerCase();
    final spans = <TextSpan>[];
    
    int start = 0;
    int index = lowercaseText.indexOf(lowercaseQuery);
    
    while (index != -1) {
      // Add text before the match
      if (index > start) {
        spans.add(
          TextSpan(
            text: text.substring(start, index),
            style: TextStyle(
              color: colorScheme.onBackground,
              fontSize: 14,
            ),
          ),
        );
      }
      
      // Add highlighted match
      spans.add(
        TextSpan(
          text: text.substring(index, index + query.length),
          style: TextStyle(
            color: colorScheme.primary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      );
      
      start = index + query.length;
      index = lowercaseText.indexOf(lowercaseQuery, start);
    }
    
    // Add remaining text
    if (start < text.length) {
      spans.add(
        TextSpan(
          text: text.substring(start),
          style: TextStyle(
            color: colorScheme.onBackground,
            fontSize: 14,
          ),
        ),
      );
    }
    
    return spans;
  }

  Widget _buildSearchResults(BuildContext context) {
    // ignore: unused_local_variable
    final colorScheme = Theme.of(context).colorScheme;
    
    return BlocBuilder<MovieBloc, MovieState>(
      bloc: _searchBloc,
      builder: (context, state) {
        if (state is MovieLoading) {
          return _buildLoadingState(context);
        } else if (state is MovieLoaded) {
          if (state.movies.isEmpty) {
            return _buildNoResultsState(context);
          }
          return _buildResultsList(context, state.movies);
        } else if (state is MovieError) {
          return _buildErrorState(context, state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 20),
          Text(
            'Searching...',
            style: TextStyle(
              color: colorScheme.onBackground,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
                      Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: 6,
                itemBuilder: (context, index) {
                  return SkeletonWidgets.movieCardSkeleton(context, width: 160, height: 240);
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildNoResultsState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
                Icons.search_off_rounded,
              size: 80,
              color: colorScheme.onBackground.withOpacity(0.5),
            ),
            const SizedBox(height: 24),
            Text(
              'No Results Found',
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'We couldn\'t find any movies matching "$_query".\nTry searching with different keywords.',
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _clearSearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsList(BuildContext context, List<Movie> movies) {
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
              'Found ${movies.length} result${movies.length == 1 ? '' : 's'}',
            style: TextStyle(
                color: Theme.of(context).colorScheme.onBackground,
              fontSize: 18,
                fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.65,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
              itemCount: movies.length,
              itemBuilder: (context, index) {
                final movie = movies[index];
                  return GestureDetector(
                    onTap: () => _onMovieTap(movie),
                    child: _buildMovieCard(context, movie),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMovieCard(BuildContext context, Movie movie) {
    final colorScheme = Theme.of(context).colorScheme;
    
                return Container(
                  decoration: BoxDecoration(
        color: colorScheme.surface,
                    borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
                  ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                      child: Image.network(
                        movie.posterPath,
                width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                    width: double.infinity,
                    color: colorScheme.surfaceVariant,
                            child: Icon(
                              Icons.movie,
                      size: 48,
                      color: colorScheme.onSurfaceVariant,
                            ),
                          );
                        },
                      ),
                    ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                      movie.title,
                      style: TextStyle(
                    color: colorScheme.onSurface,
                        fontWeight: FontWeight.bold,
                    fontSize: 14,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                    ),
                        const SizedBox(height: 4),
                        Text(
                          movie.releaseYear,
                          style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 12,
                              ),
                            ),
                          ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, String message) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return SlideTransition(
      position: _slideAnimation,
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: colorScheme.error,
            ),
            const SizedBox(height: 24),
            Text(
              'Search Error',
              style: TextStyle(
                color: colorScheme.onBackground,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              style: TextStyle(
                color: colorScheme.onBackground.withOpacity(0.7),
                fontSize: 16,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _onSearchChanged(_query),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry Search'),
            ),
          ],
        ),
      ),
    );
  }
}
