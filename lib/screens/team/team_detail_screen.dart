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
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
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
        onTap: () => ExerciseDetailSheet.show(context, exercise),
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



class ExerciseDetailSheet extends StatelessWidget {
  final ExerciseTemplate exercise;

  const ExerciseDetailSheet({super.key, required this.exercise});

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
                  // Media Section
                  if (exercise.hasMedia) _buildMediaSection(),

                  // Description Section
                  if (exercise.description != null) _buildDescriptionSection(),

                  // Exercise Type Info
                  _buildTypeInfoSection(),

                  // Stats Section
                  _buildStatsSection(),
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
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: _getExerciseColor().withOpacity(0.1),
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
              color: _getExerciseColor().withOpacity(0.2),
              borderRadius: BorderRadius.circular(SizeApp.s10),
            ),
            child: Icon(
              _getExerciseIcon(),
              color: _getExerciseColor(),
              size: 24.sp,
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
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: _getExerciseColor(),
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s8,
                    vertical: SizeApp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: _getExerciseColor(),
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Text(
                    exercise.type.arabicName,
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

  Widget _buildMediaSection() {
    // Debug prints
    log('DEBUG: ExerciseDetailSheet for ${exercise.title}:');
    log('- Thumbnail: ${exercise.thumbnailPath}');
    log('- Media Gallery: ${exercise.mediaGallery.length} items');
    log('- Legacy Media: ${exercise.mediaPath}');
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
          if (exercise.thumbnailPath != null) _buildThumbnailSection(),

          // Display media gallery
          if (exercise.mediaGallery.isNotEmpty) _buildMediaGallerySection(),

          // Legacy media support
          if (exercise.mediaPath != null && exercise.thumbnailPath == null && exercise.mediaGallery.isEmpty)
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
                File(exercise.thumbnailPath!),
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
            'معرض الوسائط (${exercise.mediaGallery.length})',
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
              itemCount: exercise.mediaGallery.length,
              itemBuilder: (context, index) {
                final media = exercise.mediaGallery[index];
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
      child: exercise.mediaType == MediaType.image
          ? ClipRRect(
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: Image.file(
          File(exercise.mediaPath!),
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
            exercise.description!,
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
          _buildInfoRow('النوع', exercise.type.arabicName, _getExerciseIcon()),
          SizedBox(height: SizeApp.s8),
          _buildInfoRow('تاريخ الإضافة', _formatDate(exercise.createdAt), Icons.calendar_today_rounded),
          SizedBox(height: SizeApp.s8),
          _buildInfoRow('آخر تحديث', _formatDate(exercise.updatedAt), Icons.update_rounded),
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
                  '${exercise.assignedTeamsCount ?? 0}',
                  Icons.groups_rounded,
                  ColorsManager.primaryColor,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildStatCard(
                  'الإضافة',
                  _formatShortDate(exercise.createdAt),
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
              backgroundColor: _getExerciseColor(),
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
  Color _getExerciseColor() {
    switch (exercise.type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getExerciseIcon() {
    switch (exercise.type) {
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

  static void show(BuildContext context, ExerciseTemplate exercise) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ExerciseDetailSheet(exercise: exercise),
    );
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