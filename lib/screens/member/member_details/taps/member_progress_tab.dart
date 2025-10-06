import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/core/widgets/app_buton.dart';
import 'package:itqan_gym/core/widgets/badges/CountBadge.dart';
import 'package:itqan_gym/core/widgets/badges/IconBadge.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/skills_progress_section.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/performance_chart.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/statistics_section.dart';
import 'package:itqan_gym/screens/member/member_notes_actions.dart';
import 'package:provider/provider.dart';

import '../../../../core/widgets/premium_lock_widget.dart';
import '../widgets/member_report_generator.dart';

class MemberProgressTab extends StatefulWidget {
  final Member member;

  const MemberProgressTab({
    super.key,
    required this.member,
  });

  @override
  State<MemberProgressTab> createState() => _MemberProgressTabState();
}

class _MemberProgressTabState extends State<MemberProgressTab>
    with AutomaticKeepAliveClientMixin {
  GlobalKey _chartKey = GlobalKey();
  double? _improvement;
  List<AssignedSkill> _assignedSkills = [];
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

// وخليها كده:
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
        provider.getMemberStatistics(widget.member.id),
      ]);

      if (mounted) {
        setState(() {
          _assignedSkills = results[0] as List<AssignedSkill>;
          _statistics = results[1] as Map<String, dynamic>;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading progress data: $e');
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
    tabController.animateTo(index);
    }

  @override
// lib/screens/member/member_details/tabs/member_progress_tab.dart
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return RefreshIndicator(
      onRefresh: _loadProgressData,
      color: ColorsManager.primaryColor,
      child: _isLoading
          ? const LoadingSpinner()
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: SizeApp.padding),
          PremiumFeature(
            lockHeight: 240.h,
            lockTitle: l10n.performanceChart,
            lockDescription: l10n.trackProgressOverTime,
            lockIcon: Icons.show_chart_rounded,
            child: _buildChartSection(),
          ),

          if (_statistics.isNotEmpty) ...[
            SizedBox(height: SizeApp.s24),
            _buildStatisticsSection(),
          ],

          if (_assignedSkills.isNotEmpty) ...[
            SizedBox(height: SizeApp.s24),
            _buildSkillsSection(),
            SizedBox(height: SizeApp.padding),
          ],

        ],
      ),
    );
  }


  Widget _buildErrorState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeApp.padding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          // Using ErrorContainer widget
          ErrorContainer(
            generalError: _error,
            errorIcon: Icons.error_outline,
            iconSize: 48.sp,
            fontSize: 16.sp,
            padding: EdgeInsets.all(SizeApp.s20),
            margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
            borderRadius: BorderRadius.circular(12.r),
          ),

          SizedBox(height: SizeApp.s24),

          // Using AppButton widget
          AppButton(
            text: 'إعادة المحاولة',
            onPressed: _loadProgressData,
            leadingIcon: Icons.refresh,
            horizontalPadding: 60.w,
            verticalPadding: 0,
          ),
        ],
      ),
    );
  }



  Widget _buildChartSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.performanceChart,
          subtitle: l10n.trackProgressOverTime,
          leading: IconBadge(
            icon: Icons.show_chart_rounded,
            backgroundColor: ColorsManager.primaryColor.withOpacity(0.1),
            iconColor: ColorsManager.primaryColor,
          ),
          trailing: CountBadge(
            count: l10n.last6Weeks,
            backgroundColor: ColorsManager.primaryColor.withOpacity(0.08),
            textColor: ColorsManager.primaryColor,
          ),
        ),
        SizedBox(height: SizeApp.s16),
        RepaintBoundary(
          child: PerformanceChart(member: widget.member,
              onImprovementCalculated: (improvement) {
                setState(() => _improvement = improvement);
              },),
        ),
      ],
    );
  }




  Widget _buildSkillsSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.skillsProgress,
          subtitle: l10n.addedSkillsCompletion,
          leading: IconBadge(
            icon: Icons.sports_gymnastics_rounded,
            backgroundColor: ColorsManager.warningText.withOpacity(0.1),
            iconColor: ColorsManager.warningText,
          ),
          trailing: CountBadge(
            count: '${_assignedSkills.length}',
            icon: Icons.star,
            backgroundColor: ColorsManager.warningText.withOpacity(0.1),
            textColor: ColorsManager.warningText,
          ),
        ),
        SizedBox(height: SizeApp.s16),
        SkillsProgressSection(
          skills: _assignedSkills,
          onViewAll: () => _navigateToTab(1),
        ),
      ],
    );
  }

  Widget _buildStatisticsSection() {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.performanceStatistics,
          subtitle: l10n.overallPerformanceView,
          leading: IconBadge(
            icon: Icons.analytics_outlined,
            backgroundColor: ColorsManager.successText.withOpacity(0.1),
            iconColor: ColorsManager.successText,
          ),
          showDivider: false,
        ),
        SizedBox(height: SizeApp.s16),
        StatisticsSection(statistics: _statistics),
        SizedBox(height: SizeApp.s16),
      ],
    );
  }

}