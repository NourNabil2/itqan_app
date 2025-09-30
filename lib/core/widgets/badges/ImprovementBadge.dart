import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:provider/provider.dart';

// ============= 1. Improvement Badge Widget (منفصل وقابل لإعادة الاستخدام) =============
class ImprovementBadge extends StatelessWidget {
  final double improvement;
  final bool showIcon;
  final double? fontSize;
  final EdgeInsetsGeometry? padding;

  const ImprovementBadge({
    super.key,
    required this.improvement,
    this.showIcon = true,
    this.fontSize,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final isPositive = improvement > 0;
    final isNeutral = improvement == 0;

    Color backgroundColor;
    Color shadowColor;
    IconData icon;

    if (isPositive) {
      backgroundColor = ColorsManager.successFill;
      shadowColor = ColorsManager.successFill;
      icon = Icons.trending_up_rounded;
    } else if (isNeutral) {
      backgroundColor = ColorsManager.warningFill;
      shadowColor = ColorsManager.warningFill;
      icon = Icons.trending_flat_rounded;
    } else {
      backgroundColor = ColorsManager.errorFill;
      shadowColor = ColorsManager.errorFill;
      icon = Icons.trending_down_rounded;
    }

    return Container(
      padding: padding ?? EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            backgroundColor,
            backgroundColor.withOpacity(0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              icon,
              color: Colors.white,
              size: 16.sp,
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            '${isPositive ? '+' : ''}${improvement.toStringAsFixed(1)}%',
            style: TextStyle(
              fontSize: fontSize ?? 13.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}