import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatItem(this.title, this.value, this.icon, this.color);
}

// Alternative responsive card design with better overflow handling
class StatCard extends StatelessWidget {
  final StatItem stat;

  const StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: EdgeInsets.all(SizeApp.padding),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),

          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      stat.color.withOpacity(0.15),
                      stat.color.withOpacity(0.08),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  stat.icon,
                  color: stat.color,
                  size: SizeApp.iconSizeSmall.sp,
                ),
              ),
              SizedBox(width: SizeApp.padding),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        stat.value,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          color: stat.color,
                        ),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      stat.title,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: ColorsManager.defaultTextSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}