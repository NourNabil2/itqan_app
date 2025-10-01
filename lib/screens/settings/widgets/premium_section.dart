import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

class PremiumSection extends StatelessWidget {
  const PremiumSection({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFB800),
            Color(0xFFFF8A00),
            Color(0xFFFF6B00),
          ],
        ),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),

          // Main content
          Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              children: [
                // Premium badge
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    l10n.premiumBadge,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),

                SizedBox(height: SizeApp.s16),

                // Premium icon
                Container(
                  padding: EdgeInsets.all(16.w),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withOpacity(0.2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.workspace_premium,
                    color: Colors.white,
                    size: 48.sp,
                  ),
                ),

                SizedBox(height: SizeApp.s20),

                // Title
                Text(
                  l10n.premiumTitle,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: SizeApp.s8),

                // Subtitle
                Text(
                  l10n.premiumSubtitle,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),

                SizedBox(height: SizeApp.s24),

                // Features
                Container(
                  padding: EdgeInsets.all(20.w),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      _buildModernFeature(
                        icon: Icons.block,
                        text: l10n.removeAds,
                      ),
                      SizedBox(height: 12.h),
                      _buildModernFeature(
                        icon: Icons.cloud_upload_outlined,
                        text: l10n.cloudBackup,
                      ),
                      SizedBox(height: 12.h),
                      _buildModernFeature(
                        icon: Icons.sync,
                        text: l10n.syncDevices,
                      ),
                      SizedBox(height: 12.h),
                      _buildModernFeature(
                        icon: Icons.support_agent,
                        text: l10n.premiumSupport,
                      ),
                    ],
                  ),
                ),

                SizedBox(height: SizeApp.s24),

                // CTA button
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    gradient: LinearGradient(
                      colors: [
                        Colors.white,
                        Colors.white.withOpacity(0.95),
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _showPremiumDialog(context),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              l10n.subscribeNow,
                              style: TextStyle(
                                color: Color(0xFFFF8A00),
                                fontWeight: FontWeight.w800,
                                fontSize: 17.sp,
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.arrow_forward,
                              color: Color(0xFFFF8A00),
                              size: 20.sp,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),

                SizedBox(height: SizeApp.s12),

                // Disclaimer
                Text(
                  l10n.cancelAnytime,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernFeature({
    required IconData icon,
    required String text,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.25),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15.sp,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.4,
            ),
          ),
        ),
        Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 22.sp,
        ),
      ],
    );
  }

  void _showPremiumDialog(BuildContext context) {
    HapticFeedback.mediumImpact();
    // Show premium subscription dialog
  }
}