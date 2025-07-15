import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceAIService {
  static final VoiceAIService _instance = VoiceAIService._internal();
  factory VoiceAIService() => _instance;
  VoiceAIService._internal();

  // Speech to Text
  late stt.SpeechToText _speech;
  bool _isSTTInitialized = false;
  bool _isListening = false;
  String _lastWords = '';

  // Text to Speech
  late FlutterTts _tts;
  bool _isTTSInitialized = false;
  bool _isSpeaking = false;
  
  // Stream controllers for voice events
  final _listeningController = StreamController<bool>.broadcast();
  final _speechResultController = StreamController<String>.broadcast();
  final _finalResultController = StreamController<String>.broadcast();
  final _speakingController = StreamController<bool>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<String> get speechResultStream => _speechResultController.stream;
  Stream<String> get finalResultStream => _finalResultController.stream;
  Stream<bool> get speakingStream => _speakingController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Getters for state
  bool get isListening => _isListening;
  bool get isSpeaking => _isSpeaking;
  bool get isInitialized => _isSTTInitialized && _isTTSInitialized;
  String get lastWords => _lastWords;

  /// Initialize both speech recognition and text-to-speech
  Future<bool> initialize() async {
    if (isInitialized) return true;

    try {
      // Initialize Speech-to-Text
      final sttSuccess = await _initializeSTT();
      
      // Initialize Text-to-Speech
      final ttsSuccess = await _initializeTTS();

      if (sttSuccess && ttsSuccess) {
        print('🎤🔊 Voice AI service initialized successfully');
        return true;
      } else {
        print('❌ Voice AI service initialization failed');
        _errorController.add('Voice AI service initialization failed');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing Voice AI service: $e');
      _errorController.add('Failed to initialize Voice AI: ${e.toString()}');
      return false;
    }
  }

  /// Initialize Speech-to-Text
  Future<bool> _initializeSTT() async {
    if (_isSTTInitialized) return true;

    try {
      _speech = stt.SpeechToText();
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );

      if (available) {
        _isSTTInitialized = true;
        print('🎤 Speech-to-Text initialized');
        return true;
      } else {
        print('❌ Speech recognition not available');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing STT: $e');
      return false;
    }
  }

  /// Initialize Text-to-Speech
  Future<bool> _initializeTTS() async {
    if (_isTTSInitialized) return true;

    try {
      _tts = FlutterTts();

      // Configure TTS settings
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.9);
      await _tts.setVolume(0.8);
      await _tts.setPitch(1.0);

      // Set up event handlers
      _tts.setStartHandler(() {
        _isSpeaking = true;
        _speakingController.add(true);
        print('🔊 TTS started speaking');
      });

      _tts.setCompletionHandler(() {
        _isSpeaking = false;
        _speakingController.add(false);
        print('🔊 TTS finished speaking');
      });

      _tts.setErrorHandler((message) {
        _isSpeaking = false;
        _speakingController.add(false);
        print('❌ TTS error: $message');
        _errorController.add('Speech synthesis error: $message');
      });

      _isTTSInitialized = true;
      print('🔊 Text-to-Speech initialized');
      return true;
    } catch (e) {
      print('❌ Error initializing TTS: $e');
      return false;
    }
  }

  /// Check and request microphone permission
  Future<bool> checkPermission() async {
    try {
      var status = await Permission.microphone.status;
      
      if (status.isDenied) {
        status = await Permission.microphone.request();
      }

      if (status.isPermanentlyDenied) {
        _errorController.add('Microphone permission permanently denied. Please enable it in settings.');
        return false;
      }

      return status.isGranted;
    } catch (e) {
      print('❌ Error checking microphone permission: $e');
      _errorController.add('Failed to check microphone permission');
      return false;
    }
  }

  /// Start listening for voice input
  Future<bool> startListening({
    String localeId = 'en_US',
    Duration timeout = const Duration(seconds: 30),
  }) async {
    if (!_isSTTInitialized) {
      bool initialized = await _initializeSTT();
      if (!initialized) return false;
    }

    if (_isListening) {
      print('⚠️ Already listening');
      return true;
    }

    // Stop any ongoing speech first
    if (_isSpeaking) {
      await stopSpeaking();
    }

    // Check permission
    bool hasPermission = await checkPermission();
    if (!hasPermission) {
      return false;
    }

    try {
      await _speech.listen(
        onResult: _onSpeechResult,
        listenFor: timeout,
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        localeId: localeId,
        onSoundLevelChange: null,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );

      _isListening = true;
      _listeningController.add(true);
      print('🎤 Started listening for voice input');
      return true;
    } catch (e) {
      print('❌ Error starting voice recognition: $e');
      _errorController.add('Failed to start voice recognition: ${e.toString()}');
      return false;
    }
  }

  /// Stop listening for voice input
  Future<void> stopListening() async {
    if (!_isListening) return;

    try {
      await _speech.stop();
      _isListening = false;
      _listeningController.add(false);
      print('🛑 Stopped listening for voice input');
    } catch (e) {
      print('❌ Error stopping voice recognition: $e');
      _errorController.add('Failed to stop voice recognition');
    }
  }

  /// Cancel current listening session
  Future<void> cancelListening() async {
    if (!_isListening) return;

    try {
      await _speech.cancel();
      _isListening = false;
      _lastWords = '';
      _listeningController.add(false);
      print('❌ Cancelled voice input');
    } catch (e) {
      print('❌ Error cancelling voice recognition: $e');
    }
  }

  /// Speak the given text
  Future<bool> speak(String text, {bool interrupt = true}) async {
    if (!_isTTSInitialized) {
      bool initialized = await _initializeTTS();
      if (!initialized) return false;
    }

    if (text.trim().isEmpty) return false;

    try {
      // Stop current speech if interrupting
      if (interrupt && _isSpeaking) {
        await stopSpeaking();
      }

      // Clean text for better speech
      final cleanText = _cleanTextForSpeech(text);
      
      // Use safe UTF-8 printing to avoid console errors
      final safeText = _makeSafeForPrinting(cleanText);
      print('🔊 Speaking: "$safeText"');
      
      await _tts.speak(cleanText);
      return true;
    } catch (e) {
      print('❌ Error speaking: $e');
      _errorController.add('Failed to speak: ${e.toString()}');
      return false;
    }
  }

  /// Stop current speech
  Future<void> stopSpeaking() async {
    if (!_isSpeaking) return;

    try {
      await _tts.stop();
      _isSpeaking = false;
      _speakingController.add(false);
      print('🛑 Stopped speaking');
    } catch (e) {
      print('❌ Error stopping speech: $e');
    }
  }

  /// Clean text for better speech synthesis
  String _cleanTextForSpeech(String text) {
    // First, handle any invalid UTF-8 sequences
    String cleaned = _sanitizeUtf8(text);
    
    // Remove all emojis and pictographs using Unicode categories
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F600}-\u{1F64F}]', unicode: true), ''); // Emoticons
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F300}-\u{1F5FF}]', unicode: true), ''); // Misc symbols
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F680}-\u{1F6FF}]', unicode: true), ''); // Transport & Map
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F700}-\u{1F77F}]', unicode: true), ''); // Alchemical symbols
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F780}-\u{1F7FF}]', unicode: true), ''); // Geometric shapes
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F800}-\u{1F8FF}]', unicode: true), ''); // Supplemental arrows
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F900}-\u{1F9FF}]', unicode: true), ''); // Supplemental symbols
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1FA00}-\u{1FA6F}]', unicode: true), ''); // Chess symbols
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1FA70}-\u{1FAFF}]', unicode: true), ''); // Symbols and pictographs
    cleaned = cleaned.replaceAll(RegExp(r'[\u{2600}-\u{26FF}]', unicode: true), ''); // Misc symbols
    cleaned = cleaned.replaceAll(RegExp(r'[\u{2700}-\u{27BF}]', unicode: true), ''); // Dingbats
    cleaned = cleaned.replaceAll(RegExp(r'[\u{FE00}-\u{FE0F}]', unicode: true), ''); // Variation selectors
    cleaned = cleaned.replaceAll(RegExp(r'[\u{1F1E6}-\u{1F1FF}]', unicode: true), ''); // Flags
    
    // Remove other problematic characters
    cleaned = cleaned.replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\u00FF\u0100-\u017F\u0180-\u024F\u1E00-\u1EFF]'), '');
    
    // Replace markdown-style formatting
    cleaned = cleaned.replaceAll(RegExp(r'\*\*(.*?)\*\*'), r'\1'); // Bold
    cleaned = cleaned.replaceAll(RegExp(r'\*(.*?)\*'), r'\1'); // Italic
    cleaned = cleaned.replaceAll(RegExp(r'`(.*?)`'), r'\1'); // Code
    
    // Clean up multiple spaces and newlines
    cleaned = cleaned.replaceAll(RegExp(r'\s+'), ' ');
    cleaned = cleaned.trim();
    
    return cleaned;
  }

  /// Sanitize UTF-8 string by removing invalid sequences
  String _sanitizeUtf8(String text) {
    try {
      // Convert to bytes and back to remove invalid UTF-8 sequences
      final bytes = text.codeUnits;
      final cleanBytes = <int>[];
      
      for (int i = 0; i < bytes.length; i++) {
        final byte = bytes[i];
        // Keep valid UTF-16 code units (avoid surrogate pairs issues)
        if (byte >= 0x20 && byte <= 0xD7FF || byte >= 0xE000 && byte <= 0xFFFD) {
          cleanBytes.add(byte);
        }
      }
      
      return String.fromCharCodes(cleanBytes);
    } catch (e) {
      // If sanitization fails, return a safe fallback
      return text.replaceAll(RegExp(r'[^\x20-\x7E]'), '');
    }
  }

  /// Make text safe for console printing by removing problematic characters
  String _makeSafeForPrinting(String text) {
    try {
      // Remove any remaining problematic characters for console output
      return text.replaceAll(RegExp(r'[^\x20-\x7E\u00A0-\u00FF]'), '');
    } catch (e) {
      return 'Text contains invalid characters';
    }
  }

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isSTTInitialized) {
      await _initializeSTT();
    }
    
    try {
      return await _speech.locales();
    } catch (e) {
      print('❌ Error getting locales: $e');
      return [];
    }
  }

  /// Get available TTS languages
  Future<List<dynamic>> getAvailableTTSLanguages() async {
    if (!_isTTSInitialized) {
      await _initializeTTS();
    }
    
    try {
      return await _tts.getLanguages;
    } catch (e) {
      print('❌ Error getting TTS languages: $e');
      return [];
    }
  }

  /// Configure TTS settings
  Future<void> configureTTS({
    String? language,
    double? speechRate,
    double? volume,
    double? pitch,
  }) async {
    if (!_isTTSInitialized) return;

    try {
      if (language != null) await _tts.setLanguage(language);
      if (speechRate != null) await _tts.setSpeechRate(speechRate);
      if (volume != null) await _tts.setVolume(volume);
      if (pitch != null) await _tts.setPitch(pitch);
    } catch (e) {
      print('❌ Error configuring TTS: $e');
    }
  }

  /// Handle speech recognition results
  void _onSpeechResult(result) {
    _lastWords = result.recognizedWords;
    _speechResultController.add(_lastWords);
    
    print('🎤 Speech result: "${_lastWords}" (confidence: ${result.confidence})');
    
    if (result.finalResult) {
      _isListening = false;
      _listeningController.add(false);
      _finalResultController.add(_lastWords);
      print('✅ Final speech result: "${_lastWords}"');
    }
  }

  /// Handle speech recognition status changes
  void _onSpeechStatus(String status) {
    print('🎤 Speech status: $status');
    
    switch (status) {
      case 'listening':
        _isListening = true;
        _listeningController.add(true);
        break;
      case 'notListening':
        _isListening = false;
        _listeningController.add(false);
        break;
      case 'done':
        _isListening = false;
        _listeningController.add(false);
        break;
    }
  }

  /// Handle speech recognition errors
  void _onSpeechError(error) {
    print('❌ Speech error: ${error.errorMsg}');
    _isListening = false;
    _listeningController.add(false);
    
    String userFriendlyMessage;
    switch (error.errorMsg) {
      case 'error_no_match':
        userFriendlyMessage = 'No speech was recognized. Please try again.';
        break;
      case 'error_busy':
        userFriendlyMessage = 'Speech recognition is busy. Please wait and try again.';
        break;
      case 'error_network':
        userFriendlyMessage = 'Network error. Please check your connection and try again.';
        break;
      case 'error_network_timeout':
        userFriendlyMessage = 'Network timeout. Please try again.';
        break;
      case 'error_audio':
        userFriendlyMessage = 'Audio error. Please check your microphone.';
        break;
      case 'error_client':
        userFriendlyMessage = 'Client error. Please try again.';
        break;
      case 'error_permission':
        userFriendlyMessage = 'Microphone permission denied. Please enable microphone access.';
        break;
      case 'error_too_many_requests':
        userFriendlyMessage = 'Too many requests. Please wait a moment and try again.';
        break;
      case 'error_server':
        userFriendlyMessage = 'Server error. Please try again later.';
        break;
      case 'error_speech_timeout':
        userFriendlyMessage = 'Speech timeout. Please speak more clearly and try again.';
        break;
      default:
        userFriendlyMessage = 'Speech recognition error. Please try again.';
    }
    
    _errorController.add(userFriendlyMessage);
  }

  /// Check if device supports TTS
  Future<bool> isTTSSupported() async {
    try {
      final languages = await getAvailableTTSLanguages();
      return languages.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Check if device supports STT
  Future<bool> isSTTSupported() async {
    try {
      if (!_isSTTInitialized) {
        await _initializeSTT();
      }
      return _isSTTInitialized;
    } catch (e) {
      return false;
    }
  }

  /// Clean up resources
  void dispose() {
    _listeningController.close();
    _speechResultController.close();
    _finalResultController.close();
    _speakingController.close();
    _errorController.close();
    
    if (_isSpeaking) {
      stopSpeaking();
    }
    if (_isListening) {
      cancelListening();
    }
  }

  /// Toggle between listening and not listening
  Future<bool> toggleListening() async {
    if (_isListening) {
      await stopListening();
      return false;
    } else {
      return await startListening();
    }
  }

  /// Get current voice AI status
  Map<String, dynamic> getStatus() {
    return {
      'isInitialized': isInitialized,
      'isListening': _isListening,
      'isSpeaking': _isSpeaking,
      'sttInitialized': _isSTTInitialized,
      'ttsInitialized': _isTTSInitialized,
      'lastWords': _lastWords,
    };
  }
}