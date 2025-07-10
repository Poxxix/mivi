import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mivi/data/models/chat_models.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/repositories/movie_repository.dart';

enum GeminiModel {
  flash('gemini-1.5-flash', 'Fast & Efficient'),
  pro('gemini-1.5-pro', 'Smart & Detailed'),
  experimental('gemini-2.0-flash-exp', 'Latest Features');

  const GeminiModel(this.modelId, this.description);
  final String modelId;
  final String description;
}

class GeminiAIService {
  final MovieRepository movieRepository;
  final Random _random = Random();
  
  // TODO: Get your FREE Gemini API key from https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyDbS539Ijab-f1-02if85Ov34A4ysCfXfs';
  
  // Current model configuration
  static GeminiModel currentModel = GeminiModel.pro; // Default to Pro
  
  late final GenerativeModel _model;

  GeminiAIService({required this.movieRepository}) {
    _model = GenerativeModel(
      model: currentModel.modelId, // Use selected model
      apiKey: _apiKey,
      generationConfig: GenerationConfig(
        temperature: 0.7, // Balanced creativity vs accuracy
        topK: 40,
        topP: 0.95,
        maxOutputTokens: 2048,
      ),
      safetySettings: [
        SafetySetting(HarmCategory.harassment, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.hateSpeech, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.sexuallyExplicit, HarmBlockThreshold.medium),
        SafetySetting(HarmCategory.dangerousContent, HarmBlockThreshold.medium),
      ],
    );
  }

  // Method to switch models dynamically
  static void switchModel(GeminiModel newModel) {
    currentModel = newModel;
    print('🔄 Switched to ${newModel.modelId} (${newModel.description})');
  }

  // Get current model info
  static String getCurrentModelInfo() {
    return '${currentModel.modelId} - ${currentModel.description}';
  }

  // Enhanced system prompt for Gemini Pro
  static const String _systemPrompt = '''
You are MIVI's intelligent movie recommendation assistant. You help users discover great movies through natural conversation.

CORE CAPABILITIES:
• Movie recommendations (trending, popular, by genre, by actor)
• Movie information and details
• Personalized suggestions based on preferences
• Answer questions about films, actors, and cinema

RESPONSE GUIDELINES:
• Be conversational, friendly, and enthusiastic about movies
• When users ask for recommendations, provide helpful context about the movies
• Use emojis to make responses more engaging
• Keep responses concise but informative
• Always be encouraging and help users discover new films

MOVIE CATEGORIES YOU CAN RECOMMEND:
• Trending movies (current popular films)
• Popular movies (all-time favorites)
• Top rated movies (critically acclaimed)
• By genre: Action, Comedy, Horror, Drama, Romance, Thriller, Sci-Fi, Fantasy, Animation, Adventure
• By specific actors or directors
• Surprise recommendations

EXAMPLE INTERACTIONS:
User: "I want action movies"
You: "🎬 Perfect! Action movies are my favorite to recommend. Here are some amazing action-packed films that will keep you on the edge of your seat!"

User: "Show me something funny"
You: "😂 Comedy time! I've got some hilarious movies that will definitely make you laugh out loud. These are crowd favorites!"

User: "What's trending?"
You: "🔥 Here's what everyone's talking about right now! These trending movies are absolutely worth watching."

Remember: When recommending movies, be enthusiastic and provide context. The app will automatically show movie cards with your recommendations.
''';

  // Quick actions for convenience
  static const List<QuickAction> quickActions = [
    QuickAction(
      id: 'trending',
      label: 'Trending Now',
      query: 'Show me trending movies',
      icon: Icons.trending_up,
    ),
    QuickAction(
      id: 'action',
      label: 'Action Movies',
      query: 'Recommend action movies',
      icon: Icons.local_fire_department,
    ),
    QuickAction(
      id: 'comedy',
      label: 'Comedy Films',
      query: 'I want something funny',
      icon: Icons.mood,
    ),
    QuickAction(
      id: 'surprise',
      label: 'Surprise Me',
      query: 'Surprise me with a good movie',
      icon: Icons.shuffle,
    ),
  ];

