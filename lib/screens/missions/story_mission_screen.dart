import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mission_models.dart';
import '../../services/progress_service.dart';
import 'story_challenge_screen.dart';
import '../../providers/app_providers.dart';

class StoryMissionScreen extends ConsumerStatefulWidget {
  final StoryMission storyMission;
  
  const StoryMissionScreen({
    super.key,
    required this.storyMission,
  });

  @override
  ConsumerState<StoryMissionScreen> createState() => _StoryMissionScreenState();
}

class _StoryMissionScreenState extends ConsumerState<StoryMissionScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _storyAnimationController;
  late Animation<double> _storyFadeAnimation;
  
  List<String> _completedScenarioIds = [];
  StoryScenario? _currentScenario;
  bool _isLoading = true;
  bool _isCompleting = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupAnimations();
    _loadUserProgress();
  }

  void _setupAnimations() {
    _storyAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _storyFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _storyAnimationController,
      curve: Curves.easeOut,
    ));

    _storyAnimationController.forward();
  }

  Future<void> _loadUserProgress() async {
    try {
      print('=== STORY MISSION: LOADING USER PROGRESS ===');
      final progressService = ref.read(progressServiceProvider);
      print('Progress service obtained');
      
      final userProgress = await progressService.getUserProgress();
      print('User progress result: ${userProgress != null ? "SUCCESS" : "NULL"}');
      
      if (userProgress != null && mounted) {
        // Get completed scenarios for this story mission
        final storyProgress = userProgress.storyProgress;
        print('Story progress: ${storyProgress != null ? storyProgress.keys.toList() : "NULL"}');
        
        if (storyProgress != null && storyProgress.containsKey(widget.storyMission.id)) {
          final storyData = storyProgress[widget.storyMission.id] as Map<String, dynamic>;
          _completedScenarioIds = List<String>.from(storyData['completedScenarios'] ?? []);
          print('Found existing story progress: $_completedScenarioIds completed scenarios');
        } else {
          _completedScenarioIds = [];
          print('✅ No story progress found - this is normal for new users starting their first story!');
        }
        
        // Set current scenario
        try {
          _currentScenario = widget.storyMission.getNextAvailableScenario(_completedScenarioIds);
          print('Current scenario set: ${_currentScenario?.title ?? "NULL"}');
          
          // If no current scenario found, try to get the first available one
          if (_currentScenario == null) {
            print('No next scenario found, checking for first available scenario...');
            final firstScenario = widget.storyMission.scenarios.firstWhere(
              (s) => s.isUnlocked && s.requiredPreviousScenarios == 0,
              orElse: () => widget.storyMission.scenarios.first,
            );
            if (firstScenario != null) {
              _currentScenario = firstScenario;
              print('First available scenario set: ${firstScenario.title}');
            }
          }
        } catch (scenarioError) {
          print('Error setting current scenario: $scenarioError');
          // Fallback to first scenario if available
          if (widget.storyMission.scenarios.isNotEmpty) {
            final fallbackScenario = widget.storyMission.scenarios.first;
            _currentScenario = fallbackScenario;
            print('Fallback to first scenario: ${fallbackScenario.title}');
          } else {
            _currentScenario = null;
          }
        }
        
        setState(() {
          _isLoading = false;
        });
        print('Story mission loading completed successfully');
      } else {
        print('No user progress data, setting loading to false');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e, stackTrace) {
      print('=== STORY MISSION: ERROR LOADING USER PROGRESS ===');
      print('Error: $e');
      print('Stack trace: $stackTrace');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Mark a scenario as completed and unlock the next one
  Future<void> _completeScenario(String scenarioId) async {
    // Prevent multiple simultaneous completions
    if (_isCompleting) {
      print('Already completing a scenario, ignoring request');
      return;
    }
    
    _isCompleting = true;
    
    try {
      print('=== STARTING SCENARIO COMPLETION ===');
      print('Completing scenario: $scenarioId');
      
      // Check if context is still valid
      if (!mounted) {
        print('ERROR: Context not mounted, aborting');
        return;
      }
      
      print('Getting ProgressService...');
      final progressService = ref.read(progressServiceProvider);
      print('ProgressService obtained successfully');
      
      // Find the scenario to get its XP reward
      print('Looking for scenario in story mission...');
      print('Available scenarios: ${widget.storyMission.scenarios.map((s) => s.id).toList()}');
      
      final scenario = widget.storyMission.scenarios.firstWhere(
        (s) => s.id == scenarioId,
        orElse: () => throw Exception('Scenario not found: $scenarioId'),
      );
      
      print('Found scenario: ${scenario.title}');
      print('Scenario XP reward: ${scenario.xpReward}');
      
      // Complete the scenario in Firebase
      print('Calling Firebase service...');
      final success = await progressService.completeStoryScenario(
        widget.storyMission.id,
        scenarioId,
        scenario.xpReward,
      );
      
      print('Firebase update success: $success');
      
      if (success && mounted) {
        print('Firebase update successful, updating UI state...');
        
        // Add a small delay to ensure Firebase operations are complete
        await Future.delayed(const Duration(milliseconds: 100));
        
        // Capture current state before setState
        final currentCompletedIds = List<String>.from(_completedScenarioIds);
        print('Current completed IDs before update: $currentCompletedIds');
        
        if (mounted) {
          setState(() {
            print('Inside setState - updating completed scenarios...');
            
            try {
              // Add to completed scenarios if not already there
              if (!_completedScenarioIds.contains(scenarioId)) {
                _completedScenarioIds.add(scenarioId);
                print('Added scenario $scenarioId to completed list');
              }
              
              print('Completed scenarios after update: $_completedScenarioIds');
              
              // Update current scenario to the next available one
              print('Getting next available scenario...');
              try {
                _currentScenario = widget.storyMission.getNextAvailableScenario(_completedScenarioIds);
                print('Next scenario method completed successfully');
              } catch (nextScenarioError) {
                print('ERROR getting next scenario: $nextScenarioError');
                _currentScenario = null;
              }
              
              print('New current scenario: ${_currentScenario?.title ?? "NULL"}');
            } catch (setStateError) {
              print('ERROR in setState: $setStateError');
              // Fallback: just add the scenario ID
              if (!_completedScenarioIds.contains(scenarioId)) {
                _completedScenarioIds.add(scenarioId);
              }
            }
          });
          
          print('setState completed successfully');
          
                  // Show success message
        if (mounted) {
          print('Showing success SnackBar...');
          try {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '+${scenario.xpReward} XP earned!',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
            print('Success SnackBar shown');
          } catch (snackBarError) {
            print('Error showing success SnackBar: $snackBarError');
          }
        }
        
        // Return true to indicate scenario completion
        Navigator.of(context).pop(true);
        }
      } else {
        print('Firebase update failed or context not mounted');
      }
      
      print('=== SCENARIO COMPLETION FINISHED ===');
    } catch (e, stackTrace) {
      print('=== ERROR IN SCENARIO COMPLETION ===');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace: $stackTrace');
      
      if (mounted) {
        try {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Error completing scenario: ${e.toString()}',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
            ),
          );
        } catch (snackBarError) {
          print('Error showing error SnackBar: $snackBarError');
        }
      }
    } finally {
      _isCompleting = false;
      print('Scenario completion flag reset');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _storyAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.storyMission.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Story'),
            Tab(text: 'Progress'),
          ],
        ),
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.primary,
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildStoryTab(),
                _buildProgressTab(),
              ],
            ),
    );
  }

  Widget _buildStoryTab() {
    return FadeTransition(
      opacity: _storyFadeAnimation,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStoryHeader(),
            const SizedBox(height: 24),
            _buildCurrentScenario(),
            const SizedBox(height: 24),
            _buildStoryTimeline(),
          ],
        ),
      ),
    );
  }

  Widget _buildStoryHeader() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.primary.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark 
              ? Theme.of(context).colorScheme.primary.withOpacity(0.5)
              : Theme.of(context).colorScheme.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.person,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Protagonist',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      widget.storyMission.mainCharacter,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Story Background',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.storyMission.storyBackground,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScenario() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    if (_currentScenario == null) {
      // Check if all scenarios are completed
      final allCompleted = _completedScenarioIds.length >= widget.storyMission.scenarios.length;
      
      if (allCompleted) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isDark ? Colors.green[900] : Colors.green[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isDark ? Colors.green[700]! : Colors.green[200]!,
            ),
          ),
          child: Column(
            children: [
              Icon(
                Icons.check_circle,
                color: isDark ? Colors.green[400] : Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                'Story Complete! 🎉',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: isDark ? Colors.green[400] : Colors.green[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You\'ve successfully completed all scenarios in this story.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: isDark ? Colors.green[300] : Colors.green[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      } else {
        // Check if this is a new user (no completed scenarios)
        if (_completedScenarioIds.isEmpty) {
          // Welcome message for new users
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.secondary,
                  Theme.of(context).colorScheme.secondary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.emoji_events,
                  color: Theme.of(context).colorScheme.onSecondary,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Welcome to Your First Story! 🎉',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'You\'re about to begin an exciting cybersecurity adventure. Complete scenarios to unlock new chapters and earn rewards!',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSecondary.withOpacity(0.9),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _loadUserProgress();
                  },
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('Begin Adventure'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.onSecondary,
                    foregroundColor: Theme.of(context).colorScheme.secondary,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ],
            ),
          );
        } else {
          // Something went wrong - show error state
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.red[900] : Colors.red[50],
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark ? Colors.red[700]! : Colors.red[200]!,
              ),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.error_outline,
                  color: isDark ? Colors.red[400] : Colors.red,
                  size: 48,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Scenario',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: isDark ? Colors.red[400] : Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Please try refreshing the story or contact support.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: isDark ? Colors.red[300] : Colors.red[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    _loadUserProgress();
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh Story'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark ? Colors.red[700] : Colors.red[600],
                    foregroundColor: Theme.of(context).colorScheme.onError,
                  ),
                ),
              ],
            ),
          );
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface.withOpacity(0.9) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: isDark ? Colors.black.withOpacity(0.2) : Theme.of(context).shadowColor.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.play_arrow,
                  color: Theme.of(context).colorScheme.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Current Scenario',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${_completedScenarioIds.length + 1}/${widget.storyMission.scenarios.length}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _currentScenario!.title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentScenario!.description,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isDark ? Colors.white.withOpacity(0.9) : Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark 
                ? Theme.of(context).colorScheme.surface.withOpacity(0.5)
                : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark 
                  ? Theme.of(context).colorScheme.outline.withOpacity(0.3)
                  : Theme.of(context).colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      color: Theme.of(context).colorScheme.primary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Narrative',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  _currentScenario!.narrativeText,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white.withOpacity(0.9) : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () => _startScenario(_currentScenario!),
              icon: const Icon(Icons.play_arrow),
              label: const Text('Start Scenario'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primary,
                foregroundColor: Theme.of(context).colorScheme.onPrimary,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoryTimeline() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Story Timeline',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 16),
        ...widget.storyMission.scenarios.asMap().entries.map((entry) {
          final index = entry.key;
          final scenario = entry.value;
          final isCompleted = _completedScenarioIds.contains(scenario.id);
          final isCurrent = _currentScenario != null && scenario.id == _currentScenario!.id;
          final isLocked = !scenario.isUnlocked || 
              _completedScenarioIds.length < scenario.requiredPreviousScenarios;

          return _buildTimelineItem(
            scenario: scenario,
            index: index,
            isCompleted: isCompleted,
            isCurrent: isCurrent,
            isLocked: isLocked,
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTimelineItem({
    required StoryScenario scenario,
    required int index,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Timeline connector
          Column(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? Colors.green
                      : isCurrent
                          ? Theme.of(context).colorScheme.primary
                          : isLocked
                              ? Theme.of(context).colorScheme.outline
                              : Theme.of(context).colorScheme.secondary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCompleted
                      ? Icons.check
                      : isCurrent
                          ? Icons.play_arrow
                          : isLocked
                              ? Icons.lock
                              : Icons.radio_button_unchecked,
                  color: Theme.of(context).colorScheme.onPrimary,
                  size: 20,
                ),
              ),
              if (index < widget.storyMission.scenarios.length - 1)
                Container(
                  width: 2,
                  height: 40,
                  color: isCompleted ? Colors.green : (isDark ? Colors.white.withOpacity(0.3) : Theme.of(context).colorScheme.outline),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Scenario content
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isCurrent 
                  ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
                  : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isCurrent 
                    ? Theme.of(context).colorScheme.primary.withOpacity(0.3)
                    : (isDark ? Colors.white.withOpacity(0.2) : Theme.of(context).colorScheme.outline.withOpacity(0.2)),
                  width: isCurrent ? 2 : 1,
                ),
                boxShadow: isCurrent
                    ? [
                        BoxShadow(
                          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : null,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child:                   Text(
                    scenario.title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isLocked 
                        ? (isDark ? Colors.white.withOpacity(0.6) : Theme.of(context).colorScheme.onSurface.withOpacity(0.6))
                        : (isDark ? Colors.white : Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                      ),
                      if (scenario.characterName != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            scenario.characterName!,
                            style: TextStyle(
                              color: isDark ? Colors.white : Theme.of(context).colorScheme.secondary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    scenario.description,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: isLocked 
                        ? (isDark ? Colors.white.withOpacity(0.5) : Theme.of(context).colorScheme.onSurface.withOpacity(0.5))
                        : (isDark ? Colors.white.withOpacity(0.9) : Theme.of(context).colorScheme.onSurface),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? Colors.green.withOpacity(0.2)
                              : Colors.orange.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${scenario.xpReward} XP',
                          style: TextStyle(
                            color: isCompleted
                                ? Colors.green
                                : Colors.orange,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isLocked)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                                                  child: Text(
                          'Complete ${scenario.requiredPreviousScenarios} previous',
                          style: TextStyle(
                            color: isDark ? Colors.white.withOpacity(0.6) : Theme.of(context).colorScheme.outline,
                            fontSize: 12,
                          ),
                        ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressTab() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progress = widget.storyMission.getProgress(_completedScenarioIds);
    final completedCount = _completedScenarioIds.length;
    final totalCount = widget.storyMission.scenarios.length;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Overall progress
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  'Story Progress',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Theme.of(context).colorScheme.onPrimary.withOpacity(0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        Text(
                          '${(progress * 100).toInt()}%',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '$completedCount/$totalCount',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onPrimary.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Rewards overview
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Theme.of(context).colorScheme.surface.withOpacity(0.8) : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: isDark ? Colors.black.withOpacity(0.3) : Theme.of(context).shadowColor.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🎁 Total Rewards',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildRewardItem(
                      icon: Icons.star,
                      color: Colors.amber[600]!,
                      value: '${widget.storyMission.totalXpReward}',
                      label: 'Total XP',
                    ),
                    _buildRewardItem(
                      icon: Icons.diamond,
                      color: Colors.blue[400]!,
                      value: '${widget.storyMission.totalGemReward}',
                      label: 'Total Gems',
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          
          // Completed scenarios
          if (completedCount > 0) ...[
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? Colors.green[900] : Colors.green[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? Colors.green[700]! : Colors.green[200]!,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '✅ Completed Scenarios',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.green[400] : Colors.green[700],
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...widget.storyMission.scenarios
                      .where((s) => _completedScenarioIds.contains(s.id))
                      .map((scenario) => _buildCompletedScenarioItem(scenario))
                      .toList(),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRewardItem({
    required IconData icon,
    required Color color,
    required String value,
    required String label,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
          ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: isDark ? Colors.white.withOpacity(0.7) : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedScenarioItem(StoryScenario scenario) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? Theme.of(context).colorScheme.surface.withOpacity(0.8) : Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDark ? Colors.green[700]! : Colors.green[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle,
            color: isDark ? Colors.green[400] : Colors.green[600],
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scenario.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  '${scenario.xpReward} XP earned',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: isDark ? Colors.green[400] : Colors.green[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _startScenario(StoryScenario scenario) {
    // Navigate to the appropriate challenge screen based on challenge type
    switch (scenario.challengeType) {
      case ChallengeType.multipleChoice:
        _navigateToQuizScreen(scenario);
        break;
      case ChallengeType.terminal:
        _navigateToTerminalScreen(scenario);
        break;
      case ChallengeType.workbench:
        _navigateToWorkbenchScreen(scenario);
        break;
      case ChallengeType.codeReview:
        _navigateToCodeAnalysisScreen(scenario);
        break;
      case ChallengeType.passwordValidation:
        _navigateToPasswordLabScreen(scenario);
        break;
      case ChallengeType.storyScenario:
        // For story scenarios, we'll handle them specially
        _showScenarioDialog(scenario);
        break;
      case ChallengeType.networkSecurity:
        // For network security scenarios, we'll handle them specially
        _showScenarioDialog(scenario);
        break;
    }
  }

  void _showScenarioDialog(StoryScenario scenario) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(scenario.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              scenario.narrativeText,
              style: TextStyle(
                color: isDark ? Colors.white : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Challenge Type: ${scenario.challengeType.name}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: isDark ? Colors.white.withOpacity(0.7) : Theme.of(context).colorScheme.onSurface.withOpacity(0.7),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // For story scenarios, we'll show a simple challenge interface
              _showStoryChallenge(scenario);
            },
            child: const Text('Start Challenge'),
          ),
        ],
      ),
    );
  }

  // Navigation methods for different challenge types
  void _navigateToQuizScreen(StoryScenario scenario) {
    // TODO: Navigate to quiz screen when implemented
    _showStoryChallenge(scenario);
  }

  void _navigateToTerminalScreen(StoryScenario scenario) {
    // TODO: Navigate to terminal screen when implemented
    _showStoryChallenge(scenario);
  }

  void _navigateToWorkbenchScreen(StoryScenario scenario) {
    // TODO: Navigate to workbench screen when implemented
    _showStoryChallenge(scenario);
  }

  void _navigateToCodeAnalysisScreen(StoryScenario scenario) {
    // TODO: Navigate to code analysis screen when implemented
    _showStoryChallenge(scenario);
  }

  void _navigateToPasswordLabScreen(StoryScenario scenario) {
    // TODO: Navigate to password lab screen when implemented
    _showStoryChallenge(scenario);
  }

  // Show a story challenge interface
  void _showStoryChallenge(StoryScenario scenario) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => StoryChallengeScreen(
          scenario: scenario,
          onScenarioCompleted: _completeScenario,
        ),
      ),
    );
  }
}
