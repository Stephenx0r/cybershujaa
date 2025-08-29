import 'package:share_plus/share_plus.dart';
import '../models/mission_models.dart';
import '../models/user_model.dart';

class SocialSharingService {
  /// Share user's achievement
  static Future<void> shareAchievement(UserModel user, Mission mission) async {
    final text = '🎉 I just completed "${mission.title}" in CyberShujaa! '
        'Level ${user.level} and ${user.xp} XP! '
        'Join me in learning cybersecurity! 🛡️\n\n'
        '${mission.description}';
    
    await Share.share(
      text,
      subject: 'My CyberShujaa Achievement: ${mission.title}!',
    );
  }

  /// Share user's daily streak
  static Future<void> shareStreak(UserModel user) async {
    final text = '🔥 I\'m on a ${user.streak.currentStreak} day streak '
        'in CyberShujaa! Learning cybersecurity every day! '
        'Can you beat my streak? 🛡️\n\n'
        'Level ${user.level} • ${user.xp} XP • ${user.gems} Gems';
    
    await Share.share(
      text,
      subject: 'My CyberShujaa Daily Streak!',
    );
  }

  /// Share user's leaderboard position
  static Future<void> shareLeaderboard(UserModel user, int rank) async {
    final text = '🏆 I\'m ranked #$rank on CyberShujaa! '
        'Level ${user.level} with ${user.xp} XP! '
        'Join the competition! 🛡️\n\n'
        '${user.gems} Gems • ${user.streak.currentStreak} Day Streak';
    
    await Share.share(
      text,
      subject: 'My CyberShujaa Leaderboard Position!',
    );
  }

  /// Share skill unlock
  static Future<void> shareSkillUnlock(String skillName, String skillType) async {
    final text = '⚡ I just unlocked "$skillName" skill in CyberShujaa! '
        'Mastering $skillType! '
        'Every skill makes me stronger! 🛡️';
    
    await Share.share(
      text,
      subject: 'New Skill Unlocked in CyberShujaa!',
    );
  }

  /// Share app review request
  static Future<void> shareAppReview() async {
    const text = '⭐ If you love CyberShujaa as much as I do, '
        'please leave a review! It helps other learners discover '
        'this amazing cybersecurity app! 🛡️\n\n'
        'Your feedback makes the app better for everyone!';
    
    await Share.share(
      text,
      subject: 'Help CyberShujaa grow!',
    );
  }

  /// Share custom message
  static Future<void> shareCustomMessage(String message, String subject) async {
    await Share.share(
      message,
      subject: subject,
    );
  }

  /// Share user's progress summary
  static Future<void> shareProgressSummary(UserModel user) async {
    final text = '📊 My CyberShujaa Progress Summary:\n\n'
        '🏆 Level: ${user.level}\n'
        '⭐ XP: ${user.xp}\n'
        '💎 Gems: ${user.gems}\n'
        '🔥 Daily Streak: ${user.streak.currentStreak} days\n'
        '📅 Member since: ${_formatDate(user.createdAt)}\n\n'
        'Join me on this cybersecurity journey! 🛡️';
    
    await Share.share(
      text,
      subject: 'My CyberShujaa Progress Summary!',
    );
  }
  
  static String _formatDate(DateTime? date) {
    if (date == null) return 'Unknown';
    return '${date.month}/${date.day}/${date.year}';
  }

  /// Share mission completion
  static Future<void> shareMissionCompletion(String missionTitle, int xpEarned) async {
    final text = '✅ Just completed "$missionTitle" in CyberShujaa! '
        'Earned ${xpEarned} XP! '
        'Every mission makes me more cyber-secure! 🛡️';
    
    await Share.share(
      text,
      subject: 'Mission Completed in CyberShujaa!',
    );
  }

  /// Share level up
  static Future<void> shareLevelUp(int newLevel, int totalXp) async {
    final text = '🎊 LEVEL UP! I just reached Level $newLevel in CyberShujaa! '
        'Total XP: ${totalXp}! '
        'The journey to cybersecurity mastery continues! 🛡️';
    
    await Share.share(
      text,
      subject: 'Level Up in CyberShujaa!',
    );
  }
}
