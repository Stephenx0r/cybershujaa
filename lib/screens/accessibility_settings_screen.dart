import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/accessibility_service.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../providers/app_providers.dart';

class AccessibilitySettingsScreen extends ConsumerStatefulWidget {
  const AccessibilitySettingsScreen({super.key});

  @override
  ConsumerState<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends ConsumerState<AccessibilitySettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final accessibilityService = ref.watch(accessibilityServiceProvider);
    final themeService = ref.watch(themeServiceProvider);
    final languageService = ref.watch(languageServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.getLocalizedScreenTitle('accessibility_settings')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // High Contrast Mode
          Card(
            child: SwitchListTile(
              title: Text(languageService.getLocalizedScreenTitle('high_contrast_mode')),
              subtitle: Text(languageService.getLocalizedSubtitle('enhance_color_contrast')),
              value: accessibilityService.isHighContrastEnabled,
              onChanged: (value) {
                accessibilityService.toggleHighContrast();
                themeService.updateHighContrast(value);
              },
              secondary: const Icon(Icons.contrast),
            ),
          ),
          const SizedBox(height: 16),

          // Screen Reader Support
          Card(
            child: SwitchListTile(
              title: Text(languageService.getLocalizedScreenTitle('screen_reader_support')),
              subtitle: Text(languageService.getLocalizedSubtitle('enable_enhanced_screen_reader')),
              value: accessibilityService.isScreenReaderEnabled,
              onChanged: (value) {
                accessibilityService.toggleScreenReader();
              },
              secondary: const Icon(Icons.accessibility),
            ),
          ),
          const SizedBox(height: 16),

          // Reduced Motion
          Card(
            child: SwitchListTile(
              title: Text(languageService.getLocalizedScreenTitle('reduced_motion')),
              subtitle: Text(languageService.getLocalizedSubtitle('reduce_animations')),
              value: accessibilityService.isReducedMotionEnabled,
              onChanged: (value) {
                accessibilityService.toggleReducedMotion();
              },
              secondary: const Icon(Icons.motion_photos_pause),
            ),
          ),
          const SizedBox(height: 16),

          // Large Text
          Card(
            child: SwitchListTile(
              title: Text(languageService.getLocalizedScreenTitle('large_text')),
              subtitle: Text(languageService.getLocalizedSubtitle('increase_text_size')),
              value: accessibilityService.isLargeTextEnabled,
              onChanged: (value) {
                accessibilityService.toggleLargeText();
              },
              secondary: const Icon(Icons.text_fields),
            ),
          ),
          const SizedBox(height: 16),

          // Text Scale Factor Slider
          if (accessibilityService.isLargeTextEnabled) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${languageService.getLocalizedScreenTitle('large_text')}: ${accessibilityService.textScaleFactor.toStringAsFixed(1)}x',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Slider(
                      value: accessibilityService.textScaleFactor,
                      min: 0.8,
                      max: 3.0,
                      divisions: 22,
                      label: '${accessibilityService.textScaleFactor.toStringAsFixed(1)}x',
                      onChanged: (value) {
                        accessibilityService.setTextScaleFactor(value);
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '0.8x',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        Text(
                          '3.0x',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Reset Settings Button
          Card(
            child: ListTile(
              title: Text(languageService.getLocalizedScreenTitle('reset_settings')),
              subtitle: Text(
                languageService.getLocalizedCommonPhrase('warning_action_cannot_undo'),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
              leading: const Icon(Icons.restore, color: Colors.orange),
              onTap: () => _showResetDialog(context, languageService),
            ),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageService.getLocalizedScreenTitle('reset_settings')),
          content: Text(
            languageService.getLocalizedCommonPhrase('this_will_reset'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageService.getLocalizedButtonText('cancel')),
            ),
            TextButton(
              onPressed: () {
                ref.read(accessibilityServiceProvider).resetAllSettings();
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(languageService.getLocalizedButtonText('reset')),
                  ),
                );
              },
              child: Text(languageService.getLocalizedButtonText('reset')),
            ),
          ],
        );
      },
    );
  }
}

