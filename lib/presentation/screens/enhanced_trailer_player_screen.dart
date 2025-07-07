import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:mivi/presentation/core/app_colors.dart';

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
    // Kiểm tra nếu YouTube player có thể hoạt động trên platform hiện tại
    if (_canUseEmbeddedPlayer()) {
      try {
        _youtubeController = YoutubePlayerController(
          initialVideoId: widget.youtubeKey,
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
            enableCaption: true,
            captionLanguage: 'vi',
            showLiveFullscreenButton: true,
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
          _errorMessage = 'Lỗi khởi tạo player: ${e.toString()}';
        });
      }
    } else {
      // Fallback cho các platform không hỗ trợ embedded player
      setState(() {
        _hasError = true;
        _errorMessage = 'Platform này không hỗ trợ embedded YouTube player';
      });
    }
  }

  bool _canUseEmbeddedPlayer() {
    // YouTube player hoạt động tốt trên iOS, Android và macOS
    // Không hoạt động tốt trên web
    if (kIsWeb) {
      return false;
    }
    
    // Kiểm tra nếu đang chạy trên macOS, iOS hoặc Android
    if (Platform.isIOS || Platform.isAndroid || Platform.isMacOS) {
      return true;
    }
    
    return false;
  }

  Future<void> _openInYouTube() async {
    final url = Uri.parse('https://www.youtube.com/watch?v=${widget.youtubeKey}');
    try {
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

  @override
  void dispose() {
    _youtubeController?.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Trailer',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              setState(() {
                _hasError = false;
                _isPlayerReady = false;
              });
              _initializePlayer();
            },
            tooltip: 'Tải lại',
          ),
        ],
        elevation: 0,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: _hasError || !_canUseEmbeddedPlayer()
            ? _buildFallbackPlayer()
            : _buildEmbeddedPlayer(),
      ),
    );
  }

  Widget _buildEmbeddedPlayer() {
    if (_youtubeController == null) {
      return _buildLoadingPlayer();
    }

    return Column(
      children: [
        // YouTube Player Section
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: _isPlayerReady
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
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
                : _buildLoadingPlayer(),
          ),
        ),
        // Video Info Section
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                ],
              ),
            ),
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
                        Icons.play_circle_filled,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'YouTube Trailer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  Platform.isMacOS
                      ? 'Đang phát trực tiếp trên macOS'
                      : 'Đang phát trực tiếp trong ứng dụng',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
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
                    const SizedBox(width: 12),
                    IconButton(
                      onPressed: () {
                        if (_youtubeController != null) {
                          if (_youtubeController!.value.isPlaying) {
                            _youtubeController!.pause();
                          } else {
                            _youtubeController!.play();
                          }
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
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackPlayer() {
    return Column(
      children: [
        // Fallback Player Section
        Expanded(
          flex: 3,
          child: Container(
            width: double.infinity,
            color: Colors.black,
            child: _buildFallbackContent(),
          ),
        ),
        // Info Section
        Expanded(
          flex: 1,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.grey[900]!,
                  Colors.grey[800]!,
                ],
              ),
            ),
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
                        Icons.youtube_searched_for,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'YouTube Trailer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  _errorMessage ?? 'Nhấn nút "Xem trên YouTube" để xem trailer',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _openInYouTube,
                    icon: const Icon(Icons.launch),
                    label: const Text('Xem trên YouTube'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFallbackContent() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey[800]!,
            Colors.grey[900]!,
          ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.red, width: 3),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: _openInYouTube,
                borderRadius: BorderRadius.circular(60),
                child: const Icon(
                  Icons.play_arrow,
                  size: 60,
                  color: Colors.red,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.youtube_searched_for,
                  color: Colors.white,
                  size: 24,
                ),
                SizedBox(width: 8),
                Text(
                  'YouTube Trailer',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              _errorMessage ??
                  (kIsWeb
                      ? 'Trailer sẽ mở trong tab mới\ndo hạn chế bảo mật của trình duyệt'
                      : 'Nhấn để xem trailer chất lượng cao'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 16,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingPlayer() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey[900],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Colors.red,
            strokeWidth: 3,
          ),
          SizedBox(height: 20),
          Text(
            'Đang tải trailer...',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
} 