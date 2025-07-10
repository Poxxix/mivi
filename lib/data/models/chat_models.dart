import 'package:equatable/equatable.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:flutter/material.dart';

enum MessageType {
  user,
  ai,
  system,
  movieRecommendation,
  quickAction
}

enum ChatState {
  idle,
  typing,
  processing,
  error
}

class ChatMessage extends Equatable {
  final String id;
  final String content;
  final MessageType type;
  final DateTime timestamp;
  final List<Movie>? recommendedMovies;
  final Map<String, dynamic>? metadata;
  final bool isAnimating;

  const ChatMessage({
    required this.id,
    required this.content,
    required this.type,
    required this.timestamp,
    this.recommendedMovies,
    this.metadata,
    this.isAnimating = false,
  });

  ChatMessage copyWith({
    String? id,
    String? content,
    MessageType? type,
    DateTime? timestamp,
    List<Movie>? recommendedMovies,
    Map<String, dynamic>? metadata,
    bool? isAnimating,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      content: content ?? this.content,
      type: type ?? this.type,
      timestamp: timestamp ?? this.timestamp,
      recommendedMovies: recommendedMovies ?? this.recommendedMovies,
      metadata: metadata ?? this.metadata,
      isAnimating: isAnimating ?? this.isAnimating,
    );
  }

  @override
  List<Object?> get props => [
        id,
        content,
        type,
        timestamp,
        recommendedMovies,
        metadata,
        isAnimating,
      ];
}

class QuickAction extends Equatable {
  final String id;
  final String label;
  final String query;
  final IconData icon;

  const QuickAction({
    required this.id,
    required this.label,
    required this.query,
    required this.icon,
  });

  @override
  List<Object> get props => [id, label, query, icon];
}

class AIResponse extends Equatable {
  final String content;
  final List<Movie> movieRecommendations;
  final List<QuickAction> suggestedActions;
  final Map<String, dynamic> metadata;

  const AIResponse({
    required this.content,
    this.movieRecommendations = const [],
    this.suggestedActions = const [],
    this.metadata = const {},
  });

  @override
  List<Object> get props => [
        content,
        movieRecommendations,
        suggestedActions,
        metadata,
      ];
}

class ChatSession extends Equatable {
  final String sessionId;
  final List<ChatMessage> messages;
  final ChatState state;
  final DateTime lastActivity;

  const ChatSession({
    required this.sessionId,
    required this.messages,
    required this.state,
    required this.lastActivity,
  });

  ChatSession copyWith({
    String? sessionId,
    List<ChatMessage>? messages,
    ChatState? state,
    DateTime? lastActivity,
  }) {
    return ChatSession(
      sessionId: sessionId ?? this.sessionId,
      messages: messages ?? this.messages,
      state: state ?? this.state,
      lastActivity: lastActivity ?? this.lastActivity,
    );
  }

  @override
  List<Object> get props => [sessionId, messages, state, lastActivity];
} 