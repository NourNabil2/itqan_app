import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class ThemeSelectionDialog extends StatelessWidget {
  final ThemeMode currentTheme;

  const ThemeSelectionDialog({
    super.key,
    required this.currentTheme,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.palette_outlined, color: ColorsManager.primaryColor),
          SizedBox(width: SizeApp.s8),
          const Text('اختر المظهر'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            mode: ThemeMode.light,
            title: 'فاتح',
            icon: Icons.light_mode,
          ),
          _buildThemeOption(
            context: context,
            mode: ThemeMode.dark,
            title: 'داكن',
            icon: Icons.dark_mode,
          ),
          _buildThemeOption(
            context: context,
            mode: ThemeMode.system,
            title: 'حسب النظام',
            icon: Icons.settings_suggest,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeOption({
    required BuildContext context,
    required ThemeMode mode,
    required String title,
    required IconData icon,
  }) {
    final isSelected = currentTheme == mode;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<SettingsProvider>().setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : Colors.grey.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? ColorsManager.primaryColor
                  : Colors.grey,
            ),
            SizedBox(width: SizeApp.s12),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected
                      ? ColorsManager.primaryColor
                      : null,
                ),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle,
                color: ColorsManager.primaryColor,
                size: 20.sp,
              ),
          ],
        ),
      ),
    );
  }
}
