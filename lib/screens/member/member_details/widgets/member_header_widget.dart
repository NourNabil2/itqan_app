// lib/screens/member/member_details/widgets/member_header_widget.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
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
    if (!mounted) return;

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

  String _generateSubtitle() {
    final l10n = AppLocalizations.of(context);
    final overall = (_skillsProgress + _exercisesProgress) / 2;

    if (overall >= 80) return l10n.excellentPerformance;
    if (overall >= 50) return l10n.goodProgress;
    if (overall > 0) return l10n.goodStart;
    return l10n.startTrainingJourney;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(SizeApp.padding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
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
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Theme.of(context).colorScheme.primary,
                  ),
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: size.w,
      height: size.h,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        gradient: member.photoPath == null
            ? LinearGradient(
          colors: [
            colorScheme.secondaryContainer,
            colorScheme.secondaryContainer.withOpacity(0.8),
          ],
        )
            : null,
        image: member.photoPath != null
            ? DecorationImage(
          image: FileImage(File(member.photoPath!)),
          fit: BoxFit.cover,
        )
            : null,
      ),
      child: member.photoPath == null
          ? Center(
        child: Text(
          member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
          style: TextStyle(
            fontSize: (size * 0.4).sp,
            fontWeight: FontWeight.w700,
            color: colorScheme.onSecondaryContainer,
          ),
        ),
      )
          : null,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          member.name,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: colorScheme.onSurface,
            fontSize: 20.sp,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            if (member.age != null)
              MemberInfoBadge(
                icon: Icons.cake_outlined,
                text: l10n.yearsOld(member.age!),
                color: colorScheme.tertiary,
                backgroundColor: colorScheme.tertiaryContainer,
              ),
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
        horizontal: 10.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8.r),
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

class ProgressSummaryCard extends StatelessWidget {
  final Member member;
  final String subtitle;

  const ProgressSummaryCard({
    super.key,
    required this.member,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            colorScheme.primaryContainer.withOpacity(0.3),
            colorScheme.primaryContainer.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: colorScheme.primary.withOpacity(0.15),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Progress Circle
          SizedBox(
            width: 50.w,
            height: 50.h,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: (member.overallProgress ?? 0) / 100,
                  strokeWidth: 4,
                  backgroundColor: colorScheme.primary.withOpacity(0.2),
                  color: colorScheme.primary,
                  strokeCap: StrokeCap.round,
                ),
                Text(
                  '${(member.overallProgress ?? 0).toInt()}%',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          SizedBox(width: SizeApp.s16),

          // Progress Info
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.overallProgress,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.tertiary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Helper class for member utilities
class MemberUtils {
  static Color getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return const Color(0xFF4CAF50);
      case 'intermediate':
      case 'متوسط':
        return const Color(0xFF2196F3);
      case 'advanced':
      case 'متقدم':
        return const Color(0xFFFF9800);
      case 'expert':
      case 'خبير':
        return const Color(0xFFF44336);
      default:
        return const Color(0xFF9E9E9E);
    }
  }
}