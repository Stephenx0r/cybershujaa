/// Represents the difficulty level of a mission
enum MissionDifficulty {
  beginner,
  intermediate,
  advanced,
  expert
}

/// Represents different categories of missions
enum MissionCategory {
  phishing,
  malware,
  networkSecurity,
  cryptography,
  forensics,
  webSecurity,
  socialEngineering,
  // Kenyan-specific categories
  mPesaSecurity,
  mobileMoney,
  whatsappSecurity,
  onlineMarketplace,
  saccoBanking,
  educationYouth,
  kenyanCompliance
}

/// Represents the current status of a mission
enum MissionStatus {
  locked,
  available,
  inProgress,
  completed
}

/// Represents different types of missions
enum MissionType {
  interactiveQuiz,
  scamSimulator,
  terminalChallenge,
  codeAnalysis,
  passwordLab,
  storyMission
}

/// Represents different types of challenges within missions
enum ChallengeType {
  multipleChoice,
  workbench,
  terminal,
  codeReview,
  passwordValidation,
  storyScenario
}

class ChallengeContent {
  final String dataType;
  final String toolType;
  final String solution;
  final List<String> guidePoints;
  final Map<String, dynamic> dataPayload;

  const ChallengeContent({
    required this.dataType,
    required this.toolType,
    required this.solution,
    required this.guidePoints,
    required this.dataPayload,
  });

  Map<String, dynamic> toJson() => {
        'dataType': dataType,
        'toolType': toolType,
        'solution': solution,
        'guidePoints': guidePoints,
        'dataPayload': dataPayload,
      };

  factory ChallengeContent.fromJson(Map<String, dynamic> json) {
    return ChallengeContent(
      dataType: json['dataType'] as String,
      toolType: json['toolType'] as String,
      solution: json['solution'] as String,
      guidePoints: List<String>.from(json['guidePoints'] ?? const <String>[]),
      dataPayload:
          (json['dataPayload'] as Map?)?.cast<String, dynamic>() ?? <String, dynamic>{},
    );
  }
}

/// Represents a challenge within a mission
class Challenge {
  final String id;
  final String title;
  final String description;
  final ChallengeType type;
  final ChallengeContent content;
  final int xpReward;

  const Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.content,
    required this.xpReward,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.toString(),
        'content': content.toJson(),
        'xpReward': xpReward,
      };

  factory Challenge.fromJson(Map<String, dynamic> json) {
    return Challenge(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: Mission._parseEnumSafely<ChallengeType>(
        json['type'],
        ChallengeType.values,
        ChallengeType.multipleChoice,
      ),
      content: ChallengeContent.fromJson(json['content'] ?? {}),
      xpReward: json['xpReward'] as int,
    );
  }
}

/// Represents a mission in the game
class Mission {
  final String id;
  final String title;
  final String description;
  final MissionType type;
  final MissionDifficulty difficulty;
  final MissionCategory category;
  final MissionStatus status;
  final int requiredLevel;
  final int xpReward;
  final int gemReward;
  final List<Challenge> challenges;
  final String? imageUrl;
  final DateTime? unlockDate;
  final DateTime? expiryDate;
  // Localization support
  final Map<String, String>? localizedTitle;
  final Map<String, String>? localizedDescription;
  final String? countryContext; // e.g., "Kenya", "Global"
  final bool isLocalized; // Whether this mission has local context

