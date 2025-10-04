// lib/screens/library/widgets/library_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TabBar(
      controller: controller,
      isScrollable: false,
      tabAlignment: TabAlignment.fill,
      labelPadding: EdgeInsets.symmetric(horizontal: SizeApp.padding / 2),
      labelColor: theme.primaryColor,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: theme.primaryColor,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: theme.textTheme.labelSmall?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      tabs: tabs.map((t) => Tab(
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(t.icon, size: SizeApp.iconSizeSmall),
            SizedBox(width: SizeApp.padding / 2),
            Flexible(
              child: Text(
                t.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
              ),
            ),
          ],
        ),
      )).toList(),
      onTap: onTap,
    );

  }
}

/// Library Search Header
class LibrarySearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String? hintText;

  const LibrarySearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Padding(
      padding: EdgeInsets.all(SizeApp.padding),
      child: AppTextFieldFactory.search(
        controller: controller,
        hintText: hintText ?? l10n.search,
        fillColor: colorScheme.surfaceContainerHighest,
        focusedFillColor: colorScheme.surfaceContainerHighest,
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
    required this.text,
    this.icon = Icons.add_rounded,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final buttonColor = color ?? colorScheme.primary;

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 20.sp),
        label: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(color: buttonColor, width: 2),
          padding: EdgeInsets.symmetric(vertical: 14.h),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final emptyIconColor = iconColor ?? colorScheme.onSurfaceVariant;

    return SafeArea(
      minimum: const EdgeInsets.all(0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // أيقونة داخل دائرة خفيفة
            Container(
              padding: EdgeInsets.all(SizeApp.s24),
              decoration: BoxDecoration(
                color: emptyIconColor.withOpacity(0.10),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.folder_open_rounded,
                size: 56, // خليه ثابت عشان مايقفزش مع الشاشات الصغيرة
                color: emptyIconColor.withOpacity(0.55),
              ),
            ),

            SizedBox(height: SizeApp.s20),

            // العنوان — بدون قصّ، ويلف أسطر طبيعي
            Text(
              l10n.noItemsIn(category),
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),

            SizedBox(height: SizeApp.s8),

            // الوصف — بدون قصّ
            Text(
              l10n.startAddingItems,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
              textAlign: TextAlign.center,
              softWrap: true,
            ),

            if (onAddPressed != null) ...[
              SizedBox(height: SizeApp.s24),

              // زر الإضافة — ياخد العرض بالكامل، والنص ما يتقصش
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: onAddPressed,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: Padding(
                    padding: EdgeInsets.symmetric(horizontal: SizeApp.s8),
                    child: Text(
                      addButtonText ?? l10n.addNow,
                      softWrap: false,
                      overflow: TextOverflow.fade, // أشيك من ellipsis في الأزرار
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: emptyIconColor,
                    foregroundColor: colorScheme.onInverseSurface,
                    padding: EdgeInsets.symmetric(vertical: 14),
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Dialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 560.w,        // شكل أحلى على الشاشات الواسعة
          maxHeight: 0.85.sh,     // مايزيدش عن 85% من الارتفاع
        ),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.w),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(Icons.analytics_rounded,
                        color: colorScheme.primary, size: 20.sp),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n.libraryStatistics,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(Icons.close_rounded,
                        color: colorScheme.onSurfaceVariant),
                    tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Content (scrollable)
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final width = constraints.maxWidth;
                    // قواعد بسيطة لعدد الأعمدة حسب العرض
                    int crossAxisCount = 2;
                    if (width < 360) crossAxisCount = 1;
                    if (width > 720) crossAxisCount = 3;

                    return SingleChildScrollView(
                      child: GridView.builder(
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: 4,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 12.w,
                          mainAxisSpacing: 12.h,
                          childAspectRatio: 2,
                        ),
                        itemBuilder: (context, i) {
                          final exProv = context.read<ExerciseLibraryProvider>();
                          final skProv = context.read<SkillLibraryProvider>();

                          switch (i) {
                            case 0:
                              return _StatCard(
                                title: ExerciseType.warmup.getLocalizedName(context),
                                count: exProv.getExercisesByType(ExerciseType.warmup).length,
                                icon: ExerciseType.warmup.icon,
                                color: ExerciseType.warmup.color,
                              );
                            case 1:
                              return _StatCard(
                                title: ExerciseType.stretching.getLocalizedName(context),
                                count: exProv.getExercisesByType(ExerciseType.stretching).length,
                                icon: ExerciseType.stretching.icon,
                                color: ExerciseType.stretching.color,
                              );
                            case 2:
                              return _StatCard(
                                title: ExerciseType.conditioning.getLocalizedName(context),
                                count: exProv.getExercisesByType(ExerciseType.conditioning).length,
                                icon: ExerciseType.conditioning.icon,
                                color: ExerciseType.conditioning.color,
                              );
                            default:
                              return _StatCard(
                                title: l10n.skills,
                                count: skProv.skills.length,
                                icon: Icons.star_rounded,
                                color: colorScheme.secondary,
                              );
                          }
                        },
                      ),
                    );
                  },
                ),
              ),

              SizedBox(height: 8.h),

              // Actions
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(l10n.close),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Stats Card — Enhanced UI/UX version
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.22), width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(icon, color: color, size: 20.sp),
              ),
              // عدّاد واضح بدون FittedBox لتفادي تصغير مفرط
              Text(
                '$count',
                textAlign: TextAlign.end,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.visible,
                softWrap: false,
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Title (يسمح بسطرين بدون قص فج)
          Text(
            title,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
              height: 1.2,
            ),
            softWrap: true,
            maxLines: 2,
            overflow: TextOverflow.fade,
          ),
        ],
      ),
    );



  }
}


