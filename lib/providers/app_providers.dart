import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_core/shared_core.dart';
import '../services/accessibility_service.dart';
import '../services/auth_service.dart';
import '../services/theme_service.dart';
import '../services/language_service.dart';
import '../services/progress_service.dart';
import '../services/firebase_mission_service.dart';
import '../services/daily_challenge_service.dart';

// Theme Service Provider
final themeServiceProvider = ChangeNotifierProvider<ThemeService>((ref) {
  return ThemeService();
});

// Language Service Provider
final languageServiceProvider = Provider<LanguageService>((ref) {
  return LanguageService();
});

// Accessibility Service Provider
final accessibilityServiceProvider = ChangeNotifierProvider<AccessibilityService>((ref) {
  return AccessibilityService();
});

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Auth State Stream Provider
final authStateProvider = StreamProvider<User?>((ref) {
  final auth = ref.watch(authServiceProvider);
  return auth.authStateChanges;
});

// App User Data Provider
final appUserProvider = StreamProvider<AppUser?>((ref) async* {
  final authState = await ref.watch(authStateProvider.future);
  if (authState == null) {
    yield null;
    return;
  }
  
  try {
    final authService = ref.read(authServiceProvider);
    final userData = await authService.getUserData(authState.uid);
    if (userData != null) {
      // Convert UserModel to AppUser
      yield AppUser(
        uid: userData.uid,
        email: userData.email,
        displayName: userData.displayName,
        photoUrl: userData.photoUrl,
        level: userData.level,
        xp: userData.xp,
        gems: userData.gems,
        achievements: userData.achievements.map((a) => _convertAchievement(a)).toList(),
        missionProgress: userData.missionProgress.map((m) => _convertMissionProgress(m)).toList(),
        storyProgress: userData.storyProgress,
        streak: _convertStreakData(userData.streak),
        createdAt: userData.createdAt,
        lastLoginAt: userData.lastLoginAt,
        isAdmin: false, // Default to false since UserModel doesn't have this field
      );
    }
  } catch (e) {
    print('Error getting app user data: $e');
    yield null;
  }
});

// Conversion functions
Achievement _convertAchievement(dynamic localAchievement) {
  return Achievement(
    id: localAchievement.id,
    title: localAchievement.title,
    description: localAchievement.description,
    iconUrl: localAchievement.iconUrl,
    gemReward: localAchievement.gemReward,
    xpReward: localAchievement.xpReward,
    isUnlocked: localAchievement.isUnlocked,
    unlockedAt: localAchievement.unlockedAt,
  );
}

MissionProgress _convertMissionProgress(dynamic localProgress) {
  return MissionProgress(
    missionId: localProgress.missionId,
    isCompleted: localProgress.isCompleted,
    progress: localProgress.progress,
    startedAt: localProgress.startedAt,
    completedAt: localProgress.completedAt,
  );
}

StreakData _convertStreakData(dynamic localStreak) {
  return StreakData(
    currentStreak: localStreak.currentStreak,
    longestStreak: localStreak.longestStreak,
    lastLoginDate: localStreak.lastLoginDate,
    streakDates: localStreak.streakDates,
  );
}

// Progress Service Provider
final progressServiceProvider = Provider<ProgressService>((ref) {
  return ProgressService();
});

// Firebase Mission Service Provider
final firebaseMissionServiceProvider = Provider<FirebaseMissionService>((ref) {
  return FirebaseMissionService();
});

// Missions Provider
final missionsProvider = FutureProvider<List<Mission>>((ref) async {
  final missionService = ref.watch(firebaseMissionServiceProvider);
  final missions = await missionService.getMissions();
  // Convert local Mission models to shared_core Mission models
  return missions.map((m) => _convertMission(m)).toList();
});

// Missions Notifier Provider for refreshing
final missionsNotifierProvider = StateNotifierProvider<MissionsNotifier, AsyncValue<List<Mission>>>((ref) {
  return MissionsNotifier(ref.read(firebaseMissionServiceProvider));
});

class MissionsNotifier extends StateNotifier<AsyncValue<List<Mission>>> {
  final FirebaseMissionService _missionService;
  
  MissionsNotifier(this._missionService) : super(const AsyncValue.loading());
  
