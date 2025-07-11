import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:mivi/core/services/movie_soundtrack_service.dart';

class SoundtrackAudioService {
  static final SoundtrackAudioService _instance = SoundtrackAudioService._internal();
  factory SoundtrackAudioService() => _instance;
  SoundtrackAudioService._internal();

  late AudioPlayer _audioPlayer;
  bool _isInitialized = false;
  
  // Current playback state
  SoundtrackTrack? _currentTrack;
  PlayerState _playerState = PlayerState.stopped;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  
  // Stream controllers for reactive updates
  final _playerStateController = StreamController<PlayerState>.broadcast();
  final _positionController = StreamController<Duration>.broadcast();
  final _durationController = StreamController<Duration>.broadcast();
  final _currentTrackController = StreamController<SoundtrackTrack?>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<PlayerState> get playerStateStream => _playerStateController.stream;
  Stream<Duration> get positionStream => _positionController.stream;
  Stream<Duration> get durationStream => _durationController.stream;
  Stream<SoundtrackTrack?> get currentTrackStream => _currentTrackController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Getters for current state
  SoundtrackTrack? get currentTrack => _currentTrack;
  PlayerState get playerState => _playerState;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  bool get isStopped => _playerState == PlayerState.stopped;
  bool get isInitialized => _isInitialized;

  /// Initialize the audio player
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _audioPlayer = AudioPlayer();
      
      // Listen to player state changes
      _audioPlayer.onPlayerStateChanged.listen((PlayerState state) {
        _playerState = state;
        _playerStateController.add(state);
        print('🎵 Audio player state: $state');
      });

      // Listen to position changes
      _audioPlayer.onPositionChanged.listen((Duration position) {
        _currentPosition = position;
        _positionController.add(position);
      });

      // Listen to duration changes
      _audioPlayer.onDurationChanged.listen((Duration duration) {
        _totalDuration = duration;
        _durationController.add(duration);
        print('🎵 Track duration: ${duration.inSeconds}s');
      });

      // Listen to player completion
      _audioPlayer.onPlayerComplete.listen((_) {
        _currentPosition = Duration.zero;
        _positionController.add(Duration.zero);
        print('🎵 Track completed');
      });

