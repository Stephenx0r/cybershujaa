import 'package:flutter/material.dart';
import '../models/mission_models.dart';

/// Language Service for handling localization
/// Currently supports English and Swahili for Kenyan context
class LanguageService extends ChangeNotifier {
  static const String _englishCode = 'en';
  static const String _swahiliCode = 'sw';
  
  String _currentLanguage = _englishCode;
  
  /// Get current language code
  String get currentLanguage => _currentLanguage;
  
  /// Get current locale (for compatibility with existing code)
  Locale get currentLocale => Locale(_currentLanguage);
  
  /// Get current language name
  String get currentLanguageName {
    switch (_currentLanguage) {
      case _swahiliCode:
        return 'Kiswahili';
      case _englishCode:
      default:
        return 'English';
    }
  }
  
  /// Get available languages (for compatibility with existing code)
  List<Map<String, dynamic>> get supportedLanguages => [
    {'code': _englishCode, 'name': 'English', 'nativeName': 'English'},
    {'code': _swahiliCode, 'name': 'Swahili', 'nativeName': 'Kiswahili'},
  ];
  
  /// Check if current language is Swahili
  bool get isSwahili => _currentLanguage == _swahiliCode;
  
  /// Check if current language is English
  bool get isEnglish => _currentLanguage == _englishCode;
  
  /// Change language
  void changeLanguage(String languageCode) {
    if (_currentLanguage != languageCode && 
        [(_englishCode), _swahiliCode].contains(languageCode)) {
      _currentLanguage = languageCode;
      notifyListeners();
    }
  }
  
  /// Set language (for compatibility with existing code)
  void setLanguage(String languageCode) {
    changeLanguage(languageCode);
  }
  
  /// Get current language name (for compatibility with existing code)
  String getCurrentLanguageName() {
    return currentLanguageName;
  }
  
  /// Get localized text with fallback
  String getText(Map<String, String>? localizedMap, String fallback) {
    if (localizedMap == null) return fallback;
    return localizedMap[_currentLanguage] ?? fallback;
  }
  
  /// Get localized title
  String getLocalizedTitle(Map<String, String>? localizedTitle, String fallback) {
    return getText(localizedTitle, fallback);
  }
  
  /// Get localized description
  String getLocalizedDescription(Map<String, String>? localizedDescription, String fallback) {
    return getText(localizedDescription, fallback);
  }
  
  /// Get localized challenge content
  String getLocalizedChallengeContent(Map<String, String>? localizedContent, String fallback) {
    return getText(localizedContent, fallback);
  }
  
  /// Get localized guide points
  List<String> getLocalizedGuidePoints(List<String>? englishGuidePoints, List<String>? swahiliGuidePoints) {
    if (_currentLanguage == _swahiliCode && swahiliGuidePoints != null) {
      return swahiliGuidePoints;
    }
    return englishGuidePoints ?? [];
  }
  
  /// Get localized choice text
  String getLocalizedChoiceText(Map<String, String>? localizedChoices, String fallback) {
    return getText(localizedChoices, fallback);
  }
  
  /// Get localized narrative text
  String getLocalizedNarrativeText(Map<String, String>? localizedNarrative, String fallback) {
    return getText(localizedNarrative, fallback);
  }
  
  /// Get localized character name
  String getLocalizedCharacterName(Map<String, String>? localizedName, String fallback) {
    return getText(localizedName, fallback);
  }
  
  /// Get localized incident type
  String getLocalizedIncidentType(Map<String, String>? localizedType, String fallback) {
    return getText(localizedType, fallback);
  }
  
  /// Get localized achievement text
  String getLocalizedAchievementText(Map<String, String>? localizedAchievement, String fallback) {
    return getText(localizedAchievement, fallback);
  }
  
  /// Get localized news content
  String getLocalizedNewsContent(Map<String, String>? localizedNews, String fallback) {
    return getText(localizedNews, fallback);
  }
  
  // Button text localization
  String getLocalizedButtonText(String key) {
    switch (key) {
      case 'save':
        return isSwahili ? 'Hifadhi' : 'Save';
      case 'cancel':
        return isSwahili ? 'Ghairi' : 'Cancel';
      case 'delete':
        return isSwahili ? 'Futa' : 'Delete';
      case 'edit':
        return isSwahili ? 'Hariri' : 'Edit';
      case 'add':
        return isSwahili ? 'Ongeza' : 'Add';
      case 'submit':
        return isSwahili ? 'Wasilisha' : 'Submit';
      case 'retry':
        return isSwahili ? 'Jaribu tena' : 'Retry';
      case 'refresh':
        return isSwahili ? 'Onyesha upya' : 'Refresh';
      case 'next':
        return isSwahili ? 'Ifuatayo' : 'Next';
      case 'previous':
        return isSwahili ? 'Iliyotangulia' : 'Previous';
      case 'start':
        return isSwahili ? 'Anza' : 'Start';
      case 'finish':
        return isSwahili ? 'Maliza' : 'Finish';
      case 'continue':
        return isSwahili ? 'Endelea' : 'Continue';
      case 'back':
        return isSwahili ? 'Rudi nyuma' : 'Back';
      case 'close':
        return isSwahili ? 'Funga' : 'Close';
      case 'ok':
        return isSwahili ? 'Sawa' : 'OK';
      case 'yes':
        return isSwahili ? 'Ndiyo' : 'Yes';
      case 'no':
        return isSwahili ? 'Hapana' : 'No';
      case 'logout':
        return isSwahili ? 'Ondoka' : 'Logout';
      case 'edit_profile':
        return isSwahili ? 'Hariri wasifu' : 'Edit Profile';
      case 'change_avatar':
        return isSwahili ? 'Badilisha picha' : 'Change Avatar';
      case 'skip':
        return isSwahili ? 'Ruka' : 'Skip';
      default:
        return key;
    }
  }

