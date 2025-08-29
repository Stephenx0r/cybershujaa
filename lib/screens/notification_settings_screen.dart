import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/language_service.dart';
import '../providers/app_providers.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends ConsumerState<NotificationSettingsScreen> {
  bool _dailyReminders = true;
  bool _missionUpdates = true;
  bool _achievementAlerts = true;
  bool _streakReminders = true;
  bool _weeklyReports = false;
  bool _securityAlerts = true;
  bool _communityUpdates = false;

  @override
  Widget build(BuildContext context) {
    final languageService = ref.watch(languageServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(languageService.getLocalizedScreenTitle('push_notifications')),
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
                    languageService.getLocalizedNotificationPreferencesText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildNotificationToggles(languageService),
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
                    languageService.getLocalizedNotificationTimingText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTimingSettings(languageService),
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
                    languageService.getLocalizedNotificationInfoText(),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    languageService.getLocalizedNotificationDescriptionText(),
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

  Widget _buildNotificationToggles(LanguageService languageService) {
    return Column(
      children: [
        SwitchListTile(
          title: Text(languageService.getLocalizedCommonPhrase('daily_reminders')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('daily_reminders_description')),
          value: _dailyReminders,
          onChanged: (bool value) {
            setState(() {
              _dailyReminders = value;
            });
            _saveNotificationSettings();
          },
        ),
        SwitchListTile(
          title: Text(languageService.getLocalizedCommonPhrase('mission_updates')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('mission_updates_description')),
          value: _missionUpdates,
          onChanged: (bool value) {
            setState(() {
              _missionUpdates = value;
            });
            _saveNotificationSettings();
          },
        ),
        SwitchListTile(
          title: Text(languageService.getLocalizedCommonPhrase('achievement_alerts')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('achievement_alerts_description')),
          value: _achievementAlerts,
          onChanged: (bool value) {
            setState(() {
              _achievementAlerts = value;
            });
            _saveNotificationSettings();
          },
        ),
        SwitchListTile(
          title: Text(languageService.getLocalizedCommonPhrase('streak_reminders')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('streak_reminders_description')),
          value: _streakReminders,
          onChanged: (bool value) {
            setState(() {
              _streakReminders = value;
            });
            _saveNotificationSettings();
          },
        ),
        SwitchListTile(
          title: Text(languageService.getLocalizedCommonPhrase('weekly_reports')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('weekly_reports_description')),
          value: _weeklyReports,
          onChanged: (bool value) {
            setState(() {
              _weeklyReports = value;
            });
            _saveNotificationSettings();
          },
        ),
        SwitchListTile(
          title: Text(languageService.getLocalizedCommonPhrase('security_alerts')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('security_alerts_description')),
          value: _securityAlerts,
          onChanged: (bool value) {
            setState(() {
              _securityAlerts = value;
            });
            _saveNotificationSettings();
          },
        ),
        SwitchListTile(
          title: Text(languageService.getLocalizedCommonPhrase('community_updates')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('community_updates_description')),
          value: _communityUpdates,
          onChanged: (bool value) {
            setState(() {
              _communityUpdates = value;
            });
            _saveNotificationSettings();
          },
        ),
      ],
    );
  }

  Widget _buildTimingSettings(LanguageService languageService) {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.access_time),
          title: Text(languageService.getLocalizedCommonPhrase('quiet_hours')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('quiet_hours_description')),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showQuietHoursDialog(context, languageService);
          },
        ),
        ListTile(
          leading: const Icon(Icons.schedule),
          title: Text(languageService.getLocalizedCommonPhrase('reminder_time')),
          subtitle: Text(languageService.getLocalizedCommonPhrase('reminder_time_description')),
          trailing: const Icon(Icons.arrow_forward_ios),
          onTap: () {
            _showReminderTimeDialog(context, languageService);
          },
        ),
      ],
    );
  }

  void _saveNotificationSettings() {
    print('Saving notification settings...');
  }

  void _showQuietHoursDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageService.getLocalizedCommonPhrase('quiet_hours')),
          content: Text(languageService.getLocalizedCommonPhrase('quiet_hours_coming_soon')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageService.getLocalizedCommonPhrase('ok')),
            ),
          ],
        );
      },
    );
  }

  void _showReminderTimeDialog(BuildContext context, LanguageService languageService) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageService.getLocalizedCommonPhrase('reminder_time')),
          content: Text(languageService.getLocalizedCommonPhrase('reminder_time_coming_soon')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageService.getLocalizedCommonPhrase('ok')),
            ),
          ],
        );
      },
    );
  }
}
