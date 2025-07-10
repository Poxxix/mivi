import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:mivi/data/models/chat_models.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/repositories/movie_repository.dart';

class GeminiAIService {
  final MovieRepository movieRepository;
  final Random _random = Random();
  
  // TODO: Get your FREE Gemini API key from https://makersuite.google.com/app/apikey
  static const String _apiKey = 'AIzaSyDbS539Ijab-f1-02if85Ov34A4ysCfXfs';
  
  late final GenerativeModel _model;

  GeminiAIService({required this.movieRepository}) {
    _model = GenerativeModel(
      model: 'gemini-1.5-flash', // Latest model, completely FREE
      apiKey: _apiKey,
    );
  }

  // System prompt for the AI
  static const String _systemPrompt = '''
You are an intelligent movie recommendation AI assistant for a Flutter movie app called Mivi.

RULES:
1. Only respond to movie-related queries
2. Be concise and helpful 
3. Use emojis sparingly
4. Always end with helpful suggestions

CAPABILITIES:
- Recommend movies by genre, mood, actor
- Search for specific movies  
- Show trending, popular, top-rated movies
- Provide movie information
- Handle greetings and basic conversation

RESPONSE TYPES:
For movie recommendations: Respond with "RECOMMEND:{genre|popular|trending|top_rated|actor:name}"
For movie search: Respond with "SEARCH:{movie_name_or_actor}"
For greetings: Respond with friendly greeting + offer help
For help: Explain your capabilities
For non-movie topics: Politely redirect to movie topics

EXAMPLES:
User: "recommend action movies" → RECOMMEND:action
User: "show trending" → RECOMMEND:trending  
User: "find Tom Hanks movies" → SEARCH:Tom Hanks
User: "hello" → Friendly greeting + offer help
User: "weather today" → "I'm a movie assistant, let me help you find great films instead!"
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

    // Handle specific commands from Gemini
    if (text.contains('recommend:')) {
      return await _handleRecommendCommand(aiText);
    } else if (text.contains('search:')) {
      return await _handleSearchCommand(aiText);
    } else {
      // Direct text response with smart suggestions
      return _handleDirectResponse(aiText, originalInput);
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