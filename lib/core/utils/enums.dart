import 'package:flutter/material.dart';

enum AgeCategory {
  u6('U6', 'تحت 6 سنوات'),
  u7('U7', 'تحت 7 سنوات'),
  u8('U8', 'تحت 8 سنوات'),
  u9('U9', 'تحت 9 سنوات'),
  u10('U10', 'تحت 10 سنوات'),
  u11('U11', 'تحت 11 سنوات'), // ✅ مصحح
  u12('U12', 'تحت 12 سنوات'),
  u13('U13', 'تحت 13 سنوات'),
  u14('U14', 'تحت 14 سنوات');

  final String code;
  final String arabicName;
  const AgeCategory(this.code, this.arabicName);
}
AgeCategory? ageFromCodeSafe(String code) {
  for (final a in AgeCategory.values) {
    if (a.code.toLowerCase() == code.toLowerCase()) {
      return a;
    }
  }
  return null;
}
enum ExerciseType {
  warmup('warmup', 'الإحماء'),
  stretching('stretching', 'الإطالة'),
  conditioning('conditioning', 'اللياقة البدنية');

  final String value;
  final String arabicName;

  const ExerciseType(this.value, this.arabicName);
}



enum MediaType {
  image('image'),
  video('video');

  final String value;

  const MediaType(this.value);
}

enum ProgressStatus {
  notStarted('NotStarted', 'لم يبدأ'),
  inProgress('InProgress', 'قيد التنفيذ'),
  mastered('Mastered', 'متقن');

  final String value;
  final String arabicName;

  const ProgressStatus(this.value, this.arabicName);
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

enum Apparatus {
  floor('floor', 'الحركات الأرضية'),
  pommelHorse('pommel_horse', 'حصان الحلق'),
  stillRings('still_rings', 'الحلق'),
  vault('vault', 'طاولة القفز'),
  parallelBars('parallel_bars', 'المتوازي'),
  horizontalBar('horizontal_bar', 'العقلة'),
  unevenBars('uneven_bars', 'المتوازي المختلف'),
  beam('beam', 'عارضة التوازن');

  final String value;
  final String arabicName;
  const Apparatus(this.value, this.arabicName);
}

// دالة الألوان المطابقة
Color getApparatusColor(Apparatus apparatus) {
  switch (apparatus) {
    case Apparatus.floor:
      return const Color(0xFF4CAF50);
    case Apparatus.pommelHorse:
      return const Color(0xFF8BC34A);
    case Apparatus.stillRings:
      return const Color(0xFFFFC107);
    case Apparatus.vault:
      return const Color(0xFFFF9800);
    case Apparatus.parallelBars:
      return const Color(0xFF2196F3);
    case Apparatus.horizontalBar:
      return const Color(0xFF3F51B5);
    case Apparatus.unevenBars:
      return const Color(0xFF9C27B0);
    case Apparatus.beam:
      return const Color(0xFFE91E63);
  }
}

IconData getApparatusIcon(Apparatus apparatus) {
  switch (apparatus) {
    case Apparatus.floor:
      return Icons.sports_gymnastics_rounded;
    case Apparatus.pommelHorse:
      return Icons.sports_rounded;
    case Apparatus.stillRings:
      return Icons.radio_button_unchecked_rounded;
    case Apparatus.vault:
      return Icons.directions_run_rounded;
    case Apparatus.parallelBars:
      return Icons.drag_handle_rounded;
    case Apparatus.horizontalBar:
      return Icons.remove_rounded;
    case Apparatus.unevenBars:
      return Icons.view_stream_rounded;
    case Apparatus.beam:
      return Icons.linear_scale_rounded;
  }
}