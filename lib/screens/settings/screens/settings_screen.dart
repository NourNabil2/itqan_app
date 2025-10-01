import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/providers/settings_provider.dart';
import 'package:itqan_gym/screens/settings/widgets/about_section.dart';
import 'package:itqan_gym/screens/settings/widgets/account_section.dart';
import 'package:itqan_gym/screens/settings/widgets/appearance_section.dart';
import 'package:itqan_gym/screens/settings/widgets/backup_section.dart';
import 'package:itqan_gym/screens/settings/widgets/premium_section.dart';
import 'package:provider/provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // Modern Header
            SliverToBoxAdapter(
              child: ModernSettingsHeader(
                isLoggedIn: settings.isLoggedIn,
                isPremium: settings.isPremium,
              ),
            ),

            // Settings Content
            SliverPadding(
              padding: EdgeInsets.all(16.w),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Account Section
                  AccountSection(
                    isLoggedIn: settings.isLoggedIn,
                    isPremium: settings.isPremium,
                  ),

                  SizedBox(height: 12.h),

                  // Appearance Section
                  AppearanceSection(
                    currentTheme: settings.themeMode,
                    currentLanguage: settings.languageCode,
                  ),

                  SizedBox(height: 12.h),

                  // Notifications Section
                  NotificationsSection(
                    enabled: settings.notificationsEnabled,
                  ),

                  SizedBox(height: 12.h),

                  // Backup Section
                  BackupSection(
                    autoBackupEnabled: settings.autoBackupEnabled,
                    isPremium: settings.isPremium,
                  ),

                  SizedBox(height: 12.h),

                  // Premium Section
                  if (!settings.isPremium) ...[
                    const PremiumSection(),
                    SizedBox(height: 12.h),
                  ],

                  // About Section
                  const AboutSection(),

                  SizedBox(height: 32.h),
                ]),
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============= Modern Settings Header =============
class ModernSettingsHeader extends StatelessWidget {
  final bool isLoggedIn;
  final bool isPremium;

  const ModernSettingsHeader({
    super.key,
    required this.isLoggedIn,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(bottom: 20.h),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 20.h,
        bottom: 30.h,
        left: 20.w,
        right: 20.w,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
            ColorsManager.primaryColor.withOpacity(0.3),
            ColorsManager.primaryColor.withOpacity(0.1),
          ]
              : [
            ColorsManager.primaryColor,
            ColorsManager.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(32.r),
          bottomRight: Radius.circular(32.r),
        ),
      ),
      child: Column(
        children: [
          // Avatar with glow effect
          Container(
            width: 90.w,
            height: 90.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.3),
                  Colors.white.withOpacity(0.1),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.white.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 80.w,
                height: 80.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                ),
                child: Icon(
                  isLoggedIn ? Icons.person : Icons.person_outline,
                  size: 40.sp,
                  color: Colors.white,
                ),
              ),
            ),
          ),

          SizedBox(height: 16.h),

          // Welcome Text
          Text(
            isLoggedIn ? l10n.welcomeBack : l10n.settings,
            style: TextStyle(
              color: Colors.white,
              fontSize: 24.sp,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.5,
            ),
          ),

          if (isLoggedIn) ...[
            SizedBox(height: 8.h),
            // Membership Badge
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 8.h,
              ),
              decoration: BoxDecoration(
                color: isPremium
                    ? Colors.amber.withOpacity(0.25)
                    : Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(24.r),
                border: Border.all(
                  color: isPremium
                      ? Colors.amber.withOpacity(0.4)
                      : Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isPremium ? Colors.amber : Colors.white)
                        .withOpacity(0.2),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (isPremium)
                    Icon(
                      Icons.workspace_premium,
                      size: 18.sp,
                      color: Colors.amber,
                    ),
                  if (isPremium) SizedBox(width: 6.w),
                  Text(
                    isPremium ? l10n.premiumMember : l10n.basicMember,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ============= Notifications Section =============
class NotificationsSection extends StatelessWidget {
  final bool enabled;

  const NotificationsSection({
    super.key,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final settings = Provider.of<SettingsProvider>(context, listen: false);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  color: ColorsManager.primaryColor,
                  size: 24.sp,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.notifications,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      l10n.notificationsDescription,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: theme.textTheme.bodySmall?.color,
                      ),
                    ),
                  ],
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Switch(
                  value: enabled,
                  onChanged: (value) {
                    HapticFeedback.lightImpact();
                    settings.toggleNotifications(value);
                  },
                  activeColor: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}