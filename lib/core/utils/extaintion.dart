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