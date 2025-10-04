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

extension DateTimeX on DateTime {
  /// Relative time like:
  /// AR: "الآن" / "قبل دقيقة" / "قبل 5 دقائق" / "بعد ساعة"
  /// EN: "just now" / "1m ago" / "in 5m" / "in 1h"
  String timeAgo({String locale = 'ar', DateTime? now}) {
    final _now = now ?? DateTime.now();
    Duration diff = _now.difference(this);
    final isFuture = diff.isNegative;
    if (isFuture) diff = diff.abs();

    // seconds
    if (diff.inSeconds < 45) {
      return locale.startsWith('ar')
          ? 'الآن'
          : 'just now';
    }

    String arUnit(int n, String one, String two, String few, String many) {
      // CLDR-ish: 1, 2, 3-10, 11-99 (سهل وعملي للـ UI)
      if (n == 1) return one;               // دقيقة
      if (n == 2) return two;               // دقيقتين
      if (n >= 3 && n <= 10) return '$n $few';   // 3..10 دقائق
      return '$n $many';                    // 11.. دقائق -> دقيقة/ساعة/يوم مفرد
    }

    String arPhrase(int n, String unitOne, String unitTwo, String unitFew, String unitMany) {
      final core = arUnit(n, unitOne, unitTwo, unitFew, unitMany);
      return isFuture ? 'بعد $core' : 'قبل $core';
    }

    if (diff.inMinutes < 1) {
      final s = diff.inSeconds;
      if (locale.startsWith('ar')) {
        return arPhrase(s, 'ثانية', 'ثانيتين', 'ثوانٍ', 'ثانية');
      }
      return isFuture ? 'in ${s}s' : '${s}s ago';
    }

    if (diff.inMinutes < 60) {
      final m = diff.inMinutes;
      if (locale.startsWith('ar')) {
        return arPhrase(m, 'دقيقة', 'دقيقتين', 'دقائق', 'دقيقة');
      }
      return isFuture ? 'in ${m}m' : '${m}m ago';
    }

    if (diff.inHours < 24) {
      final h = diff.inHours;
      if (locale.startsWith('ar')) {
        return arPhrase(h, 'ساعة', 'ساعتين', 'ساعات', 'ساعة');
      }
      return isFuture ? 'in ${h}h' : '${h}h ago';
    }

    if (diff.inDays < 7) {
      final d = diff.inDays;
      if (locale.startsWith('ar')) {
        return arPhrase(d, 'يوم', 'يومين', 'أيام', 'يوم');
      }
      return isFuture ? 'in ${d}d' : '${d}d ago';
    }

    if (diff.inDays < 30) {
      final w = (diff.inDays / 7).floor();
      if (locale.startsWith('ar')) {
        return arPhrase(w, 'أسبوع', 'أسبوعين', 'أسابيع', 'أسبوع');
      }
      return isFuture ? 'in ${w}w' : '${w}w ago';
    }

    if (diff.inDays < 365) {
      final mo = (diff.inDays / 30).floor();
      if (locale.startsWith('ar')) {
        return arPhrase(mo, 'شهر', 'شهرين', 'أشهر', 'شهر');
      }
      return isFuture ? 'in ${mo}mo' : '${mo}mo ago';
    }

    final y = (diff.inDays / 365).floor();
    if (locale.startsWith('ar')) {
      return arPhrase(y, 'سنة', 'سنتين', 'سنوات', 'سنة');
    }
    return isFuture ? 'in ${y}y' : '${y}y ago';
  }

  /// yyyy-MM-dd  (e.g. 2025-10-03)
  String yMd({String sep = '-'}) =>
      '${year.toString().padLeft(4, '0')}$sep${month.toString().padLeft(2, '0')}$sep${day.toString().padLeft(2, '0')}';

  /// dd/MM/yyyy (e.g. 03/10/2025)
  String dMy({String sep = '/'}) =>
      '${day.toString().padLeft(2, '0')}$sep${month.toString().padLeft(2, '0')}$sep${year.toString().padLeft(4, '0')}';

  /// HH:mm (24h)
  String hhmm() => '${_two(hour)}:${_two(minute)}';

  // Day boundaries
  DateTime get startOfDay => DateTime(year, month, day);
  DateTime get endOfDay => DateTime(year, month, day, 23, 59, 59, 999);

  // Day checks
  bool isSameDay(DateTime other) =>
      year == other.year && month == other.month && day == other.day;

  bool get isToday => isSameDay(DateTime.now());
  bool get isYesterday => isSameDay(DateTime.now().subtract(const Duration(days: 1)));
  bool get isTomorrow => isSameDay(DateTime.now().add(const Duration(days: 1)));

  // Differences
  int daysSince([DateTime? from]) {
    final base = from ?? DateTime.now();
    return base.difference(this).inDays;
  }

  int daysUntil([DateTime? to]) {
    final base = to ?? DateTime.now();
    return difference(base).inDays;
  }
}

extension DateTimeLocalizedX on DateTime {
  /// Picks 'ar' or 'en' from the current context automatically.
  String timeAgoCtx(BuildContext context, {DateTime? now}) {
    final code = Localizations.localeOf(context).languageCode;
    final locale = code.startsWith('ar') ? 'ar' : 'en';
    return timeAgo(locale: locale, now: now);
  }
}

extension NullableDateTimeX on DateTime? {
  String timeAgoOr(String fallback, {String locale = 'ar', DateTime? now}) =>
      this == null ? fallback : this!.timeAgo(locale: locale, now: now);

  String timeAgoCtxOr(BuildContext context, String fallback, {DateTime? now}) =>
      this == null ? fallback : this!.timeAgoCtx(context, now: now);
}

// helpers
String _two(int n) => n < 10 ? '0$n' : '$n';