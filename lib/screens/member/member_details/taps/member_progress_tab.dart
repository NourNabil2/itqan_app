// ============= Member Progress Tab with Skills - تبويب التقدم محدث =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/progress/performance_chart.dart';
import '../widgets/progress/quick_stats_section.dart';

/// Enhanced Progress Tab - تبويب التقدم المحسن
class MemberProgressTab extends StatefulWidget {
  final Member member;
  final List<Map<String, dynamic>> exerciseProgress;

  const MemberProgressTab({
    super.key,
    required this.member,
    required this.exerciseProgress,
  });

  @override
  State<MemberProgressTab> createState() => _MemberProgressTabState();
}

class _MemberProgressTabState extends State<MemberProgressTab>
    with AutomaticKeepAliveClientMixin {
  List<AssignedSkill> _assignedSkills = [];
  List<AssignedExercise> _assignedExercises = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);

      // Load skills
      final skills = await provider.loadMemberSkills(widget.member.id);

      // Load exercises
      final exercises = await provider.loadMemberExercises(widget.member.id);

      // Load statistics
      final stats = await provider.getMemberStatistics(widget.member.id);

      if (mounted) {
        setState(() {
          _assignedSkills = skills;
          _assignedExercises = exercises;
          _statistics = stats;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _loadProgressData,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(SizeApp.s16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Overall Progress Card
            _buildOverallProgressCard(),

            SizedBox(height: SizeApp.s20),

            // Statistics Cards
            _buildStatisticsSection(),

            SizedBox(height: SizeApp.s20),

            // Performance Chart
            RepaintBoundary(
              child: PerformanceChart(member: widget.member),
            ),

            SizedBox(height: SizeApp.s20),

            // Skills Progress Section
            if (!_isLoading) _buildSkillsProgressSection(),

            SizedBox(height: SizeApp.s20),

            // Exercises Progress Section
            if (!_isLoading) _buildExercisesProgressSection(),

            SizedBox(height: SizeApp.s20),

            // Quick Stats (Legacy)
            RepaintBoundary(
              child: QuickStatsSection(
                member: widget.member,
                exerciseProgress: widget.exerciseProgress,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverallProgressCard() {
    final skillsProgress = _calculateSkillsProgress();
    final exercisesProgress = _calculateExercisesProgress();
    final overallProgress = ((skillsProgress + exercisesProgress) / 2).round();

    return Container(
      padding: EdgeInsets.all(SizeApp.s20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorsManager.primaryColor,
            ColorsManager.primaryColor.withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: ColorsManager.primaryColor.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'التقدم الإجمالي',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: SizeApp.s16),
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 120.w,
                height: 120.w,
                child: CircularProgressIndicator(
                  value: overallProgress / 100,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                  strokeWidth: 10,
                ),
              ),
              Column(
                children: [
                  Text(
                    '$overallProgress%',
                    style: TextStyle(
                      fontSize: 36.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'إنجاز',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: SizeApp.s20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildProgressIndicator(
                'المهارات',
                skillsProgress,
                Icons.sports_gymnastics_rounded,
              ),
              Container(
                width: 1,
                height: 40.h,
                color: Colors.white.withOpacity(0.3),
              ),
              _buildProgressIndicator(
                'التمارين',
                exercisesProgress,
                Icons.fitness_center_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator(String label, double progress, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 24.sp),
        SizedBox(height: SizeApp.s8),
        Text(
          '${progress.toInt()}%',
          style: TextStyle(
            fontSize: 20.sp,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.white.withOpacity(0.9),
          ),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    if (_isLoading || _statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    final exerciseStats = _statistics['exercises'] ?? {};
    final skillStats = _statistics['skills'] ?? {};

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: SizeApp.s12,
      mainAxisSpacing: SizeApp.s12,
      childAspectRatio: 1.5,
      children: [
        _buildStatCard(
          'المهارات المكتملة',
          '${skillStats['completed'] ?? 0}',
          Icons.check_circle_rounded,
          ColorsManager.successFill,
        ),
        _buildStatCard(
          'التمارين المكتملة',
          '${exerciseStats['completed'] ?? 0}',
          Icons.check_circle_rounded,
          ColorsManager.successFill,
        ),
        _buildStatCard(
          'قيد التقدم',
          '${(skillStats['in_progress'] ?? 0) + (exerciseStats['in_progress'] ?? 0)}',
          Icons.schedule_rounded,
          ColorsManager.warningFill,
        ),
        _buildStatCard(
          'المجموع الكلي',
          '${(skillStats['total'] ?? 0) + (exerciseStats['total'] ?? 0)}',
          Icons.assessment_rounded,
          ColorsManager.primaryColor,
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 28.sp),
          SizedBox(height: SizeApp.s8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
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

  Widget _buildSkillsProgressSection() {
    if (_assignedSkills.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.sports_gymnastics_rounded,
              color: ColorsManager.primaryColor,
              size: 20.sp,
            ),
            SizedBox(width: SizeApp.s8),
            Text(
              'تقدم المهارات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${_assignedSkills.length} مهارة',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorsManager.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeApp.s12),
        ...List.generate(
          _assignedSkills.length > 3 ? 3 : _assignedSkills.length,
              (index) => _buildSkillProgressCard(_assignedSkills[index]),
        ),
        if (_assignedSkills.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to skills tab
              DefaultTabController.of(context)?.animateTo(2);
            },
            child: Text('عرض كل المهارات (${_assignedSkills.length})'),
          ),
      ],
    );
  }

  Widget _buildSkillProgressCard(AssignedSkill skill) {
    if (skill.skill == null) return const SizedBox.shrink();

    final apparatusColor = getApparatusColor(skill.skill!.apparatus);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s8),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: apparatusColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            getApparatusIcon(skill.skill!.apparatus),
            color: apparatusColor,
            size: 24.sp,
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.skill!.skillName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.defaultText,
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                LinearProgressIndicator(
                  value: skill.progress / 100,
                  backgroundColor: apparatusColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(apparatusColor),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: SizeApp.s12),
          Column(
            children: [
              Text(
                '${skill.progress.toInt()}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: apparatusColor,
                ),
              ),
              Text(
                _getStatusText(skill),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: ColorsManager.defaultTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExercisesProgressSection() {
    if (_assignedExercises.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.fitness_center_rounded,
              color: ColorsManager.secondaryColor,
              size: 20.sp,
            ),
            SizedBox(width: SizeApp.s8),
            Text(
              'تقدم التمارين',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
            const Spacer(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: ColorsManager.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                '${_assignedExercises.length} تمرين',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorsManager.secondaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: SizeApp.s12),
        ...List.generate(
          _assignedExercises.length > 3 ? 3 : _assignedExercises.length,
              (index) => _buildExerciseProgressCard(_assignedExercises[index]),
        ),
        if (_assignedExercises.length > 3)
          TextButton(
            onPressed: () {
              // Navigate to exercises tab
              DefaultTabController.of(context)?.animateTo(1);
            },
            child: Text('عرض كل التمارين (${_assignedExercises.length})'),
          ),
      ],
    );
  }

  Widget _buildExerciseProgressCard(AssignedExercise exercise) {
    if (exercise.exercise == null) return const SizedBox.shrink();

    final exerciseColor = _getExerciseTypeColor(exercise.exercise!.type);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s8),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: exerciseColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getExerciseTypeIcon(exercise.exercise!.type),
            color: exerciseColor,
            size: 24.sp,
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exercise.exercise!.title,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.defaultText,
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                LinearProgressIndicator(
                  value: exercise.progress / 100,
                  backgroundColor: exerciseColor.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation(exerciseColor),
                  minHeight: 4,
                ),
              ],
            ),
          ),
          SizedBox(width: SizeApp.s12),
          Column(
            children: [
              Text(
                '${exercise.progress.toInt()}%',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: exerciseColor,
                ),
              ),
              Text(
                _getExerciseStatusText(exercise),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: ColorsManager.defaultTextSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Helper Methods
  double _calculateSkillsProgress() {
    if (_assignedSkills.isEmpty) return 0;
    final total = _assignedSkills.map((s) => s.progress).reduce((a, b) => a + b);
    return total / _assignedSkills.length;
  }

  double _calculateExercisesProgress() {
    if (_assignedExercises.isEmpty) return 0;
    final total = _assignedExercises.map((e) => e.progress).reduce((a, b) => a + b);
    return total / _assignedExercises.length;
  }

  String _getStatusText(AssignedSkill skill) {
    if (skill.isCompleted) return 'مكتمل';
    if (skill.isInProgress) return 'قيد التقدم';
    return 'لم يبدأ';
  }

  String _getExerciseStatusText(AssignedExercise exercise) {
    if (exercise.isCompleted) return 'مكتمل';
    if (exercise.isInProgress) return 'قيد التقدم';
    return 'لم يبدأ';
  }

  Color _getExerciseTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
    }
  }

  IconData _getExerciseTypeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }
}