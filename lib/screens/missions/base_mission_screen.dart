import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/mission_models.dart';
import '../../services/language_service.dart';
import '../../services/social_sharing_service.dart';
import '../../utils/app_theme.dart';
import '../../providers/app_providers.dart';

abstract class BaseMissionScreen extends ConsumerStatefulWidget {
  final Mission mission;
  final bool isPractice;

  const BaseMissionScreen({
    super.key,
    required this.mission,
    this.isPractice = false,
  });

  @override
  ConsumerState<BaseMissionScreen> createState() => createStateImpl();
  
  ConsumerState<BaseMissionScreen> createStateImpl();
}

abstract class BaseMissionScreenState<T extends BaseMissionScreen> extends ConsumerState<T> {
  bool _showHelp = false;
  int _currentChallengeIndex = 0;
  bool _isCompleted = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final languageService = ref.watch(languageServiceProvider);
    
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        final shouldPop = await _showLeaveDialog(context, languageService);
        if (shouldPop == true) {
          if (context.mounted) {
            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.mission.title),
          backgroundColor: Colors.transparent,
          elevation: 0,
          actions: [
            IconButton(
              icon: const Icon(Icons.help_outline),
              onPressed: () {
                setState(() {
                  _showHelp = !_showHelp;
                });
              },
            ),
          ],
        ),
        body: Stack(
          children: [
            Column(
              children: [
                // Mission Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.mission.title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.mission.description,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildDifficultyChip(widget.mission.difficulty, languageService),
                          const SizedBox(width: 12),
                          _buildCategoryChip(widget.mission.category, languageService),
                          const Spacer(),
                          if (widget.isPractice)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Practice',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.blue[700],
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Help Panel
                if (_showHelp) _buildHelpPanel(languageService),

                // Mission Content
                Expanded(
                  child: buildMissionContent(),
                ),
              ],
            ),
            if (_isLoading)
              Container(
                color: Theme.of(context).brightness == Brightness.dark 
                    ? Colors.black54 
                    : Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDifficultyChip(MissionDifficulty difficulty, LanguageService languageService) {
    Color color;
    switch (difficulty) {
      case MissionDifficulty.beginner:
        color = Colors.green;
        break;
      case MissionDifficulty.intermediate:
        color = Colors.orange;
        break;
      case MissionDifficulty.advanced:
        color = Colors.red;
        break;
      case MissionDifficulty.expert:
        color = Colors.purple;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        languageService.getLocalizedDifficultyName(difficulty),
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildCategoryChip(MissionCategory category, LanguageService languageService) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        languageService.getLocalizedCategoryName(category),
        style: TextStyle(
          fontSize: 12,
          color: Colors.blue[700],
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildHelpPanel(LanguageService languageService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: Colors.blue.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: Colors.blue[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                '${widget.mission.title} - ${languageService.getLocalizedCommonPhrase('cyber_hygiene')}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[700],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (widget.mission.challenges.isNotEmpty &&
              widget.mission.challenges[_currentChallengeIndex].content.guidePoints.isNotEmpty)
            ...widget.mission.challenges[_currentChallengeIndex].content.guidePoints.map((point) => Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '• ',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Expanded(child: Text(point)),
                ],
              ),
            )),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                setState(() {
                  _showHelp = false;
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[700],
                foregroundColor: Colors.white,
              ),
              child: Text(languageService.getLocalizedButtonText('close')),
            ),
          ),
        ],
      ),
    );
  }

  // Abstract method to be implemented by subclasses
  Widget buildMissionContent();

  // Utility methods for subclasses
  void showLoading() {
    setState(() => _isLoading = true);
  }

  void hideLoading() {
    setState(() => _isLoading = false);
  }

  Future<void> completeMission() async {
    if (widget.isPractice) {
      // In practice mode we do not persist completion or rewards
      setState(() => _isCompleted = true);
      return;
    }
    setState(() => _isCompleted = true);
    
    try {
      // Get the progress service and complete the mission
      final progressService = ref.read(progressServiceProvider);
      final success = await progressService.completeMission(widget.mission.id, widget.mission);
      
      if (success) {
        print('Mission completed successfully! Awarded ${widget.mission.xpReward} XP and ${widget.mission.gemReward} Gems');
      } else {
        print('Failed to complete mission in Firebase');
      }
    } catch (e) {
      print('Error completing mission: $e');
    }
  }

  void showSuccessAndExit() {
    final languageService = ref.read(languageServiceProvider);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            widget.isPractice 
              ? languageService.getLocalizedCommonPhrase('practice_complete')
              : languageService.getLocalizedCommonPhrase('mission_completed'),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                widget.isPractice
                  ? languageService.getLocalizedCommonPhrase('practice_complete')
                  : languageService.getLocalizedCommonPhrase('mission_completed_congratulations'),
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (!widget.isPractice) ...[
                Text(
                  languageService.getLocalizedCommonPhrase('you_earned'),
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildRewardItem(
                      context,
                      '${widget.mission.xpReward} XP',
                      Icons.star,
                      Colors.orange,
                    ),
                    _buildRewardItem(
                      context,
                      '${widget.mission.gemReward} Gems',
                      Icons.diamond,
                      Colors.blue,
                    ),
                  ],
                ),
              ],
            ],
          ),
          actions: [
            if (!widget.isPractice) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    SocialSharingService.shareMissionCompletion(
                      widget.mission.title,
                      widget.mission.xpReward,
                    );
                  },
                  icon: const Icon(Icons.share),
                  label: const Text('Share Achievement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.of(context).pop(); // Return to previous screen
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(languageService.getLocalizedButtonText('continue')),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildRewardItem(BuildContext context, String text, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }

  Future<bool?> _showLeaveDialog(BuildContext context, LanguageService languageService) {
    return showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(languageService.getLocalizedCommonPhrase('leave_mission')),
          content: Text(languageService.getLocalizedCommonPhrase('are_you_sure_leave')),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(languageService.getLocalizedButtonText('stay')),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(languageService.getLocalizedButtonText('leave')),
            ),
          ],
        );
      },
    );
  }
}
