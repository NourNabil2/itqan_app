// ============= 3. Count Badge Widget =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';

class CountBadge extends StatelessWidget {
  final String count;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;

  const CountBadge({
    super.key,
    required this.count,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = backgroundColor ?? ColorsManager.primaryColor.withOpacity(0.1);
    final color = textColor ?? ColorsManager.primaryColor;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14.sp, color: color),
            SizedBox(width: 4.w),
          ],
          Text(
            count,
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 13.sp,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}