      _isInitialized = true;
      print('🎵 Soundtrack audio service initialized');
      return true;
    } catch (e) {
      print('❌ Error initializing audio player: $e');
      _errorController.add('Failed to initialize audio player: ${e.toString()}');
      return false;
    }
  }

  /// Play a soundtrack track
  Future<bool> playTrack(SoundtrackTrack track) async {
    print('🎵 PlayTrack called for: "${track.title}" by "${track.artist}"');
    print('🎵 Audio URL: ${track.audioUrl ?? "NULL"}');
    
    if (!_isInitialized) {
      print('🎵 Audio service not initialized, initializing...');
      bool initialized = await initialize();
      if (!initialized) {
        print('❌ Failed to initialize audio service');
        return false;
      }
    }

    if (track.audioUrl == null || track.audioUrl!.isEmpty) {
      print('❌ No audio URL available for track: ${track.title}');
      _errorController.add('No audio URL available for this track');
      return false;
    }

    try {
      print('🎵 Attempting to play audio from: ${track.audioUrl}');
      
      // Stop current playback if any
      if (_playerState == PlayerState.playing || _playerState == PlayerState.paused) {
        print('🎵 Stopping current playback...');
        await _audioPlayer.stop();
      }

      // Set new track
      _currentTrack = track;
      _currentTrackController.add(track);
      print('🎵 Set current track to: ${track.title}');

      // Play the track
      print('🎵 Starting playback...');
      await _audioPlayer.play(UrlSource(track.audioUrl!));
      
      print('🎵 Successfully started playing: ${track.title} by ${track.artist}');
      return true;
    } catch (e) {
      print('❌ Error playing track "${track.title}": $e');
      print('❌ Error type: ${e.runtimeType}');
      print('❌ Audio URL that failed: ${track.audioUrl}');
      _errorController.add('Failed to play track: ${e.toString()}');
      return false;
    }
  }

  /// Resume playback
  Future<void> resume() async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.resume();
      print('🎵 Resumed playback');
    } catch (e) {
      print('❌ Error resuming: $e');
      _errorController.add('Failed to resume playback');
    }
  }

  /// Pause playback
  Future<void> pause() async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.pause();
      print('🎵 Paused playback');
    } catch (e) {
      print('❌ Error pausing: $e');
      _errorController.add('Failed to pause playback');
    }
  }

  /// Stop playback
  Future<void> stop() async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.stop();
      _currentPosition = Duration.zero;
      _positionController.add(Duration.zero);
      print('🎵 Stopped playback');
    } catch (e) {
      print('❌ Error stopping: $e');
      _errorController.add('Failed to stop playback');
    }
  }

  /// Seek to a specific position
  Future<void> seek(Duration position) async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.seek(position);
      print('🎵 Seeked to: ${position.inSeconds}s');
    } catch (e) {
      print('❌ Error seeking: $e');
      _errorController.add('Failed to seek to position');
    }
  }

  /// Set volume (0.0 to 1.0)
  Future<void> setVolume(double volume) async {
    if (!_isInitialized) return;
    
    try {
      await _audioPlayer.setVolume(volume.clamp(0.0, 1.0));
      print('🎵 Volume set to: ${(volume * 100).round()}%');
    } catch (e) {
      print('❌ Error setting volume: $e');
    }
  }

  /// Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_playerState == PlayerState.playing) {
      await pause();
    } else if (_playerState == PlayerState.paused) {
      await resume();
    }
  }

  /// Check if a track is currently playing
  bool isTrackPlaying(SoundtrackTrack track) {
    return _currentTrack?.title == track.title && 
           _currentTrack?.artist == track.artist && 
           _playerState == PlayerState.playing;
  }

  /// Check if a track is currently paused
  bool isTrackPaused(SoundtrackTrack track) {
    return _currentTrack?.title == track.title && 
           _currentTrack?.artist == track.artist && 
           _playerState == PlayerState.paused;
  }

  /// Check if a track is the current track (playing or paused)
  bool isCurrentTrack(SoundtrackTrack track) {
    return _currentTrack?.title == track.title && 
           _currentTrack?.artist == track.artist;
  }

  /// Get formatted current position
  String get formattedPosition {
    final minutes = _currentPosition.inMinutes;
    final seconds = _currentPosition.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get formatted total duration
  String get formattedDuration {
    final minutes = _totalDuration.inMinutes;
    final seconds = _totalDuration.inSeconds % 60;
    return '${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Get progress as percentage (0.0 to 1.0)
  double get progress {
    if (_totalDuration.inMilliseconds == 0) return 0.0;
    return _currentPosition.inMilliseconds / _totalDuration.inMilliseconds;
  }

  /// Get remaining time
  Duration get remainingTime {
    return _totalDuration - _currentPosition;
  }

  /// Get formatted remaining time
  String get formattedRemainingTime {
    final remaining = remainingTime;
    final minutes = remaining.inMinutes;
    final seconds = remaining.inSeconds % 60;
    return '-${minutes}:${seconds.toString().padLeft(2, '0')}';
  }

  /// Clean up resources
  void dispose() {
    _playerStateController.close();
    _positionController.close();
    _durationController.close();
    _currentTrackController.close();
    _errorController.close();
    
    if (_isInitialized) {
      _audioPlayer.dispose();
    }
  }

  /// Get playback status info
  Map<String, dynamic> getPlaybackInfo() {
    return {
      'isInitialized': _isInitialized,
      'currentTrack': _currentTrack?.toJson(),
      'playerState': _playerState.toString(),
      'position': _currentPosition.inSeconds,
      'duration': _totalDuration.inSeconds,
      'progress': progress,
      'formattedPosition': formattedPosition,
      'formattedDuration': formattedDuration,
    };
  }

  /// Test audio service with a simple sound
  Future<void> testAudioService() async {
    print('🎵 Testing audio service...');
    
    final testTrack = SoundtrackTrack(
      title: "Test Audio",
      artist: "Audio Test",
      audioUrl: "https://commondatastorage.googleapis.com/codeskulptor-demos/DDR_assets/Kangaroo_MusiQue_-_The_Neverwritten_Role_Playing_Game.mp3",
    );
    
    final success = await playTrack(testTrack);
    print('🎵 Audio test result: ${success ? "SUCCESS" : "FAILED"}');
  }
} 