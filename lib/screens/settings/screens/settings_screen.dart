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
    final theme = Theme.of(context);

    return Consumer<SettingsProvider>(
      builder: (context, settings, _) {
        return Scaffold(
          backgroundColor: theme.scaffoldBackgroundColor,
          body: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Simple App Bar
              SliverAppBar(
                floating: true,
                snap: true,
                backgroundColor: theme.scaffoldBackgroundColor,
                elevation: 0,
                title: Text(
                  l10n.settings,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                actions: [
                  if (settings.isPremium)
                    Padding(
                      padding: EdgeInsets.only(right: 16.w),
                      child: Center(
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 12.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.amber.shade600,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.workspace_premium,
                                size: 16.sp,
                                color: Colors.white,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                l10n.premiumMember,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),

              // Settings Content
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    // User Info Card (if logged in)
                    if (settings.isLoggedIn)
                      _buildUserInfoCard(context, settings.isPremium),

                    if (settings.isLoggedIn)
                      SizedBox(height: 16.h),

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
          ),
        );
      },
    );
  }

  Widget _buildUserInfoCard(BuildContext context, bool isPremium) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: theme.dividerColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: ColorsManager.primaryColor.withOpacity(0.1),
            ),
            child: Icon(
              Icons.person,
              size: 28.sp,
              color: ColorsManager.primaryColor,
            ),
          ),

          SizedBox(width: 16.w),

          // User Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.welcomeBack,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  isPremium ? l10n.premiumMember : l10n.basicMember,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isPremium
                        ? Colors.amber.shade700
                        : theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),

          // Premium Badge Icon
          if (isPremium)
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                Icons.workspace_premium,
                size: 24.sp,
                color: Colors.amber.shade700,
              ),
            ),
        ],
      ),
    );
  }
}

