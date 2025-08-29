import '../data/kenyan_cybersecurity_content.dart';
import '../models/mission_models.dart';
import 'language_service.dart';

/// Service for integrating Kenyan cybersecurity content with the existing app
/// This service acts as a bridge between the Kenyan content and the main app
class KenyanContentIntegrationService {
  final LanguageService _languageService;
  
  KenyanContentIntegrationService(this._languageService);
  
  /// Get all available Kenyan missions
  List<Mission> getAllKenyanMissions() {
    return KenyanCybersecurityContent.getAllKenyanMissions();
  }
  
  /// Get all available Kenyan story missions
  List<StoryMission> getAllKenyanStoryMissions() {
    return KenyanCybersecurityContent.getAllKenyanStoryMissions();
  }
  
  /// Get Kenyan missions filtered by category
  List<Mission> getKenyanMissionsByCategory(MissionCategory category) {
    return KenyanCybersecurityContent.getMissionsByCategory(category);
  }
  
  /// Get Kenyan missions filtered by difficulty
  List<Mission> getKenyanMissionsByDifficulty(MissionDifficulty difficulty) {
    return KenyanCybersecurityContent.getMissionsByDifficulty(difficulty);
  }
  
  /// Get beginner-friendly Kenyan missions (for onboarding)
  List<Mission> getBeginnerKenyanMissions() {
    return KenyanCybersecurityContent.getBeginnerMissions();
  }
  
  /// Get M-PESA specific missions
  List<Mission> getMPesaMissions() {
    return KenyanCybersecurityContent.getMPesaMissions();
  }
  
  /// Get WhatsApp specific missions
  List<Mission> getWhatsAppMissions() {
    return KenyanCybersecurityContent.getWhatsAppMissions();
  }
  
  /// Get marketplace specific missions
  List<Mission> getMarketplaceMissions() {
    return KenyanCybersecurityContent.getMarketplaceMissions();
  }
  
  /// Get localized mission title
  String getLocalizedMissionTitle(Mission mission) {
    return _languageService.getLocalizedTitle(
      mission.localizedTitle,
      mission.title,
    );
  }
  
  /// Get localized mission description
  String getLocalizedMissionDescription(Mission mission) {
    return _languageService.getLocalizedDescription(
      mission.localizedDescription,
      mission.description,
    );
  }
  
  /// Get localized category name
  String getLocalizedCategoryName(MissionCategory category) {
    return _languageService.getLocalizedCategoryName(category);
  }
  
  /// Get localized difficulty name
  String getLocalizedDifficultyName(MissionDifficulty difficulty) {
    return _languageService.getLocalizedDifficultyName(difficulty);
  }
  
  /// Get localized mission type name
  String getLocalizedMissionTypeName(MissionType type) {
    return _languageService.getLocalizedMissionTypeName(type);
  }
  
  /// Get localized status name
  String getLocalizedStatusName(MissionStatus status) {
    return _languageService.getLocalizedStatusName(status);
  }
  
  /// Get localized common phrase
  String getLocalizedCommonPhrase(String phraseKey) {
    return _languageService.getLocalizedCommonPhrase(phraseKey);
  }
  
  /// Check if a mission is Kenyan-specific
  bool isKenyanMission(Mission mission) {
    return mission.countryContext == 'Kenya' || mission.isLocalized;
  }
  
  /// Check if a story mission is Kenyan-specific
  bool isKenyanStoryMission(StoryMission storyMission) {
    return storyMission.countryContext == 'Kenya';
  }
  
  /// Get missions with localization support
  List<Mission> getLocalizedMissions() {
    return getAllKenyanMissions().where((mission) => mission.isLocalized).toList();
  }
  
  /// Get missions available in a specific language
  List<Mission> getMissionsInLanguage(String languageCode) {
    return getAllKenyanMissions().where((mission) {
      if (languageCode == 'sw') {
        return mission.localizedTitle?.containsKey('sw') == true ||
               mission.localizedDescription?.containsKey('sw') == true;
      }
      return true; // English is always available
    }).toList();
  }
  
  /// Get story missions available in a specific language
  List<StoryMission> getStoryMissionsInLanguage(String languageCode) {
    return getAllKenyanStoryMissions().where((storyMission) {
      // For now, all story missions support both languages
      return true;
    }).toList();
  }
  
