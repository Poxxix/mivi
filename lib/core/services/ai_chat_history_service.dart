import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mivi/data/models/chat_models.dart';
import 'package:mivi/data/models/movie_model.dart';


class AIChatHistoryService {
  static const String _chatHistoryKey = 'ai_chat_history';
  static const String _chatSessionsKey = 'ai_chat_sessions';
  static const int _maxMessages = 100; // Keep last 100 messages
  static const int _maxSessions = 10; // Keep last 10 sessions

  static AIChatHistoryService? _instance;
  static AIChatHistoryService get instance => _instance ??= AIChatHistoryService._();
  AIChatHistoryService._();

  List<ChatMessage> _chatHistory = [];
  List<ChatSession> _chatSessions = [];
  String? _currentSessionId;

  List<ChatMessage> get chatHistory => List.unmodifiable(_chatHistory);
  List<ChatSession> get chatSessions => List.unmodifiable(_chatSessions);
  String? get currentSessionId => _currentSessionId;

  // Initialize service and load data
  Future<void> initialize() async {
    await _loadChatHistory();
    await _loadChatSessions();
  }

  // Load chat history from SharedPreferences
  Future<void> _loadChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_chatHistoryKey) ?? [];
      
      _chatHistory = historyJson
          .map((json) => _chatMessageFromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading chat history: $e');
      _chatHistory = [];
    }
  }

  // Load chat sessions from SharedPreferences
  Future<void> _loadChatSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_chatSessionsKey) ?? [];
      
      _chatSessions = sessionsJson
          .map((json) => _chatSessionFromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('Error loading chat sessions: $e');
      _chatSessions = [];
    }
  }

  // Save chat history to SharedPreferences
  Future<void> _saveChatHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = _chatHistory
          .map((message) => jsonEncode(_chatMessageToJson(message)))
          .toList();
      
      await prefs.setStringList(_chatHistoryKey, historyJson);
    } catch (e) {
      print('Error saving chat history: $e');
    }
  }

  // Save chat sessions to SharedPreferences
  Future<void> _saveChatSessions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = _chatSessions
          .map((session) => jsonEncode(_chatSessionToJson(session)))
          .toList();
      
      await prefs.setStringList(_chatSessionsKey, sessionsJson);
    } catch (e) {
      print('Error saving chat sessions: $e');
    }
  }

  // Add message to history
  Future<void> addMessage(ChatMessage message) async {
    _chatHistory.add(message);
    
    // Keep only the most recent messages
    if (_chatHistory.length > _maxMessages) {
      _chatHistory = _chatHistory.take(_maxMessages).toList();
    }
    
    await _saveChatHistory();
    
    // Update current session
    if (_currentSessionId != null) {
      await _updateCurrentSession();
    }
  }

  // Add multiple messages to history
  Future<void> addMessages(List<ChatMessage> messages) async {
    _chatHistory.addAll(messages);
    
    // Keep only the most recent messages
    if (_chatHistory.length > _maxMessages) {
      _chatHistory = _chatHistory.take(_maxMessages).toList();
    }
    
    await _saveChatHistory();
    
    // Update current session
    if (_currentSessionId != null) {
      await _updateCurrentSession();
    }
  }

  // Start new chat session
  Future<String> startNewSession() async {
    final sessionId = 'session_${DateTime.now().millisecondsSinceEpoch}';
    _currentSessionId = sessionId;
    
    final newSession = ChatSession(
      sessionId: sessionId,
      messages: [],
      state: ChatState.idle,
      lastActivity: DateTime.now(),
    );
    
    _chatSessions.insert(0, newSession);
    
    // Keep only the most recent sessions
    if (_chatSessions.length > _maxSessions) {
      _chatSessions = _chatSessions.take(_maxSessions).toList();
    }
    
    await _saveChatSessions();
    return sessionId;
  }

  // Update current session with latest messages
  Future<void> _updateCurrentSession() async {
    if (_currentSessionId == null) return;
    
    final sessionIndex = _chatSessions.indexWhere(
      (session) => session.sessionId == _currentSessionId,
    );
    
    if (sessionIndex != -1) {
      final currentSession = _chatSessions[sessionIndex];
      final updatedSession = currentSession.copyWith(
        messages: List.from(_chatHistory),
        lastActivity: DateTime.now(),
      );
      
      _chatSessions[sessionIndex] = updatedSession;
      await _saveChatSessions();
    }
  }

  // Load session messages
  Future<List<ChatMessage>> loadSession(String sessionId) async {
    _currentSessionId = sessionId;
    
    final session = _chatSessions.firstWhere(
      (s) => s.sessionId == sessionId,
      orElse: () => ChatSession(
        sessionId: '',
        messages: [],
        state: ChatState.idle,
        lastActivity: DateTime.now(),
      ),
    );
    
    if (session.sessionId.isNotEmpty) {
      _chatHistory = List.from(session.messages);
      await _saveChatHistory();
      return session.messages;
    }
    
    return [];
  }

  // Get recent messages (for context)
  List<ChatMessage> getRecentMessages({int count = 10}) {
    if (_chatHistory.length <= count) {
      return _chatHistory;
    }
    return _chatHistory.sublist(_chatHistory.length - count);
  }

  // Clear all chat history
  Future<void> clearHistory() async {
    _chatHistory.clear();
    await _saveChatHistory();
  }

  // Clear all sessions
  Future<void> clearSessions() async {
    _chatSessions.clear();
    _currentSessionId = null;
    await _saveChatSessions();
  }

  // Clear all data
  Future<void> clearAll() async {
    await clearHistory();
    await clearSessions();
  }

  // Get session summary for UI
  String getSessionSummary(ChatSession session) {
    if (session.messages.isEmpty) {
      return 'Empty conversation';
    }
    
    final firstUserMessage = session.messages
        .where((m) => m.type == MessageType.user)
        .firstOrNull;
    
    if (firstUserMessage != null) {
      final content = firstUserMessage.content;
      return content.length > 30 ? '${content.substring(0, 30)}...' : content;
    }
    
    return 'Chat session';
  }

  // Get time ago string for session
  String getTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return 'Unknown';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // JSON serialization helpers
  Map<String, dynamic> _chatMessageToJson(ChatMessage message) {
    return {
      'id': message.id,
      'content': message.content,
      'type': message.type.index,
      'timestamp': message.timestamp.millisecondsSinceEpoch,
      'recommendedMovies': message.recommendedMovies?.map((movie) => {
        'id': movie.id,
        'title': movie.title,
        'posterPath': movie.posterPath,
        'backdropPath': movie.backdropPath,
        'voteAverage': movie.voteAverage,
        'releaseDate': movie.releaseDate,
        'overview': movie.overview,
        'genres': movie.genres.map((g) => g.toJson()).toList(),
        'isFavorite': movie.isFavorite,
      }).toList(),
      'metadata': message.metadata,
      'isAnimating': message.isAnimating,
    };
  }

  ChatMessage _chatMessageFromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String,
      content: json['content'] as String,
      type: MessageType.values[json['type'] as int],
      timestamp: DateTime.fromMillisecondsSinceEpoch(json['timestamp'] as int),
      recommendedMovies: (json['recommendedMovies'] as List?)?.map((movieJson) {
        final movieMap = movieJson as Map<String, dynamic>;
        return Movie(
          id: movieMap['id'] as int,
          title: movieMap['title'] as String? ?? '',
          overview: movieMap['overview'] as String? ?? '',
          posterPath: movieMap['posterPath'] as String? ?? '',
          backdropPath: movieMap['backdropPath'] as String? ?? '',
          voteAverage: (movieMap['voteAverage'] as num?)?.toDouble() ?? 0.0,
          releaseDate: movieMap['releaseDate'] as String? ?? '',
          genres: (movieMap['genres'] as List?)?.map((g) => Genre.fromJson(g)).toList() ?? [],
          isFavorite: movieMap['isFavorite'] as bool? ?? false,
        );
      }).toList(),
      metadata: json['metadata'] as Map<String, dynamic>?,
      isAnimating: json['isAnimating'] as bool? ?? false,
    );
  }

  Map<String, dynamic> _chatSessionToJson(ChatSession session) {
    return {
      'sessionId': session.sessionId,
      'messages': session.messages.map(_chatMessageToJson).toList(),
      'state': session.state.index,
      'lastActivity': session.lastActivity?.millisecondsSinceEpoch,
    };
  }

  ChatSession _chatSessionFromJson(Map<String, dynamic> json) {
    return ChatSession(
      sessionId: json['sessionId'] as String,
      messages: (json['messages'] as List)
          .map((msgJson) => _chatMessageFromJson(msgJson as Map<String, dynamic>))
          .toList(),
      state: ChatState.values[json['state'] as int],
      lastActivity: json['lastActivity'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['lastActivity'] as int)
          : DateTime.now(),
    );
  }
} 