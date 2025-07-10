import 'dart:math';
import 'package:flutter/material.dart';
import 'package:mivi/data/models/chat_models.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/repositories/movie_repository.dart';

class AIChatService {
  final MovieRepository movieRepository;
  final Random _random = Random();

  AIChatService({required this.movieRepository});

  // Predefined quick actions for user convenience
  static const List<QuickAction> quickActions = [
    QuickAction(
      id: 'trending',
      label: 'Trending Movies',
      query: 'Show me trending movies',
      icon: Icons.trending_up,
    ),
    QuickAction(
      id: 'action',
      label: 'Action Movies',
      query: 'Recommend some action movies',
      icon: Icons.local_fire_department,
    ),
    QuickAction(
      id: 'comedy',
      label: 'Comedy Movies',
      query: 'I want to watch something funny',
      icon: Icons.mood,
    ),
    QuickAction(
      id: 'romantic',
      label: 'Romance Movies',
      query: 'Suggest romantic movies',
      icon: Icons.favorite,
    ),
    QuickAction(
      id: 'help',
      label: 'How to use',
      query: 'How do I use this app?',
      icon: Icons.help_outline,
    ),
  ];

  // Generate AI response based on user input
  Future<AIResponse> generateResponse(String userInput) async {
    final input = userInput.toLowerCase().trim();
    
    // Analyze user intent
    final intent = _analyzeIntent(input);
    
    switch (intent.type) {
      case IntentType.movieRecommendation:
        return await _handleMovieRecommendation(input, intent);
      case IntentType.movieSearch:
        return await _handleMovieSearch(input, intent);
      case IntentType.movieInfo:
        return await _handleMovieInfo(input, intent);
      case IntentType.help:
        return _handleHelp(input);
      case IntentType.greeting:
        return _handleGreeting();
      case IntentType.appNavigation:
        return _handleAppNavigation(input);
      default:
        return _handleGeneral(input);
    }
  }

  // Analyze user intent from input
  UserIntent _analyzeIntent(String input) {
    // Movie recommendation keywords
    if (_containsAny(input, [
      'recommend', 'suggest', 'want to watch', 'looking for',
      'show me', 'find me', 'good movie', 'best movie'
    ])) {
      return UserIntent(IntentType.movieRecommendation, _extractGenreFromInput(input));
    }

    // Movie search keywords
    if (_containsAny(input, ['search', 'find', 'look for', 'movie called'])) {
      return UserIntent(IntentType.movieSearch, null);
    }

    // Movie info keywords
    if (_containsAny(input, [
      'tell me about', 'what is', 'about movie', 'movie info',
      'plot', 'cast', 'director', 'release date'
    ])) {
      return UserIntent(IntentType.movieInfo, null);
    }

    // Help keywords
    if (_containsAny(input, ['help', 'how to', 'how do i', 'guide', 'tutorial'])) {
      return UserIntent(IntentType.help, null);
    }

    // Greeting keywords
    if (_containsAny(input, ['hi', 'hello', 'hey', 'good morning', 'good evening'])) {
      return UserIntent(IntentType.greeting, null);
    }

    // App navigation keywords
    if (_containsAny(input, ['go to', 'open', 'navigate', 'show', 'favorites', 'profile', 'search'])) {
      return UserIntent(IntentType.appNavigation, null);
    }

    return UserIntent(IntentType.general, null);
  }

  // Extract genre from user input
  String? _extractGenreFromInput(String input) {
    final genreMap = {
      'action': ['action', 'adventure', 'fight', 'thriller'],
      'comedy': ['comedy', 'funny', 'humor', 'laugh'],
      'drama': ['drama', 'emotional', 'serious'],
      'horror': ['horror', 'scary', 'fear', 'spooky'],
      'romance': ['romance', 'romantic', 'love', 'couple'],
      'sci-fi': ['sci-fi', 'science fiction', 'space', 'future'],
      'fantasy': ['fantasy', 'magic', 'supernatural'],
      'crime': ['crime', 'detective', 'mystery', 'police'],
    };

    for (final entry in genreMap.entries) {
      if (_containsAny(input, entry.value)) {
        return entry.key;
      }
    }
    return null;
  }

