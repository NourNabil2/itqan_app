// lib/data/models/skill_template.dart
import 'dart:convert';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:uuid/uuid.dart';

class MediaItem {
  final String path;
  final MediaType type;
  final bool isNetworkUrl; // ✅ جديد: لمعرفة إذا كان الرابط من الإنترنت

  MediaItem({
    required this.path,
    required this.type,
    this.isNetworkUrl = false, // ✅ افتراضياً محلي
  });

  Map<String, dynamic> toMap() => {
    'path': path,
    'type': type.value,
    'is_network_url': isNetworkUrl, // ✅
  };

  factory MediaItem.fromMap(Map<String, dynamic> map) {
    return MediaItem(
      path: map['path'] as String,
      type: MediaType.values.firstWhere(
            (m) => m.value == map['type'],
        orElse: () => MediaType.image,
      ),
      isNetworkUrl: map['is_network_url'] as bool? ?? false, // ✅
    );
  }

  MediaItem copyWith({
    String? path,
    MediaType? type,
    bool? isNetworkUrl,
  }) {
    return MediaItem(
      path: path ?? this.path,
      type: type ?? this.type,
      isNetworkUrl: isNetworkUrl ?? this.isNetworkUrl,
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
  final int assignedTeamsCount;

  // ✅ حقول جديدة للـ Supabase
  final bool isSystem; // هل هي مهارة جاهزة من النظام؟
  final String? videoUrl; // رابط الفيديو من Supabase
  final String? description; // وصف إضافي للمهارة الجاهزة
  final String? difficultyLevel; // مستوى الصعوبة

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
    // ✅ القيم الافتراضية للحقول الجديدة
    this.isSystem = false,
    this.videoUrl,
    this.description,
    this.difficultyLevel,
  })  : id = id ?? const Uuid().v4(),
        mediaGallery = mediaGallery ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ✅ تحديث toMap
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
      // ✅ الحقول الجديدة
      'is_system': isSystem ? 1 : 0, // SQLite لا يدعم bool مباشرة
      'video_url': videoUrl,
      'description': description,
      'difficulty_level': difficultyLevel,
    };
  }

  // ✅ تحديث fromMap
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
      apparatus: Apparatus.values.firstWhere(
            (a) => a.value == map['apparatus'],
        orElse: () => Apparatus.floor,
      ),
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
      assignedTeamsCount: (map['assigned_teams_count'] as int?) ?? 0,
      // ✅ قراءة الحقول الجديدة
      isSystem: (map['is_system'] as int?) == 1 || (map['is_system'] as bool?) == true,
      videoUrl: map['video_url'] as String?,
      description: map['description'] as String?,
      difficultyLevel: map['difficulty_level'] as String?,
    );
  }

  // ✅ تحديث copyWith
  SkillTemplate copyWith({
    String? id,
    Apparatus? apparatus,
    String? skillName,
    String? thumbnailPath,
    List<MediaItem>? mediaGallery,
    String? technicalAnalysis,
    String? preRequisites,
    String? skillProgression,
    String? drills,
    String? physicalPreparation,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? assignedTeamsCount,
    // ✅
    bool? isSystem,
    String? videoUrl,
    String? description,
    String? difficultyLevel,
  }) {
    return SkillTemplate(
      id: id ?? this.id,
      apparatus: apparatus ?? this.apparatus,
      skillName: skillName ?? this.skillName,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mediaGallery: mediaGallery ?? this.mediaGallery,
      technicalAnalysis: technicalAnalysis ?? this.technicalAnalysis,
      preRequisites: preRequisites ?? this.preRequisites,
      skillProgression: skillProgression ?? this.skillProgression,
      drills: drills ?? this.drills,
      physicalPreparation: physicalPreparation ?? this.physicalPreparation,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTeamsCount: assignedTeamsCount ?? this.assignedTeamsCount,
      // ✅
      isSystem: isSystem ?? this.isSystem,
      videoUrl: videoUrl ?? this.videoUrl,
      description: description ?? this.description,
      difficultyLevel: difficultyLevel ?? this.difficultyLevel,
    );
  }

  // ✅ Helper method لتحويل بيانات Supabase إلى SkillTemplate
  factory SkillTemplate.fromSupabase(Map<String, dynamic> map) {
    // معالجة الـ media_gallery من JSONB
    List<MediaItem> gallery = [];
    if (map['media_gallery'] != null) {
      final mediaList = map['media_gallery'] is List
          ? map['media_gallery'] as List
          : jsonDecode(map['media_gallery'].toString()) as List;

      gallery = mediaList.map((m) {
        if (m is Map) {
          return MediaItem(
            path: m['url'] ?? m['path'] ?? '',
            type: m['type'] == 'video' ? MediaType.video : MediaType.image,
            isNetworkUrl: true,
          );
        }
        return MediaItem(path: m.toString(), type: MediaType.image, isNetworkUrl: true);
      }).toList();
    }

    return SkillTemplate(
      id: map['id'] as String,
      apparatus: Apparatus.values.firstWhere(
            (a) => a.value == map['apparatus'],
        orElse: () => Apparatus.floor,
      ),
      skillName: map['skill_name_ar'] ?? map['skill_name'] as String,
      thumbnailPath: map['thumbnail_url'] as String?,
      videoUrl: map['video_url'] as String?,
      description: map['description'] as String?,
      technicalAnalysis: map['technical_analysis'] as String?,
      preRequisites: map['pre_requisites'] as String?,
      skillProgression: map['skill_progression'] as String?,
      drills: map['drills'] as String?,
      physicalPreparation: map['physical_preparation'] as String?,
      difficultyLevel: map['difficulty_level'] as String?,
      isSystem: true, // ✅ دائماً true للبيانات القادمة من Supabase
      mediaGallery: gallery,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }
}