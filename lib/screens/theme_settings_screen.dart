import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../providers/app_providers.dart';

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeService = ref.watch(themeServiceProvider);
    final languageService = ref.watch(languageServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.getLocalizedScreenTitle('theme_mode')),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageService.getLocalizedCommonPhrase('theme_mode'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildThemeModeSelector(ref, themeService, languageService),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    languageService.getLocalizedCommonPhrase('display_options'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildDisplayOptions(ref, themeService, languageService),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeModeSelector(WidgetRef ref, ThemeService themeService, LanguageService languageService) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: Text(languageService.getLocalizedLightModeText()),
          value: ThemeMode.light,
          groupValue: themeService.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeService.setThemeMode(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text(languageService.getLocalizedDarkModeText()),
          value: ThemeMode.dark,
          groupValue: themeService.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeService.setThemeMode(value);
            }
          },
        ),
        RadioListTile<ThemeMode>(
          title: Text(languageService.getLocalizedSystemDefaultText()),
          value: ThemeMode.system,
          groupValue: themeService.themeMode,
          onChanged: (ThemeMode? value) {
            if (value != null) {
              themeService.setThemeMode(value);
            }
          },
        ),
      ],
    );
  }

  Widget _buildDisplayOptions(WidgetRef ref, ThemeService themeService, LanguageService languageService) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(languageService.getLocalizedHighContrastText()),
          subtitle: Text(languageService.getLocalizedHighContrastDescriptionText()),
          value: themeService.isHighContrast,
          onChanged: (bool value) {
            themeService.updateHighContrast(value);
          },
        ),
        SwitchListTile(
          title: Text(languageService.getLocalizedLargeTextText()),
          subtitle: Text(languageService.getLocalizedLargeTextDescriptionText()),
          value: themeService.textScaleFactor > 1.0,
          onChanged: (bool value) {
            themeService.setTextScaleFactor(value ? 1.3 : 1.0);
          },
        ),
      ],
    );
  }
}
