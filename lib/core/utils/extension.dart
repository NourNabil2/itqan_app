// ✅ Extensions للملاحظات (ضعها في ملف منفصل)
import 'package:flutter/material.dart';
import 'enums.dart';

extension NoteTypeExtension on NoteType {
  IconData get icon {
    switch (this) {
      case NoteType.general:
        return Icons.note_rounded;
      case NoteType.performance:
        return Icons.trending_up_rounded;
      case NoteType.behavior:
        return Icons.psychology_rounded;
      case NoteType.health:
        return Icons.health_and_safety_rounded;
    }
  }

  String get arabicName {
    switch (this) {
      case NoteType.general:
        return 'عامة';
      case NoteType.performance:
        return 'أداء';
      case NoteType.behavior:
        return 'سلوك';
      case NoteType.health:
        return 'صحة';
    }
  }
}

extension NotePriorityExtension on NotePriority {
  String get arabicName {
    switch (this) {
      case NotePriority.low:
        return 'منخفضة';
      case NotePriority.normal:
        return 'متوسطة';
      case NotePriority.high:
        return 'عالية';
    }
  }
}

/// Exercise Type Extensions
extension ExerciseTypeExtension on ExerciseType {
  IconData get icon {
    switch (this) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }

  Color get color {
    switch (this) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722); // Deep Orange
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50); // Green
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3); // Blue
    }
  }
}