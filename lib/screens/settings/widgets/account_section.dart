// lib/screens/settings/widgets/account_section.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/providers/auth_provider.dart';
import 'package:itqan_gym/screens/settings/screens/login_screen.dart';
import 'package:itqan_gym/screens/settings/screens/payment_status_screen.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
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

  static const String kSupportEmail = 'nour60g@gmail.com';

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
            icon: Icons.receipt_long,
            title: l10n.paymentStatus,
            subtitle: l10n.viewPaymentRequests,
            onTap: () => _handlePaymentStatus(context),
          ),

          SettingsTile(
            icon: Icons.support_agent_outlined,
            title: l10n.support,
            subtitle: l10n.contactSupportForHelp,
            onTap: () => _handleSupport(context),
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
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const LoginScreen(returnToPremium: false),
      ),
    );
  }

  void _handlePaymentStatus(BuildContext context) {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PaymentStatusScreen(),
      ),
    );
  }

  void _handleSupport(BuildContext context) async {
    HapticFeedback.lightImpact();
    final l10n = AppLocalizations.of(context);

    final uri = Uri(
      scheme: 'mailto',
      path: kSupportEmail,
      query: 'subject=${Uri.encodeComponent(l10n.supportRequestSubject)}'
          '&body=${Uri.encodeComponent(l10n.supportRequestBody)}',
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.error),
              backgroundColor: ColorsManager.errorFill,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.error),
            backgroundColor: ColorsManager.errorFill,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
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
              final auth = context.read<AuthProvider>();
              auth.signOut();
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