  /// Get localized screen titles
  String getLocalizedScreenTitle(String titleKey) {
    switch (titleKey) {
      case 'accessibility_settings':
        return isSwahili ? 'Mipangilio ya Ufikiaji' : 'Accessibility Settings';
      case 'profile':
        return isSwahili ? 'Wasifu' : 'Profile';
      case 'theme_mode':
        return isSwahili ? 'Hali ya Muonekano' : 'Theme Mode';
      case 'color_scheme':
        return isSwahili ? 'Mpango wa Rangi' : 'Color Scheme';
      case 'auto_theme':
        return isSwahili ? 'Muonekano wa Kiotomatiki' : 'Auto Theme';
      case 'push_notifications':
        return isSwahili ? 'Arifa za Kushinikiza' : 'Push Notifications';
      case 'sound_effects':
        return isSwahili ? 'Sauti za Athari' : 'Sound Effects';
      case 'vibration':
        return isSwahili ? 'Kutetemeka' : 'Vibration';
      case 'language':
        return isSwahili ? 'Lugha' : 'Language';
      case 'share_achievement':
        return isSwahili ? 'Shiriki Mafanikio' : 'Share Achievement';
      case 'high_contrast_mode':
        return isSwahili ? 'Hali ya Utofauti wa Juu' : 'High Contrast Mode';
      case 'screen_reader_support':
        return isSwahili ? 'Msaada wa Kifaa cha Kusoma' : 'Screen Reader Support';
      case 'reduced_motion':
        return isSwahili ? 'Mwanguko Mdogo' : 'Reduced Motion';
      case 'large_text':
        return isSwahili ? 'Maandishi Makubwa' : 'Large Text';
      case 'reset_settings':
        return isSwahili ? 'Weka Upya Mipangilio' : 'Reset Settings';
      default:
        return titleKey;
    }
  }

  /// Get localized navigation labels
  String getLocalizedNavigationLabel(String labelKey) {
    switch (labelKey) {
      case 'Hhome':
        return isSwahili ? 'Nyumbani' : 'Home';
      case 'missions':
        return isSwahili ? 'Misioni' : 'Missions';
      case 'leaderboard':
        return isSwahili ? 'Orodha ya Washindi' : 'Leaderboard';
      case 'profile':
        return isSwahili ? 'Wasifu' : 'Profile';
      default:
        return labelKey;
    }
  }

  /// Get localized category name
  String getLocalizedCategoryName(MissionCategory category) {
    switch (category) {
      case MissionCategory.mPesaSecurity:
        return isSwahili ? 'Usalama wa M-PESA' : 'M-PESA Security';
      case MissionCategory.mobileMoney:
        return isSwahili ? 'Pesa za Simu' : 'Mobile Money';
      case MissionCategory.whatsappSecurity:
        return isSwahili ? 'Usalama wa WhatsApp' : 'WhatsApp Security';
      case MissionCategory.onlineMarketplace:
        return isSwahili ? 'Soko la Mtandaoni' : 'Online Marketplace';
      case MissionCategory.saccoBanking:
        return isSwahili ? 'SACCO na Benki' : 'SACCO & Banking';
      case MissionCategory.educationYouth:
        return isSwahili ? 'Elimu na Vijana' : 'Education & Youth';
      case MissionCategory.kenyanCompliance:
        return isSwahili ? 'Uzingatiaji wa Kenya' : 'Kenyan Compliance';
      default:
        return category.toString().split('.').last;
    }
  }

  /// Get localized difficulty name
  String getLocalizedDifficultyName(MissionDifficulty difficulty) {
    switch (difficulty) {
      case MissionDifficulty.beginner:
        return isSwahili ? 'Mwanzo' : 'Beginner';
      case MissionDifficulty.intermediate:
        return isSwahili ? 'Kati' : 'Intermediate';
      case MissionDifficulty.advanced:
        return isSwahili ? 'Juu' : 'Advanced';
      case MissionDifficulty.expert:
        return isSwahili ? 'Mtaalamu' : 'Expert';
      default:
        return difficulty.toString().split('.').last;
    }
  }

  /// Get localized mission type name
  String getLocalizedMissionTypeName(MissionType type) {
    switch (type) {
      case MissionType.interactiveQuiz:
        return isSwahili ? 'Jaribio la Maswali' : 'Interactive Quiz';
      case MissionType.scamSimulator:
        return isSwahili ? 'Simulator ya Ujanja' : 'Scam Simulator';
      case MissionType.terminalChallenge:
        return isSwahili ? 'Changamoto ya Terminal' : 'Terminal Challenge';
      case MissionType.codeAnalysis:
        return isSwahili ? 'Uchambuzi wa Msimbo' : 'Code Analysis';
      case MissionType.passwordLab:
        return isSwahili ? 'Maabara ya Nenosiri' : 'Password Lab';
      case MissionType.storyMission:
        return isSwahili ? 'Misioni ya Hadithi' : 'Story Mission';
      default:
        return type.toString().split('.').last;
    }
  }

