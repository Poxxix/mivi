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

  // Main method to generate AI response
  Future<AIResponse> generateResponse(String userInput) async {
    try {
      print('🤖 Gemini Input: "$userInput"');
      
      final content = [
        Content.text('$_systemPrompt\n\nUser: $userInput\nAssistant:')
      ];
      final response = await _model.generateContent(content);
      final aiText = response.text ?? '';
      
      print('🧠 Gemini Response: "$aiText"');
      
      // Parse Gemini response and take action
      return await _parseGeminiResponse(aiText, userInput);
    } catch (e) {
      print('❌ Gemini Error: $e');
      return _handleError();
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

  // Handle smart recommendations based on natural language
  Future<AIResponse> _handleSmartRecommendation(String userInput, String aiText) async {
    try {
      List<Movie> movies = [];
      String response = aiText;

      // Determine what type of recommendation to make
      if (userInput.contains('trending') || userInput.contains('popular now')) {
        movies = await movieRepository.getTrendingMovies();
      } else if (userInput.contains('popular')) {
        movies = await movieRepository.getPopularMovies();
      } else if (userInput.contains('top rated') || userInput.contains('best')) {
        movies = await movieRepository.getTopRatedMovies();
      } else if (userInput.contains('action')) {
        movies = await movieRepository.getMoviesByGenre(28); // Action
      } else if (userInput.contains('comedy') || userInput.contains('funny')) {
        movies = await movieRepository.getMoviesByGenre(35); // Comedy
      } else if (userInput.contains('horror') || userInput.contains('scary')) {
        movies = await movieRepository.getMoviesByGenre(27); // Horror
      } else if (userInput.contains('romance') || userInput.contains('love')) {
        movies = await movieRepository.getMoviesByGenre(10749); // Romance
      } else if (userInput.contains('drama')) {
        movies = await movieRepository.getMoviesByGenre(18); // Drama
      } else if (userInput.contains('thriller')) {
        movies = await movieRepository.getMoviesByGenre(53); // Thriller
      } else if (userInput.contains('sci-fi') || userInput.contains('science fiction')) {
        movies = await movieRepository.getMoviesByGenre(878); // Sci-Fi
      } else if (userInput.contains('fantasy')) {
        movies = await movieRepository.getMoviesByGenre(14); // Fantasy
      } else if (userInput.contains('animation') || userInput.contains('animated')) {
        movies = await movieRepository.getMoviesByGenre(16); // Animation
      } else if (userInput.contains('adventure')) {
        movies = await movieRepository.getMoviesByGenre(12); // Adventure
      } else {
        // Default to trending for general requests
        movies = await movieRepository.getTrendingMovies();
      }

      return AIResponse(
        content: response,
        movieRecommendations: movies.take(6).toList(),
        suggestedActions: quickActions.take(3).toList(),
      );
    } catch (e) {
      return _handleAPIError();
    }
  }

  // Handle recommendation commands
  Future<AIResponse> _handleRecommendCommand(String aiText) async {
    try {
      final command = aiText.split('RECOMMEND:')[1].trim();
      List<Movie> movies = [];
      String response = '';

      if (command.contains('trending')) {
        movies = await movieRepository.getTrendingMovies();
        response = '🔥 Here are the hottest trending movies right now:';
      } else if (command.contains('popular')) {
        movies = await movieRepository.getPopularMovies();
        response = '⭐ Here are some popular movies you might enjoy:';
      } else if (command.contains('top_rated')) {
        movies = await movieRepository.getTopRatedMovies();
        response = '🏆 Here are the highest-rated movies:';
      } else if (command.contains('actor:')) {
        final actor = command.split('actor:')[1].trim();
        movies = await movieRepository.searchMovies(actor);
        response = 'Here are movies featuring $actor:';
      } else {
        // Genre-based recommendation
        final genre = command.toLowerCase();
        final allGenres = await movieRepository.getGenres();
        final matchedGenre = allGenres.firstWhere(
          (g) => g.name.toLowerCase().contains(genre),
          orElse: () => Genre(id: 28, name: 'Action'),
        );
        movies = await movieRepository.getMoviesByGenre(matchedGenre.id);
        response = 'Here are some great ${matchedGenre.name.toLowerCase()} movies:';
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

  // Handle search commands
  Future<AIResponse> _handleSearchCommand(String aiText) async {
    try {
      final searchTerm = aiText.split('SEARCH:')[1].trim();
      final results = await movieRepository.searchMovies(searchTerm);
      
      if (results.isEmpty) {
        return AIResponse(
          content: "I couldn't find any movies matching '$searchTerm'. Try a different search term!",
          suggestedActions: quickActions.take(3).toList(),
        );
      }

      return AIResponse(
        content: "Found ${results.length} result(s) for '$searchTerm':",
        movieRecommendations: results.take(4).toList(),
      );
    } catch (e) {
      return _handleAPIError();
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

  // Handle API errors
  AIResponse _handleAPIError() {
    return AIResponse(
      content: "I'm having trouble getting movie data right now. Please try again in a moment!",
      suggestedActions: [
        const QuickAction(
          id: 'retry',
          label: 'Try Again',
          query: 'Show me popular movies',
          icon: Icons.refresh,
        ),
      ],
    );
  }

  // Handle service errors
  AIResponse _handleError() {
    return AIResponse(
      content: "Oops! My AI brain had a hiccup. Please try asking again!",
      suggestedActions: [
        const QuickAction(
          id: 'help_error',
          label: 'Get Help',
          query: 'How do I use this?',
          icon: Icons.help,
        ),
      ],
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