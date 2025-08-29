import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import '../models/mission_models.dart';
import '../models/skill_tree_models.dart';
import '../services/progress_service.dart';
import '../services/skill_tree_service.dart';
import '../services/language_service.dart';
import '../services/social_sharing_service.dart';
import '../utils/app_theme.dart';
import '../providers/app_providers.dart';
import '../screens/main_navigation_screen.dart';
import 'missions/interactive_quiz_screen.dart';
import 'missions/web_traffic_analysis_screen.dart';
import 'missions/terminal_simulation_screen.dart';
import 'missions/password_lab_screen.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> with TickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _skillTreeController;
  late AnimationController _welcomeController;
  late Animation<double> _skillTreeAnimation;
  late Animation<double> _welcomeAnimation;
  
  int _userLevel = 1;
  int _userXp = 0;
  int _nextLevelXp = 1000;
  double _levelProgress = 0.0;
  int _currentStreak = 0;
  bool _isLoading = true;
  bool _isDark = false;

  // Skill tree data
  late List<SkillNode> _skillTree;
  final SkillTreeService _skillTreeService = SkillTreeService();

  @override
  void initState() {
    super.initState();
    _skillTree = _skillTreeService.getSkillTree();
    _setupAnimations();
    _loadUserProgress();
    
    // Listen for app lifecycle changes to refresh progress when returning
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Refresh progress when app becomes active (returning from mission)
    if (state == AppLifecycleState.resumed) {
      _loadUserProgress();
    }
  }

  void _setupAnimations() {
    _skillTreeController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _welcomeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _skillTreeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _skillTreeController,
      curve: Curves.easeOutBack,
    ));

    _welcomeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _welcomeController,
      curve: Curves.easeOut,
    ));

    _welcomeController.forward();
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) _skillTreeController.forward();
    });
  }

  Future<void> _loadUserProgress() async {
    try {
      print('=== HOME SCREEN: LOADING USER PROGRESS ===');
      final progressService = ref.read(progressServiceProvider);
      print('Progress service obtained');
      
      final userProgress = await progressService.getUserProgress();
      print('User progress result: ${userProgress != null ? "SUCCESS" : "NULL"}');
      
      if (userProgress != null && mounted) {
        print('Setting user data: Level ${userProgress.level}, XP ${userProgress.xp}');
        setState(() {
          _userLevel = userProgress.level;
          _userXp = userProgress.xp;
          _nextLevelXp = userProgress.getNextLevelXp();
          _levelProgress = userProgress.getLevelProgress() / 100.0;
          _currentStreak = userProgress.streak.currentStreak ?? 0;
          _isLoading = false;
        });
        
        // Update skill tree based on user progress
        _skillTreeService.updateSkillTree(_skillTree, _userXp);
        print('User progress loaded successfully');
      } else {
        print('No user progress data, setting loading to false');
        setState(() {
          _isLoading = false;
        });
        
        // Show error message for debugging
        if (mounted) {
          final languageService = ref.read(languageServiceProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(languageService.getLocalizedCommonPhrase('failed_to_load_progress')),
              action: SnackBarAction(
                label: 'Refresh',
                textColor: Colors.white,
                onPressed: () => _loadUserProgress(),
              ),
            ),
          );
        }
      }
    } catch (e, stackTrace) {
      print('=== HOME SCREEN: ERROR LOADING USER PROGRESS ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSkillNodeTapped(SkillNode skill) {
    if (!skill.isUnlocked) {
      // Show locked skill message
      final xpNeeded = skill.xpRequired - _userXp;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You need $xpNeeded more XP to unlock ${skill.title}!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.orange,
          duration: const Duration(seconds: 3),
          action: SnackBarAction(
            label: 'View Missions',
            textColor: Colors.white,
            onPressed: () {
              // Switch to Missions tab via shared provider
              ref.read(mainTabIndexProvider.notifier).state = 1;
            },
          ),
        ),
      );
    } else if (skill.isCompleted) {
      // Show completed skill message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '🎉 ${skill.title} completed! Great job!',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } else {
      // Navigate to skill missions
      _navigateToSkillMissions(skill);
    }
  }

  void _navigateToSkillMissions(SkillNode skill) {
    // Map skill IDs to mission IDs and deep link into mission list
    final Map<String, String> skillToMission = {
      'networking': 'M101',
      'cryptography': 'M102',
      'log_analysis': 'M201',
      'memory_analysis': 'M202',
      'static_analysis': 'M301',
      'dynamic_analysis': 'M302',
      'containment': 'M401',
      'recovery': 'M402',
    };

    final missionId = skillToMission[skill.id];
    if (missionId == null) {
      // Fallback: switch to Missions tab
      ref.read(mainTabIndexProvider.notifier).state = 1;
      return;
    }

    // Switch to Missions and open the mapped mission
    ref.read(mainTabIndexProvider.notifier).state = 1;
    // Use a microtask so tab switch applies before navigation
    Future.microtask(() async {
      try {
        final missionService = ref.read(firebaseMissionServiceProvider);
        final mission = await missionService.getMissionById(missionId);
        await missionService.startMission(mission.id);
        if (!mounted) return;
        switch (mission.type) {
          case MissionType.interactiveQuiz:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => InteractiveQuizScreen(mission: mission),
              ),
            );
            break;
          case MissionType.scamSimulator:
            if (mission.challenges.first.content.dataType == 'web_traffic_logs') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => WebTrafficAnalysisScreen(mission: mission),
                ),
              );
            } else if (mission.challenges.first.content.dataType == 'terminal_output') {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => TerminalSimulationScreen(mission: mission),
                ),
              );
            }
            break;
          case MissionType.terminalChallenge:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => TerminalSimulationScreen(mission: mission),
              ),
            );
            break;
          case MissionType.codeAnalysis:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Code Analysis coming soon!')),
            );
            break;
          case MissionType.passwordLab:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PasswordLabScreen(mission: mission),
              ),
            );
            break;
          case MissionType.storyMission:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Story missions are in the Story tab.')),
            );
            break;
        }
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to start mission for ${skill.title}')),
        );
      }
    });
  }

  @override
  void dispose() {
    _skillTreeController.dispose();
    _welcomeController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _isDark = Theme.of(context).brightness == Brightness.dark;
    final languageService = ref.watch(languageServiceProvider);
    return Scaffold(
      backgroundColor: _isDark ? AppTheme.backgroundDark : AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 16),
              child: _buildWelcomeSection(),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.only(top: 8),
              child: _buildProgressSection(),
            ),
          ),
          _buildSkillTreeHeaderSliver(),
          _buildSkillTreeSliver(),
          const SliverToBoxAdapter(
            child: SizedBox(height: 100), // Bottom padding for bottom nav
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            _isLoading = true;
          });
          _loadUserProgress();
        },
        backgroundColor: AppTheme.primaryPurple,
        foregroundColor: Colors.white,
        elevation: 8,
        tooltip: 'Refresh Progress',
        child: const Icon(Icons.refresh),
      ),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 100,
      floating: false,
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      actions: [
        // Compact Notification Bell
        Container(
          margin: const EdgeInsets.only(right: 4),
          child: Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.white, size: 20),
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notifications coming soon!')),
                  );
                },
                tooltip: 'Notifications',
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
              // Small Notification Badge
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: AppTheme.accentRed,
                    borderRadius: BorderRadius.circular(7),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 14,
                    minHeight: 14,
                  ),
                  child: const Text(
                    '3',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        // Compact Level Badge
        Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star,
                color: AppTheme.accentOrange,
                size: 12,
              ),
              const SizedBox(width: 3),
              Text(
                'Level ${_userLevel}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        title: AnimatedBuilder(
          animation: _welcomeAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: 0.7 + (_welcomeAnimation.value * 0.3),
              child: const Text(
                'CyberShujaa',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                  letterSpacing: 0.8,
                  fontFamily: 'monospace',
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 2,
                      color: Colors.black26,
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        titlePadding: const EdgeInsets.only(left: 16, bottom: 12),
        background: Container(
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
          child: Stack(
            children: [
              // Subtle Background Pattern
              Positioned.fill(
                child: Opacity(
                  opacity: 0.03,
                  child: CustomPaint(
                    painter: HexagonPatternPainter(),
                  ),
                ),
              ),
              // Minimal Background Elements
              Positioned(
                top: -15,
                right: -15,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              Positioned(
                bottom: -20,
                left: -20,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return AnimatedBuilder(
      animation: _welcomeAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _welcomeAnimation.value,
          child: Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isDark 
                    ? [
                        AppTheme.primaryPurple.withOpacity(0.2),
                        AppTheme.primaryPurple.withOpacity(0.1),
                      ]
                    : [
                        AppTheme.primaryPurple.withOpacity(0.1),
                        AppTheme.primaryPurple.withOpacity(0.05),
                      ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: _isDark 
                    ? AppTheme.primaryPurple.withOpacity(0.3)
                    : AppTheme.primaryPurple.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: AppTheme.primaryPurple,
                      child: Icon(
                        Icons.security,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _getTimeBasedGreeting(),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppTheme.primaryPurple,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'Level $_userLevel Cyber Defender',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: _isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem(
                      icon: Icons.local_fire_department,
                      value: '$_currentStreak',
                      label: 'Day Streak',
                      color: Colors.orange,
                    ),
                    _buildStatItem(
                      icon: Icons.star,
                      value: '$_userXp',
                      label: 'Total XP',
                      color: Colors.amber,
                    ),
                    _buildStatItem(
                      icon: Icons.emoji_events,
                      value: '$_userLevel',
                      label: 'Level',
                      color: AppTheme.primaryPurple,
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: _isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: _isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _isDark ? AppTheme.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _isDark ? Colors.black.withOpacity(0.2) : Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Level Progress',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$_userXp / $_nextLevelXp XP',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          LinearProgressIndicator(
            value: _levelProgress,
            backgroundColor: _isDark ? AppTheme.dividerDark : Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryPurple),
            minHeight: 12,
            borderRadius: BorderRadius.circular(6),
          ),
          const SizedBox(height: 8),
          Text(
            '${(_levelProgress * 100).toInt()}% to next level',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: _isDark ? AppTheme.dividerDark : AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  // Create a temporary user object for sharing
                  final tempUser = UserModel(
                    uid: 'temp',
                    email: 'user@example.com',
                    displayName: 'Cyber Defender',
                    level: _userLevel,
                    xp: _userXp,
                    gems: 0,
                    streak: StreakData(
                      currentStreak: _currentStreak,
                      longestStreak: _currentStreak,
                      lastLoginDate: DateTime.now(),
                      streakDates: [],
                    ),
                    missionProgress: [],
                    achievements: [],
                    createdAt: DateTime.now(),
                    lastLoginAt: DateTime.now(),
                  );
                  SocialSharingService.shareProgressSummary(tempUser);
                },
                icon: const Icon(Icons.share, size: 16),
                label: const Text('Share Progress'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryPurple,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sliver header for the skill tree section (title + description)
  SliverToBoxAdapter _buildSkillTreeHeaderSliver() {
    return SliverToBoxAdapter(
      child: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Skill Tree',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: _isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unlock new cybersecurity skills as you progress',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: _isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Sliver list for the skill tree items to avoid nested scrolling
  Widget _buildSkillTreeSliver() {
    return AnimatedBuilder(
      animation: _skillTreeAnimation,
      builder: (context, child) {
        final items = _buildSkillTreeItems(_skillTree, 0)
            .map((w) => Transform.scale(scale: _skillTreeAnimation.value, child: w))
            .toList();
        return SliverList(
          delegate: SliverChildListDelegate(items),
        );
      },
    );
  }

  // Flattens the tree into a linear list of Widgets suitable for SliverList
  List<Widget> _buildSkillTreeItems(List<SkillNode> skills, int depth) {
    final List<Widget> widgets = [];
    for (int index = 0; index < skills.length; index++) {
      final skill = skills[index];
      widgets.add(_buildSkillNodeWithZigZag(skill, index, depth));
      if (skill.children.isNotEmpty) {
        widgets.add(
          Container(
            height: 30,
            width: 2,
            margin: EdgeInsets.only(left: (depth * 40.0) + 20),
            child: CustomPaint(
              painter: DottedLinePainter(
                color: skill.color.withOpacity(0.3),
              ),
            ),
          ),
        );
        widgets.addAll(_buildSkillTreeItems(skill.children, depth + 1));
      }
    }
    return widgets;
  }

  Widget _buildSkillNode(SkillNode skill, int depth) {
    final isUnlocked = skill.isUnlocked;
    final isCompleted = skill.isCompleted;
    
    return Container(
      margin: EdgeInsets.only(left: depth * 40.0),
      child: Row(
        children: [
          // Skill icon and info
          Expanded(
            child: GestureDetector(
              onTap: () => _onSkillNodeTapped(skill),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: isUnlocked ? skill.color.withOpacity(0.1) : (_isDark ? AppTheme.surfaceDark : Colors.grey[200]),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isUnlocked ? skill.color : (_isDark ? AppTheme.dividerDark : Colors.grey[300]!),
                    width: 2,
                  ),
                  boxShadow: isUnlocked ? [
                    BoxShadow(
                      color: skill.color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ] : null,
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUnlocked ? skill.color : (_isDark ? AppTheme.iconDark : Colors.grey[400]),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        skill.icon,
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
                            skill.title,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: isUnlocked ? (_isDark ? AppTheme.textPrimaryDark : AppTheme.textPrimary) : (_isDark ? AppTheme.textLightDark : Colors.grey[500]),
                            ),
                          ),
                          Text(
                            skill.description,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: isUnlocked ? (_isDark ? AppTheme.textSecondaryDark : AppTheme.textSecondary) : (_isDark ? AppTheme.textLightDark : Colors.grey[400]),
                            ),
                          ),
                          if (isUnlocked) ...[
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.star,
                                  color: skill.color,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${skill.xpRequired} XP',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: skill.color,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),

                          ],
                        ],
                      ),
                    ),
                    if (isUnlocked && !isCompleted)
                      Icon(
                        Icons.lock_open,
                        color: skill.color,
                        size: 20,
                      )
                    else if (isCompleted)
                      Icon(
                        Icons.check_circle,
                        color: Colors.green,
                        size: 24,
                      )
                    else
                      Icon(
                        Icons.lock,
                        color: _isDark ? AppTheme.textLightDark : Colors.grey[400],
                        size: 20,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillNodeWithZigZag(SkillNode skill, int index, int depth) {
    // Determine alignment based on whether the index is even or odd
    final bool isLeftAligned = index % 2 == 0;
    
    return Column(
      children: [
        // Add connecting line from previous skill (if not first)
        if (index > 0) _buildConnectingLine(index, depth, skill.color),
        
        // The skill card with zig-zag positioning
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0),
          child: Row(
            children: [
              if (!isLeftAligned) const Spacer(), // If right-aligned, push the card right
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.75, // Card takes up 75% of width
                child: _buildSkillNode(skill, depth),
              ),
              if (isLeftAligned) const Spacer(), // If left-aligned, push the card left
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildConnectingLine(int index, int depth, Color skillColor) {
    // Determine the previous skill's alignment
    final bool previousWasLeft = (index - 1) % 2 == 0;
    // Determine current skill's alignment
    final bool currentIsLeft = index % 2 == 0;
    
    // Calculate the positions for the connecting line
    final screenWidth = MediaQuery.of(context).size.width;
    final cardWidth = screenWidth * 0.75;
    final cardCenter = cardWidth / 2;
    
    // Previous skill position (center of previous card)
    final previousX = previousWasLeft 
        ? cardCenter 
        : screenWidth - cardCenter;
    
    // Current skill position (center of current card)
    final currentX = currentIsLeft 
        ? cardCenter 
        : screenWidth - cardCenter;
    
    // Create a custom painter for the zig-zag line
    return Container(
      height: 40,
      child: CustomPaint(
        painter: ZigZagLinePainter(
          startX: previousX,
          endX: currentX,
          color: skillColor,
        ),
        size: Size(screenWidth, 40),
      ),
    );
  }

  String _getTimeBasedGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    } else if (hour < 17) {
      return 'Good Afternoon';
    } else {
      return 'Good Evening';
    }
  }

  double _getLevelProgress() {
    return _levelProgress;
  }
}



class DottedLinePainter extends CustomPainter {
  final Color color;

  DottedLinePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    const dashHeight = 4;
    const dashSpace = 3;
    double startY = 0;

    while (startY < size.height) {
      canvas.drawLine(
        Offset(size.width / 2, startY),
        Offset(size.width / 2, startY + dashHeight),
        paint,
      );
      startY += dashHeight + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class ZigZagLinePainter extends CustomPainter {
  final double startX;
  final double endX;
  final Color color;

  ZigZagLinePainter({
    required this.startX,
    required this.endX,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.6)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Create a smooth curved path from start to end
    final path = Path();
    
    // Start point (bottom of previous card)
    path.moveTo(startX, 0);
    
    // Control points for smooth curve
    final controlPoint1 = Offset(startX, size.height * 0.3);
    final controlPoint2 = Offset(endX, size.height * 0.7);
    
    // End point (top of current card)
    final endPoint = Offset(endX, size.height);
    
    // Draw smooth curve
    path.quadraticBezierTo(
      controlPoint1.dx, controlPoint1.dy,
      (startX + endX) / 2, size.height * 0.5,
    );
    path.quadraticBezierTo(
      controlPoint2.dx, controlPoint2.dy,
      endPoint.dx, endPoint.dy,
    );
    
    canvas.drawPath(path, paint);
    
    // Add small dots at start and end
    final dotPaint = Paint()
      ..color = color.withOpacity(0.8)
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(Offset(startX, 0), 4, dotPaint);
    canvas.drawCircle(Offset(endX, size.height), 4, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class HexagonPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final double hexagonSize = 10.0;
    final double gap = hexagonSize * 0.5;

    for (int row = 0; row < size.height ~/ (hexagonSize + gap); row++) {
      for (int col = 0; col < size.width ~/ (hexagonSize + gap); col++) {
        double x = col * (hexagonSize + gap);
        double y = row * (hexagonSize + gap);

        if (row % 2 == 0) {
          x += hexagonSize / 2;
        }

        final path = Path();
        path.moveTo(x, y);
        path.lineTo(x + hexagonSize, y);
        path.lineTo(x + hexagonSize + hexagonSize / 2, y + hexagonSize / 2);
        path.lineTo(x + hexagonSize, y + hexagonSize);
        path.lineTo(x, y + hexagonSize);
        path.lineTo(x - hexagonSize / 2, y + hexagonSize / 2);
        path.close();

        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
