import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
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
    final l10n = AppLocalizations.of(context);

    return SettingsCard(
      title: l10n.account,
      icon: Icons.person_outline,
      children: [
        if (!isLoggedIn)
          SettingsTile(
            icon: Icons.login,
            title: l10n.loginTitle,
            subtitle: l10n.loginDescription,
            onTap: () => _handleLogin(context),
          )
        else ...[
          SettingsTile(
            icon: Icons.person,
            title: l10n.profileTitle,
            subtitle: l10n.profileDescription,
            onTap: () => _handleProfile(context),
          ),
          SettingsTile(
            icon: Icons.logout,
            title: l10n.logoutTitle,
            subtitle: l10n.logoutDescription,
            onTap: () => _handleLogout(context),
            iconColor: ColorsManager.errorFill,
          ),
        ],
      ],
    );
  }

  void _handleLogin(BuildContext context) {
    HapticFeedback.lightImpact();
    // Navigate to login screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => LoginScreen()));
  }

  void _handleProfile(BuildContext context) {
    HapticFeedback.lightImpact();
    // Navigate to profile screen
    // Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen()));
  }

  void _handleLogout(BuildContext context) {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        title: Text(
          l10n.logoutConfirmTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.logoutConfirmMessage,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            style: TextButton.styleFrom(
              foregroundColor: theme.textTheme.bodyLarge?.color,
            ),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              context.read<SettingsProvider>().setLoggedIn(false);
              Navigator.pop(dialogContext);
            },
            style: TextButton.styleFrom(
              foregroundColor: ColorsManager.errorFill,
            ),
            child: Text(
              l10n.logoutTitle,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}