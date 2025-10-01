import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return AlertDialog(
      backgroundColor: theme.dialogBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Row(
        children: [
          Icon(
            Icons.palette_outlined,
            color: ColorsManager.primaryColor,
          ),
          SizedBox(width: SizeApp.s8),
          Text(l10n.selectTheme),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildThemeOption(
            context: context,
            mode: ThemeMode.light,
            title: l10n.lightMode,
            icon: Icons.light_mode,
          ),
          _buildThemeOption(
            context: context,
            mode: ThemeMode.dark,
            title: l10n.darkMode,
            icon: Icons.dark_mode,
          ),
          _buildThemeOption(
            context: context,
            mode: ThemeMode.system,
            title: l10n.systemMode,
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
    final theme = Theme.of(context);
    final isSelected = currentTheme == mode;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<SettingsProvider>().setThemeMode(mode);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        margin: EdgeInsets.only(bottom: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : theme.dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? ColorsManager.primaryColor : theme.iconTheme.color,
            ),
            SizedBox(width: SizeApp.s12),
            Expanded(
              child: Text(
                title,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  color: isSelected ? ColorsManager.primaryColor : null,
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