  // Handle movie recommendation requests
  Future<AIResponse> _handleMovieRecommendation(String input, UserIntent intent) async {
    List<Movie> recommendations = [];
    String response = '';

    try {
      if (intent.genre != null) {
        // Get movies by genre from API
        final allGenres = await movieRepository.getGenres();
        final genre = allGenres.firstWhere(
          (g) => g.name.toLowerCase().contains(intent.genre!),
          orElse: () => Genre(id: 28, name: 'Action'), // Default to Action
        );
        
        final genreMovies = await movieRepository.getMoviesByGenre(genre.id);
        recommendations = genreMovies.take(5).toList();
        response = "Here are some great ${intent.genre} movies I recommend:";
      } else if (_containsAny(input, ['trending', 'popular', 'hot'])) {
        recommendations = await movieRepository.getTrendingMovies();
        recommendations = recommendations.take(5).toList();
        response = "Here are the trending movies right now:";
      } else if (_containsAny(input, ['top rated', 'best', 'highest rated'])) {
        recommendations = await movieRepository.getTopRatedMovies();
        recommendations = recommendations.take(5).toList();
        response = "Here are the top-rated movies:";
      } else if (_containsAny(input, ['now playing', 'in theaters', 'current'])) {
        recommendations = await movieRepository.getNowPlayingMovies();
        recommendations = recommendations.take(5).toList();
        response = "Here are movies currently playing in theaters:";
      } else {
        // Popular movies as default
        recommendations = await movieRepository.getPopularMovies();
        recommendations = recommendations.take(5).toList();
        response = "Here are some popular movies you might enjoy:";
      }
    } catch (e) {
      // Fallback to error message if API fails
      return AIResponse(
        content: "Sorry, I'm having trouble fetching movie recommendations right now. Please try again later or check your internet connection.",
        suggestedActions: [
          const QuickAction(
            id: 'retry',
            label: 'Try Again',
            query: 'Show me some movies',
            icon: Icons.refresh,
          ),
        ],
      );
    }

    return AIResponse(
      content: response,
      movieRecommendations: recommendations,
      suggestedActions: [
        const QuickAction(
          id: 'more_like_this',
          label: 'More like this',
          query: 'Show me more similar movies',
          icon: Icons.refresh,
        ),
        const QuickAction(
          id: 'different_genre',
          label: 'Different genre',
          query: 'Suggest a different genre',
          icon: Icons.shuffle,
        ),
      ],
    );
  }

  // Handle movie search requests
  Future<AIResponse> _handleMovieSearch(String input, UserIntent intent) async {
    final searchTerm = _extractSearchTerm(input);
    
    if (searchTerm.isEmpty) {
      return const AIResponse(
        content: "What movie would you like me to search for? Just tell me the name!",
        suggestedActions: [
          QuickAction(
            id: 'search_action',
            label: 'Search Action Movies',
            query: 'Search for action movies',
            icon: Icons.search,
          ),
        ],
      );
    }

    try {
      final results = await movieRepository.searchMovies(searchTerm);
      final limitedResults = results.take(3).toList();

      if (limitedResults.isEmpty) {
        return AIResponse(
          content: "I couldn't find any movies matching '$searchTerm'. Try a different search term or let me recommend something for you!",
          suggestedActions: quickActions.take(3).toList(),
        );
      }

      return AIResponse(
        content: "Found ${limitedResults.length} movie(s) matching '$searchTerm':",
        movieRecommendations: limitedResults,
      );
    } catch (e) {
      return AIResponse(
        content: "Sorry, I'm having trouble searching for movies right now. Please try again later.",
        suggestedActions: [
          const QuickAction(
            id: 'retry_search',
            label: 'Try Again',
            query: 'Search for movies',
            icon: Icons.refresh,
          ),
        ],
      );
    }
  }

