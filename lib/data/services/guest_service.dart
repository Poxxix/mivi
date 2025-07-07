import 'package:shared_preferences/shared_preferences.dart';

class GuestService {
  static const String _guestModeKey = 'is_guest_mode';
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';

  // Singleton pattern
  static final GuestService _instance = GuestService._internal();
  factory GuestService() => _instance;
  GuestService._internal();

  // Current state
  bool _isGuestMode = false;
  bool _hasSeenOnboarding = false;

  // Getters
  bool get isGuestMode => _isGuestMode;
  bool get hasSeenOnboarding => _hasSeenOnboarding;
  bool get isLoggedIn => !_isGuestMode;

  // Initialize guest service
  Future<void> initialize() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isGuestMode = prefs.getBool(_guestModeKey) ?? false;
      _hasSeenOnboarding = prefs.getBool(_hasSeenOnboardingKey) ?? false;
    } catch (e) {
      print('Error initializing guest service: $e');
      _isGuestMode = false;
      _hasSeenOnboarding = false;
    }
  }

  // Enter guest mode
  Future<bool> enterGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, true);
      await prefs.setBool(_hasSeenOnboardingKey, true);
      _isGuestMode = true;
      _hasSeenOnboarding = true;
      return true;
    } catch (e) {
      print('Error entering guest mode: $e');
      return false;
    }
  }

  // Exit guest mode (when user logs in)
  Future<bool> exitGuestMode() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_guestModeKey, false);
      _isGuestMode = false;
      return true;
    } catch (e) {
      print('Error exiting guest mode: $e');
      return false;
    }
  }

  // Clear all guest data
  Future<bool> clearGuestData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_guestModeKey);
      await prefs.remove(_hasSeenOnboardingKey);
      _isGuestMode = false;
      _hasSeenOnboarding = false;
      return true;
    } catch (e) {
      print('Error clearing guest data: $e');
      return false;
    }
  }

  // Get guest profile info
  Map<String, dynamic> getGuestProfile() {
    return {
      'id': 'guest_user',
      'username': 'Guest User',
      'email': null,
      'isGuest': true,
      'joinedDate': DateTime.now().toIso8601String(),
      'favoriteGenres': [],
      'watchHistory': [],
    };
  }

  // Check if feature is available for guest
  bool isFeatureAvailable(String featureName) {
    // Most features are available for guests
    // Only exclude features that require authentication
    const restrictedFeatures = [
      'sync_across_devices',
      'cloud_backup',
      'social_features',
      'premium_content',
    ];
    
    return !restrictedFeatures.contains(featureName);
  }

  // Get limitations for guest users
  List<String> getGuestLimitations() {
    return [
      'Data is stored locally only',
      'No sync across devices',
      'Limited access to premium content',
      'No social features',
      'Create account to unlock all features',
    ];
  }

  // Get guest benefits message
  String getGuestBenefitsMessage() {
    return 'You\'re browsing as a guest. Create an account to sync your favorites across devices and unlock premium features!';
  }
} 