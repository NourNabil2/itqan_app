import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/widgets/CustomIcon.dart';

class EmptyStateWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? buttonText;
  final VoidCallback? onPressed;

  /// استخدم واحدة فقط:
  final IconData? iconData;      // أيقونة مادية عادية
  final String? assetSvgPath;    // مسار SVG (يُعرض عبر CustomIcon)

  final IconData buttonIcon;
  final double circleSize;
  final double iconSize;
  final bool showButton; // للتحكم في إظهار الزر
  final Color? iconColor; // لون الأيقونة (اختياري)

  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.buttonText,
    this.onPressed,
    this.iconData,
    this.assetSvgPath,
    this.buttonIcon = Icons.add,
    this.circleSize = 120,
    this.iconSize = 60,
    this.showButton = true,
    this.iconColor,
  }) : assert(iconData != null || assetSvgPath != null,
  'Provide either iconData or assetSvgPath'),
        assert(!showButton || (buttonText != null && onPressed != null),
        'If showButton is true, provide buttonText and onPressed');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final onSurface = theme.colorScheme.onSurface.withOpacity(0.8);

    // اختَر الودجت المناسبة: Icon أو CustomIcon (SVG)
    final Widget iconWidget = assetSvgPath != null
        ? CustomIcon(
      assetPath: assetSvgPath!,
      size: iconSize.sp,
      color: iconColor ?? primary,
    )
        : Icon(
      iconData,
      color: iconColor ?? primary,
      size: iconSize.sp,
    );

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
                height: circleSize.w,
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
                child: iconWidget, // ← هنا بقى SVG عبر CustomIcon لو assetSvgPath موجود
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

              // زر الإجراء (اختياري)
              if (showButton) ...[
                SizedBox(height: 24.h),
                ConstrainedBox(
                  constraints: BoxConstraints(minWidth: 180.w),
                  child: ElevatedButton.icon(
                    onPressed: onPressed!,
                    icon: Icon(buttonIcon, color: ColorsManager.backgroundSurface),
                    label: Text(buttonText!),
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
            ],
          ),
        ),
      ),
    );
  }
}
