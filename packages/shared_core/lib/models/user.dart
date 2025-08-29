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
      isUnlocked: json['isUnlocked'] as bool? ?? false,
      unlockedAt: json['unlockedAt'] != null
          ? DateTime.parse(json['unlockedAt'] as String)
          : null,
    );
  }
}

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
        'streakDates': streakDates.map((d) => d.toIso8601String()).toList(),
      };

  factory StreakData.fromJson(Map<String, dynamic> json) {
    return StreakData(
      currentStreak: json['currentStreak'] as int? ?? 0,
      longestStreak: json['longestStreak'] as int? ?? 0,
      lastLoginDate: DateTime.parse(json['lastLoginDate'] as String),
      streakDates: ((json['streakDates'] as List?) ?? const <dynamic>[])
          .map((d) => DateTime.parse(d as String))
          .toList(),
    );
  }
}

class MissionProgress {
  final String missionId;
  final bool isCompleted;
  final int progress;
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
      isCompleted: json['isCompleted'] as bool? ?? false,
      progress: json['progress'] as int? ?? 0,
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'] as String)
          : null,
    );
  }
}

class AppUser {
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
  final bool isAdmin;

  const AppUser({
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
    this.isAdmin = false,
  });

  AppUser copyWith({
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
    bool? isAdmin,
  }) {
    return AppUser(
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
      isAdmin: isAdmin ?? this.isAdmin,
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
        'isAdmin': isAdmin,
      };

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      displayName: json['displayName'] as String,
      photoUrl: json['photoUrl'] as String?,
      level: json['level'] as int? ?? 1,
      xp: json['xp'] as int? ?? 0,
      gems: json['gems'] as int? ?? 0,
      achievements: ((json['achievements'] as List?) ?? const <dynamic>[])
          .map((a) => Achievement.fromJson((a as Map).cast<String, dynamic>()))
          .toList(),
      missionProgress: ((json['missionProgress'] as List?) ?? const <dynamic>[])
          .map((m) =>
              MissionProgress.fromJson((m as Map).cast<String, dynamic>()))
          .toList(),
      storyProgress: (json['storyProgress'] as Map?)?.cast<String, dynamic>(),
      streak: StreakData.fromJson((json['streak'] as Map).cast<String, dynamic>()),
      createdAt: DateTime.parse(json['createdAt'] as String),
      lastLoginAt: DateTime.parse(json['lastLoginAt'] as String),
      isAdmin: json['isAdmin'] as bool? ?? false,
    );
  }

  int getNextLevelXp() {
    return 1000 * level;
  }

  int getLevelProgress() {
    final int nextLevelXp = getNextLevelXp();
    final int currentLevelXp = 1000 * (level - 1);
    final int xpInCurrentLevel = xp - currentLevelXp;
    final int xpRequiredForNextLevel = nextLevelXp - currentLevelXp;
    if (xpRequiredForNextLevel <= 0) return 0;
    final double ratio = xpInCurrentLevel / xpRequiredForNextLevel;
    return (ratio.clamp(0.0, 1.0) * 100).round();
  }
}


