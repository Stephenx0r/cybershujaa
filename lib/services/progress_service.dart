import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/mission_models.dart';
import 'auth_service.dart';

class ProgressService {
  // Singleton pattern
  static final ProgressService _instance = ProgressService._internal();
  factory ProgressService() => _instance;
  ProgressService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Get user progress
  Future<UserModel?> getUserProgress() async {
    try {
      print('=== GET USER PROGRESS: STARTING ===');
      final user = _authService.currentUser;
      if (user != null) {
        print('Current user found: ${user.uid}');
        final userData = await _authService.getUserData(user.uid);
        print('User data retrieved: ${userData != null ? "SUCCESS" : "NULL"}');
        if (userData != null) {
          print('User XP: ${userData.xp}, Level: ${userData.level}');
        }
        return userData;
      } else {
        print('No current user found');
      }
      return null;
    } catch (e, stackTrace) {
      print('=== GET USER PROGRESS: ERROR ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Update user XP
  Future<bool> updateXp(int xpToAdd) async {
    try {
      print('=== UPDATE XP: STARTING ===');
      print('XP to add: $xpToAdd');
      
      final user = _authService.currentUser;
      if (user == null) {
        print('ERROR: No current user');
        return false;
      }
      print('Current user ID: ${user.uid}');

      // Get current user data
      print('Getting user data for XP update...');
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) {
        print('ERROR: No user data found for XP update');
        return false;
      }
      print('User data retrieved for XP update');
      print('Current XP: ${userData.xp}');
      print('Current level: ${userData.level}');

      // Calculate new XP and level
      print('Calculating new XP and level...');
      final newXp = userData.xp + xpToAdd;
      int newLevel = userData.level;
      
      print('New XP will be: $newXp');
      print('Starting level calculation...');
      
      // Check if level up - with safety checks
      try {
        int levelCheck = 0;
        while (newXp >= (userData.level + levelCheck) * 1000) {
          levelCheck++;
          print('Level up check: ${userData.level + levelCheck} * 1000 = ${(userData.level + levelCheck) * 1000}');
          if (levelCheck > 100) { // Safety limit to prevent infinite loop
            print('WARNING: Level calculation exceeded safety limit, breaking');
            break;
          }
        }
        newLevel = userData.level + levelCheck;
        print('Final new level: $newLevel');
      } catch (levelCalcError) {
        print('ERROR in level calculation: $levelCalcError');
        // Fallback: just increment level by 1 if XP increased significantly
        if (newXp > userData.xp + 500) {
          newLevel = userData.level + 1;
          print('Using fallback level calculation: $newLevel');
        }
      }

      // Update user document
      print('Updating Firestore with new XP and level...');
      await _firestore.collection('users').doc(user.uid).update({
        'xp': newXp,
        'level': newLevel,
      });
      print('Firestore update completed successfully');

      print('=== UPDATE XP: FINISHED ===');
      return true;
    } catch (e, stackTrace) {
      print('=== UPDATE XP: ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Update user gems
  Future<bool> updateGems(int gemsToAdd) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return false;

      // Calculate new gems
      final newGems = userData.gems + gemsToAdd;

      // Update user document
      await _firestore.collection('users').doc(user.uid).update({
        'gems': newGems,
      });

      return true;
    } catch (e) {
      print('Error updating gems: $e');
      return false;
    }
  }

  // Start mission
  Future<bool> startMission(String missionId) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return false;

      // Check if mission already started
      final existingProgress = userData.missionProgress
          .where((m) => m.missionId == missionId)
          .toList();
      
      if (existingProgress.isNotEmpty) {
        // Mission already started, do nothing
        return true;
      }

      // Create new mission progress
      final newProgress = MissionProgress(
        missionId: missionId,
        isCompleted: false,
        progress: 0,
        startedAt: DateTime.now(),
      );

      // Add to user's mission progress
      final updatedProgress = List<MissionProgress>.from(userData.missionProgress)
        ..add(newProgress);

      // Update user document
      await _firestore.collection('users').doc(user.uid).update({
        'missionProgress': updatedProgress.map((m) => m.toJson()).toList(),
      });

      return true;
    } catch (e) {
      print('Error starting mission: $e');
      return false;
    }
  }

  // Complete story scenario and update XP
  Future<bool> completeStoryScenario(String storyMissionId, String scenarioId, int xpReward) async {
    try {
      print('=== PROGRESS SERVICE: STARTING STORY SCENARIO COMPLETION ===');
      print('Story Mission ID: $storyMissionId');
      print('Scenario ID: $scenarioId');
      print('XP Reward: $xpReward');
      
      final user = _authService.currentUser;
      if (user == null) {
        print('ERROR: No current user');
        return false;
      }
      print('Current user ID: ${user.uid}');

      // Get current user data
      print('Getting user data...');
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) {
        print('ERROR: No user data found');
        return false;
      }
      print('User data retrieved successfully');
      print('Current user XP: ${userData.xp}');
      print('Current user level: ${userData.level}');

      // Update XP first
      print('Updating XP...');
      final xpUpdateSuccess = await updateXp(xpReward);
      if (!xpUpdateSuccess) {
        print('ERROR: XP update failed');
        return false;
      }
      print('XP updated successfully');

      // Get or create story progress
      print('Processing story progress...');
      Map<String, dynamic> storyProgress = {};
      if (userData.storyProgress != null) {
        print('Existing story progress found, copying...');
        storyProgress = Map<String, dynamic>.from(userData.storyProgress!);
        print('Story progress keys: ${storyProgress.keys.toList()}');
      } else {
        print('No existing story progress, creating new map');
      }

      // Initialize story mission progress if it doesn't exist
      if (!storyProgress.containsKey(storyMissionId)) {
        print('Initializing story mission progress for: $storyMissionId');
        storyProgress[storyMissionId] = {
          'completedScenarios': [],
          'totalXpEarned': 0,
          'startedAt': DateTime.now().toIso8601String(),
        };
      }

      // Add completed scenario if not already completed
      print('Updating completed scenarios...');
      final storyData = storyProgress[storyMissionId] as Map<String, dynamic>;
      final completedScenarios = List<String>.from(storyData['completedScenarios'] ?? []);
      
      print('Current completed scenarios: $completedScenarios');
      
      if (!completedScenarios.contains(scenarioId)) {
        completedScenarios.add(scenarioId);
        storyData['completedScenarios'] = completedScenarios;
        storyData['totalXpEarned'] = (storyData['totalXpEarned'] ?? 0) + xpReward;
        storyData['lastCompletedAt'] = DateTime.now().toIso8601String();
        print('Added scenario $scenarioId to completed list');
        print('Updated total XP earned: ${storyData['totalXpEarned']}');
      } else {
        print('Scenario $scenarioId already completed, skipping');
      }

      // Update user document
      print('Updating Firestore document...');
      await _firestore.collection('users').doc(user.uid).update({
        'storyProgress': storyProgress,
      });
      print('Firestore update completed successfully');

      print('=== PROGRESS SERVICE: STORY SCENARIO COMPLETION FINISHED ===');
      return true;
    } catch (e, stackTrace) {
      print('=== PROGRESS SERVICE: ERROR ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Update mission progress
  Future<bool> updateMissionProgress(String missionId, int progress) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return false;

      // Find mission progress
      final missionProgressIndex = userData.missionProgress
          .indexWhere((m) => m.missionId == missionId);
      
      if (missionProgressIndex == -1) {
        // Mission not started, start it
        await startMission(missionId);
        // Get updated user data
        final updatedUserData = await _authService.getUserData(user.uid);
        if (updatedUserData == null) return false;
        
        // Find newly created mission progress
        final newIndex = updatedUserData.missionProgress
            .indexWhere((m) => m.missionId == missionId);
        
        if (newIndex == -1) return false;
        
        // Update progress
        final updatedProgress = List<MissionProgress>.from(updatedUserData.missionProgress);
        updatedProgress[newIndex] = updatedProgress[newIndex].copyWith(
          progress: progress,
        );
        
        // Update user document
        await _firestore.collection('users').doc(user.uid).update({
          'missionProgress': updatedProgress.map((m) => m.toJson()).toList(),
        });
      } else {
        // Update existing mission progress
        final updatedProgress = List<MissionProgress>.from(userData.missionProgress);
        updatedProgress[missionProgressIndex] = updatedProgress[missionProgressIndex].copyWith(
          progress: progress,
        );
        
        // Update user document
        await _firestore.collection('users').doc(user.uid).update({
          'missionProgress': updatedProgress.map((m) => m.toJson()).toList(),
        });
      }

      return true;
    } catch (e) {
      print('Error updating mission progress: $e');
      return false;
    }
  }

  // Complete mission
  Future<bool> completeMission(String missionId, Mission mission) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return false;

      // Find mission progress
      final missionProgressIndex = userData.missionProgress
          .indexWhere((m) => m.missionId == missionId);
      
      if (missionProgressIndex == -1) {
        // Mission not started, can't complete
        return false;
      }

      // Update mission progress
      final updatedProgress = List<MissionProgress>.from(userData.missionProgress);
      updatedProgress[missionProgressIndex] = updatedProgress[missionProgressIndex].copyWith(
        isCompleted: true,
        progress: 100,
        completedAt: DateTime.now(),
      );
      
      // Update user document with completed mission
      await _firestore.collection('users').doc(user.uid).update({
        'missionProgress': updatedProgress.map((m) => m.toJson()).toList(),
      });

      // Add XP and gems rewards
      await updateXp(mission.xpReward);
      await updateGems(mission.gemReward);

      return true;
    } catch (e) {
      print('Error completing mission: $e');
      return false;
    }
  }

  // Unlock achievement
  Future<bool> unlockAchievement(String achievementId, int xpReward, int gemReward) async {
    final user = _authService.currentUser;
    if (user == null) return false;

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return false;

      // Check if achievement already unlocked
      final existingAchievement = userData.achievements
          .where((a) => a.id == achievementId && a.isUnlocked)
          .toList();
      
      if (existingAchievement.isNotEmpty) {
        // Achievement already unlocked
        return true;
      }

      // Find achievement
      final achievementIndex = userData.achievements
          .indexWhere((a) => a.id == achievementId);
      
      if (achievementIndex == -1) {
        // Achievement not found in user's list
        // This shouldn't happen as achievements should be pre-loaded
        return false;
      }

      // Update achievement
      final updatedAchievements = List<Achievement>.from(userData.achievements);
      updatedAchievements[achievementIndex] = updatedAchievements[achievementIndex].copyWith(
        isUnlocked: true,
        unlockedAt: DateTime.now(),
      );
      
      // Update user document
      await _firestore.collection('users').doc(user.uid).update({
        'achievements': updatedAchievements.map((a) => a.toJson()).toList(),
      });

      // Add XP and gems rewards
      await updateXp(xpReward);
      await updateGems(gemReward);

      return true;
    } catch (e) {
      print('Error unlocking achievement: $e');
      return false;
    }
  }

  // Get mission progress
  Future<MissionProgress?> getMissionProgress(String missionId) async {
    final user = _authService.currentUser;
    if (user == null) return null;

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return null;

      // Find mission progress
      final missionProgress = userData.missionProgress
          .where((m) => m.missionId == missionId)
          .toList();
      
      if (missionProgress.isEmpty) {
        return null;
      }

      return missionProgress.first;
    } catch (e) {
      print('Error getting mission progress: $e');
      return null;
    }
  }

  // Get completed missions
  Future<List<String>> getCompletedMissions() async {
    final user = _authService.currentUser;
    if (user == null) return [];

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return [];

      // Get completed missions
      return userData.missionProgress
          .where((m) => m.isCompleted)
          .map((m) => m.missionId)
          .toList();
    } catch (e) {
      print('Error getting completed missions: $e');
      return [];
    }
  }

  // Get unlocked achievements
  Future<List<Achievement>> getUnlockedAchievements() async {
    final user = _authService.currentUser;
    if (user == null) return [];

    try {
      // Get current user data
      final userData = await _authService.getUserData(user.uid);
      if (userData == null) return [];

      // Get unlocked achievements
      return userData.achievements
          .where((a) => a.isUnlocked)
          .toList();
    } catch (e) {
      print('Error getting unlocked achievements: $e');
      return [];
    }
  }
}