  Future<void> loadMissions() async {
    state = const AsyncValue.loading();
    try {
      final missions = await _missionService.getMissions();
      // Convert local Mission models to shared_core Mission models
      final convertedMissions = missions.map((m) => _convertMission(m)).toList();
      state = AsyncValue.data(convertedMissions);
    } catch (error, stackTrace) {
      state = AsyncValue.error(error, stackTrace);
    }
  }
  
  Future<void> refreshMissions() async {
    _missionService.clearCache();
    await loadMissions();
  }
}

// Mission conversion function
Mission _convertMission(dynamic localMission) {
  return Mission(
    id: localMission.id,
    title: localMission.title,
    description: localMission.description,
    type: _parseEnumSafely(localMission.type.toString().split('.').last, MissionType.values, MissionType.interactiveQuiz),
    difficulty: _parseEnumSafely(localMission.difficulty.toString().split('.').last, MissionDifficulty.values, MissionDifficulty.beginner),
    category: _parseEnumSafely(localMission.category.toString().split('.').last, MissionCategory.values, MissionCategory.phishing),
    status: _parseEnumSafely(localMission.status?.toString().split('.').last ?? 'locked', MissionStatus.values, MissionStatus.locked),
    requiredLevel: localMission.requiredLevel ?? 1,
    xpReward: localMission.xpReward,
    gemReward: localMission.gemReward,
    challenges: localMission.challenges.map((c) => _convertChallenge(c)).toList(),
    imageUrl: localMission.imageUrl,
    unlockDate: localMission.unlockDate,
    expiryDate: localMission.expiryDate,
    localizedTitle: localMission.localizedTitle,
    localizedDescription: localMission.localizedDescription,
    countryContext: localMission.countryContext,
    isLocalized: localMission.isLocalized ?? false,
  );
}

Challenge _convertChallenge(dynamic localChallenge) {
  return Challenge(
    id: localChallenge.id,
    title: localChallenge.title,
    description: localChallenge.description,
    type: _parseEnumSafely(localChallenge.type.toString().split('.').last, ChallengeType.values, ChallengeType.multipleChoice),
    content: _convertChallengeContent(localChallenge.content),
    xpReward: localChallenge.xpReward ?? 0,
  );
}

ChallengeContent _convertChallengeContent(dynamic localContent) {
  return ChallengeContent(
    dataType: localContent.dataType ?? 'text',
    toolType: localContent.toolType ?? 'default',
    solution: localContent.solution ?? '',
    guidePoints: localContent.guidePoints ?? [],
    dataPayload: localContent.dataPayload ?? {},
  );
}

// Helper function to parse enums safely
T _parseEnumSafely<T>(String value, List<T> values, T defaultValue) {
  try {
    final cleanValue = value.toLowerCase().replaceAll('_', '');
    for (final enumValue in values) {
      if (enumValue.toString().split('.').last.toLowerCase().replaceAll('_', '') == cleanValue) {
        return enumValue;
      }
    }
  } catch (e) {
    print('Error parsing enum value: $value');
  }
  return defaultValue;
}

// Daily Challenge Service Provider
final dailyChallengeServiceProvider = Provider<DailyChallengeService>((ref) {
  return DailyChallengeService();
});

// Theme Mode Provider
final themeModeProvider = Provider<ThemeMode>((ref) {
  final themeService = ref.watch(themeServiceProvider);
  return themeService.themeMode;
});

// High Contrast Provider
final highContrastProvider = Provider<bool>((ref) {
  final themeService = ref.watch(themeServiceProvider);
  return themeService.isHighContrast;
});

// Text Scale Provider
final textScaleProvider = Provider<double>((ref) {
  final themeService = ref.watch(themeServiceProvider);
  return themeService.textScaleFactor;
});

// Accessibility Status Provider
final accessibilityStatusProvider = Provider<Map<String, dynamic>>((ref) {
  final accessibilityService = ref.watch(accessibilityServiceProvider);
  return accessibilityService.getAccessibilityStatus();
});

// Screen Reader Provider
final screenReaderProvider = Provider<bool>((ref) {
  final accessibilityService = ref.watch(accessibilityServiceProvider);
  return accessibilityService.isScreenReaderEnabled;
});

// Reduced Motion Provider
final reducedMotionProvider = Provider<bool>((ref) {
  final accessibilityService = ref.watch(accessibilityServiceProvider);
  return accessibilityService.isReducedMotionEnabled;
});

// Main navigation tab index (0: Home, 1: Missions, 2: Leaderboard, 3: Profile)
final mainTabIndexProvider = StateProvider<int>((ref) => 0);

