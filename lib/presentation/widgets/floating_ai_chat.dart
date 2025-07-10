import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class FloatingAIChat extends StatefulWidget {
  const FloatingAIChat({super.key});

  @override
  State<FloatingAIChat> createState() => _FloatingAIChatState();
}

class _FloatingAIChatState extends State<FloatingAIChat>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    // Start the pulse animation on a loop
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTap() {
    // Stop animation momentarily for tap feedback
    _animationController.stop();
    
    // Navigate to chat screen
    context.push('/ai-chat');
    
    // Resume animation after a short delay
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) {
        _animationController.repeat(reverse: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Positioned(
      right: 16,
      bottom: 90, // Above bottom navigation bar
      child: GestureDetector(
        onTap: _onTap,
        onTapDown: (_) {
          setState(() => _isHovered = true);
        },
        onTapUp: (_) {
          setState(() => _isHovered = false);
        },
        onTapCancel: () {
          setState(() => _isHovered = false);
        },
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Stack(
              alignment: Alignment.center,
              children: [
                // Pulse effect background
                Container(
                  width: 56 * _pulseAnimation.value,
                  height: 56 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withOpacity(
                      0.2 * (1 - _pulseAnimation.value * 0.5),
                    ),
                  ),
                ),
                
                // Secondary pulse
                Container(
                  width: 56 * (_pulseAnimation.value * 0.8),
                  height: 56 * (_pulseAnimation.value * 0.8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: colorScheme.primary.withOpacity(
                      0.3 * (1 - _pulseAnimation.value * 0.6),
                    ),
                  ),
                ),
                
                // Main floating button
                Transform.scale(
                  scale: _isHovered ? 0.95 : 1.0,
                  child: Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.secondary,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // AI Icon
                        Icon(
                          Icons.smart_toy,
                          color: Colors.white,
                          size: 24,
                        ),
                        
                        // Small notification dot (optional - for showing AI activity)
                        Positioned(
                          right: 8,
                          top: 8,
                          child: Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: Colors.greenAccent,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.greenAccent.withOpacity(0.5),
                                  blurRadius: 4,
                                  spreadRadius: 1,
                                ),
                              ],
                            ),
                          ).animate(onPlay: (controller) => controller.repeat())
                              .fadeIn(duration: 800.ms)
                              .then()
                              .fadeOut(duration: 800.ms),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ).animate()
          .fadeIn(duration: 500.ms, delay: 1000.ms)
          .slideY(begin: 1.0, duration: 500.ms, delay: 1000.ms),
    );
  }
}

class FloatingAIChatProvider extends StatefulWidget {
  final Widget child;
  final bool showFloatingChat;

  const FloatingAIChatProvider({
    super.key,
    required this.child,
    this.showFloatingChat = true,
  });

  @override
  State<FloatingAIChatProvider> createState() => _FloatingAIChatProviderState();
}

class _FloatingAIChatProviderState extends State<FloatingAIChatProvider> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showFloatingChat)
          const FloatingAIChat(),
      ],
    );
  }
}

// Quick access widget for immediate AI help
class QuickAIHelper extends StatelessWidget {
  final String helpText;
  final VoidCallback? onTap;

  const QuickAIHelper({
    super.key,
    required this.helpText,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return GestureDetector(
      onTap: onTap ?? () => context.push('/ai-chat'),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary.withOpacity(0.1),
              colorScheme.secondary.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: colorScheme.primary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.auto_awesome,
                color: colorScheme.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Assistant',
                    style: TextStyle(
                      color: colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    helpText,
                    style: TextStyle(
                      color: colorScheme.onSurface.withOpacity(0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: colorScheme.primary,
              size: 16,
            ),
          ],
        ),
      ),
    ).animate()
        .fadeIn(duration: 300.ms)
        .slideX(begin: 0.2, duration: 300.ms);
  }
} 