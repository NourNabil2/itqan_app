import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

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
        'التمارين المكتملة',
        '${exerciseStats['completed'] ?? 0}',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeApp.s4),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      ColorsManager.primaryColor,
                      ColorsManager.primaryColor.withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.analytics_outlined,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Text(
                'إحصائيات الأداء',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.defaultText,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: SizeApp.s16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: SizeApp.s12,
            mainAxisSpacing: SizeApp.s12,
            childAspectRatio: 1.4,
          ),
          itemCount: stats.length,
          itemBuilder: (context, index) => _StatCard(stat: stats[index]),
        ),
      ],
    );
  }
}

class StatItem {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  StatItem(this.title, this.value, this.icon, this.color);
}

class _StatCard extends StatelessWidget {
  final StatItem stat;

  const _StatCard({required this.stat});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeApp.padding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: stat.color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(10.sp),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  stat.color.withOpacity(0.15),
                  stat.color.withOpacity(0.08),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              stat.icon,
              color: stat.color,
              size: 24.sp,
            ),
          ),
          SizedBox(height: SizeApp.s10),
          Text(
            stat.value,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.w700,
              color: stat.color,
            ),
          ),
          SizedBox(height: SizeApp.s4),
          Text(
            stat.title,
            style: TextStyle(
              fontSize: 11.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}