  // Main method to generate AI response with guaranteed success
  Future<AIResponse> generateResponse(String userInput) async {
    try {
      print('🤖 Gemini Input: "$userInput"');
      
      final content = [
        Content.text('$_systemPrompt\n\nUser: $userInput\nAssistant:')
      ];
      
      // Add timeout to prevent hanging
      final response = await _model.generateContent(content).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          print('⏰ Gemini API timeout');
          throw TimeoutException('Gemini API timeout', const Duration(seconds: 10));
        },
      );
      
      final aiText = response.text ?? '';
      
      print('🧠 Gemini Response: "$aiText"');
      
      // Parse Gemini response and take action
      return await _parseGeminiResponse(aiText, userInput);
    } catch (e) {
      print('❌ Gemini Error: $e');
      
      // Direct fallback to smart recommendation without Gemini
      return await _handleDirectFallback(userInput);
    }
  }

  // Direct fallback when Gemini is unavailable
  Future<AIResponse> _handleDirectFallback(String userInput) async {
    print('🔄 Using direct fallback for: "$userInput"');
    
    // Detect if this is a recommendation request
    if (_shouldShowMovieRecommendations(userInput, '')) {
      return await _handleSmartRecommendation(userInput, _getDefaultResponseMessage(userInput));
    } else {
      return _handleDirectResponse(_getDefaultResponseMessage(userInput), userInput);
    }
  }

  // Get default response message when Gemini is unavailable
  String _getDefaultResponseMessage(String userInput) {
    if (userInput.contains('trending')) {
      return "🔥 Here are the hottest trending movies right now!";
    } else if (userInput.contains('action')) {
      return "💥 Get ready for some adrenaline! Here are amazing action movies:";
    } else if (userInput.contains('comedy') || userInput.contains('funny')) {
      return "😂 Time to laugh! Here are hilarious comedy movies:";
    } else if (userInput.contains('surprise')) {
      return "🎲 Surprise time! Here's a wonderful mix of movies for you:";
    } else {
      return "🎬 Here are some fantastic movies I recommend for you!";
    }
  }

  // Parse Gemini response and execute appropriate actions
  Future<AIResponse> _parseGeminiResponse(String aiText, String originalInput) async {
    final text = aiText.toLowerCase();
    final input = originalInput.toLowerCase();

    // Handle specific commands from Gemini
    if (text.contains('recommend:')) {
      return await _handleRecommendCommand(aiText);
    } else if (text.contains('search:')) {
      return await _handleSearchCommand(aiText);
    } 
    // Smart detection of recommendation requests
    else if (_shouldShowMovieRecommendations(input, text)) {
      return await _handleSmartRecommendation(input, aiText);
    } else {
      // Direct text response with smart suggestions
      return _handleDirectResponse(aiText, originalInput);
    }
  }

  // Smart detection for when to show movie recommendations
  bool _shouldShowMovieRecommendations(String userInput, String aiResponse) {
    final recommendKeywords = [
      'recommend', 'suggest', 'show me', 'find', 'watch',
      'movies', 'films', 'trending', 'popular', 'top rated',
      'action', 'comedy', 'horror', 'drama', 'romance', 'thriller',
      'sci-fi', 'fantasy', 'adventure', 'animation',
      'actor', 'director', 'genre', 'surprise me'
    ];
    
    final responseKeywords = [
      'here are', 'i recommend', 'you should watch', 'check out',
      'great movies', 'perfect for you', 'trending', 'popular'
    ];
    
    bool inputMatches = recommendKeywords.any((keyword) => userInput.contains(keyword));
    bool responseMatches = responseKeywords.any((keyword) => aiResponse.contains(keyword));
    
    return inputMatches || responseMatches;
  }

  // Handle smart recommendations based on natural language with 100% success guarantee
  Future<AIResponse> _handleSmartRecommendation(String userInput, String aiText) async {
    List<Movie> movies = [];
    String response = aiText;

    try {
      // Priority-based recommendation logic with multiple fallbacks
      movies = await _getMoviesWithFallback(userInput);
      
      // If no movies found, guarantee response with trending
      if (movies.isEmpty) {
        movies = await _getMoviesWithFallback('trending');
      }
      
      // Final fallback - use mock data if all APIs fail
      if (movies.isEmpty) {
        movies = _getMockMovies(userInput);
        response = "🎬 Here are some great ${_getGenreFromInput(userInput)} movies I recommend! (Showing curated selection)";
      }

      return AIResponse(
        content: response,
        movieRecommendations: movies.take(6).toList(),
        suggestedActions: _getContextualActions(userInput),
      );
    } catch (e) {
      print('❌ Smart recommendation error: $e');
      // Guarantee fallback with mock movies
      return AIResponse(
        content: "🎬 Here are some fantastic movies I recommend for you!",
        movieRecommendations: _getMockMovies(userInput),
        suggestedActions: quickActions,
      );
    }
  }

  // Get movies with multiple fallback strategies
  Future<List<Movie>> _getMoviesWithFallback(String userInput) async {
    // Primary strategy: match exact intent
    try {
      if (userInput.contains('trending') || userInput.contains('popular now')) {
        return await movieRepository.getTrendingMovies();
      } else if (userInput.contains('popular')) {
        return await movieRepository.getPopularMovies();
      } else if (userInput.contains('top rated') || userInput.contains('best')) {
        return await movieRepository.getTopRatedMovies();
      } else if (userInput.contains('action')) {
        return await movieRepository.getMoviesByGenre(28); // Action
      } else if (userInput.contains('comedy') || userInput.contains('funny')) {
        return await movieRepository.getMoviesByGenre(35); // Comedy
      } else if (userInput.contains('horror') || userInput.contains('scary')) {
        return await movieRepository.getMoviesByGenre(27); // Horror
      } else if (userInput.contains('romance') || userInput.contains('love')) {
        return await movieRepository.getMoviesByGenre(10749); // Romance
      } else if (userInput.contains('drama')) {
        return await movieRepository.getMoviesByGenre(18); // Drama
      } else if (userInput.contains('thriller')) {
        return await movieRepository.getMoviesByGenre(53); // Thriller
      } else if (userInput.contains('sci-fi') || userInput.contains('science fiction')) {
        return await movieRepository.getMoviesByGenre(878); // Sci-Fi
      } else if (userInput.contains('fantasy')) {
        return await movieRepository.getMoviesByGenre(14); // Fantasy
      } else if (userInput.contains('animation') || userInput.contains('animated')) {
        return await movieRepository.getMoviesByGenre(16); // Animation
      } else if (userInput.contains('adventure')) {
        return await movieRepository.getMoviesByGenre(12); // Adventure
      } else if (userInput.contains('surprise')) {
        // For "surprise me", mix different categories
        final allCategories = [
          movieRepository.getTrendingMovies(),
          movieRepository.getPopularMovies(),
          movieRepository.getTopRatedMovies(),
        ];
        final results = await Future.wait(allCategories);
        final combined = results.expand((list) => list).toList();
        combined.shuffle(_random);
        return combined;
      } else {
        // Default to trending for general requests
        return await movieRepository.getTrendingMovies();
      }
    } catch (e) {
      print('❌ Primary strategy failed: $e');
      
      // Secondary strategy: try trending
      try {
        return await movieRepository.getTrendingMovies();
      } catch (e2) {
        print('❌ Secondary strategy failed: $e2');
        
        // Tertiary strategy: try popular
        try {
          return await movieRepository.getPopularMovies();
        } catch (e3) {
          print('❌ Tertiary strategy failed: $e3');
          return [];
        }
      }
    }
  }

  // Get genre name from input for fallback messages
  String _getGenreFromInput(String input) {
    if (input.contains('action')) return 'action';
    if (input.contains('comedy') || input.contains('funny')) return 'comedy';
    if (input.contains('horror') || input.contains('scary')) return 'horror';
    if (input.contains('romance') || input.contains('love')) return 'romance';
    if (input.contains('drama')) return 'drama';
    if (input.contains('thriller')) return 'thriller';
    if (input.contains('sci-fi') || input.contains('science fiction')) return 'sci-fi';
    if (input.contains('fantasy')) return 'fantasy';
    if (input.contains('animation') || input.contains('animated')) return 'animation';
    if (input.contains('adventure')) return 'adventure';
    return 'popular';
  }

  // Get contextual actions based on user input
  List<QuickAction> _getContextualActions(String userInput) {
    if (userInput.contains('action')) {
      return [
        quickActions[0], // Trending
        quickActions[2], // Comedy (different genre)
        quickActions[3], // Surprise
      ];
    } else if (userInput.contains('comedy')) {
      return [
        quickActions[0], // Trending  
        quickActions[1], // Action (different genre)
        quickActions[3], // Surprise
      ];
    } else {
      return quickActions;
    }
  }

  // Mock movies as final fallback
  List<Movie> _getMockMovies(String userInput) {
    // Return genre-appropriate mock movies
    if (userInput.contains('action')) {
      return _getActionMockMovies();
    } else if (userInput.contains('comedy') || userInput.contains('funny')) {
      return _getComedyMockMovies();
    } else if (userInput.contains('horror') || userInput.contains('scary')) {
      return _getHorrorMockMovies();
    } else {
      return _getTrendingMockMovies();
    }
  }

  List<Movie> _getActionMockMovies() {
    return [
      Movie(
        id: 99001,
        title: "The Dark Knight",
        overview: "Batman faces the Joker in this epic superhero thriller.",
        posterPath: "/qJ2tW6WMUDux911r6m7haRef0WH.jpg",
        backdropPath: "/hkBaDkMWbLaf8B1lsWsKX7Ew3Xq.jpg",
        releaseDate: "2008-07-18",
        voteAverage: 9.0,
        genres: [Genre(id: 28, name: 'Action')],
      ),
      Movie(
        id: 99002,
        title: "Mad Max: Fury Road",
        overview: "A post-apocalyptic action extravaganza.",
        posterPath: "/hA2ple9q4qnwxp3hKVNhroipsir.jpg",
        backdropPath: "/tbhdm8UJAb4ViCTsulYFL3lxMCd.jpg",
        releaseDate: "2015-05-15",
        voteAverage: 8.1,
        genres: [Genre(id: 28, name: 'Action')],
      ),
      Movie(
        id: 99003,
        title: "John Wick",
        overview: "An ex-hitman comes out of retirement.",
        posterPath: "/fZPSd91yGE9fCcCe6OoQr6E3Bev.jpg",
        backdropPath: "/umC04Cozevu8nn3JTDJ1pc7PVTn.jpg",
        releaseDate: "2014-10-24",
        voteAverage: 7.4,
        genres: [Genre(id: 28, name: 'Action')],
      ),
    ];
  }

  List<Movie> _getComedyMockMovies() {
    return [
      Movie(
        id: 99004,
        title: "The Hangover",
        overview: "A wild bachelor party gone wrong.",
        posterPath: "/cs36gPb5OTOlrCK0ZuRN0Maw7Vg.jpg",
        backdropPath: "/9Fz7qQT1I5qXKIqASqtcY8VzDny.jpg",
        releaseDate: "2009-06-05",
        voteAverage: 7.7,
        genres: [Genre(id: 35, name: 'Comedy')],
      ),
      Movie(
        id: 99005,
        title: "Superbad",
        overview: "Two high school best friends navigate senior year.",
        posterPath: "/ek8e8txUyUwd2BNqj6lFEerJfbq.jpg",
        backdropPath: "/fGGFL1aOqn6XF28VCIDupEq5CcJ.jpg",
        releaseDate: "2007-08-17",
        voteAverage: 7.6,
        genres: [Genre(id: 35, name: 'Comedy')],
      ),
    ];
  }

  List<Movie> _getHorrorMockMovies() {
    return [
      Movie(
        id: 99006,
        title: "Get Out",
        overview: "A young African-American visits his white girlfriend's family estate.",
        posterPath: "/1SwAVYpuLj8KsHxllTF8Dpsx7xD.jpg",
        backdropPath: "/aHntZkuiElgOtbQk5nEKcaOZkCF.jpg",
        releaseDate: "2017-02-24",
        voteAverage: 7.7,
        genres: [Genre(id: 27, name: 'Horror')],
      ),
    ];
  }

  List<Movie> _getTrendingMockMovies() {
    return [
      Movie(
        id: 99007,
        title: "Avatar: The Way of Water",
        overview: "Jake Sully and Neytiri's family face new challenges.",
        posterPath: "/t6HIqrRAclMCA60NsSmeqe9RmNV.jpg",
        backdropPath: "/ovM06PdF3M8wvKb06i4sjW3xoww.jpg",
        releaseDate: "2022-12-16",
        voteAverage: 7.6,
        genres: [Genre(id: 878, name: 'Science Fiction')],
      ),
      Movie(
        id: 99008,
        title: "Top Gun: Maverick",
        overview: "Pete 'Maverick' Mitchell returns to Top Gun.",
        posterPath: "/62HCnUTziyWcpDaBO2i1DX17ljH.jpg",
        backdropPath: "/odJ4hx6g6vBt4lBWKFD1tI8WS4x.jpg",
        releaseDate: "2022-05-27",
        voteAverage: 8.3,
        genres: [Genre(id: 28, name: 'Action')],
      ),
    ];
  }

  // Handle recommendation commands with guaranteed success
  Future<AIResponse> _handleRecommendCommand(String aiText) async {
    try {
      final command = aiText.split('RECOMMEND:')[1].trim();
      List<Movie> movies = [];
      String response = '';

      if (command.contains('trending')) {
        movies = await _getMoviesWithFallback('trending');
        response = '🔥 Here are the hottest trending movies right now:';
      } else if (command.contains('popular')) {
        movies = await _getMoviesWithFallback('popular');
        response = '⭐ Here are some popular movies you might enjoy:';
      } else if (command.contains('top_rated')) {
        movies = await _getMoviesWithFallback('top rated');
        response = '🏆 Here are the highest-rated movies:';
      } else if (command.contains('actor:')) {
        final actor = command.split('actor:')[1].trim();
        try {
          movies = await movieRepository.searchMovies(actor);
          response = 'Here are movies featuring $actor:';
        } catch (e) {
          movies = _getTrendingMockMovies();
          response = 'I couldn\'t search for $actor right now, but here are some great movies:';
        }
      } else {
        // Genre-based recommendation with fallback
        final genre = command.toLowerCase();
        try {
          final allGenres = await movieRepository.getGenres();
          final matchedGenre = allGenres.firstWhere(
            (g) => g.name.toLowerCase().contains(genre),
            orElse: () => Genre(id: 28, name: 'Action'),
          );
          movies = await movieRepository.getMoviesByGenre(matchedGenre.id);
          response = 'Here are some great ${matchedGenre.name.toLowerCase()} movies:';
        } catch (e) {
          movies = _getMockMovies(genre);
          response = 'Here are some great $genre movies from my curated collection:';
        }
      }

      // Final fallback if no movies found
      if (movies.isEmpty) {
        movies = _getTrendingMockMovies();
        response = '🎬 Here are some fantastic movies I recommend:';
      }

      return AIResponse(
        content: response,
        movieRecommendations: movies.take(5).toList(),
        suggestedActions: quickActions.take(3).toList(),
      );
    } catch (e) {
      return _handleAPIError();
    }
  }

  // Handle search commands with guaranteed results
  Future<AIResponse> _handleSearchCommand(String aiText) async {
    try {
      final searchTerm = aiText.split('SEARCH:')[1].trim();
      List<Movie> results = [];
      
      try {
        results = await movieRepository.searchMovies(searchTerm);
      } catch (e) {
        print('❌ Search API failed: $e');
        // Fallback to mock results based on search term
        results = _getSearchMockResults(searchTerm);
      }
      
      if (results.isEmpty) {
        return AIResponse(
          content: "I couldn't find any movies matching '$searchTerm', but here are some popular movies you might enjoy instead:",
          movieRecommendations: _getTrendingMockMovies(),
          suggestedActions: quickActions.take(3).toList(),
        );
      }

      return AIResponse(
        content: "Found ${results.length} result(s) for '$searchTerm':",
        movieRecommendations: results.take(4).toList(),
        suggestedActions: [
          const QuickAction(
            id: 'more_search',
            label: 'More Like This',
            query: 'Show me more movies like these',
            icon: Icons.search,
          ),
          ...quickActions.take(2).toList(),
        ],
      );
    } catch (e) {
      return _handleAPIError();
    }
  }

  // Mock search results as fallback
  List<Movie> _getSearchMockResults(String searchTerm) {
    final term = searchTerm.toLowerCase();
    
    if (term.contains('batman') || term.contains('dark knight')) {
      return [_getActionMockMovies().first];
    } else if (term.contains('avatar')) {
      return [_getTrendingMockMovies().first];
    } else if (term.contains('comedy') || term.contains('funny')) {
      return _getComedyMockMovies();
    } else if (term.contains('action')) {
      return _getActionMockMovies();
    } else {
      return _getTrendingMockMovies().take(2).toList();
    }
  }

  // Handle direct text responses
  AIResponse _handleDirectResponse(String aiText, String originalInput) {
    // Smart suggestions based on input context
    List<QuickAction> suggestions = [];
    
    if (_containsMovieKeywords(originalInput)) {
      suggestions = quickActions.take(4).toList();
    } else {
      suggestions = [
        const QuickAction(
          id: 'help_start',
          label: 'Get Started',
          query: 'How can you help me?',
          icon: Icons.help_outline,
        ),
        ...quickActions.take(3).toList(),
      ];
    }

    return AIResponse(
      content: aiText,
      suggestedActions: suggestions,
    );
  }

  // Check if input contains movie-related keywords
  bool _containsMovieKeywords(String input) {
    final movieKeywords = [
      'movie', 'film', 'watch', 'recommend', 'actor', 'genre',
      'action', 'comedy', 'horror', 'drama', 'romance', 'trending'
    ];
    return movieKeywords.any((keyword) => input.toLowerCase().contains(keyword));
  }

  // Handle API errors with fallback movies
  AIResponse _handleAPIError() {
    return AIResponse(
      content: "🎬 I'm having trouble connecting to the movie database, but here are some great recommendations from my curated collection!",
      movieRecommendations: _getTrendingMockMovies(),
      suggestedActions: [
        const QuickAction(
          id: 'retry_trending',
          label: 'Try Trending',
          query: 'Show me trending movies',
          icon: Icons.trending_up,
        ),
        const QuickAction(
          id: 'retry_action',
          label: 'Action Movies',
          query: 'Recommend action movies',
          icon: Icons.local_fire_department,
        ),
        const QuickAction(
          id: 'retry_comedy',
          label: 'Comedy Films',
          query: 'I want something funny',
          icon: Icons.mood,
        ),
      ],
    );
  }

  // Handle service errors with guaranteed response
  AIResponse _handleError() {
    return AIResponse(
      content: "🎬 My AI brain had a quick hiccup, but I can still help you discover amazing movies! Here are some popular picks:",
      movieRecommendations: _getTrendingMockMovies(),
      suggestedActions: quickActions,
    );
  }

  // Health check
  Future<bool> isHealthy() async {
    try {
      final response = await _model.generateContent([Content.text('Hello')]);
      return response.text != null;
    } catch (e) {
      return false;
    }
  }
} 