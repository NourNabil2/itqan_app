
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

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
