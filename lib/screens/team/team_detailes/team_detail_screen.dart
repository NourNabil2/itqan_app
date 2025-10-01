import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:itqan_gym/screens/team/manage_assignments_screen.dart';
import 'package:itqan_gym/screens/team/widgets/exercise_detail_sheet.dart';
import 'package:itqan_gym/screens/team/widgets/skill_detail_sheet.dart';
import 'package:itqan_gym/screens/team/widgets/team_members_manager.dart';
import 'package:provider/provider.dart';
import '../../../data/models/team.dart';
import '../../../providers/team_provider.dart';

class TeamDetailScreen extends StatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeamData();
  }

  void _loadTeamData() {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    teamProvider.selectTeam(widget.team);
    teamProvider.loadTeamContent(widget.team.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: widget.team.name,
      ),
      body: Column(
        children: [
          _buildTeamInfoHeader(),

          // Tab Bar
          Container(
            color: theme.cardColor,
            child: TabBar(
              controller: _tabController,
              labelColor: theme.primaryColor,
              unselectedLabelColor: theme.textTheme.bodySmall?.color,
              indicatorColor: theme.primaryColor,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: [
                Tab(text: l10n.members),
                Tab(text: l10n.content),
                Tab(text: l10n.progress),
              ],
            ),
          ),

          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMembersTab(),
                _buildContentTab(),
                _buildProgressTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamInfoHeader() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        return Container(
          color: theme.cardColor,
          child: SectionHeader(
            title: widget.team.name,
            subtitle: '${widget.team.ageCategory.getLocalizedName(context)} • ${l10n.memberCount(teamProvider.totalMembers)}',
            leading: Container(
              padding: EdgeInsets.all(SizeApp.s10),
              decoration: BoxDecoration(
                color: theme.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeApp.s10),
              ),
              child: Icon(
                Icons.groups_rounded,
                color: theme.primaryColor,
                size: SizeApp.iconSize,
              ),
            ),
            trailing: _buildQuickStatsChips(),
            padding: EdgeInsets.all(SizeApp.s16),
            showDivider: true,
          ),
        );
      },
    );
  }

  Widget _buildQuickStatsChips() {
    final l10n = AppLocalizations.of(context);

    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatChip(
              '${teamProvider.totalExercises}',
              l10n.exercisesAndSkillsLibrary,
              ColorsManager.secondaryColor,
            ),
            SizedBox(width: SizeApp.s4),
            _buildStatChip(
              '${teamProvider.totalSkills}',
              l10n.skills,
              ColorsManager.primaryColor,
            ),
          ],
        );
      },
    );
  }

  Widget _buildStatChip(String count, String label, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s8,
        vertical: SizeApp.s4,
      ),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(width: SizeApp.s2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return TeamMembersManager(team: widget.team);
  }

  Widget _buildContentTab() {
    final l10n = AppLocalizations.of(context);

    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final exercises = teamProvider.teamExercises;
        final skills = teamProvider.teamSkills;

        if (teamProvider.isLoading) {
          return _buildLoadingState();
        }

        if (exercises.isEmpty && skills.isEmpty) {
          return _buildEmptyContentState();
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(SizeApp.s16),
          child: Column(
            children: [
              _buildManageAssignmentsButton(),
              SizedBox(height: SizeApp.s20),

              if (exercises.isNotEmpty) ...[
                _buildContentSection(
                  title: l10n.assignedExercises,
                  icon: Icons.fitness_center_rounded,
                  color: ColorsManager.secondaryColor,
                  children: _buildExercisesList(exercises),
                ),
                SizedBox(height: SizeApp.s20),
              ],

              if (skills.isNotEmpty) ...[
                _buildContentSection(
                  title: l10n.assignedSkills,
                  icon: Icons.star_rounded,
                  color: ColorsManager.primaryColor,
                  children: _buildSkillsList(skills),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(theme.primaryColor),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            l10n.loadingData,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContentState() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeApp.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeApp.s20),
              decoration: BoxDecoration(
                color: theme.iconTheme.color?.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64.sp,
                color: theme.iconTheme.color?.withOpacity(0.6),
              ),
            ),
            SizedBox(height: SizeApp.s20),
            Text(
              l10n.noContentAssigned,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              l10n.startAssigningContent,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                height: 1.4,
              ),
            ),
            SizedBox(height: SizeApp.s32),
            _buildManageAssignmentsButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildManageAssignmentsButton() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToManageAssignments(),
        icon: Icon(Icons.assignment_rounded, size: SizeApp.iconSize),
        label: Text(l10n.manageAssignments),
        style: ElevatedButton.styleFrom(
          backgroundColor: theme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          ),
          elevation: 2,
        ),
      ),
    );
  }

  Widget _buildContentSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SizeApp.radiusSmall),
                topRight: Radius.circular(SizeApp.radiusSmall),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color, size: SizeApp.iconSize),
                SizedBox(width: SizeApp.s8),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(SizeApp.s16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExercisesList(List exercises) {
    final theme = Theme.of(context);

    return exercises.map<Widget>((exercise) {
      return InkWell(
        onTap: () => ExerciseDetailSheet.show(
          context,
          exercise,
          teamId: widget.team.id,
        ),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: Container(
          margin: EdgeInsets.only(bottom: SizeApp.s8),
          padding: EdgeInsets.all(SizeApp.s12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: _getExerciseColor(exercise.type).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                ),
                child: Icon(
                  _getExerciseIcon(exercise.type),
                  color: _getExerciseColor(exercise.type),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      exercise.title,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (exercise.description != null) ...[
                      SizedBox(height: SizeApp.s2),
                      Text(
                        exercise.description!,
                        style: theme.textTheme.bodySmall,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: theme.iconTheme.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSkillsList(List skills) {
    final theme = Theme.of(context);

    return skills.map<Widget>((skill) {
      return InkWell(
        onTap: () => SkillDetailSheet.show(context, skill, widget.team.id),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: Container(
          margin: EdgeInsets.only(bottom: SizeApp.s8),
          padding: EdgeInsets.all(SizeApp.s12),
          decoration: BoxDecoration(
            color: theme.scaffoldBackgroundColor,
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.3),
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: getApparatusColor(skill.apparatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                ),
                child: Icon(
                  getApparatusIcon(skill.apparatus),
                  color: getApparatusColor(skill.apparatus),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.skillName,
                      style: theme.textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: SizeApp.s2),
                    Text(
                      skill.apparatus.getLocalizedName(context),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: theme.iconTheme.color?.withOpacity(0.5),
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildProgressTab() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s20),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timeline_rounded,
              size: 64.sp,
              color: theme.primaryColor,
            ),
          ),
          SizedBox(height: SizeApp.s20),
          Text(
            l10n.comingSoonProgressTracking,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            l10n.featureComingSoon,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.directions_run_rounded;
      case ExerciseType.stretching:
        return Icons.self_improvement_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }

  Color _getExerciseColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
    }
  }

  void _navigateToManageAssignments() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ManageAssignmentsScreen(team: widget.team),
      ),
    ).then((_) => _loadTeamData());
  }
}