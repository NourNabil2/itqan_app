import 'package:flutter/material.dart';

import 'package:flutter/material.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';

enum AgeCategory {
  u6('U6'),
  u7('U7'),
  u8('U8'),
  u9('U9'),
  u10('U10'),
  u11('U11'),
  u12('U12'),
  u13('U13'),
  u14('U14');

  final String code;
  const AgeCategory(this.code);

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return l10n.ageCategory(code);
  }
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
  warmup('warmup'),
  stretching('stretching'),
  conditioning('conditioning');

  final String value;
  const ExerciseType(this.value);

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case ExerciseType.warmup:
        return l10n.warmup;
      case ExerciseType.stretching:
        return l10n.stretching;
      case ExerciseType.conditioning:
        return l10n.conditioning;
    }
  }
}

enum MediaType {
  image('image'),
  video('video');

  final String value;
  const MediaType(this.value);
}

enum ProgressStatus {
  notStarted('NotStarted'),
  inProgress('InProgress'),
  mastered('Mastered');

  final String value;
  const ProgressStatus(this.value);

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case ProgressStatus.notStarted:
        return l10n.notStarted;
      case ProgressStatus.inProgress:
        return l10n.inProgress;
      case ProgressStatus.mastered:
        return l10n.mastered;
    }
  }
}

enum NoteType {
  general('general', Icons.note_outlined),
  performance('performance', Icons.trending_up_rounded),
  behavior('behavior', Icons.psychology_outlined),
  health('health', Icons.health_and_safety_outlined);

  const NoteType(this.value, this.icon);
  final String value;
  final IconData icon;

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case NoteType.general:
        return l10n.general;
      case NoteType.performance:
        return l10n.performance;
      case NoteType.behavior:
        return l10n.behavior;
      case NoteType.health:
        return l10n.health;
    }
  }
}

enum NotePriority {
  low('low', Colors.green),
  normal('normal', Colors.blue),
  high('high', Colors.red);

  const NotePriority(this.value, this.color);
  final String value;
  final Color color;

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case NotePriority.low:
        return l10n.lowPriority;
      case NotePriority.normal:
        return l10n.normalPriority;
      case NotePriority.high:
        return l10n.highPriority;
    }
  }
}

enum Apparatus {
  floor('floor'),
  pommelHorse('pommel_horse'),
  stillRings('still_rings'),
  vault('vault'),
  parallelBars('parallel_bars'),
  horizontalBar('horizontal_bar'),
  unevenBars('uneven_bars'),
  beam('beam');

  final String value;
  const Apparatus(this.value);

  String getLocalizedName(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    switch (this) {
      case Apparatus.floor:
        return l10n.floor;
      case Apparatus.pommelHorse:
        return l10n.pommelHorse;
      case Apparatus.stillRings:
        return l10n.stillRings;
      case Apparatus.vault:
        return l10n.vault;
      case Apparatus.parallelBars:
        return l10n.parallelBars;
      case Apparatus.horizontalBar:
        return l10n.horizontalBar;
      case Apparatus.unevenBars:
        return l10n.unevenBars;
      case Apparatus.beam:
        return l10n.beam;
    }
  }
}

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