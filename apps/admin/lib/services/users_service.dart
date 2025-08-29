import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_core/shared_core.dart';

class AdminUsersService {
  static final AdminUsersService _instance = AdminUsersService._internal();
  factory AdminUsersService() => _instance;
  AdminUsersService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all users from Firestore
  Future<List<AppUser>> getUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          // Ensure all required fields have default values if null
          final safeData = <String, dynamic>{
            'uid': doc.id,
            'email': data['email'] ?? 'unknown@example.com',
            'displayName': data['displayName'] ?? 'Unknown User',
            'photoUrl': data['photoURL'],
            'level': data['level'] ?? 1,
            'xp': data['xp'] ?? 0,
            'gems': data['gems'] ?? 0,
            'streak': _safeStreakData(data['streak']),
            'achievements': _safeAchievementsData(data['achievements']),
            'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
            'lastLoginAt': data['lastLoginAt'] ?? DateTime.now().toIso8601String(),
            'isAdmin': data['isAdmin'] ?? false,
          };
          
          return AppUser.fromJson(safeData);
        } catch (e) {
          print('Error parsing user ${doc.id}: $e');
          // Return a default user if parsing fails
          return AppUser(
            uid: doc.id,
            email: 'error@example.com',
            displayName: 'Error Loading User',
            level: 1,
            xp: 0,
            gems: 0,
            streak: StreakData(
              currentStreak: 0,
              longestStreak: 0,
              lastLoginDate: DateTime.now(),
              streakDates: [],
            ),
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
          );
        }
      }).toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }

  // Search users by email or display name
  Future<List<AppUser>> searchUsers(String query) async {
    try {
      if (query.isEmpty) return await getUsers();
      
      // Search by email (exact match)
      final emailQuery = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThan: query + '\uf8ff')
          .get();
      
      // Search by display name (exact match)
      final nameQuery = await _firestore
          .collection('users')
          .where('displayName', isGreaterThanOrEqualTo: query)
          .where('displayName', isLessThan: query + '\uf8ff')
          .get();
      
      final allDocs = {...emailQuery.docs, ...nameQuery.docs};
      
      return allDocs.map((doc) {
        try {
          final data = doc.data();
          // Ensure all required fields have default values if null
          final safeData = <String, dynamic>{
            'uid': doc.id,
            'email': data['email'] ?? 'unknown@example.com',
            'displayName': data['displayName'] ?? 'Unknown User',
            'photoUrl': data['photoURL'],
            'level': data['level'] ?? 1,
            'xp': data['xp'] ?? 0,
            'gems': data['gems'] ?? 0,
            'streak': _safeStreakData(data['streak']),
            'achievements': _safeAchievementsData(data['achievements']),
            'createdAt': data['createdAt'] ?? DateTime.now().toIso8601String(),
            'lastLoginAt': data['lastLoginAt'] ?? DateTime.now().toIso8601String(),
            'isAdmin': data['isAdmin'] ?? false,
          };
          
          return AppUser.fromJson(safeData);
        } catch (e) {
          print('Error parsing user ${doc.id}: $e');
          // Return a default user if parsing fails
          return AppUser(
            uid: doc.id,
            email: 'error@example.com',
            displayName: 'Error Loading User',
            level: 1,
            xp: 0,
            gems: 0,
            streak: StreakData(
              currentStreak: 0,
              longestStreak: 0,
              lastLoginDate: DateTime.now(),
              streakDates: [],
            ),
            createdAt: DateTime.now(),
            lastLoginAt: DateTime.now(),
            achievements: [],
            isAdmin: false,
          );
        }
      }).toList();
    } catch (e) {
      print('Error searching users: $e');
      return [];
    }
  }

  // Get user progress for a specific user
  Future<Map<String, dynamic>?> getUserProgress(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .get();
      
      if (doc.docs.isEmpty) return null;
      
      final progress = <String, dynamic>{};
      for (final progressDoc in doc.docs) {
        progress[progressDoc.id] = progressDoc.data();
      }
      
      return progress;
    } catch (e) {
      print('Error getting user progress: $e');
      return null;
    }
  }

  // Get user achievements
  Future<List<Achievement>> getUserAchievements(String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      if (!doc.exists) return [];
      
      final data = doc.data() as Map<String, dynamic>;
      final achievements = data['achievements'] as List? ?? [];
      
      return achievements.map((a) => Achievement.fromJson(a as Map<String, dynamic>)).toList();
    } catch (e) {
      print('Error getting user achievements: $e');
      return [];
    }
  }

  // Update user role (admin claim)
  Future<void> updateUserRole(String userId, bool isAdmin) async {
    try {
      // Note: This would typically be done through a Cloud Function
      // since custom claims can't be set from client-side code
      await _firestore.collection('users').doc(userId).update({
        'isAdmin': isAdmin,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error updating user role: $e');
      rethrow;
    }
  }

  // Get user statistics
  Future<Map<String, dynamic>> getUserStats(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return {};
      
      final userData = userDoc.data() as Map<String, dynamic>;
      final progress = await getUserProgress(userId);
      final achievements = await getUserAchievements(userId);
      
      return {
        'user': userData,
        'progress': progress,
        'achievements': achievements,
        'totalMissions': progress?.length ?? 0,
        'completedMissions': progress?.values
            .where((p) => p['isCompleted'] == true)
            .length ?? 0,
        'totalAchievements': achievements.length,
        'unlockedAchievements': achievements
            .where((a) => a.isUnlocked)
            .length,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Reset user progress
  Future<void> resetUserProgress(String userId) async {
    try {
      final batch = _firestore.batch();
      
      // Reset user stats
      batch.update(_firestore.collection('users').doc(userId), {
        'level': 1,
        'xp': 0,
        'gems': 0,
        'streak': {
          'currentStreak': 0,
          'longestStreak': 0,
          'lastLoginDate': DateTime.now().toIso8601String(),
          'streakDates': []
        },
        'achievements': [],
        'updatedAt': DateTime.now().toIso8601String(),
      });
      
      // Clear all progress subcollections
      final progressDocs = await _firestore
          .collection('users')
          .doc(userId)
          .collection('progress')
          .get();
      
      for (final doc in progressDocs.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      print('Error resetting user progress: $e');
      rethrow;
    }
  }

  // Helper method to safely parse streak data
  Map<String, dynamic> _safeStreakData(dynamic streakData) {
    try {
      if (streakData == null) {
        return {
          'currentStreak': 0,
          'longestStreak': 0,
          'lastLoginDate': DateTime.now().toIso8601String(),
          'streakDates': []
        };
      }

      // If it's already a Map, validate and return
      if (streakData is Map) {
        return {
          'currentStreak': streakData['currentStreak'] ?? 0,
          'longestStreak': streakData['longestStreak'] ?? 0,
          'lastLoginDate': streakData['lastLoginDate'] ?? DateTime.now().toIso8601String(),
          'streakDates': streakData['streakDates'] ?? []
        };
      }

      // If it's any other type, return default
      print('Warning: Invalid streak data type: ${streakData.runtimeType}, using defaults');
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastLoginDate': DateTime.now().toIso8601String(),
        'streakDates': []
      };
    } catch (e) {
      print('Error parsing streak data: $e, using defaults');
      return {
        'currentStreak': 0,
        'longestStreak': 0,
        'lastLoginDate': DateTime.now().toIso8601String(),
        'streakDates': []
      };
    }
  }

  // Helper method to safely parse achievements data
  List<Achievement> _safeAchievementsData(dynamic achievementsData) {
    try {
      if (achievementsData == null) {
        return [];
      }

      if (achievementsData is List) {
        return achievementsData.map((a) => Achievement.fromJson(a as Map<String, dynamic>)).toList();
      }

      print('Warning: Invalid achievements data type: ${achievementsData.runtimeType}, using defaults');
      return [];
    } catch (e) {
      print('Error parsing achievements data: $e, using defaults');
      return [];
    }
  }
}
