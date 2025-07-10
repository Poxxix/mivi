import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:bubble/bubble.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:mivi/data/models/chat_models.dart';
import 'package:mivi/data/models/movie_model.dart';
import 'package:mivi/data/services/gemini_ai_service.dart';
import 'package:mivi/data/repositories/movie_repository.dart';
import 'package:mivi/presentation/widgets/horizontal_movie_scroller.dart';


class AIChatScreen extends StatefulWidget {
  const AIChatScreen({super.key});

  @override
  State<AIChatScreen> createState() => _AIChatScreenState();
}

class _AIChatScreenState extends State<AIChatScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();
  
  late GeminiAIService _aiService;
  late AnimationController _fabAnimationController;
  
  final List<ChatMessage> _messages = [];
  ChatState _chatState = ChatState.idle;
  bool _isKeyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _aiService = GeminiAIService(movieRepository: MovieRepository());
    _fabAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    // Welcome message
    _addWelcomeMessage();
    
    // Listen to focus changes for keyboard visibility
    _focusNode.addListener(() {
      setState(() {
        _isKeyboardVisible = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _addWelcomeMessage() {
    final welcomeMessage = ChatMessage(
      id: 'welcome',
      content: "Hi! I'm your AI movie assistant 🤖\n\nI can help you discover amazing movies, get personalized recommendations, and answer questions about films. Try the quick actions below or just ask me anything!",
      type: MessageType.ai,
      timestamp: DateTime.now(),
    );
    
    setState(() {
      _messages.add(welcomeMessage);
    });
  }

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      content: text,
      type: MessageType.user,
      timestamp: DateTime.now(),
    );

    setState(() {
      _messages.add(userMessage);
      _chatState = ChatState.processing;
    });

    _messageController.clear();
    _scrollToBottom();

    try {
      // Get AI response
      final aiResponse = await _aiService.generateResponse(text);
      
      final aiMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        content: aiResponse.content,
        type: aiResponse.movieRecommendations.isNotEmpty 
            ? MessageType.movieRecommendation 
            : MessageType.ai,
        timestamp: DateTime.now(),
        recommendedMovies: aiResponse.movieRecommendations,
        metadata: {
          'suggestedActions': aiResponse.suggestedActions,
        },
      );

      setState(() {
        _messages.add(aiMessage);
        _chatState = ChatState.idle;
      });

      _scrollToBottom();
    } catch (e) {
      setState(() {
        _chatState = ChatState.error;
      });
    }
  }

  void _onQuickActionTap(QuickAction action) {
    _sendMessage(action.query);
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        backgroundColor: colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.smart_toy,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI Assistant',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  _chatState == ChatState.processing 
                      ? 'Thinking...' 
                      : 'Online',
                  style: TextStyle(
                    color: _chatState == ChatState.processing 
                        ? colorScheme.primary 
                        : Colors.green,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: colorScheme.onSurface),
            onPressed: () {
              setState(() {
                _messages.clear();
                _addWelcomeMessage();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages List
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length + (_chatState == ChatState.processing ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length && _chatState == ChatState.processing) {
                  return _buildTypingIndicator(colorScheme);
                }
                
                return _buildMessageBubble(_messages[index], colorScheme)
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.3, duration: 300.ms);
              },
            ),
          ),
          
          // Quick Actions (show when not typing)
          if (!_isKeyboardVisible && _messages.length <= 2)
            _buildQuickActions(colorScheme),
          
          // Input Section
          _buildInputSection(colorScheme),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, ColorScheme colorScheme) {
    final isUser = message.type == MessageType.user;
    
    return Padding(
      padding: EdgeInsets.only(
        bottom: 16,
        left: isUser ? 50 : 0,
        right: isUser ? 0 : 50,
      ),
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          // Message bubble
          Bubble(
            alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
            nip: isUser ? BubbleNip.rightTop : BubbleNip.leftTop,
            color: isUser ? colorScheme.primary : colorScheme.surface,
            elevation: 2,
            padding: const BubbleEdges.all(16),
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : colorScheme.onSurface,
                  fontSize: 14,
                  height: 1.4,
                ),
              ),
            ),
          ),
          
          // Movie recommendations
          if (message.recommendedMovies?.isNotEmpty == true)
            _buildMovieRecommendations(message.recommendedMovies!, colorScheme),
          
          // Quick actions
          if (message.metadata?['suggestedActions'] != null)
            _buildSuggestedActions(
              List<QuickAction>.from(message.metadata!['suggestedActions']),
              colorScheme,
            ),
          
          // Timestamp
          Padding(
            padding: EdgeInsets.only(
              top: 4,
              left: isUser ? 0 : 16,
              right: isUser ? 16 : 0,
            ),
            child: Text(
              _formatTime(message.timestamp),
              style: TextStyle(
                color: colorScheme.onSurface.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMovieRecommendations(List<Movie> movies, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: HorizontalMovieScroller(
        movies: movies,
        title: "Recommended Movies",
        isCompact: true,
        showNavigationButtons: true,
      ),
    );
  }

  Widget _buildSuggestedActions(List<QuickAction> actions, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: actions.map((action) => _buildActionChip(action, colorScheme)).toList(),
      ),
    );
  }

  Widget _buildActionChip(QuickAction action, ColorScheme colorScheme) {
    return ActionChip(
      avatar: Icon(action.icon, size: 16),
      label: Text(action.label),
      onPressed: () => _onQuickActionTap(action),
      backgroundColor: colorScheme.surfaceVariant.withOpacity(0.3),
      labelStyle: TextStyle(
        color: colorScheme.onSurface,
        fontSize: 12,
      ),
    );
  }

  Widget _buildQuickActions(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextStyle(
              color: colorScheme.onSurface,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: GeminiAIService.quickActions
                .map((action) => _buildActionChip(action, colorScheme))
                .toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTypingIndicator(ColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16, right: 50),
      child: Bubble(
        alignment: Alignment.centerLeft,
        nip: BubbleNip.leftTop,
        color: colorScheme.surface,
        elevation: 2,
        padding: const BubbleEdges.all(16),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.1),
                    colorScheme.secondary.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.smart_toy,
                color: colorScheme.primary,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'AI is searching...',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Finding great movies...',
                      style: TextStyle(
                        color: colorScheme.onSurface.withOpacity(0.7),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputSection(ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outline.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(25),
                  border: Border.all(
                    color: colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _focusNode,
                  decoration: InputDecoration(
                    hintText: 'Ask me about movies...',
                    hintStyle: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  style: TextStyle(color: colorScheme.onSurface),
                  maxLines: 3,
                  minLines: 1,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (text) => _sendMessage(text),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [colorScheme.primary, colorScheme.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  _chatState == ChatState.processing 
                      ? Icons.stop 
                      : Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                onPressed: _chatState == ChatState.processing 
                    ? null 
                    : () => _sendMessage(_messageController.text),
              ),
            ).animate().scale(
              duration: 150.ms,
              curve: Curves.easeOut,
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inMinutes < 1) return 'now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    return '${difference.inDays}d';
  }
}

 