  /// Get localized challenge type name
  String getLocalizedChallengeTypeName(ChallengeType type) {
    switch (type) {
      case ChallengeType.multipleChoice:
        return isSwahili ? 'Chaguo Nyingi' : 'Multiple Choice';
      case ChallengeType.workbench:
        return isSwahili ? 'Bweni la Kazi' : 'Workbench';
      case ChallengeType.terminal:
        return isSwahili ? 'Terminal' : 'Terminal';
      case ChallengeType.codeReview:
        return isSwahili ? 'Ukaguzi wa Msimbo' : 'Code Review';
      case ChallengeType.passwordValidation:
        return isSwahili ? 'Uthibitishaji wa Nenosiri' : 'Password Validation';
      case ChallengeType.storyScenario:
        return isSwahili ? 'Hali ya Hadithi' : 'Story Scenario';
      default:
        return type.toString().split('.').last;
    }
  }

  /// Get localized status name
  String getLocalizedStatusName(MissionStatus status) {
    switch (status) {
      case MissionStatus.locked:
        return isSwahili ? 'Imefungwa' : 'Locked';
      case MissionStatus.available:
        return isSwahili ? 'Inapatikana' : 'Available';
      case MissionStatus.inProgress:
        return isSwahili ? 'Inaendelea' : 'In Progress';
      case MissionStatus.completed:
        return isSwahili ? 'Imekamilika' : 'Completed';
      default:
        return status.toString().split('.').last;
    }
  }
  
  /// Get localized subtitle text
  String getLocalizedSubtitle(String subtitleKey) {
    switch (subtitleKey) {
      case 'enhance_color_contrast':
        return isSwahili ? 'Boresha tofauti ya rangi kwa uonekano bora' : 'Enhance color contrast for better visibility';
      case 'enable_enhanced_screen_reader':
        return isSwahili ? 'Washa vipengele vya juu vya kifaa cha kusoma' : 'Enable enhanced screen reader features';
      case 'reduce_animations':
        return isSwahili ? 'Punguza mwanguko kwa uwezo wa kuhisi mwendo' : 'Reduce animations for motion sensitivity';
      case 'increase_text_size':
        return isSwahili ? 'Ongeza ukubwa wa maandishi kwa usomaji bora' : 'Increase text size for better readability';
      case 'follow_system_theme':
        return isSwahili ? 'Fuata muonekano wa mfumo' : 'Follow system theme';
      case 'get_notified_about_missions':
        return isSwahili ? 'Pata arifa kuhusu misioni mpya na mafanikio' : 'Get notified about new missions and achievements';
      case 'play_sounds_for_achievements':
        return isSwahili ? 'Cheza sauti kwa mafanikio na mwingiliano' : 'Play sounds for achievements and interactions';
      case 'vibrate_on_achievements':
        return isSwahili ? 'Tetemeka kwa mafanikio na matukio muhimu' : 'Vibrate on achievements and important events';
      case 'share_latest_achievement':
        return isSwahili ? 'Shiriki mafanikio yako ya hivi karibuni kwenye mitandao ya kijamii' : 'Share your latest achievement on social media';
      default:
        return subtitleKey;
    }
  }
  
