import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a user achievement
class Achievement {
  final String id;
  final String title;
  final String description;
  final String iconUrl;
  final int gemReward;
  final int xpReward;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.iconUrl,
    required this.gemReward,
    required this.xpReward,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({
    String? id,
    String? title,
    String? description,
    String? iconUrl,
    int? gemReward,
    int? xpReward,
    bool? isUnlocked,
    DateTime? unlockedAt,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      iconUrl: iconUrl ?? this.iconUrl,
      gemReward: gemReward ?? this.gemReward,
      xpReward: xpReward ?? this.xpReward,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      unlockedAt: unlockedAt ?? this.unlockedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'iconUrl': iconUrl,
    'gemReward': gemReward,
    'xpReward': xpReward,
    'isUnlocked': isUnlocked,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory Achievement.fromJson(Map<String, dynamic> json) {
    return Achievement(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      iconUrl: json['iconUrl'] as String,
      gemReward: json['gemReward'] as int,
      xpReward: json['xpReward'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

/// Represents a user streak
class StreakData {
  final int currentStreak;
  final int longestStreak;
  final DateTime lastLoginDate;
  final List<DateTime> streakDates;

  const StreakData({
    this.currentStreak = 0,
    this.longestStreak = 0,
    required this.lastLoginDate,
    this.streakDates = const [],
  });

  StreakData copyWith({
    int? currentStreak,
    int? longestStreak,
    DateTime? lastLoginDate,
    List<DateTime>? streakDates,
  }) {
    return StreakData(
      currentStreak: currentStreak ?? this.currentStreak,
      longestStreak: longestStreak ?? this.longestStreak,
      lastLoginDate: lastLoginDate ?? this.lastLoginDate,
      streakDates: streakDates ?? this.streakDates,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentStreak': currentStreak,
    'longestStreak': longestStreak,
    'lastLoginDate': lastLoginDate.toIso8601String(),
    'streakDates': streakDates.map((date) => date.toIso8601String()).toList(),
  };

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] as int,
      longestStreak: json['longestStreak'] as int,
      lastLoginDate: DateTime.parse(json['lastLoginDate'] as String),
      streakDates: (json['streakDates'] as List)
          .map((date) => DateTime.parse(date as String))
          .toList(),
    );
  }
}

/// Represents a mission progress
class MissionProgress {
  final String missionId;
  final bool isCompleted;
  final int progress; // Percentage 0-100
  final DateTime startedAt;
  final DateTime? completedAt;

  const MissionProgress({
    required this.missionId,
    this.isCompleted = false,
    this.progress = 0,
    required this.startedAt,
    this.completedAt,
  });

  MissionProgress copyWith({
    String? missionId,
    bool? isCompleted,
    int? progress,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return MissionProgress(
      missionId: missionId ?? this.missionId,
      isCompleted: isCompleted ?? this.isCompleted,
      progress: progress ?? this.progress,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'missionId': missionId,
    'isCompleted': isCompleted,
    'progress': progress,
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
  };

  factory MissionProgress.fromJson(Map<String, dynamic> json) {
    return MissionProgress(
      missionId: json['missionId'] as String,
      isCompleted: json['isCompleted'] as bool,
      progress: json['progress'] as int,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

/// Represents a user profile with progress data
class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String? photoUrl;
  final int level;
  final int xp;
  final int gems;
  final List<Achievement> achievements;
  final List<MissionProgress> missionProgress;
  final Map<String, dynamic>? storyProgress;
  final StreakData streak;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    this.photoUrl,
    this.level = 1,
    this.xp = 0,
    this.gems = 0,
    this.achievements = const [],
    this.missionProgress = const [],
    this.storyProgress,
    required this.streak,
    required this.createdAt,
    required this.lastLoginAt,
  });

  UserModel copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoUrl,
    int? level,
    int? xp,
    int? gems,
    List<Achievement>? achievements,
    List<MissionProgress>? missionProgress,
    Map<String, dynamic>? storyProgress,
    StreakData? streak,
    DateTime? createdAt,
    DateTime? lastLoginAt,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      gems: gems ?? this.gems,
      achievements: achievements ?? this.achievements,
      missionProgress: missionProgress ?? this.missionProgress,
      storyProgress: storyProgress ?? this.storyProgress,
      streak: streak ?? this.streak,
      createdAt: createdAt ?? this.createdAt,
      lastLoginAt: lastLoginAt ?? this.lastLoginAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'level': level,
    'xp': xp,
    'gems': gems,
    'achievements': achievements.map((a) => a.toJson()).toList(),
    'missionProgress': missionProgress.map((m) => m.toJson()).toList(),
    'storyProgress': storyProgress,
    'streak': streak.toJson(),
    'createdAt': createdAt.toIso8601String(),
    'lastLoginAt': lastLoginAt.toIso8601String(),
  };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      level: json['level'] as int,
      xp: json['xp'] as int,
      gems: json['gems'] as int,
      achievements: (json['achievements'] as List)
          .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
          .toList(),
      missionProgress: (json['missionProgress'] as List)
          .map((m) => MissionProgress.fromJson(m as Map<String, dynamic>))
          .toList(),
      storyProgress: json['storyProgress'] as Map<String, dynamic>?,
      streak: StreakData.fromJson(json['streak'] as Map<String, dynamic>),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    try {
      final data = doc.data() as Map<String, dynamic>;
      return UserModel(
        uid: doc.id,
        email: data['email'] as String? ?? 'unknown@email.com',
        displayName: data['displayName'] as String? ?? 'Unknown User',
        photoUrl: data['photoUrl'] as String?,
        level: data['level'] as int? ?? 1,
        xp: data['xp'] as int? ?? 0,
        gems: data['gems'] as int? ?? 0,
        achievements: ((data['achievements'] as List?) ?? [])
            .map((a) => Achievement.fromJson(a as Map<String, dynamic>))
            .toList(),
        missionProgress: ((data['missionProgress'] as List?) ?? [])
            .map((m) => MissionProgress.fromJson(m as Map<String, dynamic>))
            .toList(),
        storyProgress: data['storyProgress'] as Map<String, dynamic>?,
        streak: data['streak'] != null 
            ? StreakData.fromJson(data['streak'] as Map<String, dynamic>)
            : StreakData(lastLoginDate: DateTime.now(), streakDates: [DateTime.now()]),
        createdAt: _parseDateTime(data['createdAt']),
        lastLoginAt: _parseDateTime(data['lastLoginAt']),
      );
    } catch (e) {
      print('Error parsing user data from Firestore: $e');
      // Return a default user model if parsing fails
      return UserModel.createNew(doc.id, 'error@email.com', 'Error User');
    }
  }

  /// Calculate the XP required for the next level
  int getNextLevelXp() {
    // Simple formula: 1000 * level
    return 1000 * level;
  }

  /// Calculate progress to next level (0-100)
  int getLevelProgress() {
    final nextLevelXp = getNextLevelXp();
    final currentLevelXp = 1000 * (level - 1);
    final xpInCurrentLevel = xp - currentLevelXp;
    final xpRequiredForNextLevel = nextLevelXp - currentLevelXp;
    
    return ((xpInCurrentLevel / xpRequiredForNextLevel) * 100).round();
  }

  /// Check if user has completed a mission
  bool hasMissionCompleted(String missionId) {
    return missionProgress.any((m) => m.missionId == missionId && m.isCompleted);
  }

  /// Get mission progress percentage
  int getMissionProgress(String missionId) {
    final mission = missionProgress.firstWhere(
      (m) => m.missionId == missionId,
      orElse: () => MissionProgress(
        missionId: missionId,
        startedAt: DateTime.now(),
        progress: 0,
      ),
    );
    return mission.progress;
  }

  /// Create a new user model from Firebase auth user
  factory UserModel.createNew(String uid, String email, String displayName) {
    final now = DateTime.now();
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName,
      level: 1,                    // Start at level 1
      xp: 0,                       // Start with 0 XP
      gems: 0,                     // Start with 0 gems
      achievements: const [],       // No achievements yet
      missionProgress: const [],    // No missions started yet
      storyProgress: null,          // No story progress yet
      streak: StreakData(
        lastLoginDate: now,
        streakDates: [now],
      ),
      createdAt: now,
      lastLoginAt: now,
    );
  }

  /// Helper method to parse DateTime from various Firebase formats
  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) {
      return value.toDate();
    } else if (value is String) {
      return DateTime.parse(value);
    } else if (value is DateTime) {
      return value;
    } else {
      // Fallback to current time if parsing fails
      return DateTime.now();
    }
  }
}
