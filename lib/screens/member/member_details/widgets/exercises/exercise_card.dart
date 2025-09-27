
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

/// Exercise Card Widget
class ExerciseCard extends StatelessWidget {
  final Map<String, dynamic> exercise;
  final VoidCallback? onTap;

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          child: Container(
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(SizeApp.radiusMed),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExerciseHeader(),
                SizedBox(height: SizeApp.s12),
                _buildProgressBar(),
                if (exercise['lastUpdated'] != null) ...[
                  SizedBox(height: SizeApp.s8),
                  _buildLastUpdateText(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(SizeApp.s8),
          decoration: BoxDecoration(
            color: (exercise['color'] as Color).withOpacity(0.1),
            borderRadius: BorderRadius.circular(SizeApp.s8),
          ),
          child: Icon(
            exercise['icon'],
            color: exercise['color'],
            size: 20.sp,
          ),
        ),

        SizedBox(width: SizeApp.s12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                exercise['name'],
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.defaultText,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                exercise['status'],
                style: TextStyle(
                  fontSize: 13.sp,
                  color: exercise['color'],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),

        Text(
          '${exercise['progress'].toInt()}%',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: exercise['color'],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressBar() {
    return Container(
      height: 6.h,
      decoration: BoxDecoration(
        color: ColorsManager.defaultSurface,
        borderRadius: BorderRadius.circular(3.r),
      ),
      child: FractionallySizedBox(
        alignment: Alignment.centerLeft,
        widthFactor: exercise['progress'] / 100,
        child: Container(
          decoration: BoxDecoration(
            color: exercise['color'],
            borderRadius: BorderRadius.circular(3.r),
          ),
        ),
      ),
    );
  }

  Widget _buildLastUpdateText() {
    return Text(
      'آخر تحديث: ${_formatDate(exercise['lastUpdated'])}',
      style: TextStyle(
        fontSize: 11.sp,
        color: ColorsManager.defaultTextSecondary,
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