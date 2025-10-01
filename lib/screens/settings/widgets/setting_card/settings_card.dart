import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:provider/provider.dart';

// Settings Card Container
class SettingsCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;
  final bool isPremiumFeature;

  const SettingsCard({
    super.key,
    required this.title,
    required this.icon,
    required this.children,
    this.isPremiumFeature = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.padding),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.all(SizeApp.s16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(SizeApp.padding /2 ),
                  decoration: BoxDecoration(
                    color: ColorsManager.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                  ),
                  child: Icon(
                    icon,
                    color: ColorsManager.primaryColor,
                    size: 20.sp,
                  ),
                ),
                SizedBox(width: SizeApp.s12),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isPremiumFeature)
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.star,
                          size: 14.sp,
                          color: Colors.amber,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'مميز',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.amber[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1),
          ...children,
        ],
      ),
    );
  }
}
