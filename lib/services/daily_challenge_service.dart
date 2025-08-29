import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mission_models.dart';

class DailyChallengeService extends ChangeNotifier {
  // Empty service - no daily challenges
  DailyChallengeService();

  // Get daily challenge - returns null (no daily challenge)
  Mission? getDailyChallenge() {
    return null;
  }

  // Get current streak - always 0
  int getCurrentStreak() {
    return 0;
  }

  // Get best streak - always 0
  int getBestStreak() {
    return 0;
  }

  // Check if daily challenge is completed today - always false
  bool isDailyChallengeCompleted() {
    return false;
  }

  // Mark daily challenge as completed - does nothing
  void markDailyChallengeCompleted() {
    // No daily challenges to complete
  }

  // Reset streak - does nothing
  void resetStreak() {
    // No streak to reset
  }
}

// Provider for the daily challenge service
final dailyChallengeServiceProvider = ChangeNotifierProvider<DailyChallengeService>((ref) {
  return DailyChallengeService();
});
