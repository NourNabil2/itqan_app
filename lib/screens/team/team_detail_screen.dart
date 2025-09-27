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
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/team/manage_assignments_screen.dart';
import 'package:itqan_gym/screens/team/widgets/team_members_manager.dart';
import 'package:provider/provider.dart';
import '../../data/models/exercise_template.dart';
import '../../data/models/skill_template.dart';
import '../../data/models/team.dart';
import '../../providers/team_provider.dart';

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
        onTap: () => SkillDetailSheet.show(context, skill),
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



// ============= تحديث ExerciseDetailSheet مع زر التعيين =============
// أضف هذه التحديثات في ExerciseDetailSheet

class ExerciseDetailSheet extends StatefulWidget {
  final ExerciseTemplate exercise;
  final String? teamId; // إضافة معرف الفريق

  const ExerciseDetailSheet({
    super.key,
    required this.exercise,
    this.teamId,
  });

  @override
  State<ExerciseDetailSheet> createState() => _ExerciseDetailSheetState();

  static void show(BuildContext context, ExerciseTemplate exercise, {required String teamId}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailSheet(exercise: exercise,teamId: teamId,),
    );
  }



}

class _ExerciseDetailSheetState extends State<ExerciseDetailSheet> {
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _membersFuture = Provider.of<ExerciseAssignmentProvider>(context, listen: false)
        .loadExerciseMembers(widget.exercise.id);
  }

  Future<void> _refreshMembers() async {
    setState(() {
      _membersFuture = Provider.of<ExerciseAssignmentProvider>(context, listen: false)
          .loadExerciseMembers(widget.exercise.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: SizeApp.s12),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.inputBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header مع زر التعيين
          _buildHeaderWithActions(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // قسم الأعضاء المعينين
                  if (widget.teamId != null) _buildAssignedMembersSection(context),

                  // Media Section
                  if (widget.exercise.hasMedia) _buildMediaSection(),

                  // Description Section
                  if (widget.exercise.description != null) _buildDescriptionSection(),

                  // Exercise Type Info
                  _buildTypeInfoSection(),

                  // Stats Section
                  _buildStatsSection(),
                ],
              ),
            ),
          ),

          // Bottom Actions
          _buildBottomActions(context),
        ],
      ),
    );
  }

  Widget _buildHeaderWithActions(BuildContext context) {
    final exerciseColor = _getExerciseColor();
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: exerciseColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s12),
            decoration: BoxDecoration(
              color: exerciseColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(SizeApp.s10),
            ),
            child: Icon(
              _getExerciseIcon(),
              color: exerciseColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.exercise.title,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: exerciseColor,
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s8,
                    vertical: SizeApp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: exerciseColor,
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Text(
                    widget.exercise.type.arabicName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // زر التعيين للأعضاء
          if (widget.teamId != null) ...[
            IconButton(
              onPressed: () => _showAssignmentSheet(context),
              icon: Container(
                padding: EdgeInsets.all(SizeApp.s8),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                ),
                child: Icon(
                  Icons.person_add_rounded,
                  color: ColorsManager.primaryColor,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignedMembersSection(BuildContext context) {
    return FutureBuilder<List<Member>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSection();
        }
        final members = snapshot.data ?? const <Member>[];
        if (members.isEmpty) {
          return _buildEmptyMembersSection(context);
        }
        return Container(
          margin: EdgeInsets.only(bottom: SizeApp.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.groups_rounded, color: ColorsManager.primaryColor, size: 20.sp),
                  SizedBox(width: SizeApp.s8),
                  Text(
                    'الأعضاء المعينون (${members.length})',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorsManager.defaultText),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => _showAssignmentSheet(context),
                    child: Row(
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 16.sp),
                        SizedBox(width: SizeApp.s4),
                        Text('إضافة', style: TextStyle(fontSize: 14.sp)),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeApp.s12),
              SizedBox(
                height: 90.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) => _buildMemberCard(members[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  Widget _buildMemberCard(Member member) {
    return Container(
      width: 140.w,
      margin: EdgeInsets.only(left: SizeApp.s8),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: ColorsManager.backgroundCard,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 36.w,
            height: 36.w,
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
          ),
          SizedBox(height: SizeApp.s8),
          // Name
          Text(
            member.name,
            style: TextStyle(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          // Progress
          if ((member.overallProgress ??  0)> 0) ...[
            SizedBox(height: SizeApp.s4),
            LinearProgressIndicator(
              value: member.overallProgress??0 / 100,
              backgroundColor: ColorsManager.inputBorder.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(ColorsManager.primaryColor),
              minHeight: 3,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmptyMembersSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.backgroundCard,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_add_rounded,
            size: 48.sp,
            color: ColorsManager.defaultTextSecondary.withOpacity(0.5),
          ),
          SizedBox(height: SizeApp.s12),
          Text(
            'لم يتم تعيين أي عضو لهذا التمرين',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          ElevatedButton.icon(
            onPressed: () => _showAssignmentSheet(context),
            icon: Icon(Icons.person_add_rounded, size: 18.sp),
            label: Text('تعيين أعضاء'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: SizeApp.s16,
                vertical: SizeApp.s8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(ColorsManager.primaryColor),
        ),
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: ColorsManager.inputBorder.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Close Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _getExerciseColor(),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
                child: Text(
                  'إغلاق',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            // Assign Members Button
            if (widget.teamId != null) ...[
              SizedBox(width: SizeApp.s12),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showAssignmentSheet(context),
                  icon: Icon(Icons.person_add_rounded),
                  label: Text('تعيين للأعضاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                    ),
                    side: BorderSide(color: ColorsManager.primaryColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showAssignmentSheet(BuildContext context) async {
    if (widget.teamId == null) return;

    final result = await AssignExerciseToMembersSheet.show(context, widget.exercise, widget.teamId!);

    if (result == true) {
      // إعادة تحميل الأعضاء المعينين
      if (context.mounted) {
        final provider = Provider.of<ExerciseAssignmentProvider>(
          context,
          listen: false,
        );
        provider.loadExerciseMembers(widget.exercise.id);
      }
    }
  }

  Widget _buildMediaSection() {
    // Debug prints
    log('DEBUG: ExerciseDetailSheet for ${widget.exercise.title}:');
    log('- Thumbnail: ${widget.exercise.thumbnailPath}');
    log('- Media Gallery: ${widget.exercise.mediaGallery.length} items');
    log('- Legacy Media: ${widget.exercise.mediaPath}');
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الوسائط التعليمية',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s12),

          // Display thumbnail if available
          if (widget.exercise.thumbnailPath != null) _buildThumbnailSection(),

          // Display media gallery
          if (widget.exercise.mediaGallery.isNotEmpty) _buildMediaGallerySection(),

          // Legacy media support
          if (widget.exercise.mediaPath != null && widget.exercise.thumbnailPath == null && widget.exercise.mediaGallery.isEmpty)
            _buildLegacyMediaSection(),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الصورة المصغرة',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Container(
            height: 180.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              color: ColorsManager.backgroundCard,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              child: Image.file(
                File(widget.exercise.thumbnailPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                      color: ColorsManager.defaultTextSecondary.withOpacity(0.1),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_rounded,
                            size: 48.sp,
                            color: ColorsManager.defaultTextSecondary,
                          ),
                          SizedBox(height: SizeApp.s8),
                          Text(
                            'لا يمكن عرض الصورة',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallerySection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معرض الوسائط (${widget.exercise.mediaGallery.length})',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: widget.exercise.mediaGallery.length,
              itemBuilder: (context, index) {
                final media = widget.exercise.mediaGallery[index];
                return Container(
                  width: 140.w,
                  margin: EdgeInsets.only(right: SizeApp.s8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                    color: ColorsManager.backgroundCard,
                  ),
                  child: media.type == MediaType.image
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                    child: Image.file(
                      File(media.path),
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                            color: ColorsManager.defaultTextSecondary.withOpacity(0.1),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.broken_image_rounded,
                              size: 32.sp,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                          ),
                        );
                      },
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                      color: _getExerciseColor().withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 40.sp,
                          color: _getExerciseColor(),
                        ),
                        SizedBox(height: SizeApp.s8),
                        Text(
                          'فيديو',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: _getExerciseColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegacyMediaSection() {
    return Container(
      height: 200.h,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        color: ColorsManager.backgroundCard,
      ),
      child: widget.exercise.mediaType == MediaType.image
          ? ClipRRect(
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: Image.file(
          File(widget.exercise.mediaPath!),
          fit: BoxFit.cover,
          width: double.infinity,
          height: double.infinity,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                color: ColorsManager.defaultTextSecondary.withOpacity(0.1),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.broken_image_rounded,
                      size: 48.sp,
                      color: ColorsManager.defaultTextSecondary,
                    ),
                    SizedBox(height: SizeApp.s8),
                    Text(
                      'لا يمكن عرض الصورة',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: ColorsManager.defaultTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      )
          : Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          color: _getExerciseColor().withOpacity(0.1),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_circle_outline_rounded,
                size: 48.sp,
                color: _getExerciseColor(),
              ),
              SizedBox(height: SizeApp.s8),
              Text(
                'فيديو توضيحي',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: _getExerciseColor(),
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: SizeApp.s4),
              Text(
                'اضغط للتشغيل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorsManager.defaultTextSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.backgroundCard,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.description_outlined,
                color: _getExerciseColor(),
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'وصف التمرين',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.defaultText,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          Text(
            widget.exercise.description!,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeInfoSection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: _getExerciseColor().withOpacity(0.05),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: _getExerciseColor().withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: _getExerciseColor(),
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'معلومات التمرين',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: _getExerciseColor(),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          _buildInfoRow('النوع', widget.exercise.type.arabicName, _getExerciseIcon()),
          SizedBox(height: SizeApp.s8),
          _buildInfoRow('تاريخ الإضافة', _formatDate(widget.exercise.createdAt), Icons.calendar_today_rounded),
          SizedBox(height: SizeApp.s8),
          _buildInfoRow('آخر تحديث', _formatDate(widget.exercise.updatedAt), Icons.update_rounded),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16.sp,
          color: _getExerciseColor().withOpacity(0.7),
        ),
        SizedBox(width: SizeApp.s8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: ColorsManager.defaultText,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: ColorsManager.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'إحصائيات الاستخدام',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.defaultText,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'الفرق المعينة',
                  '${widget.exercise.assignedTeamsCount ?? 0}',
                  Icons.groups_rounded,
                  ColorsManager.primaryColor,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildStatCard(
                  'الإضافة',
                  _formatShortDate(widget.exercise.createdAt),
                  Icons.add_circle_outline_rounded,
                  ColorsManager.secondaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 24.sp,
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: SizeApp.s4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Helper Methods
  Color _getExerciseColor() {
    switch (widget.exercise.type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getExerciseIcon() {
    switch (widget.exercise.type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}';
  }
}

class SkillDetailSheet extends StatelessWidget {
  final SkillTemplate skill;

  const SkillDetailSheet({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: SizeApp.s12),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.inputBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail Section
                  if (skill.thumbnailPath != null) _buildThumbnailSection(),

                  // Media Gallery Section
                  if (skill.mediaGallery.isNotEmpty) _buildMediaGallerySection(),

                  // Technical Analysis
                  if (skill.technicalAnalysis != null) _buildDetailSection(
                    'التحليل الفني',
                    skill.technicalAnalysis!,
                    Icons.psychology_rounded,
                    getApparatusColor(skill.apparatus),
                  ),

                  // Pre-requisites
                  if (skill.preRequisites != null) _buildDetailSection(
                    'المتطلبات المسبقة',
                    skill.preRequisites!,
                    Icons.checklist_rounded,
                    const Color(0xFF9C27B0),
                  ),

                  // Skill Progression
                  if (skill.skillProgression != null) _buildDetailSection(
                    'تدرج المهارة',
                    skill.skillProgression!,
                    Icons.trending_up_rounded,
                    const Color(0xFF4CAF50),
                  ),

                  // Drills
                  if (skill.drills != null) _buildDetailSection(
                    'التمرينات المهارية',
                    skill.drills!,
                    Icons.sports_gymnastics_rounded,
                    const Color(0xFF2196F3),
                  ),

                  // Physical Preparation
                  if (skill.physicalPreparation != null) _buildDetailSection(
                    'الإعداد البدني',
                    skill.physicalPreparation!,
                    Icons.fitness_center_rounded,
                    const Color(0xFFFF5722),
                  ),

                  // Stats Section
                  _buildStatsSection(),

                  SizedBox(height: SizeApp.s20),
                ],
              ),
            ),
          ),

          // Close Button
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final apparatusColor = getApparatusColor(skill.apparatus);

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: apparatusColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s12),
            decoration: BoxDecoration(
              color: apparatusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(SizeApp.s10),
            ),
            child: Icon(
              getApparatusIcon(skill.apparatus),
              color: apparatusColor,
              size: 24.sp,
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: apparatusColor,
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s8,
                    vertical: SizeApp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: apparatusColor,
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Text(
                    skill.apparatus.arabicName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الصورة المصغرة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          Container(
            height: 200.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              color: ColorsManager.backgroundCard,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              child: Image.file(
                File(skill.thumbnailPath!),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallerySection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معرض الوسائط (${skill.mediaGallery.length})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: skill.mediaGallery.length,
              itemBuilder: (context, index) {
                final media = skill.mediaGallery[index];
                return Container(
                  width: 120.w,
                  margin: EdgeInsets.only(right: SizeApp.s8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                    color: ColorsManager.backgroundCard,
                  ),
                  child: media.type == MediaType.image
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                    child: Image.file(
                      File(media.path),
                      fit: BoxFit.cover,
                    ),
                  )
                      : Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                      color: getApparatusColor(skill.apparatus).withOpacity(0.1),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.play_circle_outline_rounded,
                          size: 32.sp,
                          color: getApparatusColor(skill.apparatus),
                        ),
                        SizedBox(height: SizeApp.s4),
                        Text(
                          'فيديو',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: getApparatusColor(skill.apparatus),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20.sp,
              ),
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
          SizedBox(height: SizeApp.s12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: ColorsManager.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'معلومات المهارة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.defaultText,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s16),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'الجهاز',
                  skill.apparatus.arabicName,
                  getApparatusIcon(skill.apparatus),
                  getApparatusColor(skill.apparatus),
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildInfoCard(
                  'الفرق المعينة',
                  '${skill.assignedTeamsCount ?? 0}',
                  Icons.groups_rounded,
                  ColorsManager.primaryColor,
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s12),

          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'تاريخ الإضافة',
                  _formatDate(skill.createdAt),
                  Icons.add_circle_outline_rounded,
                  ColorsManager.secondaryColor,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildInfoCard(
                  'آخر تحديث',
                  _formatDate(skill.updatedAt),
                  Icons.update_rounded,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeApp.s4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: ColorsManager.inputBorder.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: getApparatusColor(skill.apparatus),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static void show(BuildContext context, SkillTemplate skill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkillDetailSheet(skill: skill),
    );
  }
}

// ============= واجهة تعيين التمارين للأعضاء =============
class AssignExerciseToMembersSheet extends StatefulWidget {
  final ExerciseTemplate exercise;
  final String teamId;

  const AssignExerciseToMembersSheet({
    super.key,
    required this.exercise,
    required this.teamId,
  });

  static Future<bool?> show(BuildContext context, ExerciseTemplate exercise, String teamId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignExerciseToMembersSheet(
        exercise: exercise,
        teamId: teamId,
      ),
    );
  }


  @override
  State<AssignExerciseToMembersSheet> createState() => _AssignExerciseToMembersSheetState();
}

class _AssignExerciseToMembersSheetState extends State<AssignExerciseToMembersSheet> {
  final Set<String> _selectedMemberIds = {};
  List<Member> _availableMembers = [];
  List<Member> _assignedMembers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }



  Future<void> _loadMembers() async {
    try {
      // جلب الأعضاء من الفريق
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final exerciseProvider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);

      // جلب أعضاء الفريق
      await memberProvider.loadTeamMembers(widget.teamId);
      final teamMembers = memberProvider.members;

      // جلب الأعضاء المعينين مسبقاً لهذا التمرين
      final assignedMemberIds = await exerciseProvider.getExerciseAssignedMemberIds(widget.exercise.id);

      setState(() {
        _assignedMembers = teamMembers.where((m) => assignedMemberIds.contains(m.id)).toList();
        _availableMembers = teamMembers.where((m) => !assignedMemberIds.contains(m.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في تحميل الأعضاء: ${e.toString()}')),
        );
      }
    }
  }

  List<Member> get _filteredMembers {
    if (_searchQuery.isEmpty) return _availableMembers;
    final q = _searchQuery.toLowerCase();
    return _availableMembers.where((m) {
      final name = m.name.toLowerCase();
      final level = (m.level ?? '').toLowerCase();
      return name.contains(q) || level.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: SizeApp.s12),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.inputBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header
          _buildHeader(),

          // Search Bar
          _buildSearchBar(),

          // Content
          Expanded(
            child: _isLoading
                ? const LoadingSpinner()
                : _buildContent(),
          ),

          // Bottom Actions
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(
            color: ColorsManager.inputBorder.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.assignment_ind_rounded,
            color: ColorsManager.primaryColor,
            size: 24.sp,
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'تعيين التمرين للأعضاء',
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.defaultText,
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                Text(
                  widget.exercise.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorsManager.defaultTextSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'البحث عن عضو...',
          prefixIcon: Icon(
            Icons.search_rounded,
            color: ColorsManager.defaultTextSecondary,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear_rounded,
              color: ColorsManager.defaultTextSecondary,
            ),
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
              });
            },
          )
              : null,
          filled: true,
          fillColor: ColorsManager.backgroundCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: SizeApp.s16,
            vertical: SizeApp.s12,
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // الأعضاء المعينين مسبقاً
          if (_assignedMembers.isNotEmpty) ...[
            _buildSectionTitle('الأعضاء المعينين مسبقاً', Icons.check_circle_rounded),
            SizedBox(height: SizeApp.s8),
            ..._assignedMembers.map((member) => _buildAssignedMemberCard(member)),
            SizedBox(height: SizeApp.s20),
          ],

          // الأعضاء المتاحين
          if (_filteredMembers.isNotEmpty) ...[
            _buildSectionTitle('الأعضاء المتاحين', Icons.people_rounded),
            SizedBox(height: SizeApp.s8),
            ..._filteredMembers.map((member) => _buildMemberSelectionCard(member)),
          ] else ...[
            _buildEmptyState(),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20.sp,
          color: ColorsManager.primaryColor,
        ),
        SizedBox(width: SizeApp.s8),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),
        if (title.contains('المتاحين') && _selectedMemberIds.isNotEmpty) ...[
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeApp.s12,
              vertical: SizeApp.s4,
            ),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor,
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            ),
            child: Text(
              '${_selectedMemberIds.length} محدد',
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAssignedMemberCard(Member member) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s8),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: ColorsManager.successFill.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.successFill.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: ColorsManager.successFill.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: ColorsManager.successFill,
                ),
              ),
            ),
          ),
          SizedBox(width: SizeApp.s12),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.defaultText,
                  ),
                ),
                Text(
                  '${member.age} سنة • ${member.level}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorsManager.defaultTextSecondary,
                  ),
                ),
              ],
            ),
          ),
          // Assigned Badge
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeApp.s8,
              vertical: SizeApp.s4,
            ),
            decoration: BoxDecoration(
              color: ColorsManager.successFill,
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_rounded,
                  size: 14.sp,
                  color: Colors.white,
                ),
                SizedBox(width: SizeApp.s4),
                Text(
                  'معين',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelectionCard(Member member) {
    final isSelected = _selectedMemberIds.contains(member.id);

    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedMemberIds.remove(member.id);
          } else {
            _selectedMemberIds.add(member.id);
          }
        });
      },
      child: Container(
        margin: EdgeInsets.only(bottom: SizeApp.s8),
        padding: EdgeInsets.all(SizeApp.s12),
        decoration: BoxDecoration(
          color: isSelected
              ? ColorsManager.primaryColor.withOpacity(0.1)
              : ColorsManager.backgroundCard,
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          border: Border.all(
            color: isSelected
                ? ColorsManager.primaryColor
                : ColorsManager.inputBorder.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            // Checkbox
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected
                      ? ColorsManager.primaryColor
                      : ColorsManager.defaultTextSecondary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Icon(
                Icons.check_rounded,
                size: 16.sp,
                color: Colors.white,
              )
                  : null,
            ),
            SizedBox(width: SizeApp.s12),
            // Avatar
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  member.name.substring(0, 1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
            ),
            SizedBox(width: SizeApp.s12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.name,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.defaultText,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        '${member.age} سنة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: ColorsManager.defaultTextSecondary,
                        ),
                      ),
                      SizedBox(width: SizeApp.s8),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeApp.s6,
                          vertical: SizeApp.s2,
                        ),
                        decoration: BoxDecoration(
                          color: _getLevelColor(member.level).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          member.level,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: _getLevelColor(member.level),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Progress if exists
            if ((member.overallProgress ?? 0) > 0) ...[
              Container(
                width: 50.w,
                height: 50.w,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: member.overallProgress??0 / 100,
                      backgroundColor: ColorsManager.inputBorder.withOpacity(0.2),
                      valueColor: AlwaysStoppedAnimation(ColorsManager.primaryColor),
                      strokeWidth: 3,
                    ),
                    Text(
                      '${member.overallProgress??0.toInt()}%',
                      style: TextStyle(
                        fontSize: 10.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.primaryColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s32),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64.sp,
              color: ColorsManager.defaultTextSecondary.withOpacity(0.5),
            ),
            SizedBox(height: SizeApp.s16),
            Text(
              _searchQuery.isNotEmpty
                  ? 'لا يوجد أعضاء متطابقين مع البحث'
                  : 'جميع الأعضاء معينين لهذا التمرين',
              style: TextStyle(
                fontSize: 16.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: ColorsManager.inputBorder.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Cancel
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  side: BorderSide(color: ColorsManager.inputBorder),
                ),
                child: Text(
                  'إلغاء',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.defaultTextSecondary,
                  ),
                ),
              ),
            ),
            SizedBox(width: SizeApp.s12),
            // Assign
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedMemberIds.isEmpty
                    ? null
                    : () => _assignExercise(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
                child: Text(
                  _selectedMemberIds.isEmpty
                      ? 'حدد الأعضاء'
                      : 'تعيين (${_selectedMemberIds.length})',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _assignExercise() async {
    try {
      final provider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);

      await provider.assignExerciseToMembers(
        widget.exercise.id,
        _selectedMemberIds.toList(),
      );

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعيين التمرين لـ ${_selectedMemberIds.length} عضو بنجاح'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في تعيين التمرين: ${e.toString()}'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'مبتدئ':
        return ColorsManager.successFill;
      case 'متوسط':
        return ColorsManager.warningFill;
      case 'متقدم':
        return ColorsManager.errorFill;
      default:
        return ColorsManager.primaryColor;
    }
  }


}