  /// Get content statistics
  Map<String, dynamic> getContentStatistics() {
    final allMissions = getAllKenyanMissions();
    final allStories = getAllKenyanStoryMissions();
    
    return {
      'total_missions': allMissions.length,
      'total_stories': allStories.length,
      'localized_missions': allMissions.where((m) => m.isLocalized).length,
      'categories': {
        'mPesaSecurity': allMissions.where((m) => m.category == MissionCategory.mPesaSecurity).length,
        'whatsappSecurity': allMissions.where((m) => m.category == MissionCategory.whatsappSecurity).length,
        'onlineMarketplace': allMissions.where((m) => m.category == MissionCategory.onlineMarketplace).length,
        'mobileMoney': allMissions.where((m) => m.category == MissionCategory.mobileMoney).length,
      },
      'difficulties': {
        'beginner': allMissions.where((m) => m.difficulty == MissionDifficulty.beginner).length,
        'intermediate': allMissions.where((m) => m.difficulty == MissionDifficulty.intermediate).length,
        'advanced': allMissions.where((m) => m.difficulty == MissionDifficulty.advanced).length,
        'expert': allMissions.where((m) => m.difficulty == MissionDifficulty.expert).length,
      },
      'total_xp_reward': allMissions.fold(0, (sum, m) => sum + m.xpReward),
      'total_gem_reward': allMissions.fold(0, (sum, m) => sum + m.gemReward),
      'story_total_xp': allStories.fold(0, (sum, s) => sum + s.totalXpReward),
      'story_total_gems': allStories.fold(0, (sum, s) => sum + s.totalGemReward),
    };
  }
  
  /// Get recommended mission order for new users
  List<Mission> getRecommendedMissionOrder() {
    final missions = getAllKenyanMissions();
    
    // Sort by difficulty and category for optimal learning path
    missions.sort((a, b) {
      // First by difficulty
      final difficultyOrder = {
        MissionDifficulty.beginner: 1,
        MissionDifficulty.intermediate: 2,
        MissionDifficulty.advanced: 3,
        MissionDifficulty.expert: 4,
      };
      
      final difficultyDiff = difficultyOrder[a.difficulty]! - difficultyOrder[b.difficulty]!;
      if (difficultyDiff != 0) return difficultyDiff;
      
      // Then by category (M-PESA first, then WhatsApp, then marketplace)
      final categoryOrder = {
        MissionCategory.mPesaSecurity: 1,
        MissionCategory.whatsappSecurity: 2,
        MissionCategory.onlineMarketplace: 3,
        MissionCategory.mobileMoney: 4,
      };
      
      return (categoryOrder[a.category] ?? 5) - (categoryOrder[b.category] ?? 5);
    });
    
    return missions;
  }
  
  /// Get mission prerequisites
  Map<String, List<String>> getMissionPrerequisites() {
    return {
      'KENYA_MPESA_001': [], // No prerequisites
      'KENYA_MPESA_002': ['KENYA_MPESA_001'], // Requires basic M-PESA knowledge
      'KENYA_WHATSAPP_001': ['KENYA_MPESA_001'], // Requires basic security awareness
      'KENYA_MARKETPLACE_001': ['KENYA_MPESA_001', 'KENYA_WHATSAPP_001'], // Requires both
    };
  }
  
  /// Check if a mission can be unlocked
  bool canUnlockMission(String missionId, List<String> completedMissionIds) {
    final prerequisites = getMissionPrerequisites()[missionId] ?? [];
    return prerequisites.every((prereq) => completedMissionIds.contains(prereq));
  }
  
  /// Get next recommended mission
  Mission? getNextRecommendedMission(List<String> completedMissionIds) {
    final recommendedOrder = getRecommendedMissionOrder();
    
    for (final mission in recommendedOrder) {
      if (!completedMissionIds.contains(mission.id) && 
          canUnlockMission(mission.id, completedMissionIds)) {
        return mission;
      }
    }
    
    return null;
  }
  
  /// Get learning path progress
  Map<String, dynamic> getLearningPathProgress(List<String> completedMissionIds) {
    final totalMissions = getAllKenyanMissions().length;
    final completedCount = completedMissionIds.length;
    final progress = totalMissions > 0 ? (completedCount / totalMissions) * 100 : 0.0;
    
    return {
      'total_missions': totalMissions,
      'completed_missions': completedCount,
      'remaining_missions': totalMissions - completedCount,
      'progress_percentage': progress,
      'progress_fraction': '$completedCount/$totalMissions',
      'next_mission': getNextRecommendedMission(completedMissionIds)?.id,
      'is_complete': completedCount >= totalMissions,
    };
  }
}
