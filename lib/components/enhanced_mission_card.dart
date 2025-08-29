import 'package:flutter/material.dart';
import '../models/mission_models.dart';
import '../utils/app_theme.dart';

class EnhancedMissionCard extends StatelessWidget {
  final Mission mission;
  final VoidCallback onStart;
  final Animation<double>? animation;

  const EnhancedMissionCard({
    super.key,
    required this.mission,
    required this.onStart,
    this.animation,
  });

  Color _getDifficultyColor() {
    return AppTheme.getDifficultyColor(mission.difficulty.name);
  }

  Widget _buildRewards() {
    return Row(
      children: [
        Icon(Icons.star, color: Colors.amber[700], size: 20),
        const SizedBox(width: 4),
        Text('${mission.xpReward} XP'),
        const SizedBox(width: 12),
        Icon(Icons.diamond, color: Colors.blue[400], size: 20),
        const SizedBox(width: 4),
        Text('${mission.gemReward} Gems'),
      ],
    );
  }

  Widget _buildContent(BuildContext context) {
    final isLocked = mission.status == MissionStatus.locked;
    final isCompleted = mission.status == MissionStatus.completed;
    final opacity = isLocked ? 0.6 : 1.0;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Opacity(
      opacity: opacity,
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spaceMedium,
          vertical: AppTheme.spaceSmall,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          boxShadow: AppTheme.cardShadow,
          border: Border.all(
            color: isCompleted
                ? Colors.amber[600]!
                : (isLocked ? (isDark ? AppTheme.textLightDark : AppTheme.textLight) : Colors.transparent),
            width: isCompleted ? 2 : 1,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
            if (mission.imageUrl != null)
              Image.asset(
                mission.imageUrl!,
                height: 120,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 120,
                    color: isDark ? AppTheme.surfaceDark : Colors.grey[200],
                    child: Icon(
                      Icons.security,
                      size: 50,
                      color: isDark ? AppTheme.iconDark : Colors.grey[400],
                    ),
                  );
                },
              ),
            Padding(
              padding: const EdgeInsets.all(AppTheme.spaceLarge),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          mission.title,
                          style: AppTheme.getHeadlineSmall(isDark),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceMedium,
                          vertical: AppTheme.spaceSmall,
                        ),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getDifficultyColor().withOpacity(0.1),
                              _getDifficultyColor().withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                          border: Border.all(
                            color: _getDifficultyColor().withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          mission.difficulty.name.toUpperCase(),
                          style: AppTheme.getLabelMedium(isDark).copyWith(
                            color: _getDifficultyColor(),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceMedium),
                  Text(
                    mission.description,
                    style: AppTheme.getBodyMedium(isDark),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: AppTheme.spaceLarge),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spaceMedium,
                          vertical: AppTheme.spaceSmall,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryPurple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: Text(
                          mission.category.name,
                          style: AppTheme.getLabelMedium(isDark).copyWith(
                            color: AppTheme.primaryPurple,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (!isCompleted) _buildRewards() else
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spaceMedium,
                            vertical: AppTheme.spaceXSmall,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber[50],
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                            border: Border.all(color: Colors.amber[300]!),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green, size: 18),
                              const SizedBox(width: 6),
                              Text(
                                'Mastered',
                                style: AppTheme.getLabelMedium(isDark).copyWith(
                                  color: Colors.amber[800],
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spaceLarge),
                  if (isLocked)
                    Container(
                      padding: const EdgeInsets.all(AppTheme.spaceMedium),
                      decoration: BoxDecoration(
                        color: AppTheme.accentRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                        border: Border.all(
                          color: AppTheme.accentRed.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lock_outline,
                            color: AppTheme.accentRed,
                            size: 20,
                          ),
                          const SizedBox(width: AppTheme.spaceSmall),
                          Text(
                            'Requires Level ${mission.requiredLevel}',
                            style: AppTheme.getLabelMedium(isDark).copyWith(
                              color: AppTheme.accentRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      decoration: isCompleted
                          ? BoxDecoration(
                              color: isDark ? AppTheme.surfaceDark : AppTheme.surfaceLight,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              border: Border.all(color: Colors.amber[300]!),
                            )
                          : BoxDecoration(
                              gradient: AppTheme.primaryGradient,
                              borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryPurple.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                      child: ElevatedButton(
                        onPressed: onStart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isCompleted ? Colors.transparent : Colors.transparent,
                          shadowColor: Colors.transparent,
                          minimumSize: const Size(double.infinity, 56),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(isCompleted ? Icons.school : Icons.play_arrow, size: 20, color: isCompleted ? AppTheme.primaryPurple : Colors.white),
                            const SizedBox(width: AppTheme.spaceSmall),
                            Text(
                              isCompleted ? 'Practice' : 'Start Mission',
                              style: AppTheme.labelLarge.copyWith(
                                color: isCompleted ? AppTheme.primaryPurple : Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (animation != null) {
      return FadeTransition(
        opacity: animation!,
        child: _buildContent(context),
      );
    }
    return _buildContent(context);
  }
}
