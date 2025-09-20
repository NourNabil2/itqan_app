import 'dart:convert';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:uuid/uuid.dart';

class MediaItem {
  final String path;
  final MediaType type;

  MediaItem({required this.path, required this.type});

  Map<String, dynamic> toMap() => {
    'path': path,
    'type': type.value,
  };

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      path: map['path'] as String,
      type: MediaType.values.firstWhere((m) => m.value == map['type']),
    );
  }
}

class SkillTemplate {
  final String id;
  final Apparatus apparatus;
  final String skillName;
  final String? thumbnailPath;
  final List<MediaItem> mediaGallery;
  final String? technicalAnalysis;
  final String? preRequisites;
  final String? skillProgression;
  final String? drills;
  final String? physicalPreparation;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int assignedTeamsCount; // يفضل يجي من Query

  SkillTemplate({
    String? id,
    required this.apparatus,
    required this.skillName,
    this.thumbnailPath,
    List<MediaItem>? mediaGallery,
    this.technicalAnalysis,
    this.preRequisites,
    this.skillProgression,
    this.drills,
    this.physicalPreparation,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.assignedTeamsCount = 0,
  })  : id = id ?? const Uuid().v4(),
        mediaGallery = mediaGallery ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'apparatus': apparatus.value,
      'skill_name': skillName,
      'thumbnail_path': thumbnailPath,
      'media_gallery': jsonEncode(mediaGallery.map((m) => m.toMap()).toList()),
      'technical_analysis': technicalAnalysis,
      'pre_requisites': preRequisites,
      'skill_progression': skillProgression,
      'drills': drills,
      'physical_preparation': physicalPreparation,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // لا تكتب assigned_teams_count هنا إلا لو عمود فعلي
    };
  }

  factory SkillTemplate.fromMap(Map<String, dynamic> map) {
    final List<MediaItem> gallery = [];
    if (map['media_gallery'] != null) {
      final decoded = jsonDecode(map['media_gallery']);
      if (decoded is List) {
        gallery.addAll(decoded.map((m) => MediaItem.fromMap(m)));
      }
    }

    return SkillTemplate(
      id: map['id'] as String,
      apparatus:
      Apparatus.values.firstWhere((a) => a.value == map['apparatus']),
      skillName: map['skill_name'] as String,
      thumbnailPath: map['thumbnail_path'] as String?,
      mediaGallery: gallery,
      technicalAnalysis: map['technical_analysis'] as String?,
      preRequisites: map['pre_requisites'] as String?,
      skillProgression: map['skill_progression'] as String?,
      drills: map['drills'] as String?,
      physicalPreparation: map['physical_preparation'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      assignedTeamsCount:
      (map['assigned_teams_count'] as int?) ?? 0, // يفضل query مخصص
    );
  }
}
