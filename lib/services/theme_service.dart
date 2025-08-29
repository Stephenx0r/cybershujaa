import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const String _themeKey = 'theme_mode';
  static const String _highContrastKey = 'high_contrast_mode';
  static const String _textScaleKey = 'text_scale_factor';
  
  ThemeMode _themeMode = ThemeMode.system;
  bool _isHighContrast = false;
  double _textScaleFactor = 1.0;
  
  ThemeMode get themeMode => _themeMode;
  bool get isHighContrast => _isHighContrast;
  double get textScaleFactor => _textScaleFactor;
  
  // Accessibility getters
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }
  
  bool get isLightMode {
    if (_themeMode == ThemeMode.system) {
      return WidgetsBinding.instance.platformDispatcher.platformBrightness == Brightness.light;
    }
    return _themeMode == ThemeMode.light;
  }
  
  // Get current theme data with accessibility support
  ThemeData get currentTheme {
    if (_isHighContrast) {
      // Return a simple high contrast theme
      return ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        primaryColor: Colors.yellow,
        scaffoldBackgroundColor: Colors.black,
        cardColor: Colors.grey[900],
        textTheme: ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.yellow,
        ),
      );
    }
    
    // Return basic light/dark themes
    if (isDarkMode) {
      return ThemeData.dark();
    } else {
      return ThemeData.light();
    }
  }
  
  ThemeService() {
    _loadPreferences();
  }
  
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load theme mode
      final themeIndex = prefs.getInt(_themeKey) ?? 0;
      _themeMode = ThemeMode.values[themeIndex];
      
      // Load high contrast mode
      _isHighContrast = prefs.getBool(_highContrastKey) ?? false;
      
      // Load text scale factor
      _textScaleFactor = prefs.getDouble(_textScaleKey) ?? 1.0;
      
      notifyListeners();
    } catch (e) {
      print('Error loading theme preferences: $e');
    }
  }
  
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_themeKey, _themeMode.index);
      await prefs.setBool(_highContrastKey, _isHighContrast);
      await prefs.setDouble(_textScaleKey, _textScaleFactor);
    } catch (e) {
      print('Error saving theme preferences: $e');
    }
  }
  
  void setThemeMode(ThemeMode mode) {
    if (_themeMode != mode) {
      print('ThemeService: Changing theme from $_themeMode to $mode');
      _themeMode = mode;
      _savePreferences();
      try {
        notifyListeners();
        print('ThemeService: Theme changed successfully to $mode and listeners notified');
      } catch (e) {
        print('Theme service error: $e');
      }
    } else {
      print('ThemeService: Theme mode already set to $mode, no change needed');
    }
  }
  
  void setHighContrastMode(bool enabled) {
    if (_isHighContrast != enabled) {
      print('ThemeService: Changing high contrast from $_isHighContrast to $enabled');
      _isHighContrast = enabled;
      _savePreferences();
      try {
        notifyListeners();
        print('ThemeService: High contrast changed successfully to $enabled');
      } catch (e) {
        print('Theme service error: $e');
      }
    }
  }
  
  void setTextScaleFactor(double factor) {
    // Clamp text scale factor between 0.8 and 3.0 for accessibility
    final clampedFactor = factor.clamp(0.8, 3.0);
    if (_textScaleFactor != clampedFactor) {
      print('ThemeService: Changing text scale from $_textScaleFactor to $clampedFactor');
      _textScaleFactor = clampedFactor;
      _savePreferences();
      try {
        notifyListeners();
        print('ThemeService: Text scale changed successfully to $clampedFactor');
      } catch (e) {
        print('Theme service error: $e');
      }
    }
  }
  
  // Convenience methods for theme modes
  void setLightTheme() {
    setThemeMode(ThemeMode.light);
  }
  
  void setDarkTheme() {
    setThemeMode(ThemeMode.dark);
  }
  
  void setSystemTheme() {
    setThemeMode(ThemeMode.system);
  }
  
  // Accessibility convenience methods
  void toggleHighContrast() {
    setHighContrastMode(!_isHighContrast);
  }
  
  /// Update high contrast mode (alias for setHighContrastMode)
  void updateHighContrast(bool enabled) {
    setHighContrastMode(enabled);
  }
  
  void increaseTextSize() {
    setTextScaleFactor(_textScaleFactor + 0.1);
  }
  
  void decreaseTextSize() {
    setTextScaleFactor(_textScaleFactor - 0.1);
  }
  
  void resetTextSize() {
    setTextScaleFactor(1.0);
  }
  
  // Get accessibility status summary
  Map<String, dynamic> getAccessibilityStatus() {
    return {
      'isDarkMode': isDarkMode,
      'isHighContrast': _isHighContrast,
      'textScaleFactor': _textScaleFactor,
      'themeMode': _themeMode.name,
    };
  }
}
