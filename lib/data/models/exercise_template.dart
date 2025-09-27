import 'dart:convert';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:uuid/uuid.dart';

import 'skill_template.dart';

class ExerciseTemplate {
  final String id;
  final ExerciseType type;
  final String title;
  final String? description;

  // New media system
  final String? thumbnailPath;
  final List<MediaItem> mediaGallery;

  // Legacy fields for backward compatibility
  final String? mediaPath;
  final MediaType? mediaType;

  final DateTime createdAt;
  final DateTime updatedAt;
  int assignedTeamsCount;

  ExerciseTemplate({
    String? id,
    required this.type,
    required this.title,
    this.description,
    this.thumbnailPath,
    List<MediaItem>? mediaGallery,
    this.mediaPath,
    this.mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.assignedTeamsCount = 0,
  }) : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now(),
        mediaGallery = mediaGallery ?? [];

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'description': description,
      'thumbnail_path': thumbnailPath,
      'media_gallery': mediaGallery.isNotEmpty
          ? json.encode(mediaGallery.map((item) => item.toMap()).toList())
          : null,
      // Keep legacy fields for backward compatibility
      'media_path': mediaPath,
      'media_type': mediaType?.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExerciseTemplate.fromMap(Map<String, dynamic> map) {
    // Parse media gallery with better error handling
    List<MediaItem> mediaGallery = [];
    if (map['media_gallery'] != null && map['media_gallery'].toString().isNotEmpty) {
      try {
        List<dynamic> mediaJson = json.decode(map['media_gallery']);
        mediaGallery = mediaJson.map((item) {
          if (item is Map<String, dynamic>) {
            return MediaItem.fromMap(item);
          } else {
            // Handle old format or invalid data
            return null;
          }
        }).where((item) => item != null).cast<MediaItem>().toList();
      } catch (e) {
        print('Error parsing media gallery for exercise ${map['id']}: $e');
        mediaGallery = [];
      }
    }

    return ExerciseTemplate(
      id: map['id']?.toString() ?? '',
      type: ExerciseType.values.firstWhere(
            (e) => e.value == map['type'],
        orElse: () => ExerciseType.conditioning,
      ),
      title: map['title']?.toString() ?? '',
      description: map['description']?.toString(),
      thumbnailPath: map['thumbnail_path']?.toString(),
      mediaGallery: mediaGallery,
      // Legacy fields
      mediaPath: map['media_path']?.toString(),
      mediaType: map['media_type'] != null
          ? MediaType.values.firstWhere(
            (m) => m.value == map['media_type'],
        orElse: () => MediaType.image,
      )
          : null,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'])
          : DateTime.now(),
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'])
          : DateTime.now(),
      assignedTeamsCount: (map['assigned_teams_count'] as num?)?.toInt() ?? 0,
    );
  }

  // Convenience methods
  bool get hasMedia => thumbnailPath != null || mediaGallery.isNotEmpty || mediaPath != null;

  bool get hasMultipleMedia => mediaGallery.length > 1;

  String? get primaryMediaPath => thumbnailPath ?? mediaPath;

  MediaType? get primaryMediaType {
    if (thumbnailPath != null) return MediaType.image;
    return mediaType;
  }

  // Get all media items (including legacy)
  List<MediaItem> get allMediaItems {
    List<MediaItem> allMedia = [...mediaGallery];

    // Add legacy media if exists and not already in gallery
    if (mediaPath != null && mediaType != null) {
      bool alreadyExists = allMedia.any((item) => item.path == mediaPath);
      if (!alreadyExists) {
        allMedia.insert(0, MediaItem(path: mediaPath!, type: mediaType!));
      }
    }

    return allMedia;
  }

  // Copy with method for updates
  ExerciseTemplate copyWith({
    String? id,
    ExerciseType? type,
    String? title,
    String? description,
    String? thumbnailPath,
    List<MediaItem>? mediaGallery,
    String? mediaPath,
    MediaType? mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? assignedTeamsCount,
  }) {
    return ExerciseTemplate(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      mediaGallery: mediaGallery ?? this.mediaGallery,
      mediaPath: mediaPath ?? this.mediaPath,
      mediaType: mediaType ?? this.mediaType,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      assignedTeamsCount: assignedTeamsCount ?? this.assignedTeamsCount,
    );
  }

  @override
  String toString() {
    return 'ExerciseTemplate(id: $id, type: $type, title: $title, hasMedia: $hasMedia)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExerciseTemplate &&
        other.id == id &&
        other.type == type &&
        other.title == title;
  }

  @override
  int get hashCode {
    return id.hashCode ^ type.hashCode ^ title.hashCode;
  }
}