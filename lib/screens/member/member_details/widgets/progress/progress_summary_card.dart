import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';

/// Progress Summary Card - ملخص التقدم
class ProgressSummaryCard extends StatelessWidget {
  final Member member;
  final String subtitle;

  const ProgressSummaryCard({
    super.key,
    required this.member,
    this.subtitle = 'تحسن بنسبة 12% خلال الشهر الماضي',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            ColorsManager.primaryColor.withOpacity(0.08),
            ColorsManager.primaryColor.withOpacity(0.04),
          ],
        ),
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: ColorsManager.primaryColor.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          _buildProgressIndicator(),
          SizedBox(width: SizeApp.s16),
          _buildProgressInfo(),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return SizedBox(
      width: 50.w,
      height: 50.h,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 50.w,
            height: 50.h,
            child: CircularProgressIndicator(
              value: (member.overallProgress ?? 0) / 100,
              strokeWidth: 4,
              backgroundColor: ColorsManager.primaryColor.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation<Color>(
                ColorsManager.primaryColor,
              ),
              strokeCap: StrokeCap.round,
            ),
          ),
          Text(
            '${(member.overallProgress ?? 0).toInt()}%',
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: ColorsManager.primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressInfo() {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'التقدم الإجمالي',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsManager.successText,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}