// lib/core/widgets/premium_lock_widget.dart
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/screens/settings/widgets/premium_dialog.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PremiumFeature extends StatelessWidget {
  final Widget child;
  final String? lockTitle;
  final String? lockDescription;
  final IconData? lockIcon;
  final double? lockHeight;
  final double blurIntensity;
  final bool showPreview;

  const PremiumFeature({
    super.key,
    required this.child,
    this.lockTitle,
    this.lockDescription,
    this.lockIcon,
    this.lockHeight,
    this.blurIntensity = 8.0,
    this.showPreview = true,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        if (auth.isPremium) {
          return child;
        }

        return _PremiumOverlay(
          height: lockHeight,
          title: lockTitle,
          description: lockDescription,
          icon: lockIcon ?? Icons.lock_rounded,
          blurIntensity: blurIntensity,
          showPreview: showPreview,
          child: child,
        );
      },
    );
  }
}

class _PremiumOverlay extends StatelessWidget {
  final Widget child;
  final double? height;
  final String? title;
  final String? description;
  final IconData icon;
  final double blurIntensity;
  final bool showPreview;

  const _PremiumOverlay({
    required this.child,
    this.height,
    this.title,
    this.description,
    required this.icon,
    required this.blurIntensity,
    required this.showPreview,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return ClipRRect(
      borderRadius: BorderRadius.circular(12.r),
      child: Stack(
        children: [
          // Original content
          if (showPreview)
            IgnorePointer(
              child: Opacity(
                opacity: isDark ? 0.4 : 0.5,
                child: child,
              ),
            )
          else
            Container(
              height: height ?? 200.h,
              color: colorScheme.surfaceContainerHighest,
              child: Center(
                child: Icon(
                  icon,
                  size: 60.sp,
                  color: colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
              ),
            ),

          // Blur effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(
                sigmaX: blurIntensity,
                sigmaY: blurIntensity,
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: isDark
                        ? [
                      Colors.black.withOpacity(0.4),
                      Colors.black.withOpacity(0.6),
                    ]
                        : [
                      Colors.white.withOpacity(0.3),
                      Colors.white.withOpacity(0.5),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Lock content
          Positioned.fill(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(SizeApp.padding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Lock icon with glow
                    Container(
                      padding: EdgeInsets.all(16.w),
                      decoration: BoxDecoration(
                        color: colorScheme.surface,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF8A00).withOpacity(0.4),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        icon,
                        size: 32.sp,
                        color: const Color(0xFFFF8A00),
                      ),
                    ),

                    SizedBox(height: 16.h),

                    // Title
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      child: Text(
                        title ?? l10n.premiumFeature,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: isDark ? Colors.white : const Color(0xFFFF8A00),
                          fontSize: 18.sp,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 8.h),

                    // Description
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 32.w),
                      child: Text(
                        description ?? l10n.availableForPremium,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? Colors.grey.shade300
                              : colorScheme.onSurfaceVariant,
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    SizedBox(height: 20.h),

                    // Upgrade button
                    FilledButton.icon(
                      onPressed: () => PremiumDialog.show(context),
                      icon: Icon(Icons.workspace_premium, size: 18.sp),
                      label: Text(
                        l10n.upgradeNow,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFFF8A00),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: 28.w,
                          vertical: 12.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFFF8A00).withOpacity(0.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}