import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/stat_card.dart';

class StatisticsSection extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const StatisticsSection({
    super.key,
    required this.statistics,
  });

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) {
      return const SizedBox.shrink();
    }

    final exerciseStats = statistics['exercises'] ?? {};
    final skillStats = statistics['skills'] ?? {};

    final stats = [
      StatItem(
        'المهارات المكتملة',
        '${skillStats['completed'] ?? 0}',
        Icons.check_circle_rounded,
        ColorsManager.successFill,
      ),
      StatItem(
        'قيد التقدم',
        '${(skillStats['in_progress'] ?? 0) + (exerciseStats['in_progress'] ?? 0)}',
        Icons.schedule_rounded,
        ColorsManager.warningFill,
      ),
      StatItem(
        'المجموع الكلي',
        '${(skillStats['total'] ?? 0) + (exerciseStats['total'] ?? 0)}',
        Icons.assessment_rounded,
        ColorsManager.primaryColor,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.symmetric(horizontal: SizeApp.padding),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: SizeApp.s12,
        mainAxisSpacing: SizeApp.s12,
        childAspectRatio: 1.5, // Increased from 1.4 for more horizontal space
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) => StatCard(stat: stats[index]),
    );
  }
}




