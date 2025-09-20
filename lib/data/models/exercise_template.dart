import 'package:itqan_gym/core/utils/enums.dart';
import 'package:uuid/uuid.dart';


class ExerciseTemplate {
  final String id;
  final ExerciseType type;
  final String title;
  final String? description;
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
    this.mediaPath,
    this.mediaType,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.assignedTeamsCount = 0,
  }) : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.value,
      'title': title,
      'description': description,
      'media_path': mediaPath,
      'media_type': mediaType?.value,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory ExerciseTemplate.fromMap(Map<String, dynamic> map) {
    return ExerciseTemplate(
      id: map['id'],
      type: ExerciseType.values.firstWhere((e) => e.value == map['type']),
      title: map['title'],
      description: map['description'],
      mediaPath: map['media_path'],
      mediaType: map['media_type'] != null
          ? MediaType.values.firstWhere((m) => m.value == map['media_type'])
          : null,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      assignedTeamsCount: map['assigned_teams_count'] ?? 0,
    );
  }
}