  // Handle movie information requests
  Future<AIResponse> _handleMovieInfo(String input, UserIntent intent) async {
    return const AIResponse(
      content: "I can help you learn about any movie! You can:\n\n"
              "• Tap on any movie card to see detailed information\n"
              "• Ask me to recommend movies by genre or mood\n"
              "• Search for specific movies\n"
              "• Browse trending and top-rated movies",
      suggestedActions: [
        QuickAction(
          id: 'trending_info',
          label: 'Trending Now',
          query: 'Show me trending movies',
          icon: Icons.trending_up,
        ),
        QuickAction(
          id: 'top_rated_info',
          label: 'Top Rated',
          query: 'Show me top rated movies',
          icon: Icons.star,
        ),
      ],
    );
  }

  // Handle help requests
  AIResponse _handleHelp(String input) {
    return AIResponse(
      content: "I'm your AI movie assistant! Here's how I can help:\n\n"
              "🎬 **Movie Recommendations**: Ask me to suggest movies by genre, mood, or preferences\n"
              "🔍 **Movie Search**: Tell me to find specific movies\n"
              "⭐ **Trending & Popular**: Get the latest trending and top-rated movies\n"
              "📱 **App Navigation**: I can guide you to different sections\n\n"
              "Try saying things like:\n"
              "• 'Recommend some action movies'\n"
              "• 'I want something funny'\n"
              "• 'Show me trending movies'\n"
              "• 'Find movies with Tom Hanks'",
      suggestedActions: quickActions.take(4).toList(),
    );
  }

  // Handle greeting
  AIResponse _handleGreeting() {
    final greetings = [
      "Hello! I'm your AI movie assistant. What kind of movies are you in the mood for today? 🎬",
      "Hi there! Ready to discover some amazing movies? Let me know what you're looking for! 🍿",
      "Hey! I'm here to help you find the perfect movie. What genre interests you? 🎭",
      "Welcome! I can recommend great movies based on your preferences. What sounds good? ✨",
    ];

    return AIResponse(
      content: greetings[_random.nextInt(greetings.length)],
      suggestedActions: quickActions.take(4).toList(),
    );
  }

  // Handle app navigation
  AIResponse _handleAppNavigation(String input) {
    if (_containsAny(input, ['favorites', 'liked', 'saved'])) {
      return const AIResponse(
        content: "To view your favorite movies, tap the 'Favorites' tab at the bottom of the screen ❤️",
      );
    }
    
    if (_containsAny(input, ['profile', 'account', 'settings'])) {
      return const AIResponse(
        content: "You can access your profile and settings by tapping the 'Profile' tab at the bottom 👤",
      );
    }
    
    if (_containsAny(input, ['search', 'find'])) {
      return const AIResponse(
        content: "To search for movies, tap the 'Search' tab at the bottom or the search icon in the top bar 🔍",
      );
    }

    return const AIResponse(
      content: "You can navigate using the bottom tabs:\n"
              "🏠 Home - Discover movies\n"
              "🔍 Search - Find specific movies\n"
              "❤️ Favorites - Your liked movies\n"
              "👤 Profile - Settings and account",
    );
  }

  // Handle general queries
  AIResponse _handleGeneral(String input) {
    final responses = [
      "I'm specialized in helping you with movies! Ask me for recommendations, search for films, or get information about trending movies. 🎬",
      "Let me help you discover amazing movies! Try asking for recommendations by genre or mood. 🍿",
      "I'm your movie expert! I can suggest films, help you search, or show you what's trending. What interests you? 🎭",
    ];

    return AIResponse(
      content: responses[_random.nextInt(responses.length)],
      suggestedActions: quickActions.take(3).toList(),
    );
  }

  // Helper methods
  bool _containsAny(String text, List<String> keywords) {
    return keywords.any((keyword) => text.contains(keyword));
  }

  String _extractSearchTerm(String input) {
    // Simple extraction - in real app, use more sophisticated NLP
    final words = input.split(' ');
    final stopWords = ['search', 'find', 'look', 'for', 'movie', 'called', 'the', 'a', 'an'];
    return words.where((word) => !stopWords.contains(word.toLowerCase())).join(' ');
  }
}

// Intent classification
enum IntentType {
  movieRecommendation,
  movieSearch,
  movieInfo,
  help,
  greeting,
  appNavigation,
  general,
}

class UserIntent {
  final IntentType type;
  final String? genre;

  UserIntent(this.type, this.genre);
} 