  const Mission({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.difficulty,
    required this.category,
    required this.status,
    required this.requiredLevel,
    required this.xpReward,
    required this.gemReward,
    required this.challenges,
    this.imageUrl,
    this.unlockDate,
    this.expiryDate,
    this.localizedTitle,
    this.localizedDescription,
    this.countryContext,
    this.isLocalized = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'type': type.toString(),
        'difficulty': difficulty.toString(),
        'category': category.toString(),
        'status': status.toString(),
        'requiredLevel': requiredLevel,
        'xpReward': xpReward,
        'gemReward': gemReward,
        'challenges': challenges.map((c) => c.toJson()).toList(),
        'imageUrl': imageUrl,
        'unlockDate': unlockDate?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'localizedTitle': localizedTitle,
        'localizedDescription': localizedDescription,
        'countryContext': countryContext,
        'isLocalized': isLocalized,
      };

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      type: _parseEnumSafely<MissionType>(
        json['type'],
        MissionType.values,
        MissionType.storyMission,
      ),
      difficulty: _parseEnumSafely<MissionDifficulty>(
        json['difficulty'],
        MissionDifficulty.values,
        MissionDifficulty.beginner,
      ),
      category: _parseEnumSafely<MissionCategory>(
        json['category'],
        MissionCategory.values,
        MissionCategory.phishing,
      ),
      status: _parseEnumSafely<MissionStatus>(
        json['status'],
        MissionStatus.values,
        MissionStatus.available,
      ),
      requiredLevel: json['requiredLevel'] as int,
      xpReward: json['xpReward'] as int,
      gemReward: json['gemReward'] as int,
      challenges: ((json['challenges'] as List?) ?? [])
          .map((c) => Challenge.fromJson(c as Map<String, dynamic>))
          .toList(),
      imageUrl: json['imageUrl'] as String?,
      unlockDate: json['unlockDate'] != null
          ? DateTime.parse(json['unlockDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      localizedTitle: json['localizedTitle'] != null
          ? Map<String, String>.from(json['localizedTitle'] as Map)
          : null,
      localizedDescription: json['localizedDescription'] != null
          ? Map<String, String>.from(json['localizedDescription'] as Map)
          : null,
      countryContext: json['countryContext'] as String?,
      isLocalized: json['isLocalized'] as bool? ?? false,
    );
  }

  // Helper method to safely parse enums from string values
  static T _parseEnumSafely<T>(
    dynamic value,
    List<T> enumValues,
    T defaultValue,
  ) {
    if (value == null) return defaultValue;
    
    final stringValue = value.toString();
    
    // Try to find exact enum match (e.g., "MissionType.storyMission")
    try {
      return enumValues.firstWhere((e) => e.toString() == stringValue);
    } catch (_) {
      // If exact match fails, try to find by the enum name only (e.g., "storyMission")
      try {
        return enumValues.firstWhere(
          (e) => e.toString().split('.').last == stringValue,
        );
      } catch (_) {
        print('Warning: Could not parse enum value "$stringValue", using default: $defaultValue');
        return defaultValue;
      }
    }
  }

  Mission copyWith({
    String? id,
    String? title,
    String? description,
    MissionType? type,
    MissionDifficulty? difficulty,
    MissionCategory? category,
    MissionStatus? status,
    int? requiredLevel,
    int? xpReward,
    int? gemReward,
    List<Challenge>? challenges,
    String? imageUrl,
    DateTime? unlockDate,
    DateTime? expiryDate,
    Map<String, String>? localizedTitle,
    Map<String, String>? localizedDescription,
    String? countryContext,
    bool? isLocalized,
  }) {
    return Mission(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      category: category ?? this.category,
      status: status ?? this.status,
      requiredLevel: requiredLevel ?? this.requiredLevel,
      xpReward: xpReward ?? this.xpReward,
      gemReward: gemReward ?? this.gemReward,
      challenges: challenges ?? this.challenges,
      imageUrl: imageUrl ?? this.imageUrl,
      unlockDate: unlockDate ?? this.unlockDate,
      expiryDate: expiryDate ?? this.expiryDate,
      localizedTitle: localizedTitle ?? this.localizedTitle,
      localizedDescription: localizedDescription ?? this.localizedDescription,
      countryContext: countryContext ?? this.countryContext,
      isLocalized: isLocalized ?? this.isLocalized,
    );
  }
}

/// Represents a story scenario within a story mission
class StoryScenario {
  final String id;
  final String title;
  final String description;
  final String narrativeText; // The story text that sets the scene
  final ChallengeType challengeType;
  final ChallengeContent content;
  final int xpReward;
  final bool isUnlocked;
  final int requiredPreviousScenarios; // How many previous scenarios must be completed
  final String? characterName; // The character involved in this scenario
  final String? incidentType; // Type of incident (breach, malware, etc.)

  const StoryScenario({
    required this.id,
    required this.title,
    required this.description,
    required this.narrativeText,
    required this.challengeType,
    required this.content,
    required this.xpReward,
    required this.isUnlocked,
    required this.requiredPreviousScenarios,
    this.characterName,
    this.incidentType,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'narrativeText': narrativeText,
        'challengeType': challengeType.toString(),
        'content': content.toJson(),
        'xpReward': xpReward,
        'isUnlocked': isUnlocked,
        'requiredPreviousScenarios': requiredPreviousScenarios,
        'characterName': characterName,
        'incidentType': incidentType,
      };

  factory StoryScenario.fromJson(Map<String, dynamic> json) {
    return StoryScenario(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      narrativeText: json['narrativeText'] as String,
      challengeType: Mission._parseEnumSafely<ChallengeType>(
        json['challengeType'],
        ChallengeType.values,
        ChallengeType.multipleChoice,
      ),
      content: ChallengeContent.fromJson(json['content'] ?? {}),
      xpReward: json['xpReward'] as int,
      isUnlocked: json['isUnlocked'] as bool,
      requiredPreviousScenarios: json['requiredPreviousScenarios'] as int,
      characterName: json['characterName'] as String?,
      incidentType: json['incidentType'] as String?,
    );
  }
}

/// Represents a story mission with progressive scenarios
class StoryMission {
  final String id;
  final String title;
  final String description;
  final String mainCharacter; // Main protagonist (e.g., "Sarah Chen, Cybersecurity Analyst")
  final String storyBackground; // Overall story background
  final List<StoryScenario> scenarios;
  final MissionDifficulty difficulty;
  final MissionCategory category;
  final int totalXpReward;
  final int totalGemReward;
  final String? imageUrl;
  final DateTime? unlockDate;
  final DateTime? expiryDate;
  // Localization support
  final String? countryContext; // e.g., "Kenya", "Global"
  final bool isLocalized; // Whether this story mission has local context

