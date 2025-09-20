import 'package:uuid/uuid.dart';

class Member {
  final String id;
  final String? teamId; // Nullable - null means it's in global library only
  final String name;
  final int age;
  final String level;
  final String? photoPath;
  final String? notes;
  final bool isGlobal; // true if member is in global library
  final DateTime createdAt;
  final DateTime updatedAt;
  double overallProgress;

  Member({
    String? id,
    this.teamId,
    required this.name,
    required this.age,
    required this.level,
    this.photoPath,
    this.notes,
    this.isGlobal = false,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.overallProgress = 0.0,
  }) : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'team_id': teamId,
      'name': name,
      'age': age,
      'level': level,
      'photo_path': photoPath,
      'notes': notes,
      'is_global': isGlobal ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'],
      teamId: map['team_id'],
      name: map['name'],
      age: map['age'],
      level: map['level'],
      photoPath: map['photo_path'],
      notes: map['notes'],
      isGlobal: (map['is_global'] ?? 0) == 1,
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
      overallProgress: (map['overall_progress'] ?? 0.0).toDouble(),
    );
  }

  Member copyWith({
    String? id,
    String? teamId,
    String? name,
    int? age,
    String? level,
    String? photoPath,
    String? notes,
    bool? isGlobal,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? overallProgress,
  }) {
    return Member(
      id: id ?? this.id,
      teamId: teamId ?? this.teamId,
      name: name ?? this.name,
      age: age ?? this.age,
      level: level ?? this.level,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      isGlobal: isGlobal ?? this.isGlobal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }
}