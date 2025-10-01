import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'setting_card/settings_card.dart';
import 'setting_card/settings_tile.dart';

class AccountSection extends StatelessWidget {
  final bool isLoggedIn;
  final bool isPremium;

  const AccountSection({
    super.key,
    required this.isLoggedIn,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    return SettingsCard(
      title: 'الحساب',
      icon: Icons.person_outline,
      children: [
        if (!isLoggedIn)
          SettingsTile(
            icon: Icons.login,
            title: 'تسجيل الدخول',
            subtitle: 'قم بتسجيل الدخول للوصول لجميع المميزات',
            onTap: () => _handleLogin(context),
          )
        else ...[
          SettingsTile(
            icon: Icons.person,
            title: 'الملف الشخصي',
            subtitle: 'عرض وتعديل معلوماتك',
            onTap: () {},
          ),
          SettingsTile(
            icon: Icons.logout,
            title: 'تسجيل الخروج',
            subtitle: 'الخروج من حسابك',
            onTap: () => _handleLogout(context),
            iconColor: ColorsManager.errorFill,
          ),
        ],
      ],
    );
  }

  void _handleLogin(BuildContext context) {
    // Navigate to login screen
    HapticFeedback.lightImpact();
    // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  void _handleLogout(BuildContext context) {
    HapticFeedback.lightImpact();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تسجيل الخروج'),
        content: const Text('هل تريد تسجيل الخروج من حسابك؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsProvider>().setLoggedIn(false);
              Navigator.pop(context);
            },
            child: const Text(
              'خروج',
              style: TextStyle(color: ColorsManager.errorFill),
            ),
          ),
        ],
      ),
    );
  }
}
