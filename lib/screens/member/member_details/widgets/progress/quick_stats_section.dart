import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/stat_card.dart';

///  Quick Stats Section
class QuickStatsSection extends StatelessWidget {
  final Member member;
  final List<Map<String, dynamic>> exerciseProgress;

  const QuickStatsSection({
    super.key,
    required this.member,
    required this.exerciseProgress,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'التمارين المكتملة',
                value: '${exerciseProgress.where((e) => e['progress'] >= 80).length}/${exerciseProgress.length}',
                icon: Icons.check_circle_outline_rounded,
                color: ColorsManager.successFill,
              ),
            ),
            SizedBox(width: SizeApp.s12),
            const Expanded(
              child: StatCard(
                title: 'معدل الحضور',
                value: '85%',
                icon: Icons.calendar_today_outlined,
                color: ColorsManager.primaryColor,
              ),
            ),
          ],
        ),

        SizedBox(height: SizeApp.s12),

        Row(
          children: [
            Expanded(
              child: StatCard(
                title: 'متوسط الدرجات',
                value: '${(member.overallProgress ?? 0).toInt()}%',
                icon: Icons.trending_up_rounded,
                color: ColorsManager.warningFill,
              ),
            ),
            SizedBox(width: SizeApp.s12),
            Expanded(
              child: StatCard(
                title: 'أيام التدريب',
                value: '24 يوم',
                icon: Icons.fitness_center_outlined,
                color: ColorsManager.infoFill,
              ),
            ),
          ],
        ),
      ],
    );
  }
}