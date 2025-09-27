// member.dart - النسخة المصححة
import 'package:uuid/uuid.dart';

class Member {
  final String id;
  final String name;
  final int age;
  final String level;
  final String? photoPath;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double? overallProgress;

  Member({
    String? id,
    required this.name,
    required this.age,
    required this.level,
    this.photoPath,
    this.notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    this.overallProgress,
  }) :
        id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // ✅ toMap بدون team_id أو is_global
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'age': age,
      'level': level,
      'photo_path': photoPath,
      'notes': notes,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  // ✅ fromMap بدون team_id أو is_global
  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as String,
      name: map['name'] as String,
      age: map['age'] as int,
      level: map['level'] as String,
      photoPath: map['photo_path'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      overallProgress: map['overall_progress'] as double?,
    );
  }

  // ✅ copyWith بدون team_id أو is_global
  Member copyWith({
    String? id,
    String? name,
    int? age,
    String? level,
    String? photoPath,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? overallProgress,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      level: level ?? this.level,
      photoPath: photoPath ?? this.photoPath,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      overallProgress: overallProgress ?? this.overallProgress,
    );
  }

  @override
  String toString() {
    return 'Member(id: $id, name: $name, age: $age, level: $level)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Member && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}