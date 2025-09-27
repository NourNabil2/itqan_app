import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

/// Exercises Summary Card
class ExercisesSummaryCard extends StatelessWidget {
  final List<Map<String, dynamic>> exercises;

  const ExercisesSummaryCard({
    super.key,
    required this.exercises,
  });

  @override
  Widget build(BuildContext context) {
    final completed = exercises.where((e) => e['progress'] >= 80).length;
    final inProgress = exercises.where((e) => e['progress'] > 0 && e['progress'] < 80).length;
    final notStarted = exercises.where((e) => e['progress'] == 0).length;

    return Container(
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
          Text(
            'ملخص التمارين',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),

          SizedBox(height: SizeApp.s16),

          Row(
            children: [
              Expanded(
                child: _buildSummaryItem(
                  'مكتملة',
                  completed.toString(),
                  ColorsManager.successFill,
                  Icons.check_circle_rounded,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildSummaryItem(
                  'قيد التقدم',
                  inProgress.toString(),
                  ColorsManager.primaryColor,
                  Icons.schedule_rounded,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildSummaryItem(
                  'لم تبدأ',
                  notStarted.toString(),
                  ColorsManager.errorFill,
                  Icons.radio_button_unchecked_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String title, String count, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: color,
          ),
          SizedBox(height: SizeApp.s2 *2),
          Text(
            count,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}