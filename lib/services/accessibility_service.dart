import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccessibilityService extends ChangeNotifier {
  static const String _screenReaderKey = 'screen_reader_enabled';
  static const String _reducedMotionKey = 'reduced_motion_enabled';
  static const String _highContrastKey = 'high_contrast_enabled';
  static const String _largeTextKey = 'large_text_enabled';
  static const String _textScaleKey = 'text_scale_factor';
  
  bool _isScreenReaderEnabled = false;
  bool _isReducedMotionEnabled = false;
  bool _isHighContrastEnabled = false;
  bool _isLargeTextEnabled = false;
  double _textScaleFactor = 1.0;
  
  // Getters
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isReducedMotionEnabled => _isReducedMotionEnabled;
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  double get textScaleFactor => _textScaleFactor;
  
  AccessibilityService() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isScreenReaderEnabled = prefs.getBool(_screenReaderKey) ?? false;
      _isReducedMotionEnabled = prefs.getBool(_reducedMotionKey) ?? false;
      _isHighContrastEnabled = prefs.getBool(_highContrastKey) ?? false;
      _isLargeTextEnabled = prefs.getBool(_largeTextKey) ?? false;
      _textScaleFactor = prefs.getDouble(_textScaleKey) ?? 1.0;
      notifyListeners();
    } catch (e) {
      print('Error loading accessibility preferences: $e');
    }
  }
  
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_screenReaderKey, _isScreenReaderEnabled);
      await prefs.setBool(_reducedMotionKey, _isReducedMotionEnabled);
      await prefs.setBool(_highContrastKey, _isHighContrastEnabled);
      await prefs.setBool(_largeTextKey, _isLargeTextEnabled);
      await prefs.setDouble(_textScaleKey, _textScaleFactor);
    } catch (e) {
      print('Error saving accessibility preferences: $e');
    }
  }
  
  // Screen Reader Support
  void setScreenReaderEnabled(bool enabled) {
    if (_isScreenReaderEnabled != enabled) {
      _isScreenReaderEnabled = enabled;
      _savePreferences();
      notifyListeners();
    }
  }
  
  void toggleScreenReader() {
    setScreenReaderEnabled(!_isScreenReaderEnabled);
  }
  
  // Reduced Motion Support
  void setReducedMotionEnabled(bool enabled) {
    if (_isReducedMotionEnabled != enabled) {
      _isReducedMotionEnabled = enabled;
      _savePreferences();
      notifyListeners();
    }
  }
  
  void toggleReducedMotion() {
    setReducedMotionEnabled(!_isReducedMotionEnabled);
  }
  
  // High Contrast Support
  void setHighContrastEnabled(bool enabled) {
    if (_isHighContrastEnabled != enabled) {
      _isHighContrastEnabled = enabled;
      _savePreferences();
      notifyListeners();
    }
  }
  
  void toggleHighContrast() {
    setHighContrastEnabled(!_isHighContrastEnabled);
  }
  
  // Large Text Support
  void setLargeTextEnabled(bool enabled) {
    if (_isLargeTextEnabled != enabled) {
      _isLargeTextEnabled = enabled;
      _savePreferences();
      notifyListeners();
    }
  }
  
  void toggleLargeText() {
    setLargeTextEnabled(!_isLargeTextEnabled);
  }
  
  // Text Scale Factor Support
  void setTextScaleFactor(double factor) {
    // Clamp text scale factor between 0.8 and 3.0 for accessibility
    final clampedFactor = factor.clamp(0.8, 3.0);
    if (_textScaleFactor != clampedFactor) {
      _textScaleFactor = clampedFactor;
      _savePreferences();
      notifyListeners();
    }
  }
  
  // Accessibility Helper Methods
  
  /// Get appropriate animation duration based on reduced motion setting
  Duration getAnimationDuration(Duration defaultDuration) {
    if (_isReducedMotionEnabled) {
      return Duration.zero;
    }
    return defaultDuration;
  }
  
  /// Get appropriate text scale factor based on large text setting
  double getTextScaleFactor() {
    if (_isLargeTextEnabled) {
      return _textScaleFactor;
    }
    return 1.0;
  }
  
  /// Create semantic label for screen readers
  String createSemanticLabel(String label, {String? hint, String? value}) {
    if (!_isScreenReaderEnabled) return label;
    
    final parts = <String>[label];
    if (hint != null) parts.add(hint);
    if (value != null) parts.add('Value: $value');
    
    return parts.join('. ');
  }
  
  /// Get accessibility status summary
  Map<String, dynamic> getAccessibilityStatus() {
    return {
      'screenReader': _isScreenReaderEnabled,
      'reducedMotion': _isReducedMotionEnabled,
      'highContrast': _isHighContrastEnabled,
      'largeText': _isLargeTextEnabled,
      'textScaleFactor': _textScaleFactor,
    };
  }
  
  /// Reset all accessibility settings to default
  void resetToDefaults() {
    _isScreenReaderEnabled = false;
    _isReducedMotionEnabled = false;
    _isHighContrastEnabled = false;
    _isLargeTextEnabled = false;
    _textScaleFactor = 1.0;
    _savePreferences();
    notifyListeners();
  }
  
  /// Reset all settings (alias for resetToDefaults)
  void resetAllSettings() {
    resetToDefaults();
  }
}