  const StoryMission({
    required this.id,
    required this.title,
    required this.description,
    required this.mainCharacter,
    required this.storyBackground,
    required this.scenarios,
    required this.difficulty,
    required this.category,
    required this.totalXpReward,
    required this.totalGemReward,
    this.imageUrl,
    this.unlockDate,
    this.expiryDate,
    this.countryContext,
    this.isLocalized = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'mainCharacter': mainCharacter,
        'storyBackground': storyBackground,
        'scenarios': scenarios.map((s) => s.toJson()).toList(),
        'difficulty': difficulty.toString(),
        'category': category.toString(),
        'totalXpReward': totalXpReward,
        'totalGemReward': totalGemReward,
        'imageUrl': imageUrl,
        'unlockDate': unlockDate?.toIso8601String(),
        'expiryDate': expiryDate?.toIso8601String(),
        'countryContext': countryContext,
        'isLocalized': isLocalized,
      };

  factory StoryMission.fromJson(Map<String, dynamic> json) {
    return StoryMission(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String,
      mainCharacter: json['mainCharacter'] as String,
      storyBackground: json['storyBackground'] as String,
      scenarios: ((json['scenarios'] as List?) ?? [])
          .map((s) => StoryScenario.fromJson(s as Map<String, dynamic>))
          .toList(),
      difficulty: Mission._parseEnumSafely<MissionDifficulty>(
        json['difficulty'],
        MissionDifficulty.values,
        MissionDifficulty.beginner,
      ),
      category: Mission._parseEnumSafely<MissionCategory>(
        json['category'],
        MissionCategory.values,
        MissionCategory.phishing,
      ),
      totalXpReward: json['totalXpReward'] as int,
      totalGemReward: json['totalGemReward'] as int,
      imageUrl: json['imageUrl'] as String?,
      unlockDate: json['unlockDate'] != null
          ? DateTime.parse(json['unlockDate'] as String)
          : null,
      expiryDate: json['expiryDate'] != null
          ? DateTime.parse(json['expiryDate'] as String)
          : null,
      countryContext: json['countryContext'] as String?,
      isLocalized: json['isLocalized'] as bool? ?? false,
    );
  }

  /// Get the current progress in the story (0.0 to 1.0)
  double getProgress(List<String> completedScenarioIds) {
    if (scenarios.isEmpty) return 0.0;
    final completedCount = scenarios
        .where((scenario) => completedScenarioIds.contains(scenario.id))
        .length;
    return completedCount / scenarios.length;
  }

  /// Get the next available scenario
  StoryScenario? getNextAvailableScenario(List<String> completedScenarioIds) {
    try {
      // Safety check for empty scenarios list
      if (scenarios.isEmpty) {
        print('Warning: No scenarios available in story mission');
        return null;
      }
      
      // Find the next available scenario
      final nextScenario = scenarios.firstWhere(
        (scenario) => 
          !completedScenarioIds.contains(scenario.id) && 
          scenario.isUnlocked &&
          completedScenarioIds.length >= scenario.requiredPreviousScenarios,
        orElse: () => throw StateError('No next scenario available'),
      );
      
      return nextScenario;
    } catch (e) {
      print('Error getting next available scenario: $e');
      
      // Check if all scenarios are completed
      final allCompleted = scenarios.every((s) => completedScenarioIds.contains(s.id));
      if (allCompleted) {
        print('All scenarios completed in story mission');
        return null;
      } else {
        print('No next scenario available, but not all completed');
        return null;
      }
    }
  }

  /// Check if story is completed
  bool isCompleted(List<String> completedScenarioIds) {
    return completedScenarioIds.length >= scenarios.length;
  }
}


