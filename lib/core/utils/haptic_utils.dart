import 'package:flutter/services.dart';

class HapticUtils {
  // Light haptic feedback for subtle interactions
  static void light() {
    HapticFeedback.lightImpact();
  }

  // Medium haptic feedback for standard interactions
  static void medium() {
    HapticFeedback.mediumImpact();
  }

  // Heavy haptic feedback for important interactions
  static void heavy() {
    HapticFeedback.heavyImpact();
  }

  // Selection haptic feedback for picker/slider interactions
  static void selection() {
    HapticFeedback.selectionClick();
  }

  // Vibration pattern for notifications
  static void notification() {
    HapticFeedback.vibrate();
  }

  // Success haptic feedback (medium + pause + light)
  static Future<void> success() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  // Error haptic feedback (heavy + pause + heavy)
  static Future<void> error() async {
    HapticFeedback.heavyImpact();
    await Future.delayed(const Duration(milliseconds: 150));
    HapticFeedback.heavyImpact();
  }

  // Warning haptic feedback (medium + pause + medium + pause + light)
  static Future<void> warning() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 100));
    HapticFeedback.lightImpact();
  }

  // Favorite toggle haptic feedback
  static void favorite({required bool isFavorite}) {
    if (isFavorite) {
      // Adding to favorite - positive feedback
      HapticFeedback.mediumImpact();
    } else {
      // Removing from favorite - neutral feedback
      HapticFeedback.lightImpact();
    }
  }

  // Button press haptic feedback
  static void buttonPress({bool isPrimary = false}) {
    if (isPrimary) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  // Long press haptic feedback
  static void longPress() {
    HapticFeedback.heavyImpact();
  }

  // Swipe haptic feedback
  static void swipe() {
    HapticFeedback.selectionClick();
  }

  // Movie card tap haptic feedback
  static void movieTap() {
    HapticFeedback.lightImpact();
  }

  // Search feedback
  static void search() {
    HapticFeedback.selectionClick();
  }

  // Theme change feedback
  static void themeChange() {
    HapticFeedback.mediumImpact();
  }

  // Navigation feedback
  static void navigation() {
    HapticFeedback.lightImpact();
  }

  // Refresh feedback
  static void refresh() {
    HapticFeedback.mediumImpact();
  }
} 