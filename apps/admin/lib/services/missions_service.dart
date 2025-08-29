import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_core/shared_core.dart';

class AdminMissionsService {
  static final AdminMissionsService _instance = AdminMissionsService._internal();
  factory AdminMissionsService() => _instance;
  AdminMissionsService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all missions from Firestore
  Future<List<Mission>> getMissions() async {
    try {
      final snapshot = await _firestore.collection('missions').get();
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          // Ensure all required fields have default values if null
          final safeData = <String, dynamic>{
            'id': doc.id,
            'title': data['title'] ?? 'Untitled Mission',
            'description': data['description'] ?? '',
            'type': data['type'] ?? MissionType.storyMission.toString(),
            'difficulty': data['difficulty'] ?? MissionDifficulty.beginner.toString(),
            'category': data['category'] ?? MissionCategory.phishing.toString(),
            'status': data['status'] ?? MissionStatus.available.toString(),
            'requiredLevel': data['requiredLevel'] ?? 1,
            'xpReward': data['xpReward'] ?? 10,
            'gemReward': data['gemReward'] ?? 1,
            'challenges': data['challenges'] ?? [],
            'imageUrl': data['imageUrl'],
            'unlockDate': data['unlockDate'],
            'expiryDate': data['expiryDate'],
            'localizedTitle': data['localizedTitle'],
            'localizedDescription': data['localizedDescription'],
            'countryContext': data['countryContext'],
            'isLocalized': data['isLocalized'] ?? false,
          };
          
          return Mission.fromJson(safeData);
        } catch (e) {
          print('Error parsing mission ${doc.id}: $e');
          // Return a default mission if parsing fails
          return Mission(
            id: doc.id,
            title: 'Error Loading Mission',
            description: 'This mission could not be loaded properly.',
            type: MissionType.storyMission,
            difficulty: MissionDifficulty.beginner,
            category: MissionCategory.phishing,
            status: MissionStatus.available,
            requiredLevel: 1,
            xpReward: 10,
            gemReward: 1,
            challenges: [],
          );
        }
      }).toList();
    } catch (e) {
      print('Error getting missions: $e');
      return [];
    }
  }

  // Create or update a mission
  Future<void> saveMission(Mission mission) async {
    try {
      await _firestore.collection('missions').doc(mission.id).set(mission.toJson());
    } catch (e) {
      print('Error saving mission: $e');
      rethrow;
    }
  }

  // Delete a mission
  Future<void> deleteMission(String missionId) async {
    try {
      await _firestore.collection('missions').doc(missionId).delete();
    } catch (e) {
      print('Error deleting mission: $e');
      rethrow;
    }
  }

  // Publish/unpublish a mission
  Future<void> toggleMissionPublish(String missionId, bool isPublished) async {
    try {
      await _firestore.collection('missions').doc(missionId).update({
        'isPublished': isPublished,
      });
    } catch (e) {
      print('Error toggling mission publish: $e');
      rethrow;
    }
  }
}
