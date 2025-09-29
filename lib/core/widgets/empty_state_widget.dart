import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/widgets/CustomIcon.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  /// اختر أحدهما:
  final IconData? iconData;        // في حال استخدام Material Icon
  final String? assetSvgPath;      // في حال استخدام SVG من الأصول

  /// تخصيص اختياري
  final IconData buttonIcon;
  final double circleSize;
  final double iconSize;

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
    this.iconData,
    this.assetSvgPath,
    this.buttonIcon = Icons.add,
    this.circleSize = 120,
    this.iconSize = 60,
  }) : assert(iconData != null || assetSvgPath != null,
  'Provide either iconData or assetSvgPath');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final surface = theme.colorScheme.surface;
    final onSurface = theme.colorScheme.onSurface.withOpacity(0.8);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.95, end: 1),
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOut,
          builder: (context, value, child) => Opacity(
            opacity: (value - 0.9).clamp(0, 1) / 0.1,
            child: Transform.scale(scale: value, child: child),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // أيقونة دائرية بزخرفة خفيفة
              Container(
                width: circleSize.w,
                height: circleSize.w, // مربع علشان يطلع دايرة مضبوطة
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withOpacity(0.12),
                      primary.withOpacity(0.06),
                    ],
                  ),
                  border: Border.all(
                    color: primary.withOpacity(0.18),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withOpacity(0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: assetSvgPath != null
                    ? CustomIcon(
                  color: primary,
                  assetPath: assetSvgPath!,
                  size: iconSize.sp,
                )
                    : Icon(
                  iconData,
                  color: primary,
                  size: iconSize.sp,
                ),
              ),
              SizedBox(height: 20.h),

              // العنوان
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 8.h),

              // النص الإضافي
              Text(
                subtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: onSurface,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),

              // زر الإجراء
              ConstrainedBox(
                constraints: BoxConstraints(minWidth: 180.w),
                child: ElevatedButton.icon(
                  onPressed: onPressed,
                  icon: Icon(buttonIcon, color: ColorsManager.backgroundSurface),
                  label: Text(buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: onPrimary,
                    padding: EdgeInsets.symmetric(
                      horizontal: 22.w,
                      vertical: 12.h,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}