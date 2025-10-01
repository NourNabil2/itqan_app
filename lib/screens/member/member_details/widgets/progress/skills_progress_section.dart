import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';

class SkillsProgressSection extends StatelessWidget {
  final List<AssignedSkill> skills;
  final VoidCallback onViewAll;
  final int maxVisible;

  const SkillsProgressSection({
    super.key,
    required this.skills,
    required this.onViewAll,
    this.maxVisible = 3,
  });

  @override
  Widget build(BuildContext context) {
    if (skills.isEmpty) return const SizedBox.shrink();

    final visibleSkills = skills.take(maxVisible).toList();

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeApp.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ...visibleSkills.map((skill) => _buildSkillCard(context, skill)),
          if (skills.length > maxVisible) _buildViewAllButton(context),
        ],
      ),
    );
  }

  Widget _buildSkillCard(BuildContext context, AssignedSkill skill) {
    final theme = Theme.of(context);

    if (skill.skill == null) return const SizedBox.shrink();

    final apparatusColor = getApparatusColor(skill.skill!.apparatus);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: apparatusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  getApparatusIcon(skill.skill!.apparatus),
                  color: apparatusColor,
                  size: 20.sp,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.skill!.skillName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      skill.skill!.apparatus.getLocalizedName(context),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: SizeApp.s8),
              _buildProgressBadge(skill, apparatusColor),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          _buildProgressBar(context, skill, apparatusColor),
        ],
      ),
    );
  }

  Widget _buildProgressBadge(AssignedSkill skill, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        '${skill.progress.toInt()}%',
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Widget _buildProgressBar(BuildContext context, AssignedSkill skill, Color color) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.progress,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.6),
              ),
            ),
            Text(
              _getStatusText(context, skill),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
                color: _getStatusColor(skill),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: skill.progress / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation(color),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }

  Widget _buildViewAllButton(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.only(top: 8.h),
      child: InkWell(
        onTap: onViewAll,
        borderRadius: BorderRadius.circular(8.r),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                l10n.viewAllSkills(skills.length),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.primaryColor,
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.arrow_back_ios_rounded,
                size: 14.sp,
                color: ColorsManager.primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getStatusText(BuildContext context, AssignedSkill skill) {
    final l10n = AppLocalizations.of(context);

    if (skill.isCompleted) return l10n.completed;
    if (skill.isInProgress) return l10n.inProgress;
    return l10n.notStarted;
  }

  Color _getStatusColor(AssignedSkill skill) {
    if (skill.isCompleted) return ColorsManager.successFill;
    if (skill.isInProgress) return ColorsManager.warningFill;
    return ColorsManager.defaultTextSecondary;
  }
}