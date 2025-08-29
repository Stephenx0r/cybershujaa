import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../utils/app_theme.dart';
import '../services/language_service.dart';
import '../services/social_sharing_service.dart';
import '../models/user_model.dart';
import '../providers/app_providers.dart';

class LeaderboardScreen extends ConsumerWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageService = ref.watch(languageServiceProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          languageService.getLocalizedScreenTitle('Leaderboard'),
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
          // Trophy icon
          Icon(
            Icons.emoji_events,
            color: AppTheme.accentOrange,
            size: 28,
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .orderBy('xp', descending: true)
            .limit(20)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator.adaptive());
          }
          final docs = snapshot.data!.docs;
          
          return Column(
            children: [
              // Share button at the top
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Get current user data for sharing
                    final appUser = ref.read(appUserProvider);
                    appUser.whenData((user) {
                      if (user != null) {
                        // Find user's rank
                        final userRank = docs.indexWhere((doc) => 
                          doc.data()['email'] == user.email
                        );
                        if (userRank != -1) {
                          // Convert AppUser to UserModel for sharing
                          final userModel = UserModel(
                            uid: user.uid,
                            email: user.email,
                            displayName: user.displayName,
                            photoUrl: user.photoUrl,
                            level: user.level,
                            xp: user.xp,
                            gems: user.gems,
                            achievements: user.achievements.map((a) => Achievement(
                              id: a.id,
                              title: a.title,
                              description: a.description,
                              iconUrl: a.iconUrl,
                              gemReward: a.gemReward,
                              xpReward: a.xpReward,
                              isUnlocked: a.isUnlocked,
                              unlockedAt: a.unlockedAt,
                            )).toList(),
                            missionProgress: user.missionProgress.map((m) => MissionProgress(
                              missionId: m.missionId,
                              isCompleted: m.isCompleted,
                              progress: m.progress,
                              startedAt: m.startedAt,
                              completedAt: m.completedAt,
                            )).toList(),
                            storyProgress: user.storyProgress,
                            streak: StreakData(
                              currentStreak: user.streak.currentStreak,
                              longestStreak: user.streak.longestStreak,
                              lastLoginDate: user.streak.lastLoginDate,
                              streakDates: user.streak.streakDates,
                            ),
                            createdAt: user.createdAt,
                            lastLoginAt: user.lastLoginAt,
                          );
                          SocialSharingService.shareLeaderboard(userModel, userRank + 1);
                        } else {
                          // User not in top 20, show general leaderboard share
                          SocialSharingService.shareCustomMessage(
                            '🏆 Check out the CyberShujaa Leaderboard! '
                            'Join the competition and see how you rank! 🛡️',
                            'CyberShujaa Leaderboard'
                          );
                        }
                      }
                    });
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Leaderboard'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryPurple,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              // Leaderboard list
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.only(top: 8),
                  itemCount: docs.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final data = docs[index].data();
                    final name = (data['displayName'] as String?)?.trim();
                    final email = (data['email'] as String?)?.trim();
                    final xp = (data['xp'] as num?)?.toInt() ?? 0;
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isDark ? Colors.blue[800] : Colors.blue[100],
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isDark ? Colors.white : Colors.blue[800],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        name?.isNotEmpty == true ? name! : (email ?? 'User'),
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      trailing: Text(
                        '$xp XP', 
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.blue[300] : Colors.blue[600],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
