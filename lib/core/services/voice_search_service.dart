import 'dart:async';
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceSearchService {
  static final VoiceSearchService _instance = VoiceSearchService._internal();
  factory VoiceSearchService() => _instance;
  VoiceSearchService._internal();

  late stt.SpeechToText _speech;
  bool _isInitialized = false;
  bool _isListening = false;
  String _lastWords = '';
  
  // Stream controllers for listening to voice search events
  final _listeningController = StreamController<bool>.broadcast();
  final _speechResultController = StreamController<String>.broadcast();
  final _errorController = StreamController<String>.broadcast();

  // Getters for streams
  Stream<bool> get listeningStream => _listeningController.stream;
  Stream<String> get speechResultStream => _speechResultController.stream;
  Stream<String> get errorStream => _errorController.stream;

  // Getters for state
  bool get isListening => _isListening;
  bool get isInitialized => _isInitialized;
  String get lastWords => _lastWords;

  /// Initialize the speech recognition service
  Future<bool> initialize() async {
    if (_isInitialized) return true;

    try {
      _speech = stt.SpeechToText();
      bool available = await _speech.initialize(
        onStatus: _onSpeechStatus,
        onError: _onSpeechError,
        debugLogging: false,
      );

      if (available) {
        _isInitialized = true;
        print('🎤 Voice search service initialized successfully');
        return true;
      } else {
        print('❌ Speech recognition not available');
        _errorController.add('Speech recognition not available on this device');
        return false;
      }
    } catch (e) {
      print('❌ Error initializing speech recognition: $e');
      _errorController.add('Failed to initialize voice search: ${e.toString()}');
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
    if (!_isInitialized) {
      bool initialized = await initialize();
      if (!initialized) return false;
    }

    if (_isListening) {
      print('⚠️ Already listening');
      return true;
    }

    // Check permission first
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
  Future<void> cancel() async {
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

  /// Get available locales for speech recognition
  Future<List<stt.LocaleName>> getAvailableLocales() async {
    if (!_isInitialized) {
      await initialize();
    }
    
    try {
      return await _speech.locales();
    } catch (e) {
      print('❌ Error getting locales: $e');
      return [];
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

  /// Clean up resources
  void dispose() {
    _listeningController.close();
    _speechResultController.close();
    _errorController.close();
  }
} 