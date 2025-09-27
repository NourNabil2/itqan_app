// ============= Member Progress Widgets - كلاسات التقدم =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';

import '../widgets/progress/performance_chart.dart';
import '../widgets/progress/quick_stats_section.dart';

/// Progress Tab - تبويب التقدم كاملاً
class MemberProgressTab extends StatelessWidget {
  final Member member;
  final List<Map<String, dynamic>> exerciseProgress;

  const MemberProgressTab({
    super.key,
    required this.member,
    required this.exerciseProgress,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Performance Chart
          RepaintBoundary(
            child: PerformanceChart(member: member),
          ),

          SizedBox(height: SizeApp.s20),

          // Quick Stats
          RepaintBoundary(
            child: QuickStatsSection(
              member: member,
              exerciseProgress: exerciseProgress,
            ),
          ),
        ],
      ),
    );
  }
}
