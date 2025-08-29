import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';
import '../providers/app_providers.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageService = ref.watch(languageServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.getLocalizedScreenTitle('language')),
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
                    languageService.getLocalizedSelectLanguageText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildLanguageSelector(context, languageService),
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
                    languageService.getLocalizedLanguageInfoText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageService.getLocalizedLanguageDescriptionText(),
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageSelector(BuildContext context, LanguageService languageService) {
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('English'),
          subtitle: const Text('English'),
          value: 'en',
          groupValue: languageService.currentLanguage,
          onChanged: (String? value) {
            if (value != null) {
              languageService.setLanguage(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(languageService.getLocalizedCommonPhrase('language_changed')),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        RadioListTile<String>(
          title: const Text('Swahili'),
          subtitle: const Text('Kiswahili'),
          value: 'sw',
          groupValue: languageService.currentLanguage,
          onChanged: (String? value) {
            if (value != null) {
              languageService.setLanguage(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(languageService.getLocalizedCommonPhrase('language_changed')),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        RadioListTile<String>(
          title: const Text('Kikuyu'),
          subtitle: const Text('Gĩkũyũ'),
          value: 'ki',
          groupValue: languageService.currentLanguage,
          onChanged: (String? value) {
            if (value != null) {
              languageService.setLanguage(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(languageService.getLocalizedCommonPhrase('language_changed')),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
        RadioListTile<String>(
          title: const Text('Luo'),
          subtitle: const Text('Dholuo'),
          value: 'lu',
          groupValue: languageService.currentLanguage,
          onChanged: (String? value) {
            if (value != null) {
              languageService.setLanguage(value);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(languageService.getLocalizedCommonPhrase('language_changed')),
                  duration: const Duration(seconds: 2),
                ),
              );
            }
          },
        ),
      ],
    );
  }
}
