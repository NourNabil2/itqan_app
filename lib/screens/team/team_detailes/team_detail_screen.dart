import 'dart:developer';
import 'dart:developer';
import 'dart:developer';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/full_screen_media_viewer.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:itqan_gym/core/widgets/video_player_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/team/manage_assignments_screen.dart';
import 'package:itqan_gym/screens/team/widgets/exercise_detail_sheet.dart';
import 'package:itqan_gym/screens/team/widgets/skill_detail_sheet.dart';
import 'package:itqan_gym/screens/team/widgets/team_members_manager.dart';
import 'package:provider/provider.dart';
import '../../../data/models/exercise_template.dart';
import '../../../data/models/skill_template.dart';
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
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: widget.team.name,
      ),
      body: Column(
        children: [
          // Team Info Header
          _buildTeamInfoHeader(),

          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: ColorsManager.primaryColor,
              unselectedLabelColor: ColorsManager.defaultTextSecondary,
              indicatorColor: ColorsManager.primaryColor,
              indicatorWeight: 3,
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'الأعضاء'),
                Tab(text: 'المحتوى'),
                Tab(text: 'التقدم'),
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
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        return Container(
          color: Colors.white,
          child: SectionHeader(
            title: widget.team.name,
            subtitle: '${widget.team.ageCategory.arabicName} • ${teamProvider.totalMembers} عضو',
            leading: Container(
              padding: EdgeInsets.all(SizeApp.s10),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeApp.s10),
              ),
              child: Icon(
                Icons.groups_rounded,
                color: ColorsManager.primaryColor,
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
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatChip(
              '${teamProvider.totalExercises}',
              'تمرين',
              ColorsManager.secondaryColor,
            ),
            SizedBox(width: SizeApp.s4),
            _buildStatChip(
              '${teamProvider.totalSkills}',
              'مهارة',
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
              // Manage Assignments Button
              _buildManageAssignmentsButton(),

              SizedBox(height: SizeApp.s20),

              // Exercises Section
              if (exercises.isNotEmpty) ...[
                _buildContentSection(
                  title: 'التمارين المُعيَّنة',
                  icon: Icons.fitness_center_rounded,
                  color: ColorsManager.secondaryColor,
                  children: _buildExercisesList(exercises),
                ),
                SizedBox(height: SizeApp.s20),
              ],

              // Skills Section
              if (skills.isNotEmpty) ...[
                _buildContentSection(
                  title: 'المهارات المُعيَّنة',
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            'جاري تحميل البيانات...',
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyContentState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeApp.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeApp.s20),
              decoration: BoxDecoration(
                color: ColorsManager.defaultTextSecondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.assignment_outlined,
                size: 64.sp,
                color: ColorsManager.defaultTextSecondary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: SizeApp.s20),
            Text(
              'لم يتم تعيين محتوى بعد',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              'ابدأ بتعيين التمارين والمهارات لهذا الفريق',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.defaultTextSecondary,
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
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _navigateToManageAssignments(),
        icon: Icon(Icons.assignment_rounded, size: SizeApp.iconSize),
        label: const Text('إدارة التعيينات'),
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorsManager.primaryColor,
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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
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
          // Section Header
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

          // Content
          Padding(
            padding: EdgeInsets.all(SizeApp.s16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExercisesList(List exercises) {
    return exercises.map<Widget>((exercise) {
      return InkWell(
        onTap: () => ExerciseDetailSheet.show(context, exercise,teamId: widget.team.id,),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: Container(
          margin: EdgeInsets.only(bottom: SizeApp.s8),
          padding: EdgeInsets.all(SizeApp.s12),
          decoration: BoxDecoration(
            color: ColorsManager.backgroundSurface,
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            border: Border.all(
              color: ColorsManager.inputBorder.withOpacity(0.3),
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.defaultText,
                      ),
                    ),
                    if (exercise.description != null) ...[
                      SizedBox(height: SizeApp.s2),
                      Text(
                        exercise.description!,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ColorsManager.defaultTextSecondary,
                        ),
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
                color: ColorsManager.defaultTextSecondary,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  List<Widget> _buildSkillsList(List skills) {
    return skills.map<Widget>((skill) {
      return InkWell(
        onTap: () => SkillDetailSheet.show(context, skill, widget.team.id),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: Container(
          margin: EdgeInsets.only(bottom: SizeApp.s8),
          padding: EdgeInsets.all(SizeApp.s12),
          decoration: BoxDecoration(
            color: ColorsManager.backgroundSurface,
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            border: Border.all(
              color: ColorsManager.inputBorder.withOpacity(0.3),
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
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: ColorsManager.defaultText,
                      ),
                    ),
                    SizedBox(height: SizeApp.s2),
                    Text(
                      skill.apparatus.arabicName,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: ColorsManager.defaultTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 14.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  Widget _buildProgressTab() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s20),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.timeline_rounded,
              size: 64.sp,
              color: ColorsManager.primaryColor,
            ),
          ),
          SizedBox(height: SizeApp.s20),
          Text(
            'قريباً: تتبع التقدم',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            'سيتم إضافة هذه الوظيفة قريباً',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Helper Methods
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
