// ============= Library Widgets - Refactored =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/utils/extension.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/providers/exercise_library_provider.dart';
import 'package:itqan_gym/providers/skill_library_provider.dart';
import 'package:itqan_gym/screens/library/library_tab.dart';
import 'package:provider/provider.dart';

/// Library Tab Bar
class LibraryTabBar extends StatelessWidget {
  final TabController controller;
  final List<LibraryTab> tabs;
  final Function(int) onTap;

  const LibraryTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        labelColor: ColorsManager.primaryColor,
        unselectedLabelColor: ColorsManager.defaultTextSecondary,
        indicatorColor: ColorsManager.primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600),
        unselectedLabelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
        tabs: tabs
            .map((tab) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(tab.icon, size: 18.sp),
              SizedBox(width: SizeApp.s6),
              Text(tab.title),
            ],
          ),
        ))
            .toList(),
        onTap: onTap,
      ),
    );
  }
}

/// Library Search Header
class LibrarySearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;

  const LibrarySearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'البحث...',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.fromLTRB(SizeApp.s16, SizeApp.s20, SizeApp.s16, SizeApp.s16),
      child: AppTextFieldFactory.search(
        controller: controller,
        hintText: hintText,
        fillColor: ColorsManager.backgroundCard,
        focusedFillColor: ColorsManager.backgroundCard,
        onChanged: onChanged,
      ),
    );
  }
}

/// Library Add Button
class LibraryAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final Color? color;

  const LibraryAddButton({
    super.key,
    required this.onPressed,
    this.text = 'إضافة جديد',
    this.icon = Icons.add_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? ColorsManager.primaryColor;

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: SizeApp.iconSize),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 2),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          ),
        ),
      ),
    );
  }
}

/// Library Empty State
class LibraryEmptyState extends StatelessWidget {
  final String category;
  final IconData? icon;
  final Color? iconColor;
  final VoidCallback? onAddPressed;
  final String? addButtonText;

  const LibraryEmptyState({
    super.key,
    required this.category,
    this.icon,
    this.iconColor,
    this.onAddPressed,
    this.addButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeApp.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeApp.s24),
              decoration: BoxDecoration(
                color: (iconColor ?? ColorsManager.defaultTextSecondary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.folder_open_rounded,
                size: 64.sp,
                color: iconColor ?? ColorsManager.defaultTextSecondary.withOpacity(0.5),
              ),
            ),
            SizedBox(height: SizeApp.s24),
            Text(
              'لا توجد عناصر في $category',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              'ابدأ بإضافة العناصر لتظهر هنا',
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (onAddPressed != null) ...[
              SizedBox(height: SizeApp.s32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: onAddPressed,
                  icon: Icon(Icons.add_rounded, size: SizeApp.iconSize),
                  label: Text(addButtonText ?? 'إضافة الآن'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: iconColor ?? ColorsManager.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Library List Container
class LibraryListContainer extends StatelessWidget {
  final Widget child;

  const LibraryListContainer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: ColorsManager.backgroundSurface,
      padding: EdgeInsets.all(SizeApp.s16),
      child: child,
    );
  }
}

/// Library Stats Dialog
class LibraryStatsDialog extends StatelessWidget {
  const LibraryStatsDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      builder: (context) => const LibraryStatsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      ),
      title: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.sp),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Icon(
              Icons.analytics_rounded,
              color: ColorsManager.primaryColor,
              size: 20.sp,
            ),
          ),
          SizedBox(width: SizeApp.s12),
          Text(
            'إحصائيات المكتبة',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
      content: Consumer2<ExerciseLibraryProvider, SkillLibraryProvider>(
        builder: (context, exerciseProvider, skillProvider, _) {
          return SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: SizeApp.s12,
              crossAxisSpacing: SizeApp.s12,
              children: [
                _StatCard(
                  title: 'الإحماء',
                  count: exerciseProvider.getExercisesByType(ExerciseType.warmup).length,
                  icon: ExerciseType.warmup.icon,
                  color: ExerciseType.warmup.color,
                ),
                _StatCard(
                  title: 'الإطالة',
                  count: exerciseProvider.getExercisesByType(ExerciseType.stretching).length,
                  icon: ExerciseType.stretching.icon,
                  color: ExerciseType.stretching.color,
                ),
                _StatCard(
                  title: 'اللياقة',
                  count: exerciseProvider.getExercisesByType(ExerciseType.conditioning).length,
                  icon: ExerciseType.conditioning.icon,
                  color: ExerciseType.conditioning.color,
                ),
                _StatCard(
                  title: 'المهارات',
                  count: skillProvider.skills.length,
                  icon: Icons.star_rounded,
                  color: ColorsManager.secondaryColor,
                ),
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'إغلاق',
            style: TextStyle(
              color: ColorsManager.primaryColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

/// Stats Card (Private)
class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              Text(
                '$count',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            title,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
        ],
      ),
    );
  }
}