  /// Get localized common phrases
  String getLocalizedCommonPhrase(String phraseKey) {
    switch (phraseKey) {
      case 'start_mission':
        return isSwahili ? 'Anza Misioni' : 'Start Mission';
      case 'continue_mission':
        return isSwahili ? 'Endelea Misioni' : 'Continue Mission';
      case 'complete_mission':
        return isSwahili ? 'Kamilisha Misioni' : 'Complete Mission';
      case 'mission_completed':
        return isSwahili ? 'Misioni Imekamilika!' : 'Mission Completed!';
      case 'xp_earned':
        return isSwahili ? 'XP Imepatikana' : 'XP Earned';
      case 'gems_earned':
        return isSwahili ? 'Alama Zimepatikana' : 'Gems Earned';
      case 'level_up':
        return isSwahili ? 'Ngazi Imepanda!' : 'Level Up!';
      case 'streak_increased':
        return isSwahili ? 'Mfululizo Umeongezeka!' : 'Streak Increased!';
      case 'achievement_unlocked':
        return isSwahili ? 'Mafanikio Yamefunguliwa!' : 'Achievement Unlocked!';
      case 'cyber_shujaa':
        return isSwahili ? 'CyberShujaa' : 'CyberShujaa';
      case 'kenya_cyber_guardian':
        return isSwahili ? 'Mlinzi wa Cyber wa Kenya' : 'Kenya Cyber Guardian';
      case 'digital_defender':
        return isSwahili ? 'Mlinzi wa Kidijitali' : 'Digital Defender';
      case 'cyber_hygiene':
        return isSwahili ? 'Usafi wa Cyber' : 'Cyber Hygiene';
      case 'phishing_awareness':
        return isSwahili ? 'Ufahamu wa Ujanja' : 'Phishing Awareness';
      case 'social_engineering':
        return isSwahili ? 'Uhandisi wa Kijamii' : 'Social Engineering';
      case 'malware_protection':
        return isSwahili ? 'Ulinzi wa Malware' : 'Malware Protection';
      case 'network_security':
        return isSwahili ? 'Usalama wa Mtandao' : 'Network Security';
      case 'cryptography':
        return isSwahili ? 'Kriptografia' : 'Cryptography';
      case 'forensics':
        return isSwahili ? 'Uchunguzi wa Kidijitali' : 'Forensics';
      case 'web_security':
        return isSwahili ? 'Usalama wa Mtandao' : 'Web Security';
      case 'please_sign_in':
        return isSwahili ? 'Tafadhali ingia ili kuona wasifu wako' : 'Please sign in to view your profile';
      case 'failed_to_load_progress':
        return isSwahili 
            ? 'Imeshindwa kupakia maendeleo. Gusa onyesha upya ili ujaribu tena.'
            : 'Failed to load user progress. Tap refresh to retry.';
      case 'logout_confirmation':
        return isSwahili 
            ? 'Una uhakika unataka kuondoka?'
            : 'Are you sure you want to logout?';
      case 'code_analysis_coming_soon':
        return isSwahili ? 'Uchambuzi wa msimbo utakuja hivi karibuni!' : 'Code Analysis coming soon!';
      case 'story_missions_in_story_tab':
        return isSwahili ? 'Misioni za hadithi ziko kwenye tab ya Hadithi.' : 'Story missions are in the Story tab.';
      case 'failed_to_start_mission':
        return isSwahili ? 'Imeshindwa kuanza misioni ya' : 'Failed to start mission for';
      case 'leave_mission':
        return isSwahili ? 'Ondoa Misioni?' : 'Leave Mission?';
      case 'are_you_sure_leave':
        return isSwahili ? 'Je, una uhakika unataka kuondoka? Maendeleo yako ya sasa yatahifadhiwa.' : 'Are you sure you want to leave? Your current progress will be saved.';
      case 'practice_complete':
        return isSwahili ? 'Mazoezi Yamekamilika' : 'Practice Complete';
      case 'mission_completed_congratulations':
        return isSwahili ? 'Hongera! Umekamilisha misioni hii!' : 'Congratulations! You have completed this mission!';
      case 'you_earned':
        return isSwahili ? 'Umepata:' : 'You earned:';
      case 'warning_action_cannot_undo':
        return isSwahili ? '⚠️ Onyo: Kitendo hiki hakiwezi kufutwa!' : '⚠️ Warning: This action cannot be undone!';
      case 'are_you_sure_delete':
        return isSwahili ? 'Je, una uhakika unataka kufuta' : 'Are you sure you want to delete';
      case 'this_will_permanently_remove':
        return isSwahili ? 'Hii itaondoa kwa kudumu misioni na data yote inayohusiana.' : 'This will permanently remove the mission and all associated data.';
      case 'no_missions_found':
        return isSwahili ? 'Hakuna misioni zilizopatikana. Unda misioni yako ya kwanza!' : 'No missions found. Create your first mission!';
      case 'no_tracks_found':
        return isSwahili ? 'Hakuna njia zilizopatikana. Unda njia yako ya kwanza!' : 'No tracks found. Create your first track!';
      case 'no_users_found':
        return isSwahili ? 'Hakuna watumiaji walio patikana' : 'No users found';
      case 'current_role':
        return isSwahili ? 'Jukumu la Sasa:' : 'Current Role:';
      case 'role_changes_require_cloud_function':
        return isSwahili ? 'Kumbuka: Mabadiliko ya jukumu yanahitaji Cloud Function ili kusasisha Firebase Auth custom claims.' : 'Note: Role changes require a Cloud Function to update Firebase Auth custom claims.';
      case 'this_will_reset':
        return isSwahili ? 'Hii itaweka upya:' : 'This will reset:';
      case 'user_level_back_to_1':
        return isSwahili ? '• Ngazi ya mtumiaji kurudi kwa 1' : '• User level back to 1';
      case 'xp_back_to_0':
        return isSwahili ? '• XP kurudi kwa 0' : '• XP back to 0';
      case 'all_mission_progress':
        return isSwahili ? '• Maendeleo yote ya misioni' : '• All mission progress';
      case 'achievement_progress':
        return isSwahili ? '• Maendeleo ya mafanikio' : '• Achievement progress';
      case 'are_you_sure_continue':
        return isSwahili ? 'Je, una uhakika unataka kuendelea?' : 'Are you sure you want to continue?';
      case 'questions':
        return isSwahili ? 'maswali' : 'questions';
      case 'mission_saved_successfully':
        return isSwahili ? 'Misioni imehifadhiwa kwa mafanikio!' : 'Mission saved successfully!';
      case 'mission_deleted_successfully':
        return isSwahili ? 'Misioni imefutwa kwa mafanikio!' : 'Mission deleted successfully!';
      case 'track_saved_successfully':
        return isSwahili ? 'Njia imehifadhiwa kwa mafanikio!' : 'Track saved successfully!';
      case 'track_deleted_successfully':
        return isSwahili ? 'Njia imefutwa kwa mafanikio!' : 'Track deleted successfully!';
      case 'user_role_updated':
        return isSwahili ? 'Jukumu la mtumiaji limeboreshwa kuwa' : 'User role updated to';
      case 'error_loading_missions':
        return isSwahili ? 'Hitilafu ya kupakia misioni:' : 'Error loading missions:';
      case 'error_saving_mission':
        return isSwahili ? 'Hitilafu ya kuhifadhi misioni:' : 'Error saving mission:';
      case 'error_deleting_mission':
        return isSwahili ? 'Hitilafu ya kufuta misioni:' : 'Error deleting mission:';
      case 'error_loading_tracks':
        return isSwahili ? 'Hitilafu ya kupakia njia:' : 'Error loading tracks:';
      case 'error_saving_track':
        return isSwahili ? 'Hitilafu ya kuhifadhi njia:' : 'Error saving track:';
      case 'error_deleting_track':
        return isSwahili ? 'Hitilafut ya kufuta njia:' : 'Error deleting track:';
      case 'error_loading_users':
        return isSwahili ? 'Hitilafu ya kupakia watumiaji:' : 'Error loading users:';
      case 'error_searching_users':
        return isSwahili ? 'Hitilafu ya kutafuta watumiaji:' : 'Error searching users:';
      case 'error_loading_user_stats':
        return isSwahili ? 'Hitilafu ya kupakia takwimu za mtumiaji:' : 'Error loading user stats:';
      case 'error_updating_mission':
        return isSwahili ? 'Hitilafu ya kusasisha misioni:' : 'Error updating mission:';
      case 'error_updating_track':
        return isSwahili ? 'Hitilafu ya kusasisha njia:' : 'Error updating track:';
      case 'error_updating_user_role':
        return isSwahili ? 'Hitilafu ya kusasisha jukumu la mtumiaji:' : 'Error updating user role:';
      case 'mission_published_successfully':
        return isSwahili ? 'Misioni imechapishwa kwa mafanikio!' : 'Mission published successfully!';
      case 'mission_unpublished_successfully':
        return isSwahili ? 'Misioni imeondolewa kwa mafanikio!' : 'Mission unpublished successfully!';
      case 'profile_editing_coming_soon':
        return isSwahili 
            ? 'Uhariri wa wasifu utakuja hivi karibuni'
            : 'Profile editing coming soon';
      case 'avatar_selection_coming_soon':
        return isSwahili 
            ? 'Uchaguzi wa picha utakuja hivi karibuni'
            : 'Avatar selection coming soon';
      case 'onboarding_title_1':
        return isSwahili 
            ? 'Kuwa CyberShujaa'
            : 'Become a CyberShujaa';
      case 'onboarding_description_1':
        return isSwahili 
            ? 'Jifunze kutambua udanganyifu na kukaa salama mtandaoni.'
            : 'Learn to spot scams and stay safe online.';
      case 'onboarding_title_2':
        return isSwahili 
            ? 'Shinda Mbinu za Udanganyifu'
            : 'Beat Scam Tactics';
      case 'onboarding_description_2':
        return isSwahili 
            ? 'Misioni za kushiriki zinakufundisha ujuzi wa ulimwengu wa kweli.'
            : 'Interactive missions teach you real-world skills.';
      case 'onboarding_title_3':
        return isSwahili 
            ? 'Panda Ngazi na Shindana'
            : 'Level Up & Compete';
      case 'onboarding_description_3':
        return isSwahili 
            ? 'Pata XP, weka mfululizo, na kupanda orodha ya washindi.'
            : 'Earn XP, keep streaks, and climb the leaderboard.';
      case 'onboarding_skip_button':
        return isSwahili ? 'Ruka' : 'Skip';
      case 'onboarding_next_button':
        return isSwahili ? 'Ifuatayo' : 'Next';
      case 'onboarding_start_button':
        return isSwahili ? 'Anza' : 'Start';
      case 'reset_onboarding':
        return isSwahili ? 'Weka Upya Utangulizi' : 'Reset Onboarding';
      case 'reset_onboarding_confirmation':
        return isSwahili ? 'Una uhakika unataka kuona utangulizi tena?' : 'Are you sure you want to see the onboarding again?';
      case 'onboarding_reset_success':
        return isSwahili ? 'Utangulizi umewekwa upya! Utaona tena unapofungua programu.' : 'Onboarding reset! You will see it again when you open the app.';
      case 'reset':
        return isSwahili ? 'Weka Upya' : 'Reset';
      case 'welcome_back':
        return isSwahili ? 'Karibu Tena' : 'Welcome Back';
      case 'sign_in_continue':
        return isSwahili ? 'Ingia ili kuendelea na safari yako ya usalama wa mtandao' : 'Sign in to continue your cybersecurity journey';
      case 'email':
        return isSwahili ? 'Barua pepe' : 'Email';
      case 'password':
        return isSwahili ? 'Nywila' : 'Password';
      case 'sign_in':
        return isSwahili ? 'Ingia' : 'Sign In';
      case 'continue_with_google':
        return isSwahili ? 'Endelea na Google' : 'Continue with Google';
      case 'signing_in':
        return isSwahili ? 'Inakuingia...' : 'Signing in...';
      case 'or':
        return isSwahili ? 'au' : 'or';
      case 'dont_have_account':
        return isSwahili ? 'Huna akaunti? ' : "Don't have an account? ";
      case 'sign_up':
        return isSwahili ? 'Jisajili' : 'Sign Up';
      case 'invalid_email_password':
        return isSwahili ? 'Barua pepe au nywila si sahihi' : 'Invalid email or password';
      case 'google_signin_cancelled':
        return isSwahili ? 'Uingiaji wa Google ulighairiwa au kushindwa' : 'Google sign-in was cancelled or failed';
      case 'google_signin_error':
        return isSwahili ? 'Hitilafu ilitokea wakati wa uingiaji wa Google. Tafadhali jaribu tena.' : 'An error occurred during Google sign-in. Please try again.';
      case 'failed_create_account':
        return isSwahili ? 'Imeshindwa kuunda akaunti' : 'Failed to create account';
      case 'error_occurred':
        return isSwahili ? 'Hitilafu ilitokea. Tafadhali jaribu tena.' : 'An error occurred. Please try again.';
      case 'display_name':
        return isSwahili ? 'Jina la kuonyesha' : 'Display Name';
      case 'sign_up':
        return isSwahili ? 'Jisajili' : 'Sign Up';
      case 'create_account':
        return isSwahili ? 'Unda Akaunti' : 'Create Account';
      case 'already_have_account':
        return isSwahili ? 'Una akaunti?' : 'Already have an account?';
      case 'please_enter_email':
        return isSwahili ? 'Tafadhali ingiza barua pepe yako' : 'Please enter your email';
      case 'please_enter_valid_email':
        return isSwahili ? 'Tafadhali ingiza barua pepe sahihi' : 'Please enter a valid email';
      case 'please_enter_password':
        return isSwahili ? 'Tafadhali ingiza nywila yako' : 'Please enter your password';
      case 'password_min_length':
        return isSwahili ? 'Nywila lazima iwe na angalau herufi 6' : 'Password must be at least 6 characters';
      case 'forgot_password':
        return isSwahili ? 'Umesahau Nywila?' : 'Forgot Password?';
      case 'reset_password':
        return isSwahili ? 'Weka Upya Nywila' : 'Reset Password';
      case 'enter_email_reset':
        return isSwahili ? 'Ingiza barua pepe yako ili kuweka upya nywila yako' : 'Enter your email to reset your password';
      case 'send_reset_link':
        return isSwahili ? 'Tuma Kiungo cha Kuweka Upya' : 'Send Reset Link';
      case 'reset_link_sent':
        return isSwahili ? 'Kiungo cha kuweka upya nywila kimetumwa kwenye barua pepe yako' : 'Password reset link sent to your email';
      case 'check_email':
        return isSwahili ? 'Angalia Barua Pepe Yako' : 'Check Your Email';
      case 'back_to_login':
        return isSwahili ? 'Rudi kwenye Uingiaji' : 'Back to Login';
      case 'system':
        return isSwahili ? 'Mfumo' : 'System';
      case 'light':
        return isSwahili ? 'Mwanga' : 'Light';
      case 'dark':
        return isSwahili ? 'Giza' : 'Dark';
      case 'level':
        return isSwahili ? 'Ngazi' : 'Level';
      case 'admin':
        return isSwahili ? 'Msimamizi' : 'Admin';
      case 'user':
        return isSwahili ? 'Mtumiaji' : 'User';
      case 'make_admin':
        return isSwahili ? 'Fanya Msimamizi' : 'Make Admin';
      case 'make_user':
        return isSwahili ? 'Fanya Mtumiaji' : 'Make User';
      default:
        return phraseKey;
    }
  }

