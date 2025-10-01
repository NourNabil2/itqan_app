import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/skill_library_provider.dart';
import 'package:provider/provider.dart';
import '../../../providers/exercise_library_provider.dart';

class SelectContentStep extends StatefulWidget {
  final List<String> selectedExercises;
  final List<String> selectedSkills;
  final Function(List<String>) onExercisesChanged;
  final Function(List<String>) onSkillsChanged;

  const SelectContentStep({
    super.key,
    required this.selectedExercises,
    required this.selectedSkills,
    required this.onExercisesChanged,
    required this.onSkillsChanged,
  });

  @override
  State<SelectContentStep> createState() => _SelectContentStepState();
}

class _SelectContentStepState extends State<SelectContentStep>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _tempSelectedExercises = {};
  final Set<String> _tempSelectedSkills = {};

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tempSelectedExercises.addAll(widget.selectedExercises);
    _tempSelectedSkills.addAll(widget.selectedSkills);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.selectContent,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                l10n.selectContentDescription,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: theme.cardColor,
          child: TabBar(
            controller: _tabController,
            labelColor: theme.primaryColor,
            unselectedLabelColor: theme.textTheme.bodySmall?.color,
            indicatorColor: theme.primaryColor,
            tabs: [
              Tab(text: ExerciseType.warmup.getLocalizedName(context)),
              Tab(text: ExerciseType.stretching.getLocalizedName(context)),
              Tab(text: ExerciseType.conditioning.getLocalizedName(context)),
              Tab(text: l10n.skills),
            ],
          ),
        ),

        // Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildExerciseList(ExerciseType.warmup),
              _buildExerciseList(ExerciseType.stretching),
              _buildExerciseList(ExerciseType.conditioning),
              _buildSkillsList(),
            ],
          ),
        ),

        // Selected Count
        Container(
          color: theme.cardColor,
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.selectedItems,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_tempSelectedExercises.length + _tempSelectedSkills.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseList(ExerciseType type) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, child) {
        final exercises = provider.getExercisesByType(type);

        if (exercises.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox,
                  size: 60.sp,
                  color: theme.iconTheme.color?.withOpacity(0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.noExercisesAvailable(type.getLocalizedName(context)),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.addFromLibraryFirst,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            final isSelected = _tempSelectedExercises.contains(exercise.id);

            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              color: isSelected
                  ? theme.primaryColor.withOpacity(0.05)
                  : theme.cardColor,
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _tempSelectedExercises.add(exercise.id);
                    } else {
                      _tempSelectedExercises.remove(exercise.id);
                    }
                    widget.onExercisesChanged(_tempSelectedExercises.toList());
                  });
                },
                title: Text(
                  exercise.title,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: exercise.description != null
                    ? Text(
                  exercise.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall,
                )
                    : null,
                secondary: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getExerciseIcon(type),
                    color: theme.primaryColor,
                  ),
                ),
                activeColor: theme.primaryColor,
                checkColor: Colors.white,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkillsList() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Consumer<SkillLibraryProvider>(
      builder: (context, provider, child) {
        if (provider.skills.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.sports_gymnastics,
                  size: 60.sp,
                  color: theme.iconTheme.color?.withOpacity(0.3),
                ),
                SizedBox(height: 16.h),
                Text(
                  l10n.noSkillsAvailable,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  l10n.addFromLibraryFirst,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.textTheme.bodySmall?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          );
        }

        // Group skills by apparatus
        final skillsByApparatus = <Apparatus, List<SkillTemplate>>{};
        for (final skill in provider.skills) {
          skillsByApparatus.putIfAbsent(skill.apparatus, () => []).add(skill);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: skillsByApparatus.length,
          itemBuilder: (context, index) {
            final apparatus = skillsByApparatus.keys.elementAt(index);
            final skills = skillsByApparatus[apparatus]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.h),
                  child: Text(
                    apparatus.getLocalizedName(context),
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ...skills.map((skill) {
                  final isSelected = _tempSelectedSkills.contains(skill.id);

                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    color: isSelected
                        ? theme.primaryColor.withOpacity(0.05)
                        : theme.cardColor,
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _tempSelectedSkills.add(skill.id);
                          } else {
                            _tempSelectedSkills.remove(skill.id);
                          }
                          widget.onSkillsChanged(_tempSelectedSkills.toList());
                        });
                      },
                      title: Text(
                        skill.skillName,
                        style: theme.textTheme.bodyLarge,
                      ),
                      secondary: Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: getApparatusColor(apparatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          getApparatusIcon(apparatus),
                          color: getApparatusColor(apparatus),
                        ),
                      ),
                      activeColor: theme.primaryColor,
                      checkColor: Colors.white,
                    ),
                  );
                }),
              ],
            );
          },
        );
      },
    );
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.directions_run;
      case ExerciseType.stretching:
        return Icons.self_improvement;
      case ExerciseType.conditioning:
        return Icons.fitness_center;
    }
  }
}