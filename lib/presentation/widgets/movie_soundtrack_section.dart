import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:mivi/core/services/movie_soundtrack_service.dart';
import 'package:mivi/core/services/soundtrack_audio_service.dart';
import 'package:mivi/core/utils/haptic_utils.dart';
import 'package:mivi/core/utils/toast_utils.dart';
import 'dart:async';

class MovieSoundtrackSection extends StatefulWidget {
  final int movieId;
  final String movieTitle;

  const MovieSoundtrackSection({
    super.key,
    required this.movieId,
    required this.movieTitle,
  });

  @override
  State<MovieSoundtrackSection> createState() => _MovieSoundtrackSectionState();
}

class _MovieSoundtrackSectionState extends State<MovieSoundtrackSection> {
  final MovieSoundtrackService _soundtrackService = MovieSoundtrackService.instance;
  final SoundtrackAudioService _audioService = SoundtrackAudioService();
  
  MovieSoundtrack? _soundtrack;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _loadSoundtrack();
    _initializeAudioService();
  }

  @override
  void dispose() {
    // Stop any playing track and clean up
    _audioService.stop();
    super.dispose();
  }

  Future<void> _initializeAudioService() async {
    await _audioService.initialize();
  }

  Future<void> _loadSoundtrack() async {
    // Debug: Loading soundtrack for movie ID: ${widget.movieId}, title: ${widget.movieTitle}
    
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      // Show Last.fm API loading state
      // Debug: Fetching from Last.fm API...
      
      // Use the new method with fallback
      final soundtrack = await _soundtrackService.getMovieSoundtrackWithFallback(
        widget.movieId, 
        widget.movieTitle
      );
      
      // Debug: Soundtrack service returned: ${soundtrack != null ? "NOT NULL" : "NULL"}
      if (soundtrack != null) {
        // Debug: Soundtrack details: movieId=${soundtrack.movieId}, title="${soundtrack.movieTitle}", tracks=${soundtrack.tracks.length}
        if (soundtrack.albumArtUrl != null) {
          // Debug: Found album artwork from API
        }
        for (int i = 0; i < soundtrack.tracks.length; i++) {
          final track = soundtrack.tracks[i];
                      // Debug: Track $i: "${track.title}" by "${track.artist}", audioUrl: ${track.audioUrl != null ? "HAS_URL" : "NO_URL"}
        }
      }
      
      setState(() {
        _soundtrack = soundtrack;
        _isLoading = false;
      });
    } catch (e) {
              // Debug: Error loading soundtrack: $e
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Icon(
                Icons.music_note,
                color: colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Movie Soundtrack',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            ],
          ),
          
          const SizedBox(height: 16),
          
          // Content
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (_hasError)
            Column(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 48,
                  color: colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error loading soundtrack',
                  style: TextStyle(
                    color: colorScheme.error,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadSoundtrack,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            )
          else if (_soundtrack == null || _soundtrack!.tracks.isEmpty)
            Column(
              children: [
                Icon(
                  Icons.music_off,
                  size: 48,
                  color: colorScheme.onSurface.withOpacity(0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'No soundtrack available for this movie',
                  style: TextStyle(
                    color: colorScheme.onSurface.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _searchOnPlatform('youtube'),
                        icon: const Icon(Icons.play_circle, size: 16),
                        label: const Text('Search YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _searchOnPlatform('spotify'),
                        icon: const Icon(Icons.music_note, size: 16),
                        label: const Text('Search Spotify'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Soundtrack info with album artwork and main play button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Album artwork (if available from Last.fm)
                    if (_soundtrack!.albumArtUrl != null)
                      Container(
                        width: 80,
                        height: 80,
                        margin: const EdgeInsets.only(right: 16),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            _soundtrack!.albumArtUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Icon(
                                  Icons.album,
                                  color: colorScheme.onSurfaceVariant,
                                  size: 32,
                                ),
                              );
                            },
                            loadingBuilder: (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Container(
                                color: colorScheme.surfaceContainerHighest,
                                child: Center(
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    value: loadingProgress.expectedTotalBytes != null
                                        ? loadingProgress.cumulativeBytesLoaded /
                                            loadingProgress.expectedTotalBytes!
                                        : null,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    
                    // Main play button
                    Container(
                      width: 60,
                      height: 60,
                      margin: const EdgeInsets.only(right: 16),
                      child: ElevatedButton(
                        onPressed: _playMainTheme,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: colorScheme.primary,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: EdgeInsets.zero,
                          elevation: 4,
                        ),
                        child: Icon(
                          _getMainPlayIcon(),
                          size: 32,
                        ),
                      ),
                    ),
                    
                    // Soundtrack info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _soundtrack!.movieTitle,
                            style: TextStyle(
                              color: colorScheme.onSurface,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (_soundtrack!.composer != null)
                            Text(
                              'by ${_soundtrack!.composer}',
                              style: TextStyle(
                                color: colorScheme.onSurface.withOpacity(0.7),
                                fontSize: 14,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            '${_soundtrack!.tracks.length} tracks • ${_soundtrack!.formattedTotalDuration}',
                            style: TextStyle(
                              color: colorScheme.onSurface.withOpacity(0.6),
                              fontSize: 12,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                

                
                // Track list
                Text(
                  'Tracks (${_soundtrack!.tracks.length})',
                  style: TextStyle(
                    color: colorScheme.onSurface,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                
                const SizedBox(height: 8),
                
                // Enhanced track list
                for (int i = 0; i < _soundtrack!.tracks.length; i++)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _audioService.isCurrentTrack(_soundtrack!.tracks[i])
                        ? colorScheme.primaryContainer.withOpacity(0.3)
                        : colorScheme.surfaceContainerHighest.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: _audioService.isCurrentTrack(_soundtrack!.tracks[i])
                        ? Border.all(color: colorScheme.primary.withOpacity(0.5), width: 1)
                        : null,
                    ),
                    child: Row(
                      children: [
                        // Large play button for each track
                        Container(
                          width: 48,
                          height: 48,
                          margin: const EdgeInsets.only(right: 16),
                          child: ElevatedButton(
                            onPressed: () => _handleTrackAction(_soundtrack!.tracks[i]),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _soundtrack!.tracks[i].audioUrl != null
                                ? colorScheme.primary
                                : colorScheme.outline,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: EdgeInsets.zero,
                              elevation: _audioService.isCurrentTrack(_soundtrack!.tracks[i]) ? 4 : 2,
                            ),
                            child: Icon(
                              _getTrackButtonIcon(_soundtrack!.tracks[i]),
                              size: 24,
                            ),
                          ),
                        ),
                        
                        // Track info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _soundtrack!.tracks[i].title,
                                      style: TextStyle(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15,
                                      ),
                                    ),
                                  ),
                                  if (_soundtrack!.tracks[i].isMainTheme)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: colorScheme.primary,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        'Main Theme',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      _soundtrack!.tracks[i].artist,
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 13,
                                      ),
                                    ),
                                  ),
                                  if (_soundtrack!.tracks[i].duration != null)
                                    Text(
                                      _soundtrack!.tracks[i].formattedDuration,
                                      style: TextStyle(
                                        color: colorScheme.onSurface.withOpacity(0.7),
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                ],
                              ),
                              // Current playing indicator
                              if (_audioService.isTrackPlaying(_soundtrack!.tracks[i]))
                                Container(
                                  margin: const EdgeInsets.only(top: 4),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.equalizer,
                                        size: 14,
                                        color: colorScheme.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Now Playing',
                                        style: TextStyle(
                                          color: colorScheme.primary,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 20),

                // Mini player bar (if something is playing)
                if (_audioService.currentTrack != null && _audioService.isInitialized)
                  Container(
                    padding: const EdgeInsets.all(16),
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: colorScheme.primary.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        // Mini play/pause button
                        Container(
                          width: 40,
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_audioService.isPlaying) {
                                _pauseTrack();
                              } else {
                                _resumeTrack();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: colorScheme.primary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.zero,
                            ),
                            child: Icon(
                              _audioService.isPlaying ? Icons.pause : Icons.play_arrow,
                              size: 20,
                            ),
                          ),
                        ),
                        
                        const SizedBox(width: 12),
                        
                        // Current track info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _audioService.currentTrack!.title,
                                style: TextStyle(
                                  color: colorScheme.onSurface,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                _audioService.currentTrack!.artist,
                                style: TextStyle(
                                  color: colorScheme.onSurface.withOpacity(0.7),
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        
                        // Stop button
                        IconButton(
                          onPressed: () async {
                            await _audioService.stop();
                            setState(() {});
                            ToastUtils.showInfo(context, 'Stopped', icon: Icons.stop);
                          },
                          icon: Icon(
                            Icons.stop,
                            color: colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                
                const SizedBox(height: 16),
                
                // Music platform buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _searchOnPlatform('youtube'),
                        icon: const Icon(Icons.play_circle, size: 16),
                        label: const Text('YouTube'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _searchOnPlatform('spotify'),
                        icon: const Icon(Icons.music_note, size: 16),
                        label: const Text('Spotify'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }



  // Check if this is a generated soundtrack (fallback)
  bool _isGeneratedSoundtrack() {
    if (_soundtrack == null) return false;
    
    // Check if all tracks have search URLs instead of direct audio URLs
    return _soundtrack!.tracks.every((track) => 
      track.audioUrl == null && 
      (track.spotifyUrl?.contains('search') == true || 
       track.youtubeUrl?.contains('search') == true)
    );
  }

  // Get appropriate icon for track button
  IconData _getTrackButtonIcon(SoundtrackTrack track) {
    if (track.audioUrl != null) {
      // Check if this track is currently playing
      if (_audioService.isTrackPlaying(track)) {
        return Icons.pause;
      } else if (_audioService.isTrackPaused(track)) {
        return Icons.play_arrow;
      } else {
        return Icons.play_arrow;
      }
    } else {
      return Icons.search;
    }
  }

  // Handle track action (play or search)
  void _handleTrackAction(SoundtrackTrack track) {
    HapticUtils.light();
    
    if (track.audioUrl != null) {
      // Handle play/pause for tracks with audio
      if (_audioService.isTrackPlaying(track)) {
        _pauseTrack();
      } else if (_audioService.isTrackPaused(track)) {
        _resumeTrack();
      } else {
        _playTrack(track);
      }
    } else {
      // Search for the track
      _searchForTrack(track);
    }
  }

  // Play track using audio service
  Future<void> _playTrack(SoundtrackTrack track) async {
    // Debug: Widget _playTrack called for: "${track.title}"
    
    try {
      // Show loading state
      ToastUtils.showInfo(
        context, 
        'Loading: ${track.title}',
        icon: Icons.hourglass_empty,
      );
      
      final success = await _audioService.playTrack(track);
      
      if (success && mounted) {
        setState(() {}); // Refresh UI to show playing state
        ToastUtils.showSuccess(
          context, 
          'Playing: ${track.title}',
          icon: Icons.play_arrow,
        );
      } else if (mounted) {
        ToastUtils.showError(
          context, 
          'Could not play track: ${track.title}',
          icon: Icons.error,
        );
        
        // Try to show search option instead
        _searchForTrack(track);
      }
    } catch (e) {
      // Debug: Widget error playing track: $e
      if (mounted) {
        ToastUtils.showError(
          context, 
          'Error: ${e.toString()}',
          icon: Icons.error,
        );
      }
    }
  }

  // Pause current track
  Future<void> _pauseTrack() async {
    await _audioService.pause();
    if (mounted) {
      setState(() {}); // Refresh UI
      ToastUtils.showInfo(context, 'Paused', icon: Icons.pause);
    }
  }

  // Resume current track
  Future<void> _resumeTrack() async {
    await _audioService.resume();
    if (mounted) {
      setState(() {}); // Refresh UI
      ToastUtils.showInfo(context, 'Resumed', icon: Icons.play_arrow);
    }
  }

  // Search for a specific track
  void _searchForTrack(SoundtrackTrack track) async {
    ToastUtils.showInfo(
      context,
      'Opening YouTube Music for: ${track.title}',
      icon: Icons.play_circle,
    );
    
    // Try to launch YouTube video directly
    final success = await _soundtrackService.launchYouTubeVideo(
      widget.movieTitle, 
      track.title
    );
    
    if (!success && mounted) {
      // Fallback to Spotify if YouTube fails
      ToastUtils.showInfo(
        context,
        'Opening Spotify search',
        icon: Icons.music_note,
      );
      
      if (track.spotifyUrl != null) {
        _soundtrackService.launchMusicService(track, 'spotify');
      }
    }
  }

  // Play the main theme track
  void _playMainTheme() {
    HapticUtils.light();
    
    if (_soundtrack != null && _soundtrack!.tracks.isNotEmpty) {
      // Get main theme track or first track
      final mainTrack = _soundtrack!.mainThemes.isNotEmpty 
          ? _soundtrack!.mainThemes.first 
          : _soundtrack!.tracks.first;
          
      if (_audioService.isTrackPlaying(mainTrack)) {
        _pauseTrack();
      } else if (_audioService.isTrackPaused(mainTrack)) {
        _resumeTrack();
      } else {
        _playTrack(mainTrack);
      }
    } else {
      ToastUtils.showInfo(context, 'No tracks available');
    }
  }

  // Get the appropriate icon for the main play button
  IconData _getMainPlayIcon() {
    if (_soundtrack == null || _soundtrack!.tracks.isEmpty) {
      return Icons.play_arrow;
    }
    
    // Get main theme track or first track
    final mainTrack = _soundtrack!.mainThemes.isNotEmpty 
        ? _soundtrack!.mainThemes.first 
        : _soundtrack!.tracks.first;
        
    if (_audioService.isTrackPlaying(mainTrack)) {
      return Icons.pause;
    } else if (_audioService.isTrackPaused(mainTrack)) {
      return Icons.play_arrow;
    } else {
      return Icons.play_arrow;
    }
  }

  // Search on a specific platform
  void _searchOnPlatform(String platform) async {
    HapticUtils.light();
    
    if (platform == 'youtube') {
      // For YouTube, try to get first video directly
      ToastUtils.showInfo(
        context, 
        'Opening YouTube Music...',
        icon: Icons.play_circle,
      );
      
      final success = await _soundtrackService.launchYouTubeVideo(
        widget.movieTitle, 
        'soundtrack'
      );
      
      if (!success && mounted) {
        ToastUtils.showError(context, 'Could not open YouTube');
      }
    } else {
      // For other platforms, use regular search
      final searchUrls = _soundtrackService.generateSearchUrls(
        widget.movieTitle, 
        _soundtrack?.composer,
      );
      
      final url = searchUrls[platform];
      if (url != null) {
        ToastUtils.showSuccess(
          context, 
          'Opening ${platform.toUpperCase()} search',
          icon: platform == 'spotify' ? Icons.music_note : Icons.play_circle,
        );
        
        // Launch the URL
        _launchUrl(url);
      }
    }
  }

  // Launch URL helper
  Future<void> _launchUrl(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      if (mounted) {
        ToastUtils.showError(context, 'Could not open link');
      }
    }
  }


} 