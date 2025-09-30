import 'package:flutter/material.dart';
import 'package:itqan_gym/core/utils/enums.dart';

class LibraryTab {
  final String title;
  final IconData icon;
  final ExerciseType? exerciseType;

  const LibraryTab({
    required this.title,
    required this.icon,
    this.exerciseType,
  });

  // Predefined tabs
  static const List<LibraryTab> tabs = [
    LibraryTab(
      title: 'الإحماء',
      icon: Icons.whatshot_rounded,
      exerciseType: ExerciseType.warmup,
    ),
    LibraryTab(
      title: 'الإطالة',
      icon: Icons.accessibility_new_rounded,
      exerciseType: ExerciseType.stretching,
    ),
    LibraryTab(
      title: 'اللياقة',
      icon: Icons.fitness_center_rounded,
      exerciseType: ExerciseType.conditioning,
    ),
    LibraryTab(
      title: 'المهارات',
      icon: Icons.star_rounded,
    ),
  ];
}