  // Theme and Display Settings
  String getLocalizedThemeModeText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Hali ya Muonekano';
      case 'ki':
        return 'Hũthĩrĩro wa Mũonekano';
      case 'lu':
        return 'Tich Maber';
      default:
        return 'Theme Mode';
    }
  }

  String getLocalizedLightModeText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Mwangaza';
      case 'ki':
        return 'Ũũru';
      case 'lu':
        return 'Chieng';
      default:
        return 'Light Mode';
    }
  }

  String getLocalizedDarkModeText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Giza';
      case 'ki':
        return 'Mũtĩĩ';
      case 'lu':
        return 'Ochiko';
      default:
        return 'Dark Mode';
    }
  }

  String getLocalizedSystemDefaultText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Mfumo wa Chaguo';
      case 'ki':
        return 'Mũhaka wa Sĩsitemũ';
      case 'lu':
        return 'Sistem';
      default:
        return 'System Default';
    }
  }

  String getLocalizedDisplayOptionsText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Chaguo za Onyesho';
      case 'ki':
        return 'Mũhaka wa Kũonania';
      case 'lu':
        return 'Tich Maber';
      default:
        return 'Display Options';
    }
  }

  String getLocalizedHighContrastText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Tofauti ya Juu';
      case 'ki':
        return 'Mũhaka wa Kũhũthĩrĩra';
      case 'lu':
        return 'Kalo Maber';
      default:
        return 'High Contrast';
    }
  }

  String getLocalizedHighContrastDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Onyesha picha na maandishi kwa tofauti kubwa';
      case 'ki':
        return 'Ona mũhaka na maandĩko na mũhaka mũnene';
      case 'lu':
        return 'Nyiso picha gi tich ma ber';
      default:
        return 'Show images and text with high contrast';
    }
  }

  String getLocalizedLargeTextText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Maandishi Makubwa';
      case 'ki':
        return 'Maandĩko Manene';
      case 'lu':
        return 'Tich Nene';
      default:
        return 'Large Text';
    }
  }

  String getLocalizedLargeTextDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Onyesha maandishi kwa ukubwa mkubwa';
      case 'ki':
        return 'Ona maandĩko na ũkũrũ mũnene';
      case 'lu':
        return 'Nyiso tich ma nene';
      default:
        return 'Show text in larger size';
    }
  }

  // Language Settings
  String getLocalizedSelectLanguageText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Chagua Lugha';
      case 'ki':
        return 'Hũthĩra Rũthiomi';
      case 'lu':
        return 'Yiero Dho';
      default:
        return 'Select Language';
    }
  }

  String getLocalizedLanguageInfoText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Maelezo ya Lugha';
      case 'ki':
        return 'Ũmenyereri wa Rũthiomi';
      case 'lu':
        return 'Ngeche Dho';
      default:
        return 'Language Information';
    }
  }

  String getLocalizedLanguageDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Chagua lugha unayopenda kutumia katika programu. Mabadiliko yataanza kutumika mara moja.';
      case 'ki':
        return 'Hũthĩra rũthiomi ũrĩa ũkũũrĩte gũtũmĩra kũrĩa sĩsitemũ. Mũhaka ũkaambĩrĩria gũtũmĩka mara ĩmwe.';
      case 'lu':
        return 'Yiero dho ma wuon gi wuon. Moko biro chalo mara achiel.';
      default:
        return 'Choose the language you prefer to use in the app. Changes will take effect immediately.';
    }
  }

  String getLocalizedLanguageChangedText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Lugha imebadilishwa';
      case 'ki':
        return 'Rũthiomi rũhũthĩrĩtwo';
      case 'lu':
        return 'Dho oyudo';
      default:
        return 'Language changed';
    }
  }

  // Notification Settings
  String getLocalizedNotificationPreferencesText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Mapendeleo ya Arifa';
      case 'ki':
        return 'Mũhaka wa Kũmenyerera';
      case 'lu':
        return 'Wuon Ngeche';
      default:
        return 'Notification Preferences';
    }
  }

  String getLocalizedDailyRemindersText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Kumbusho za Kila Siku';
      case 'ki':
        return 'Kũkũmũkĩra Mũthenya';
      case 'lu':
        return 'Kanyo Odiechieng';
      default:
        return 'Daily Reminders';
    }
  }

  String getLocalizedDailyRemindersDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Pokea kumbusho za kufanya mazoezi ya usalama';
      case 'ki':
        return 'Kũmenya kũkũmũkĩra gũtũma mazoezi ya ũhoro wa ũũgĩ';
      case 'lu':
        return 'Goyo kanyo ma tiyo gi wuon ũgĩ';
      default:
        return 'Receive reminders to do security exercises';
    }
  }

  String getLocalizedMissionUpdatesText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Sasisho za Misheni';
      case 'ki':
        return 'Mũhaka wa Mũũrĩko';
      case 'lu':
        return 'Ngeche Mũũrĩko';
      default:
        return 'Mission Updates';
    }
  }

  String getLocalizedMissionUpdatesDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Pokea arifa kuhusu misheni mpya na mabadiliko';
      case 'ki':
        return 'Kũmenya ngeche kũrĩ mũũrĩko mũũru na mũhaka';
      case 'lu':
        return 'Goyo ngeche ma mũũrĩko machiek gi moko';
      default:
        return 'Receive notifications about new missions and changes';
    }
  }

  String getLocalizedAchievementAlertsText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Tahadhari za Mafanikio';
      case 'ki':
        return 'Kũmenyerera kwa Mũũgĩ';
      case 'lu':
        return 'Ngeche Mũũgĩ';
      default:
        return 'Achievement Alerts';
    }
  }

  String getLocalizedAchievementAlertsDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Pokea arifa unapofanikiwa kukamilisha changamoto';
      case 'ki':
        return 'Kũmenya ngeche ũrĩa ũkũũgĩa gũkũnyiiha mũũrĩko';
      case 'lu':
        return 'Goyo ngeche ka iwuon gi mũũrĩko';
      default:
        return 'Receive notifications when you complete challenges';
    }
  }

  String getLocalizedStreakRemindersText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Kumbusho za Mfululizo';
      case 'ki':
        return 'Kũkũmũkĩra wa Mũũrĩko';
      case 'lu':
        return 'Kanyo Mũũrĩko';
      default:
        return 'Streak Reminders';
    }
  }

  String getLocalizedStreakRemindersDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Pokea kumbusho za kudumisha mfululizo wako';
      case 'ki':
        return 'Kũmenya kũkũmũkĩra gũtũma mũũrĩko waku';
      case 'lu':
        return 'Goyo kanyo ma tiyo gi mũũrĩko ma';
      default:
        return 'Receive reminders to maintain your streak';
    }
  }

  String getLocalizedWeeklyReportsText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Ripoti za Wiki';
      case 'ki':
        return 'Ngeche wa Kiumia';
      case 'lu':
        return 'Ngeche Chieng';
      default:
        return 'Weekly Reports';
    }
  }

  String getLocalizedWeeklyReportsDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Pokea ripoti za mafanikio yako ya kila wiki';
      case 'ki':
        return 'Kũmenya ngeche wa mũũgĩ waku wa kiumia';
      case 'lu':
        return 'Goyo ngeche ma mũũgĩ ma chieng';
      default:
        return 'Receive weekly progress reports';
    }
  }

  String getLocalizedSecurityAlertsText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Tahadhari za Usalama';
      case 'ki':
        return 'Kũmenyerera wa Ũũgĩ';
      case 'lu':
        return 'Ngeche Ũũgĩ';
      default:
        return 'Security Alerts';
    }
  }

  String getLocalizedSecurityAlertsDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Pokea arifa muhimu za usalama wa mtandao';
      case 'ki':
        return 'Kũmenya ngeche mũũru wa ũhoro wa ũũgĩ wa thĩrĩra';
      case 'lu':
        return 'Goyo ngeche ma ũũgĩ ma thĩrĩra';
      default:
        return 'Receive important cybersecurity alerts';
    }
  }

  String getLocalizedCommunityUpdatesText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Sasisho za Jamii';
      case 'ki':
        return 'Mũhaka wa Ũrĩa';
      case 'lu':
        return 'Ngeche Ũrĩa';
      default:
        return 'Community Updates';
    }
  }

  String getLocalizedCommunityUpdatesDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Pokea arifa kuhusu jamii ya usalama wa mtandao';
      case 'ki':
        return 'Kũmenya ngeche kũrĩ ũrĩa wa ũhoro wa ũũgĩ wa thĩrĩra';
      case 'lu':
        return 'Goyo ngeche ma ũrĩa ma ũũgĩ ma thĩrĩra';
      default:
        return 'Receive updates about the cybersecurity community';
    }
  }

  String getLocalizedNotificationTimingText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Muda wa Arifa';
      case 'ki':
        return 'Hĩndĩ ya Kũmenyerera';
      case 'lu':
        return 'Chieng Ngeche';
      default:
        return 'Notification Timing';
    }
  }

  String getLocalizedQuietHoursText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Saa za Kimya';
      case 'ki':
        return 'Hĩndĩ ya Kũnyamara';
      case 'lu':
        return 'Chieng Kũnyamara';
      default:
        return 'Quiet Hours';
    }
  }

  String getLocalizedQuietHoursDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Weka muda wa usiku usipokei arifa';
      case 'ki':
        return 'Hũthĩra hĩndĩ ya ũtukũ ũtamenya ngeche';
      case 'lu':
        return 'Hũthĩra chieng ma otieno ma goyo ngeche';
      default:
        return 'Set night time when you won\'t receive notifications';
    }
  }

  String getLocalizedReminderTimeText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Muda wa Kumbusho';
      case 'ki':
        return 'Hĩndĩ ya Kũkũmũkĩra';
      case 'lu':
        return 'Chieng Kanyo';
      default:
        return 'Reminder Time';
    }
  }

  String getLocalizedReminderTimeDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Weka muda wa kuchukua kumbusho za kila siku';
      case 'ki':
        return 'Hũthĩra hĩndĩ ya gũtũma kũkũmũkĩra mũthenya';
      case 'lu':
        return 'Hũthĩra chieng ma tiyo kanyo odiechieng';
      default:
        return 'Set time to receive daily reminders';
    }
  }

  String getLocalizedNotificationInfoText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Maelezo ya Arifa';
      case 'ki':
        return 'Ũmenyereri wa Kũmenyerera';
      case 'lu':
        return 'Ngeche Ngeche';
      default:
        return 'Notification Information';
    }
  }

  String getLocalizedNotificationDescriptionText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Arifa hizi zitakusaidia kukumbuka kufanya mazoezi ya usalama na kufuatilia mafanikio yako. Unaweza kuziweka au kuzizima wakati wowote.';
      case 'ki':
        return 'Ngeche icio ĩkaakũũrĩte gũkũmũkĩra gũtũma mazoezi ya ũhoro wa ũũgĩ na gũtũma mũũgĩ waku. Ũkaahũthĩra kana ũkaazĩnga hĩndĩ o ĩngĩ.';
      case 'lu':
        return 'Ngeche ma gi biro kũũr gi kanyo ma tiyo gi wuon ũgĩ gi wuon mũũgĩ ma. I biro hũthĩr gi kana i zing gi chieng o achiel.';
      default:
        return 'These notifications will help you remember to do security exercises and track your progress. You can enable or disable them at any time.';
    }
  }

  String getLocalizedQuietHoursComingSoonText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Huduma hii itakuja hivi karibuni';
      case 'ki':
        return 'Ũũrĩki ũyũ ũkaaĩa hĩndĩ ya gũtũũra';
      case 'lu':
        return 'Tiyo ma biro biro chieng ma';
      default:
        return 'This feature is coming soon';
    }
  }

  String getLocalizedReminderTimeComingSoonText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Huduma hii itakuja hivi karibuni';
      case 'ki':
        return 'Ũũrĩki ũyũ ũkaaĩa hĩndĩ ya gũtũũra';
      case 'lu':
        return 'Tiyo ma biro biro chieng ma';
      default:
        return 'This feature is coming soon';
    }
  }

  String getLocalizedOkText() {
    switch (currentLanguage) {
      case 'sw':
        return 'Sawa';
      case 'ki':
        return 'Ũũ';
      case 'lu':
        return 'Ber';
      default:
        return 'OK';
    }
  }
}
