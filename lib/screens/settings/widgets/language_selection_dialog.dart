import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:itqan_gym/screens/settings/widgets/setting_card/settings_toggle.dart';
import 'package:provider/provider.dart';

import 'setting_card/settings_card.dart';

class LanguageSelectionDialog extends StatelessWidget {
  final String currentLanguage;

  const LanguageSelectionDialog({
    super.key,
    required this.currentLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.language, color: ColorsManager.primaryColor),
          SizedBox(width: SizeApp.s8),
          const Text('اختر اللغة'),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildLanguageOption(
            context: context,
            code: 'ar',
            title: 'العربية',
            flag: '🇸🇦',
          ),
          SizedBox(height: SizeApp.s8),
          _buildLanguageOption(
            context: context,
            code: 'en',
            title: 'English',
            flag: '🇺🇸',
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption({
    required BuildContext context,
    required String code,
    required String title,
    required String flag,
  }) {
    final isSelected = currentLanguage == code;

    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        context.read<SettingsProvider>().setLanguage(code);
        Navigator.pop(context);
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.all(16.w),
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
            Text(flag, style: TextStyle(fontSize: 24.sp)),
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
// ============= 8. Notifications Section ============= //todo:: remove this
class NotificationsSection extends StatelessWidget {
  final bool enabled;

  const NotificationsSection({
    super.key,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'الإشعارات',
      icon: Icons.notifications_outlined,
      children: [
        SettingsToggle(
          icon: Icons.notifications_active,
          title: 'الإشعارات',
          subtitle: 'تلقي إشعارات التطبيق',
          value: enabled,
          onChanged: (value) {
            context.read<SettingsProvider>().toggleNotifications(value);
          },
        ),
      ],
    );
  }
}
