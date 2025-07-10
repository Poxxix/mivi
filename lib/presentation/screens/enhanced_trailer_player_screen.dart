import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
// Note: WebView implementation simplified for better web compatibility

class EnhancedTrailerPlayerScreen extends StatefulWidget {
  final String youtubeKey;
  const EnhancedTrailerPlayerScreen({super.key, required this.youtubeKey});

  @override
  State<EnhancedTrailerPlayerScreen> createState() => _EnhancedTrailerPlayerScreenState();
}

class _EnhancedTrailerPlayerScreenState extends State<EnhancedTrailerPlayerScreen> 
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _youtubeController;
  bool _isPlayerReady = false;
  bool _hasError = false;
  String? _errorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _initializePlayer();
    _animationController.forward();
  }

  void _initializePlayer() {
    if (kIsWeb) {
      // For web, we'll use a simpler approach - direct YouTube link
      setState(() {
        _hasError = true;
        _errorMessage = 'Web platform: Nhấn nút bên dưới để xem trailer trong YouTube';
      });
    } else if (_canUseEmbeddedPlayer()) {
      _initializeYouTubePlayer();
    } else {
      setState(() {
        _hasError = true;
        _errorMessage = 'Platform này không hỗ trợ embedded player';
      });
    }
  }

  void _initializeYouTubePlayer() {
    try {
      _youtubeController = YoutubePlayerController(
        initialVideoId: widget.youtubeKey,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
          enableCaption: true,
          captionLanguage: 'vi',
          showLiveFullscreenButton: true,
          isLive: false,
        ),
      );

      _youtubeController!.addListener(() {
        if (_youtubeController!.value.isReady && !_isPlayerReady) {
          setState(() {
            _isPlayerReady = true;
          });
        }
        
        if (_youtubeController!.value.hasError) {
          setState(() {
            _hasError = true;
            _errorMessage = 'Không thể tải video YouTube';
          });
        }
      });
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = 'Lỗi khởi tạo YouTube player: ${e.toString()}';
      });
    }
  }

  bool _canUseEmbeddedPlayer() {
    if (kIsWeb) return false;
    return Platform.isIOS || Platform.isAndroid || Platform.isMacOS;
  }

  Future<void> _openInYouTube() async {
    final url = Uri.parse('https://www.youtube.com/watch?v=${widget.youtubeKey}');
    try {
      HapticFeedback.lightImpact();
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        _showErrorSnackBar('Không thể mở YouTube');
      }
    } catch (e) {
      _showErrorSnackBar('Lỗi mở YouTube: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
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

  @override
  void dispose() {
    _youtubeController?.dispose();
    _animationController.dispose();
    
    // Reset orientation when leaving
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen ? null : AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Trailer',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new, color: Colors.white),
            onPressed: _openInYouTube,
            tooltip: 'Mở trong YouTube',
          ),
          if (!kIsWeb)
            IconButton(
              icon: Icon(
                _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
                color: Colors.white,
              ),
              onPressed: _toggleFullscreen,
              tooltip: _isFullscreen ? 'Thoát toàn màn hình' : 'Toàn màn hình',
            ),
        ],
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _buildPlayerContent(),
      ),
    );
  }

  Widget _buildPlayerContent() {
    if (_hasError || kIsWeb) {
      return _buildWebOrErrorState();
    } else if (!kIsWeb && _youtubeController != null) {
      return _buildYouTubePlayer();
    } else {
      return _buildLoadingState();
    }
  }

  Widget _buildWebOrErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // YouTube Logo Animation
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.red.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: const Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
            const SizedBox(height: 32),
            
            // Title
            Text(
              kIsWeb ? '🌐 YouTube Trailer' : 'Movie Trailer',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Description
            Text(
              kIsWeb 
                  ? 'Trên web browser, trailer sẽ mở trong tab YouTube để có trải nghiệm tốt nhất'
                  : _errorMessage ?? 'Nhấn nút bên dưới để xem trailer',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),
            
            // Action Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _openInYouTube,
                icon: const Icon(Icons.launch, color: Colors.white),
                label: Text(
                  kIsWeb ? 'Mở YouTube' : 'Xem trên YouTube',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 4,
                ),
              ),
            ),
            const SizedBox(height: 20),
            
            // Web specific info
            if (kIsWeb)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[900],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[700]!),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue[300],
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Web browsers có hạn chế với embedded video player',
                        style: TextStyle(
                          color: Colors.grey[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildYouTubePlayer() {
    return Column(
      children: [
        // YouTube Player Section
        Expanded(
          flex: _isFullscreen ? 1 : 3,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: _isPlayerReady
                ? ClipRRect(
                    borderRadius: _isFullscreen 
                        ? BorderRadius.zero 
                        : BorderRadius.circular(8),
                    child: YoutubePlayer(
                      controller: _youtubeController!,
                      showVideoProgressIndicator: true,
                      progressIndicatorColor: Colors.red,
                      bottomActions: [
                        CurrentPosition(),
                        ProgressBar(
                          isExpanded: true,
                          colors: const ProgressBarColors(
                            playedColor: Colors.red,
                            handleColor: Colors.redAccent,
                          ),
                        ),
                        RemainingDuration(),
                        FullScreenButton(),
                      ],
                    ),
                  )
                : _buildLoadingState(),
          ),
        ),
        
        // Info Section (hidden in fullscreen)
        if (!_isFullscreen)
          Expanded(
            flex: 1,
            child: _buildInfoSection(),
          ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.movie,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Official Trailer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            kIsWeb
                ? '🌐 Xem trailer chất lượng cao ngay trong app!'
                : '📱 Thưởng thức trailer với chất lượng tốt nhất',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const Spacer(),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openInYouTube,
                  icon: const Icon(Icons.launch),
                  label: const Text('Xem trên YouTube'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              if (!kIsWeb && _youtubeController != null) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () {
                    if (_youtubeController!.value.isPlaying) {
                      _youtubeController!.pause();
                    } else {
                      _youtubeController!.play();
                    }
                  },
                  icon: Icon(
                    _youtubeController?.value.isPlaying == true
                        ? Icons.pause_circle
                        : Icons.play_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(50),
            ),
            child: const CircularProgressIndicator(
              color: Colors.red,
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Đang tải trailer...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            kIsWeb ? 'Đang chuẩn bị' : 'Đang khởi tạo video player',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 