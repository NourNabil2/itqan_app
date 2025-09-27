// ============= Member Header Widget - هيدر العضو =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/progress_summary_card.dart' show ProgressSummaryCard;
import 'package:itqan_gym/screens/member/member_notes_actions.dart';

/// ✅ Member Header Widget - كامل هيدر العضو
class MemberHeaderWidget extends StatelessWidget {
  final Member member;
  final String? subtitle;
  final VoidCallback? onAvatarTap;
  final bool showProgressSummary;

  const MemberHeaderWidget({
    super.key,
    required this.member,
    this.subtitle,
    this.onAvatarTap,
    this.showProgressSummary = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(SizeApp.s20),
      child: Column(
        children: [
          Row(
            children: [
              // ✅ صورة العضو
              MemberAvatar(
                member: member,
                onTap: onAvatarTap,
              ),

              SizedBox(width: SizeApp.s16),

              // ✅ معلومات العضو
              Expanded(
                child: MemberInfoSection(member: member),
              ),
            ],
          ),

          if (showProgressSummary) ...[
            SizedBox(height: SizeApp.s16),
            // ✅ ملخص التقدم
            ProgressSummaryCard(
              member: member,
              subtitle: subtitle ?? 'تحسن بنسبة 12% خلال الشهر الماضي',
            ),
          ],
        ],
      ),
    );
  }
}

/// ✅ Member Avatar - صورة العضو
class MemberAvatar extends StatelessWidget {
  final Member member;
  final VoidCallback? onTap;
  final double size;

  const MemberAvatar({
    super.key,
    required this.member,
    this.onTap,
    this.size = 80,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Hero(
        tag: 'member_avatar_${member.id}',
        child: Container(
          width: size.w,
          height: size.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
            gradient: member.photoPath == null
                ? LinearGradient(
              colors: [
                ColorsManager.secondaryColor,
                ColorsManager.secondaryColor.withOpacity(0.8),
              ],
            )
                : null,
            image: member.photoPath != null
                ? DecorationImage(
              image: FileImage(File(member.photoPath!)),
              fit: BoxFit.cover,
            )
                : null,
            boxShadow: [
              BoxShadow(
                color: ColorsManager.secondaryColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: member.photoPath == null
              ? Center(
            child: Text(
              member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
              style: TextStyle(
                fontSize: (size * 0.4).sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          )
              : null,
        ),
      ),
    );
  }
}

/// ✅ Member Info Section - قسم معلومات العضو
class MemberInfoSection extends StatelessWidget {
  final Member member;

  const MemberInfoSection({
    super.key,
    required this.member,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ اسم العضو
        Text(
          member.name,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.w700,
            color: ColorsManager.defaultText,
            height: 1.2,
          ),
        ),

        SizedBox(height: 6.h),

        // ✅ شارات المعلومات
        Row(
          children: [
            if (member.age != null)
              MemberInfoBadge(
                icon: Icons.cake_outlined,
                text: '${member.age} سنة',
                color: ColorsManager.infoText,
                backgroundColor: ColorsManager.infoSurface,
              ),

            if (member.age != null) SizedBox(width: SizeApp.s8),

            MemberInfoBadge(
              text: member.level,
              color: MemberUtils.getLevelColor(member.level),
              backgroundColor: MemberUtils.getLevelColor(member.level).withOpacity(0.15),
            ),
          ],
        ),
      ],
    );
  }
}

/// ✅ Member Info Badge - شارة معلومات العضو
class MemberInfoBadge extends StatelessWidget {
  final IconData? icon;
  final String text;
  final Color color;
  final Color backgroundColor;

  const MemberInfoBadge({
    super.key,
    this.icon,
    required this.text,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s8,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 14.sp,
              color: color,
            ),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
