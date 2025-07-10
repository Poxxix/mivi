import 'package:flutter/material.dart';
import 'package:mivi/data/models/movie_model.dart';

class HorizontalCastScroller extends StatefulWidget {
  final List<CastMember> castMembers;
  final String title;
  final bool showNavigationButtons;

  const HorizontalCastScroller({
    super.key,
    required this.castMembers,
    this.title = "Cast",
    this.showNavigationButtons = true,
  });

  @override
  State<HorizontalCastScroller> createState() => _HorizontalCastScrollerState();
}

class _HorizontalCastScrollerState extends State<HorizontalCastScroller> {
  late ScrollController _scrollController;
  bool _canScrollLeft = false;
  bool _canScrollRight = true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_updateScrollButtons);
    
    // Check initial scroll state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateScrollButtons();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _updateScrollButtons() {
    if (_scrollController.hasClients) {
      setState(() {
        _canScrollLeft = _scrollController.offset > 0;
        _canScrollRight = _scrollController.offset < _scrollController.position.maxScrollExtent;
      });
    }
  }

  void _scrollLeft() {
    const scrollAmount = 240.0; // Width of ~2-3 cast cards
    final targetOffset = (_scrollController.offset - scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  void _scrollRight() {
    const scrollAmount = 240.0; // Width of ~2-3 cast cards
    final targetOffset = (_scrollController.offset + scrollAmount).clamp(0.0, _scrollController.position.maxScrollExtent);
    
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    if (widget.castMembers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with title and navigation
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.showNavigationButtons) ...[
                // Left arrow
                Container(
                  decoration: BoxDecoration(
                    color: _canScrollLeft 
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_back_ios_rounded,
                      color: _canScrollLeft 
                          ? colorScheme.primary 
                          : colorScheme.onSurface.withOpacity(0.3),
                      size: 16,
                    ),
                    onPressed: _canScrollLeft ? _scrollLeft : null,
                    iconSize: 16,
                    constraints: const BoxConstraints(
                      minHeight: 32,
                      minWidth: 32,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Right arrow
                Container(
                  decoration: BoxDecoration(
                    color: _canScrollRight 
                        ? colorScheme.primary.withOpacity(0.1)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: _canScrollRight 
                          ? colorScheme.primary 
                          : colorScheme.onSurface.withOpacity(0.3),
                      size: 16,
                    ),
                    onPressed: _canScrollRight ? _scrollRight : null,
                    iconSize: 16,
                    constraints: const BoxConstraints(
                      minHeight: 32,
                      minWidth: 32,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // Cast scroll view
        SizedBox(
          height: 140,
          child: ListView.builder(
            controller: _scrollController,
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: widget.castMembers.length,
            itemBuilder: (context, index) {
              final castMember = widget.castMembers[index];
              return Container(
                width: 90,
                margin: EdgeInsets.only(
                  right: index < widget.castMembers.length - 1 ? 12 : 0,
                ),
                child: _CastCard(castMember: castMember),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _CastCard extends StatelessWidget {
  final CastMember castMember;

  const _CastCard({required this.castMember});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Profile Photo
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
                boxShadow: [
                  BoxShadow(
                    color: colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: (castMember.profilePath?.isNotEmpty ?? false)
                    ? Image.network(
                        'https://image.tmdb.org/t/p/w200${castMember.profilePath}',
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildPlaceholder(context),
                      )
                    : _buildPlaceholder(context),
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Actor Info
          Expanded(
            flex: 2,
            child: Column(
              children: [
                // Actor Name
                Text(
                  castMember.name,
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 2),
                
                // Character Name
                Text(
                  castMember.character,
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.7),
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        Icons.person_rounded,
        color: colorScheme.onSurface.withOpacity(0.3),
        size: 32,
      ),
    );
  }
} 