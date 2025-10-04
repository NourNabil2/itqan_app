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

class StatCard extends StatelessWidget {
  final StatItem stat;
  const StatCard({super.key, required this.stat});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        // لو الارتفاع المتاح صغير، قلّل عدد سطور العنوان وقلّل المسافات
        final bool compact = constraints.hasBoundedHeight && constraints.maxHeight < 72;
        final int titleMaxLines = compact ? 1 : 2;

        return Container(
          padding: EdgeInsets.all(SizeApp.padding),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // أيقونة ثابتة الحجم تمنع تمدّد غير محسوب
              SizedBox(
                width: 40.w,
                height: 40.w,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [
                        stat.color.withOpacity(0.15),
                        stat.color.withOpacity(0.08),
                      ],
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      stat.icon,
                      color: stat.color,
                      size: (SizeApp.iconSizeSmall.sp).clamp(16.0, 24.0),
                    ),
                  ),
                ),
              ),

              SizedBox(width: SizeApp.padding),

              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min, // ما تطلبش ارتفاع أكثر من اللازم
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // القيمة: سطر واحد + ellipsis
                    Text(
                      stat.value,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: stat.color,
                        height: 1.0,
                      ),
                    ),

                    SizedBox(height: compact ? 2.h : 4.h),

                    // العنوان: اجعله Flexible عشان ما يكسّرش، مع maxLines ديناميكي
                    Flexible(
                      child: Text(
                        stat.title,
                        maxLines: titleMaxLines,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: ColorsManager.defaultTextSecondary,
                          fontWeight: FontWeight.w500,
                          height: 1.2,
                        ),
                      ),
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
