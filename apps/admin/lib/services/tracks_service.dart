import 'package:cloud_firestore/cloud_firestore.dart';

class Track {
  final String id;
  final String name;
  final String description;
  final int order;
  final String? locale;
  final bool isPublished;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Track({
    required this.id,
    required this.name,
    required this.description,
    required this.order,
    this.locale,
    this.isPublished = false,
    this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'order': order,
        'locale': locale,
        'isPublished': isPublished,
        'createdAt': createdAt?.toIso8601String(),
        'updatedAt': updatedAt?.toIso8601String(),
      };

  factory Track.fromJson(Map<String, dynamic> json) {
    return Track(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      order: json['order'] as int,
      locale: json['locale'] as String?,
      isPublished: json['isPublished'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Track copyWith({
    String? id,
    String? name,
    String? description,
    int? order,
    String? locale,
    bool? isPublished,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Track(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      order: order ?? this.order,
      locale: locale ?? this.locale,
      isPublished: isPublished ?? this.isPublished,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class AdminTracksService {
  static final AdminTracksService _instance = AdminTracksService._internal();
  factory AdminTracksService() => _instance;
  AdminTracksService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get all tracks from Firestore
  Future<List<Track>> getTracks() async {
    try {
      final snapshot = await _firestore
          .collection('tracks')
          .orderBy('order')
          .get();
      
      return snapshot.docs.map((doc) {
        try {
          final data = doc.data();
          // Ensure all required fields have default values if null
          final safeData = <String, dynamic>{
            'id': doc.id,
            'name': data['name'] ?? 'Untitled Track',
            'description': data['description'] ?? '',
            'order': data['order'] ?? 0,
            'locale': data['locale'] ?? 'en',
            'isPublished': data['isPublished'] ?? false,
            'createdAt': data['createdAt'] ?? FieldValue.serverTimestamp(),
            'updatedAt': data['updatedAt'] ?? FieldValue.serverTimestamp(),
          };
          
          return Track.fromJson(safeData);
        } catch (e) {
          print('Error parsing track ${doc.id}: $e');
          // Return a default track if parsing fails
          return Track(
            id: doc.id,
            name: 'Error Loading Track',
            description: 'This track could not be loaded properly.',
            order: 0,
            locale: 'en',
            isPublished: false,
          );
        }
      }).toList();
    } catch (e) {
      print('Error getting tracks: $e');
      return [];
    }
  }

  // Create or update a track
  Future<void> saveTrack(Track track) async {
    try {
      final now = DateTime.now();
      final trackToSave = track.copyWith(
        updatedAt: now,
        createdAt: track.createdAt ?? now,
      );
      
      await _firestore.collection('tracks').doc(track.id).set(trackToSave.toJson());
    } catch (e) {
      print('Error saving track: $e');
      rethrow;
    }
  }

  // Delete a track
  Future<void> deleteTrack(String trackId) async {
    try {
      await _firestore.collection('tracks').doc(trackId).delete();
    } catch (e) {
      print('Error deleting track: $e');
      rethrow;
    }
  }

  // Publish/unpublish a track
  Future<void> toggleTrackPublish(String trackId, bool isPublished) async {
    try {
      await _firestore.collection('tracks').doc(trackId).update({
        'isPublished': isPublished,
        'updatedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      print('Error toggling track publish: $e');
      rethrow;
    }
  }

  // Reorder tracks
  Future<void> reorderTracks(List<String> trackIds) async {
    try {
      final batch = _firestore.batch();
      
      for (int i = 0; i < trackIds.length; i++) {
        final trackRef = _firestore.collection('tracks').doc(trackIds[i]);
        batch.update(trackRef, {
          'order': i,
          'updatedAt': DateTime.now().toIso8601String(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      print('Error reordering tracks: $e');
      rethrow;
    }
  }
}
