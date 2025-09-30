// ============= Member Progress Tab - Clean & Refactored =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/skills_progress_section.dart';
import 'package:provider/provider.dart';
import '../widgets/exercises/exercise_details_dialog.dart';
import '../widgets/progress/performance_chart.dart';
import '../widgets/progress/statistics_section.dart';


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
  String? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadProgressData();
  }

  Future<void> _loadProgressData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final provider = context.read<ExerciseAssignmentProvider>();

      final results = await Future.wait([
        provider.loadMemberSkills(widget.member.id),
        provider.loadMemberExercises(widget.member.id),
        provider.getMemberStatistics(widget.member.id),
      ]);

      if (mounted) {
        setState(() {
          _assignedSkills = results[0] as List<AssignedSkill>;
          _assignedExercises = results[1] as List<AssignedExercise>;
          _statistics = results[2] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _navigateToTab(int index) {
    final tabController = DefaultTabController.of(context);
    if (tabController != null) {
      tabController.animateTo(index);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _loadProgressData,
      child: _isLoading
          ? _buildLoadingState()
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48.sp, color: Colors.grey),
          SizedBox(height: SizeApp.s16),
          Text('حدث خطأ في تحميل البيانات'),
          SizedBox(height: SizeApp.s8),
          ElevatedButton(
            onPressed: _loadProgressData,
            child: Text('إعادة المحاولة'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Chart
          RepaintBoundary(
            child: PerformanceChart(
              member: widget.member,
              exerciseProgress: widget.exerciseProgress,
            ),
          ),

          SizedBox(height: SizeApp.s24),

          // Skills Progress Section
          if (_assignedSkills.isNotEmpty)
            SkillsProgressSection(
              skills: _assignedSkills,
              onViewAll: () => _navigateToTab(1),
            ),

          if (_assignedSkills.isNotEmpty) SizedBox(height: SizeApp.s24),

          // Exercises Progress Section
          if (_assignedExercises.isNotEmpty)
            ExercisesProgressSection(
              exercises: _assignedExercises,
              onViewAll: () => _navigateToTab(1),
            ),

          if (_assignedExercises.isNotEmpty) SizedBox(height: SizeApp.s24),

          // Statistics Section
          if (_statistics.isNotEmpty)
            StatisticsSection(
              statistics: _statistics,
            ),
        ],
      ),
    );
  }
}