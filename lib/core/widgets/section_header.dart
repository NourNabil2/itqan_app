import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final Widget? leading;
  final Color? titleColor;
  final Color? subtitleColor;
  final double? titleSize;
  final double? subtitleSize;
  final FontWeight? titleWeight;
  final EdgeInsetsGeometry? padding;
  final bool showDivider;
  final Color? dividerColor;
  final VoidCallback? onTap;

  const SectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
    this.leading,
    this.titleColor,
    this.subtitleColor,
    this.titleSize,
    this.subtitleSize,
    this.titleWeight,
    this.padding,
    this.showDivider = false,
    this.dividerColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Widget content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: padding ?? EdgeInsets.symmetric(horizontal: SizeApp.padding),
          child: Row(
            children: [
              // Leading widget (optional)
              if (leading != null) ...[
                leading!,
                SizedBox(width: SizeApp.s12),
              ],

              // Title and subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontSize: titleSize ?? 18.sp,
                        fontWeight: titleWeight ?? FontWeight.w700,
                        color: titleColor ?? ColorsManager.defaultText,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: 2.h),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: subtitleSize ?? 13.sp,
                          color: subtitleColor ?? ColorsManager.defaultTextSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              // Trailing widget (optional)
              if (trailing != null) trailing!,
            ],
          ),
        ),

        // Optional divider
        if (showDivider) ...[
          SizedBox(height: SizeApp.s12),
          Divider(
            color: dividerColor ?? ColorsManager.inputBorder.withOpacity(0.3),
            height: 1,
            thickness: 1,
          ),
        ],
      ],
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        child: content,
      );
    }

    return content;
  }
}
