import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_core/shared_core.dart';
import '../providers/app_providers.dart';
import '../services/language_service.dart';
import '../services/social_sharing_service.dart';

import '../models/user_model.dart' as local_models;
import '../utils/app_theme.dart';
import 'accessibility_settings_screen.dart';
import 'theme_settings_screen.dart';
import 'language_settings_screen.dart';
import 'notification_settings_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> with WidgetsBindingObserver {
  int _userLevel = 1;
  int _userXp = 0;
  int _nextLevelXp = 1000;
  double _levelProgress = 0.0;
  int _currentStreak = 0;

  @override
  void initState() {
    super.initState();
    _loadUserProgress();
    
    // Listen for app lifecycle changes to refresh progress when returning
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Refresh progress when app becomes active (returning from mission)
    if (state == AppLifecycleState.resumed) {
      _loadUserProgress();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadUserProgress() async {
    try {
      print('=== PROFILE SCREEN: LOADING USER PROGRESS ===');
      final progressService = ref.read(progressServiceProvider);
      print('Progress service obtained');
      
      final userProgress = await progressService.getUserProgress();
      print('User progress result: ${userProgress != null ? "SUCCESS" : "NULL"}');
      
      if (userProgress != null && mounted) {
        print('Setting user data: Level ${userProgress.level}, XP ${userProgress.xp}');
        setState(() {
          _userLevel = userProgress.level;
          _userXp = userProgress.xp;
          _nextLevelXp = userProgress.getNextLevelXp();
          _levelProgress = userProgress.getLevelProgress() / 100.0;
          _currentStreak = userProgress.streak.currentStreak ?? 0;
        });
        print('User progress loaded successfully');
      } else {
        print('No user progress data');
      }
    } catch (e, stackTrace) {
      print('=== PROFILE SCREEN: ERROR LOADING USER PROGRESS ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
    }
  }

  @override
  Widget build(BuildContext context) {
    final appUser = ref.watch(appUserProvider);
    final languageService = ref.watch(languageServiceProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageService.getLocalizedScreenTitle('profile'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 22,
            letterSpacing: 0.5,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.primaryPurple,
                AppTheme.primaryDark,
                AppTheme.primaryLight.withOpacity(0.8),
              ],
              stops: const [0.0, 0.6, 1.0],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Advanced settings coming soon!')),
              );
            },
            tooltip: 'Settings',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: appUser.when(
        data: (user) {
          if (user == null) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return RefreshIndicator(
            onRefresh: _loadUserProgress,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  _buildProfileHeader(user),
                  const SizedBox(height: 24),
                  _buildAgentStatusCard(user),
                  const SizedBox(height: 24),
                  _buildSettingsSection(context, languageService, ref, user),
                  // Add bottom padding to ensure logout button is above bottom navigation
                  const SizedBox(height: 100),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildProfileHeader(AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: user.photoUrl != null ? NetworkImage(user.photoUrl!) : null,
              child: user.photoUrl == null ? Text(
                user.displayName[0].toUpperCase(),
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ) : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.displayName,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              user.email,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem('Level', _userLevel.toString(), Icons.star),
                _buildStatItem('XP', _userXp.toString(), Icons.flash_on),
                _buildStatItem('Gems', user.gems.toString(), Icons.diamond),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => SocialSharingService.shareProgressSummary(_convertAppUserToUserModel(user)),
              icon: const Icon(Icons.share),
              label: const Text('Share Progress'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Colors.blue),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildAgentStatusCard(AppUser user) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final completedMissions = user.missionProgress.where((m) => m.isCompleted).length;
    final inProgressMissions = user.missionProgress.where((m) => !m.isCompleted && m.progress > 0).length;
    final availableMissions = 10;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark 
            ? [
                const Color(0xFF0D1117), // GitHub Dark
                const Color(0xFF161B22), // GitHub Darker
              ]
            : [
                const Color(0xFFF6F8FA), // GitHub Light
                const Color(0xFFFFFFFF), // White
              ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Colors.black.withOpacity(0.3)
              : Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryPurple,
                      AppTheme.primaryLight,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AGENT STATUS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                        letterSpacing: 0.8,
                      ),
                    ),
                    Text(
                      'CYBERSECURITY OPS',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF24292F),
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentGreen.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppTheme.accentGreen.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'ACTIVE',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 8,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.accentGreen,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Compact stats grid - 2 rows of 3
          Row(
            children: [
              Expanded(
                child: _buildCompactStatItem(
                  icon: Icons.terminal,
                  label: 'LEVEL',
                  value: '${_userLevel}',
                  color: AppTheme.accentOrange,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatItem(
                  icon: Icons.memory,
                  label: 'XP',
                  value: '${_userXp}',
                  color: AppTheme.accentBlue,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatItem(
                  icon: Icons.local_fire_department,
                  label: 'STREAK',
                  value: '${_currentStreak}',
                  color: AppTheme.accentRed,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Mission stats row
          Row(
            children: [
              Expanded(
                child: _buildCompactStatItem(
                  icon: Icons.check_circle,
                  label: 'COMPLETED',
                  value: '$completedMissions',
                  color: AppTheme.accentGreen,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatItem(
                  icon: Icons.pending_actions,
                  label: 'IN_PROGRESS',
                  value: '$inProgressMissions',
                  color: AppTheme.primaryPurple,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactStatItem(
                  icon: Icons.lock_open,
                  label: 'AVAILABLE',
                  value: '$availableMissions',
                  color: AppTheme.primaryLight,
                  isDark: isDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Compact progress bar
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'LEVEL_PROGRESS',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
                      letterSpacing: 0.8,
                    ),
                  ),
                  Text(
                    '${_userXp} / ${_nextLevelXp} XP',
                    style: TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isDark ? const Color(0xFFF0F6FC) : const Color(0xFF24292F),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF21262D) : const Color(0xFFF1F3F4),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE),
                  ),
                ),
                child: FractionallySizedBox(
                  widthFactor: _levelProgress.clamp(0.0, 1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.primaryPurple,
                          AppTheme.primaryLight,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCompactStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0D1117) : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 16,
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'monospace',
              fontSize: 8,
              fontWeight: FontWeight.bold,
              color: isDark ? const Color(0xFF8B949E) : const Color(0xFF656D76),
              letterSpacing: 0.5,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }





  Widget _buildSettingsSection(BuildContext context, LanguageService languageService, WidgetRef ref, AppUser user) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.accessibility),
              title: Text(languageService.getLocalizedScreenTitle('accessibility_settings')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AccessibilitySettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.palette),
              title: Text(languageService.getLocalizedScreenTitle('theme_mode')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ThemeSettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(languageService.getLocalizedScreenTitle('language')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const LanguageSettingsScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(languageService.getLocalizedScreenTitle('push_notifications')),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationSettingsScreen(),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.green),
              title: Text(
                'Share Progress',
                style: const TextStyle(color: Colors.green),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.green),
              onTap: () => _showSocialSharingOptions(context, ref, user),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: Text(
                languageService.getLocalizedButtonText('logout'),
                style: const TextStyle(color: Colors.red),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, color: Colors.red),
              onTap: () => _showLogoutDialog(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    final languageService = ref.read(languageServiceProvider);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageService.getLocalizedButtonText('logout')),
          content: Text(languageService.getLocalizedCommonPhrase('logout_confirmation')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(languageService.getLocalizedButtonText('cancel')),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _performLogout(ref);
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(languageService.getLocalizedButtonText('logout')),
            ),
          ],
        );
      },
    );
  }

  void _showSocialSharingOptions(BuildContext context, WidgetRef ref, AppUser user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Share Your Progress'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.share, color: Colors.blue),
                title: const Text('Share Progress Summary'),
                subtitle: const Text('Share your overall progress'),
                onTap: () {
                  Navigator.of(context).pop();
                  SocialSharingService.shareProgressSummary(_convertAppUserToUserModel(user));
                },
              ),
              ListTile(
                leading: const Icon(Icons.local_fire_department, color: Colors.orange),
                title: const Text('Share Daily Streak'),
                subtitle: const Text('Share your current streak'),
                onTap: () {
                  Navigator.of(context).pop();
                  SocialSharingService.shareStreak(_convertAppUserToUserModel(user));
                },
              ),
              ListTile(
                leading: const Icon(Icons.star, color: Colors.amber),
                title: const Text('Share Level & XP'),
                subtitle: const Text('Share your current level'),
                onTap: () {
                  Navigator.of(context).pop();
                  SocialSharingService.shareLevelUp(_userLevel, _userXp);
                },
              ),
              ListTile(
                leading: const Icon(Icons.favorite, color: Colors.red),
                title: const Text('Share App Review'),
                subtitle: const Text('Help others discover the app'),
                onTap: () {
                  Navigator.of(context).pop();
                  SocialSharingService.shareAppReview();
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(WidgetRef ref) async {
    try {
      final authService = ref.read(authServiceProvider);
      await authService.signOut();
      
      // Note: We can't show a SnackBar here since we're logging out
      // The user will be redirected to login screen automatically
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Helper function to convert AppUser to UserModel for SocialSharingService
  local_models.UserModel _convertAppUserToUserModel(AppUser appUser) {
    return local_models.UserModel(
      uid: appUser.uid,
      email: appUser.email,
      displayName: appUser.displayName,
      photoUrl: appUser.photoUrl,
      level: _userLevel,
      xp: _userXp,
      gems: appUser.gems,
      achievements: appUser.achievements.map((a) => local_models.Achievement(
        id: a.id,
        title: a.title,
        description: a.description,
        iconUrl: a.iconUrl,
        gemReward: a.gemReward,
        xpReward: a.xpReward,
        isUnlocked: a.isUnlocked,
        unlockedAt: a.unlockedAt,
      )).toList(),
      missionProgress: appUser.missionProgress.map((m) => local_models.MissionProgress(
        missionId: m.missionId,
        isCompleted: m.isCompleted,
        progress: m.progress,
        startedAt: m.startedAt,
        completedAt: m.completedAt,
      )).toList(),
      storyProgress: appUser.storyProgress,
      streak: local_models.StreakData(
        currentStreak: _currentStreak,
        longestStreak: appUser.streak.longestStreak,
        lastLoginDate: appUser.streak.lastLoginDate,
        streakDates: appUser.streak.streakDates,
      ),
      createdAt: appUser.createdAt,
      lastLoginAt: appUser.lastLoginAt,
    );
  }
}
