import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  final String videoUrl;

  const VideoPlayerScreen({super.key, required this.videoUrl});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> with TickerProviderStateMixin {
  late VideoPlayerController _controller;
  bool _isInitialized = false;
  bool _isControlsVisible = true;
  bool _isPlaying = false;
  bool _isFullscreen = false;
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final List<double> _playbackSpeeds = [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(_animationController);
    
    // Start with controls visible
    _animationController.forward();
    
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.play();
        setState(() {
          _isPlaying = true;
        });
        // Show controls initially, then hide after delay
        _showControlsTemporarily();
      });

    _controller.addListener(_videoPlayerListener);
  }

  void _videoPlayerListener() {
    if (mounted) {
      setState(() {
        _isPlaying = _controller.value.isPlaying;
      });
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_videoPlayerListener);
    _controller.dispose();
    _animationController.dispose();
    // Exit fullscreen if needed
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    super.dispose();
  }

  void _toggleControls() {
    if (_isControlsVisible) {
      // Hide controls
      setState(() {
        _isControlsVisible = false;
      });
      _animationController.reverse();
    } else {
      // Show controls and auto-hide after delay
      _showControlsTemporarily();
    }
  }

  void _hideControlsAfterDelay() {
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted && _isPlaying && _isControlsVisible) {
        setState(() {
          _isControlsVisible = false;
        });
        _animationController.reverse();
      }
    });
  }

  void _togglePlayPause() {
    setState(() {
      if (_controller.value.isPlaying) {
        _controller.pause();
      } else {
        _controller.play();
      }
    });
    // Show controls when play state changes
    _showControlsTemporarily();
  }

  void _skipBackward() {
    final currentPosition = _controller.value.position;
    final newPosition = currentPosition - const Duration(seconds: 10);
    _controller.seekTo(newPosition < Duration.zero ? Duration.zero : newPosition);
    _showControlsTemporarily();
  }

  void _skipForward() {
    final currentPosition = _controller.value.position;
    final duration = _controller.value.duration;
    final newPosition = currentPosition + const Duration(seconds: 10);
    _controller.seekTo(newPosition > duration ? duration : newPosition);
    _showControlsTemporarily();
  }

  void _showControlsTemporarily() {
    setState(() {
      _isControlsVisible = true;
    });
    _animationController.forward();
    _hideControlsAfterDelay();
  }

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });

    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
  }

  void _changeVolume(double value) {
    setState(() {
      _volume = value;
    });
    _controller.setVolume(_volume);
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _controller.setPlaybackSpeed(_playbackSpeed);
    Navigator.of(context).pop(); // Close speed selection dialog
  }

  void _showPlaybackSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: const Text('Tốc độ phát', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _playbackSpeeds.map((speed) {
            return ListTile(
              title: Text(
                '${speed}x',
                style: TextStyle(
                  color: _playbackSpeed == speed ? Colors.red : Colors.white,
                  fontWeight: _playbackSpeed == speed ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              onTap: () => _changePlaybackSpeed(speed),
              trailing: _playbackSpeed == speed 
                ? const Icon(Icons.check, color: Colors.red)
                : null,
            );
          }).toList(),
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '$hours:${twoDigits(minutes)}:${twoDigits(seconds)}';
    }
    return '${twoDigits(minutes)}:${twoDigits(seconds)}';
  }

  Widget _buildProgressBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Text(
            _formatDuration(_controller.value.position),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: VideoProgressIndicator(
              _controller,
              allowScrubbing: true,
              padding: const EdgeInsets.symmetric(vertical: 8),
              colors: const VideoProgressColors(
                playedColor: Colors.red,
                backgroundColor: Colors.white24,
                bufferedColor: Colors.white38,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_controller.value.duration),
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        // Skip backward
        IconButton(
          icon: const Icon(Icons.replay_10, color: Colors.white, size: 32),
          onPressed: _skipBackward,
        ),
        // Play/Pause
        Container(
          decoration: const BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              _isPlaying ? Icons.pause : Icons.play_arrow,
              color: Colors.white,
              size: 40,
            ),
            onPressed: _togglePlayPause,
          ),
        ),
        // Skip forward
        IconButton(
          icon: const Icon(Icons.forward_10, color: Colors.white, size: 32),
          onPressed: _skipForward,
        ),
      ],
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white, size: 24),
            onPressed: () => Navigator.of(context).pop(),
          ),
          const Spacer(),
          // Volume control
          Row(
            children: [
              Icon(
                _volume == 0 ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
                size: 20,
              ),
              SizedBox(
                width: 80,
                child: Slider(
                  value: _volume,
                  onChanged: _changeVolume,
                  activeColor: Colors.red,
                  inactiveColor: Colors.white24,
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Playback speed
          IconButton(
            icon: const Icon(Icons.speed, color: Colors.white, size: 20),
            onPressed: _showPlaybackSpeedDialog,
          ),
          // Fullscreen toggle
          IconButton(
            icon: Icon(
              _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              color: Colors.white,
              size: 24,
            ),
            onPressed: _toggleFullscreen,
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    if (!_isInitialized) {
      return const Center(child: CircularProgressIndicator(color: Colors.red));
    }

    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withOpacity(0.7),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withOpacity(0.7),
                ],
                stops: const [0.0, 0.3, 0.7, 1.0],
              ),
            ),
            child: Column(
              children: [
                // Top controls
                _buildTopControls(),
                const Spacer(),
                // Main controls
                _buildMainControls(),
                const SizedBox(height: 32),
                // Progress bar
                _buildProgressBar(),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: MouseRegion(
          onEnter: (_) => _showControlsTemporarily(),
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: _toggleControls,
            onDoubleTap: _togglePlayPause,
            child: Stack(
            children: [
              // Video player
              Center(
                child: _isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CircularProgressIndicator(color: Colors.red),
              ),
              // Controls overlay
              if (_isControlsVisible) _buildControls(),
              // Loading indicator
              if (!_isInitialized)
                const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: Colors.red),
                      SizedBox(height: 16),
                      Text(
                        'Đang tải video...',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                ),
            ],
          ), // Stack
        ), // GestureDetector  
      ), // MouseRegion
    ), // SafeArea
    ); // Scaffold
  }
}
