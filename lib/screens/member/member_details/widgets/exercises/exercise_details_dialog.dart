
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
// ============= Exercises Progress Section - Using Existing Widgets =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';

import 'exercise_card.dart';
import 'exercises_summary_card.dart';

/// Exercise Details Dialog
class ExerciseDetailsDialog extends StatelessWidget {
  final Map<String, dynamic> exercise;

  const ExerciseDetailsDialog({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      ),
      title: Row(
        children: [
          Icon(
            exercise['icon'],
            color: exercise['color'],
            size: 24.sp,
          ),
          SizedBox(width: SizeApp.s8),
          Expanded(
            child: Text(
              exercise['name'],
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDetailRow('الحالة', exercise['status']),
          _buildDetailRow('التقدم', '${exercise['progress'].toInt()}%'),
          if (exercise['lastUpdated'] != null)
            _buildDetailRow('آخر تحديث', _formatDate(exercise['lastUpdated'])),

          SizedBox(height: SizeApp.s16),

          // Progress visualization
          Container(
            height: 8.h,
            decoration: BoxDecoration(
              color: ColorsManager.defaultSurface,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: exercise['progress'] / 100,
              child: Container(
                decoration: BoxDecoration(
                  color: exercise['color'],
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('إغلاق'),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
            // يمكن إضافة navigation لتحديث التمرين
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: exercise['color'],
            foregroundColor: Colors.white,
          ),
          child: Text('تحديث'),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeApp.s8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: ColorsManager.defaultText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}



class ExercisesProgressSection extends StatelessWidget {
  final List<AssignedExercise> exercises;
  final VoidCallback onViewAll;
  final int maxVisible;

  const ExercisesProgressSection({
    super.key,
    required this.exercises,
    required this.onViewAll,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (exercises.isEmpty) return const SizedBox.shrink();

    final visibleExercises = exercises.take(maxVisible).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(),
        SizedBox(height: SizeApp.s12),

        // Summary Card
        ExercisesSummaryCard(
          exercises: _convertToMapList(exercises),
        ),

        SizedBox(height: SizeApp.s12),

        // Exercise Cards
        ...visibleExercises.map((exercise) => ExerciseCard(
          exercise: _convertToMap(exercise),
          onTap: () => _showExerciseDetails(context, exercise),
        )),

        if (exercises.length > maxVisible) _buildViewAllButton(context),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.sp),
          decoration: BoxDecoration(
            color: ColorsManager.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            Icons.fitness_center_rounded,
            color: ColorsManager.secondaryColor,
            size: 20.sp,
          ),
        ),
        SizedBox(width: SizeApp.s12),
        Expanded(
          child: Text(
            'تقدم التمارين',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: ColorsManager.defaultText,
            ),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: ColorsManager.secondaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20.r),
          ),
          child: Text(
            '${exercises.length} تمرين',
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsManager.secondaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: InkWell(
        onTap: onViewAll,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'عرض كل التمارين (${exercises.length})',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.secondaryColor,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 14.sp,
                color: ColorsManager.secondaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showExerciseDetails(BuildContext context, AssignedExercise exercise) {
    showDialog(
      context: context,
      builder: (context) => ExerciseDetailsDialog(
        exercise: _convertToMap(exercise),
      ),
    );
  }

  // Helper Methods - Convert AssignedExercise to Map
  Map<String, dynamic> _convertToMap(AssignedExercise exercise) {
    if (exercise.exercise == null) {
      return {};
    }

    final exerciseColor = _getExerciseTypeColor(exercise.exercise!.type);
    final exerciseIcon = _getExerciseTypeIcon(exercise.exercise!.type);
    final status = _getStatusText(exercise);

    return {
      'name': exercise.exercise!.title,
      'progress': exercise.progress,
      'status': status,
      'color': exerciseColor,
      'icon': exerciseIcon,
      'lastUpdated': exercise.assignedAt,
    };
  }

  List<Map<String, dynamic>> _convertToMapList(List<AssignedExercise> exercises) {
    return exercises.map((e) => _convertToMap(e)).toList();
  }

  String _getStatusText(AssignedExercise exercise) {
    if (exercise.isCompleted) return 'مكتمل';
    if (exercise.isInProgress) return 'قيد التقدم';
    return 'لم يبدأ';
  }

  Color _getExerciseTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getExerciseTypeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }
}