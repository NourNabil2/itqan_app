// ============= Member Header Widget - Simple UI =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/screens/member/member_notes_actions.dart';
import 'package:provider/provider.dart';

class MemberHeaderWidget extends StatefulWidget {
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
  State<MemberHeaderWidget> createState() => _MemberHeaderWidgetState();
}

class _MemberHeaderWidgetState extends State<MemberHeaderWidget> {
  double _skillsProgress = 0;
  double _exercisesProgress = 0;
  bool _isLoadingProgress = false;

  @override
  void initState() {
    super.initState();
    if (widget.showProgressSummary) {
      _loadProgress();
    }
  }

  Future<void> _loadProgress() async {
    setState(() => _isLoadingProgress = true);

    try {
      final provider = context.read<ExerciseAssignmentProvider>();
      final results = await Future.wait([
        provider.loadMemberSkills(widget.member.id),
        provider.loadMemberExercises(widget.member.id),
      ]);

      if (mounted) {
        final skills = results[0] as List<AssignedSkill>;
        final exercises = results[1] as List<AssignedExercise>;

        setState(() {
          _skillsProgress = _calculateProgress(skills.map((s) => s.progress).toList());
          _exercisesProgress = _calculateProgress(exercises.map((e) => e.progress).toList());
          _isLoadingProgress = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingProgress = false);
      }
    }
  }

  double _calculateProgress(List<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(SizeApp.s20),
      child: Column(
        children: [
          Row(
            children: [
              MemberAvatar(
                member: widget.member,
                onTap: widget.onAvatarTap,
              ),
              SizedBox(width: SizeApp.s16),
              Expanded(
                child: MemberInfoSection(member: widget.member),
              ),
            ],
          ),
          if (widget.showProgressSummary) ...[
            SizedBox(height: SizeApp.s16),
            _isLoadingProgress
                ? SizedBox(
              height: 80.h,
              child: Center(
                child: SizedBox(
                  width: 20.w,
                  height: 20.h,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
              ),
            )
                : ProgressSummaryCard(
              member: widget.member.copyWith(
                overallProgress: (_skillsProgress + _exercisesProgress) / 2,
              ),
              subtitle: widget.subtitle ?? _generateSubtitle(),
            ),
          ],
        ],
      ),
    );
  }

  String _generateSubtitle() {
    final overall = (_skillsProgress + _exercisesProgress) / 2;
    if (overall >= 80) return 'أداء ممتاز! استمر في التقدم';
    if (overall >= 50) return 'تقدم جيد، واصل العمل';
    if (overall > 0) return 'بداية جيدة، استمر!';
    return 'ابدأ رحلة التدريب الآن';
  }
}

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
            Icon(icon, size: 14.sp, color: color),
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