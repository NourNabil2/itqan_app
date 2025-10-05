// ============= Custom Header Widgets - مكونات العناوين المخصصة =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

///  Step Header - عنوان الخطوة الرئيسي
class StepHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? icon;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? titleSize;
  final double? subtitleSize;
  final FontWeight? titleWeight;
  final FontWeight? subtitleWeight;
  final EdgeInsetsGeometry? padding;
  final CrossAxisAlignment? alignment;

  const StepHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.titleColor,
    this.subtitleColor,
    this.titleSize,
    this.subtitleSize,
    this.titleWeight,
    this.subtitleWeight,
    this.padding,
    this.alignment,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding ?? EdgeInsets.all(SizeApp.s16),
      child: Column(
        crossAxisAlignment: alignment ?? CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title Row with optional icon
          if (icon != null)
            Row(
              children: [
                icon!,
                SizedBox(width: SizeApp.s8),
                Expanded(child: _buildTitle(context)),
              ],
            )
          else
            _buildTitle(context),

          // Subtitle if provided
          if (subtitle != null) ...[
            SizedBox(height: SizeApp.s8),
            Text(
              subtitle!,
              style: TextStyle(
                fontSize: subtitleSize ?? 14.sp,
                fontWeight: subtitleWeight ?? FontWeight.w400,
                color: subtitleColor ?? ColorsManager.defaultTextSecondary,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTitle(context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge
    );
  }
}


