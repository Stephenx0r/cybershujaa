import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_models.dart';
import '../providers/app_providers.dart';
import '../components/enhanced_mission_card.dart';
import '../components/story_mission_card.dart';
import '../utils/app_theme.dart';
import 'missions/interactive_quiz_screen.dart';
import 'missions/web_traffic_analysis_screen.dart';
import 'missions/terminal_simulation_screen.dart';
import 'missions/password_lab_screen.dart';
import 'missions/story_mission_screen.dart';

class EnhancedMissionScreen extends ConsumerStatefulWidget {
  const EnhancedMissionScreen({super.key});

  @override
  ConsumerState<EnhancedMissionScreen> createState() => _EnhancedMissionScreenState();
}

class _EnhancedMissionScreenState extends ConsumerState<EnhancedMissionScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  late AnimationController _screenAnimationController;
  late Animation<double> _screenFadeAnimation;
  late Animation<Offset> _screenSlideAnimation;
  
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;
  
  List<Mission> _allMissions = [];
  List<Mission> _filteredMissions = [];
  Set<MissionCategory> _selectedCategories = {};
  Set<MissionDifficulty> _selectedDifficulties = {};
  String _searchQuery = '';
  
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupAnimations();
    _loadMissions();
    
    WidgetsBinding.instance.addObserver(this);
  }

  void _setupAnimations() {
    _screenAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _screenFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _screenAnimationController,
      curve: Curves.easeOut,
    ));

    _screenSlideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _screenAnimationController,
      curve: Curves.easeOut,
    ));

    _screenAnimationController.forward();
  }

  Future<void> _loadMissions() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final missionService = ref.read(firebaseMissionServiceProvider);
      final missions = await missionService.getMissions();
      
      setState(() {
        _allMissions = missions;
        _filteredMissions = missions;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading missions: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }



  Future<void> refreshMissions() async {
    await _loadMissions();
  }

  void _onSearchChanged(String query) {
    _searchQuery = query;
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 300), () {
      _applyFilters();
    });
  }

  void _toggleCategoryFilter(MissionCategory category) {
    setState(() {
      if (_selectedCategories.contains(category)) {
        _selectedCategories.remove(category);
      } else {
        _selectedCategories.add(category);
      }
      _applyFilters();
    });
  }

  void _toggleDifficultyFilter(MissionDifficulty difficulty) {
    setState(() {
      if (_selectedDifficulties.contains(difficulty)) {
        _selectedDifficulties.remove(difficulty);
      } else {
        _selectedDifficulties.add(difficulty);
      }
      _applyFilters();
    });
  }

  void _applyFilters() {
    List<Mission> filtered = _allMissions;

    // Apply category filter
    if (_selectedCategories.isNotEmpty) {
      filtered = filtered.where((mission) => 
        _selectedCategories.contains(mission.category)
      ).toList();
    }

    // Apply difficulty filter
    if (_selectedDifficulties.isNotEmpty) {
      filtered = filtered.where((mission) => 
        _selectedDifficulties.contains(mission.difficulty)
      ).toList();
    }

    // Apply search filter
    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((mission) =>
        mission.title.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        mission.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    setState(() {
      _filteredMissions = filtered;
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedDifficulties.clear();
      _searchQuery = '';
      _searchController.clear();
      _filteredMissions = _allMissions;
    });
  }

  void _startMission(Mission mission) {
    // Navigate to the appropriate mission screen based on mission type
    Widget missionScreen;
    
    switch (mission.type) {
      case MissionType.interactiveQuiz:
        missionScreen = InteractiveQuizScreen(mission: mission);
        break;
      case MissionType.terminalChallenge:
        missionScreen = TerminalSimulationScreen(mission: mission);
        break;
      case MissionType.passwordLab:
        missionScreen = PasswordLabScreen(mission: mission);
        break;
      case MissionType.scamSimulator:
        missionScreen = WebTrafficAnalysisScreen(mission: mission);
        break;
      default:
        // Fallback to a generic mission screen or show error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Mission type ${mission.type} not yet implemented'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
    }
    
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => missionScreen),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _searchDebounce?.cancel();
    _screenAnimationController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Missions',
          style: TextStyle(
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
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: refreshMissions,
            tooltip: 'Refresh Missions',
          ),
          const SizedBox(width: 8),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          indicatorWeight: 3,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white.withOpacity(0.7),
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
          tabs: const [
            Tab(text: 'Daily'),
            Tab(text: 'All'),
            Tab(text: 'Seasonal'),
            Tab(text: 'Story'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : FadeTransition(
              opacity: _screenFadeAnimation,
              child: SlideTransition(
                position: _screenSlideAnimation,
                child: RefreshIndicator(
                  onRefresh: () async {
                    await refreshMissions();
                  },
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildSearchAndFilterBar(),
                        _buildTabContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Compact search bar
          TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search missions...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: isDark ? AppTheme.surfaceDark : AppTheme.dividerLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
          const SizedBox(height: 12),
          
          // Compact categories and difficulty in a row
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Categories',
                      style: AppTheme.getBodySmall(isDark).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        // Show only the most important categories
                        MissionCategory.phishing,
                        MissionCategory.malware,
                        MissionCategory.cryptography,
                        MissionCategory.forensics,
                        MissionCategory.webSecurity,
                        MissionCategory.socialEngineering,
                      ].map((category) {
                        return FilterChip(
                          label: Text(
                            _formatCategoryName(category.name),
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: _selectedCategories.contains(category),
                          onSelected: (selected) => _toggleCategoryFilter(category),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: () => _showAllCategories(context, isDark),
                      child: Text(
                        'Show all categories',
                        style: TextStyle(
                          fontSize: 10,
                          color: AppTheme.primaryPurple,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Difficulty',
                      style: AppTheme.getBodySmall(isDark).copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: MissionDifficulty.values.map((difficulty) {
                        return FilterChip(
                          label: Text(
                            difficulty.name,
                            style: const TextStyle(fontSize: 11),
                          ),
                          selected: _selectedDifficulties.contains(difficulty),
                          onSelected: (selected) => _toggleDifficultyFilter(difficulty),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          // Compact filter results
          if (_selectedCategories.isNotEmpty ||
              _selectedDifficulties.isNotEmpty ||
              _searchQuery.isNotEmpty) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Text(
                  'Found ${_filteredMissions.length} of ${_allMissions.length} missions',
                  style: AppTheme.getBodySmall(isDark),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: _clearFilters,
                  icon: const Icon(Icons.clear_all, size: 16),
                  label: const Text('Clear all', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }





  Widget _buildTabContent() {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.7, // Increased height for better content visibility
      child: TabBarView(
        controller: _tabController,
        children: [
          _buildDailyTab(),
          _buildAllMissionsTab(),
          _buildSeasonalMissionsTab(),
          _buildStoryMissionsTab(),
        ],
      ),
    );
  }

  Widget _buildDailyTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        12.0,
        12.0,
        12.0,
        MediaQuery.of(context).padding.bottom + kBottomNavigationBarHeight + 24.0,
      ), // Ensure content clears bottom nav
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Daily Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16), // Reduced padding
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primaryPurple.withOpacity(0.1),
                  AppTheme.accentBlue.withOpacity(0.1),
                ],
              ),
              borderRadius: BorderRadius.circular(12), // Reduced border radius
              border: Border.all(
                color: AppTheme.primaryPurple.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.today,
                      color: AppTheme.primaryPurple,
                      size: 24, // Reduced icon size
                    ),
                    const SizedBox(width: 10), // Reduced spacing
                    Text(
                      'Daily Challenge',
                      style: AppTheme.getHeadlineSmall(isDark).copyWith( // Smaller text
                        color: AppTheme.primaryPurple,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6), // Reduced spacing
                Text(
                  'Complete today\'s password security challenge to earn bonus XP and maintain your streak!',
                  style: AppTheme.getBodyMedium(isDark), // Smaller text
                ),
                const SizedBox(height: 12), // Reduced spacing
                Row(
                  children: [
                    _buildDailyStat(
                      Icons.local_fire_department,
                      '0',
                      'Day Streak',
                      AppTheme.accentOrange,
                      isDark,
                    ),
                    const SizedBox(width: 16),
                    _buildDailyStat(
                      Icons.star,
                      '+50',
                      'Bonus XP',
                      AppTheme.highContrastAccent,
                      isDark,
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16), // Reduced spacing
          
          // Daily Password Lab Mission
          Text(
            'Today\'s Mission',
            style: AppTheme.getBodyLarge(isDark).copyWith( // Smaller text
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12), // Reduced spacing
          
          // Password Lab Card
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? AppTheme.dividerDark : AppTheme.dividerLight,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Mission Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryPurple.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.security,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Password Security Lab',
                              style: AppTheme.getHeadlineSmall(isDark).copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryPurple,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Master the art of creating strong passwords',
                              style: AppTheme.getBodyMedium(isDark).copyWith(
                                color: AppTheme.primaryPurple.withOpacity(0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Mission Content
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Daily Challenge',
                        style: AppTheme.getTitleMedium(isDark).copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Create a password that meets all security criteria:',
                        style: AppTheme.getBodyMedium(isDark),
                      ),
                      const SizedBox(height: 16),
                      
                      // Password Criteria
                      _buildDailyCriteria('At least 12 characters', true),
                      _buildDailyCriteria('Contains uppercase letters (A-Z)', true),
                      _buildDailyCriteria('Contains lowercase letters (a-z)', true),
                      _buildDailyCriteria('Contains numbers (0-9)', true),
                      _buildDailyCriteria('Contains special characters (!@#\$%^&*)', true),
                      _buildDailyCriteria('No common patterns', true),
                      
                      const SizedBox(height: 24),
                      
                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () => _startDailyPasswordLab(),
                              icon: const Icon(Icons.play_arrow),
                              label: const Text('Start Daily Challenge'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryPurple,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          IconButton(
                            onPressed: () => _showDailyTips(),
                            icon: const Icon(Icons.lightbulb_outline),
                            tooltip: 'Daily Tips',
                            style: IconButton.styleFrom(
                              backgroundColor: AppTheme.accentOrange.withOpacity(0.1),
                              padding: const EdgeInsets.all(16),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          

        ],
      ),
    );
  }
  
  Widget _buildDailyStat(IconData icon, String value, String label, Color color, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? AppTheme.textLightDark : AppTheme.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  Widget _buildDailyCriteria(String text, bool isMet) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.accentGreen,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 14,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            text,
            style: AppTheme.getBodyMedium(isDark),
          ),
        ],
      ),
    );
  }
  

  
  void _startDailyPasswordLab() {
    // Create a daily password lab mission
    final dailyMission = Mission(
      id: 'DAILY_PASSWORD_LAB',
      title: 'Daily Password Security Lab',
      description: 'Complete today\'s password security challenge to earn bonus XP and maintain your streak!',
      category: MissionCategory.cryptography,
      difficulty: MissionDifficulty.beginner,
      type: MissionType.passwordLab,
      status: MissionStatus.available,
      requiredLevel: 1,
      xpReward: 50,
      gemReward: 5,
      challenges: [],
      imageUrl: null,
      unlockDate: null,
      expiryDate: null,
      localizedTitle: null,
      localizedDescription: null,
      countryContext: null,
      isLocalized: false,
    );
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PasswordLabScreen(mission: dailyMission),
      ),
    );
  }
  
  void _showDailyTips() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daily Password Tips'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTipItem('🔐 Use a mix of character types'),
            _buildTipItem('📏 Make it at least 12 characters long'),
            _buildTipItem('🚫 Avoid common patterns and words'),
            _buildTipItem('🔄 Change passwords regularly'),
            _buildTipItem('💡 Consider using a password manager'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it!'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildTipItem(String tip) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(tip),
    );
  }

  String _formatCategoryName(String categoryName) {
    // Convert camelCase to readable format
    return categoryName
        .replaceAll(RegExp(r'([A-Z])'), ' \$1')
        .trim()
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  void _showAllCategories(BuildContext context, bool isDark) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('All Categories'),
        content: SizedBox(
          width: double.maxFinite,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: MissionCategory.values.map((category) {
                              return FilterChip(
                  label: Text(
                    _formatCategoryName(category.name),
                    style: const TextStyle(fontSize: 12),
                  ),
                  selected: _selectedCategories.contains(category),
                  onSelected: (selected) {
                    _toggleCategoryFilter(category);
                    Navigator.of(context).pop();
                  },
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }



  Widget _buildAllMissionsTab() {
    return RefreshIndicator(
      onRefresh: () async {
        await refreshMissions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: _filteredMissions.length,
        itemBuilder: (context, index) {
          final mission = _filteredMissions[index];
          return EnhancedMissionCard(
            mission: mission,
            onStart: () => _startMission(mission),
            animation: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _screenAnimationController,
                curve: Interval(
                  index * 0.1,
                  0.6 + index * 0.1,
                  curve: Curves.easeOut,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSeasonalMissionsTab() {
    final seasonalMissions = _allMissions.where((mission) => mission.id.startsWith('SEASONAL_')).toList();
    
    if (seasonalMissions.isEmpty) {
      return _buildEmptyState('No seasonal missions available yet');
    }
    
    return RefreshIndicator(
      onRefresh: () async {
        await refreshMissions();
      },
      child: ListView.builder(
        padding: const EdgeInsets.only(bottom: 16),
        itemCount: seasonalMissions.length,
        itemBuilder: (context, index) {
          final mission = seasonalMissions[index];
          return EnhancedMissionCard(
            mission: mission,
            onStart: () => _startMission(mission),
            animation: Tween<double>(
              begin: 0.0,
              end: 1.0,
            ).animate(
              CurvedAnimation(
                parent: _screenAnimationController,
                curve: Interval(
                  index * 0.1,
                  0.6 + index * 0.1,
                  curve: Curves.easeOut,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStoryMissionsTab() {
    return FutureBuilder<Map<String, List<String>>>(
      future: _loadStoryProgress(),
      builder: (context, progressSnapshot) {
        if (progressSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (progressSnapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(width: 16),
                Text(
                  'Error loading story progress',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }
        
        final storyProgress = progressSnapshot.data ?? {};
        
        return FutureBuilder<List<StoryMission>>(
          future: _loadStoryMissions(),
          builder: (context, missionsSnapshot) {
            if (missionsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            
            if (missionsSnapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 16),
                    Text(
                      'Error loading story missions',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }
            
            final storyMissions = missionsSnapshot.data ?? [];
            
            if (storyMissions.isEmpty) {
              return _buildEmptyState('No story missions available yet');
            }
            
            return RefreshIndicator(
              onRefresh: () async {
                setState(() {});
              },
              child: ListView.builder(
                padding: const EdgeInsets.only(bottom: 16),
                itemCount: storyMissions.length,
                itemBuilder: (context, index) {
                  final storyMission = storyMissions[index];
                  final completedScenarioIds = storyProgress[storyMission.id] ?? [];
                   
                  return StoryMissionCard(
                    storyMission: storyMission,
                    onStart: () => _startStoryMission(storyMission),
                    completedScenarioIds: completedScenarioIds,
                    animation: Tween<double>(
                      begin: 0.0,
                      end: 1.0,
                    ).animate(
                      CurvedAnimation(
                        parent: _screenAnimationController,
                        curve: Interval(
                          index * 0.1,
                          0.6 + index * 0.1,
                          curve: Curves.easeOut,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.hourglass_empty,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(width: 16),
          Text(
            message,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.orange[600],
            ),
          ),
        ],
      ),
    );
  }

  Future<List<StoryMission>> _loadStoryMissions() async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    try {
      final storyMission = StoryMission(
        id: 'STORY_001',
        title: 'The Digital Breach Investigation',
        description: 'Follow Sarah Chen, a cybersecurity analyst, as she investigates a sophisticated data breach at TechCorp Industries.',
        mainCharacter: 'Sarah Chen, Senior Cybersecurity Analyst',
        storyBackground: 'TechCorp Industries, a leading technology company, has reported unusual network activity and potential data exfiltration. As the lead investigator, you\'ll work alongside Sarah to uncover the truth behind this breach.',
        difficulty: MissionDifficulty.intermediate,
        category: MissionCategory.forensics,
        totalXpReward: 1500,
        totalGemReward: 75,
        imageUrl: null,
        scenarios: [
          StoryScenario(
            id: 'SCENARIO_001',
            title: 'The Alert',
            description: 'Review the initial security alert and understand the scope of the incident.',
            narrativeText: 'It\'s 3:47 AM when Sarah receives the urgent notification. The SIEM system has detected anomalous network traffic patterns. Multiple failed login attempts, unusual data transfers, and suspicious process executions have triggered a critical alert. "This doesn\'t look like our usual false positives," Sarah mutters as she begins her investigation.',
            challengeType: ChallengeType.multipleChoice,
            content: ChallengeContent(
              dataType: 'security_alert',
              toolType: 'siem_dashboard',
              solution: 'B',
              guidePoints: [
                'Review the alert severity and confidence score',
                'Identify the affected systems and users',
                'Check for similar patterns in recent history',
                'Determine if this is a false positive or real threat'
              ],
              dataPayload: {
                'alert_id': 'ALERT_2024_001',
                'severity': 'critical',
                'confidence': 0.89,
                'affected_systems': ['web_server_01', 'database_02'],
                'suspicious_ips': ['192.168.1.100', '10.0.0.50'],
                'question': 'What is the most critical first step when responding to a security alert?',
                'options': [
                  'A) Ignore the alert and go back to sleep',
                  'B) Immediately assess the scope and impact of the incident',
                  'C) Delete all system logs to cover up the breach',
                  'D) Share the alert details on social media'
                ],
                'correct_answer': 'B',
                'explanation': 'The first step in incident response is to assess the scope and impact. This helps determine the appropriate response level and resources needed.'
              },
            ),
            xpReward: 200,
            isUnlocked: true,
            requiredPreviousScenarios: 0,
            characterName: 'Sarah Chen',
            incidentType: 'Security Alert',
          ),
        ],
      );
      
      return [storyMission];
    } catch (e) {
      print('Error loading story missions: $e');
      return [];
    }
  }

  void _startStoryMission(StoryMission storyMission) async {
    final result = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryMissionScreen(storyMission: storyMission),
      ),
    );
    
    if (result == true && mounted) {
      setState(() {});
    }
  }

  Future<Map<String, List<String>>> _loadStoryProgress() async {
    try {
      final progressService = ref.read(progressServiceProvider);
      final userProgress = await progressService.getUserProgress();
      
      if (userProgress != null && userProgress.storyProgress != null) {
        final storyProgress = userProgress.storyProgress!;
        final Map<String, List<String>> result = {};
        
        for (final entry in storyProgress.entries) {
          final storyMissionId = entry.key;
          final storyData = entry.value as Map<String, dynamic>;
          final completedScenarios = storyData['completedScenarios'] as List<dynamic>? ?? [];
          
          result[storyMissionId] = completedScenarios.map((id) => id.toString()).toList();
        }
        
        return result;
      }
      
      return {};
    } catch (e) {
      print('Error loading story progress: $e');
      return {};
    }
  }
}
