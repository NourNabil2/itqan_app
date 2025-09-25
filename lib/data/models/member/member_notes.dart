import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class MemberNote {
  final String id;
  final String memberId;
  final String title;
  final String content;
  final String noteType; // general, performance, behavior, health
  final String priority; // low, normal, high
  final String? createdBy; // coach/trainer name
  final DateTime createdAt;
  final DateTime updatedAt;

  MemberNote({
    String? id,
    required this.memberId,
    required this.title,
    required this.content,
    this.noteType = 'general',
    this.priority = 'normal',
    this.createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'member_id': memberId,
      'title': title,
      'content': content,
      'note_type': noteType,
      'priority': priority,
      'created_by': createdBy,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  factory MemberNote.fromMap(Map<String, dynamic> map) {
    return MemberNote(
      id: map['id'],
      memberId: map['member_id'],
      title: map['title'],
      content: map['content'],
      noteType: map['note_type'] ?? 'general',
      priority: map['priority'] ?? 'normal',
      createdBy: map['created_by'],
      createdAt: DateTime.parse(map['created_at']),
      updatedAt: DateTime.parse(map['updated_at']),
    );
  }

  MemberNote copyWith({
    String? id,
    String? memberId,
    String? title,
    String? content,
    String? noteType,
    String? priority,
    String? createdBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MemberNote(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      title: title ?? this.title,
      content: content ?? this.content,
      noteType: noteType ?? this.noteType,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

// Enums for better type safety
enum NoteType {
  general('general', 'عام', Icons.note_outlined),
  performance('performance', 'الأداء', Icons.trending_up_rounded),
  behavior('behavior', 'السلوك', Icons.psychology_outlined),
  health('health', 'الصحة', Icons.health_and_safety_outlined);

  const NoteType(this.value, this.arabicName, this.icon);
  final String value;
  final String arabicName;
  final IconData icon;
}

enum NotePriority {
  low('low', 'منخفضة', Colors.green),
  normal('normal', 'عادية', Colors.blue),
  high('high', 'عالية', Colors.red);

  const NotePriority(this.value, this.arabicName, this.color);
  final String value;
  final String arabicName;
  final Color color;
}