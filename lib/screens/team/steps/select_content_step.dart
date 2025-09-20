import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'اختيار المحتوى',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'اختر التمارين والمهارات من المكتبة العالمية',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),

        // Tabs
        Container(
          color: Colors.white,
          child: TabBar(
            controller: _tabController,
            labelColor: const Color(0xFF2196F3),
            unselectedLabelColor: Colors.grey,
            indicatorColor: const Color(0xFF2196F3),
            tabs: const [
              Tab(text: 'الإحماء'),
              Tab(text: 'الإطالة'),
              Tab(text: 'اللياقة'),
              Tab(text: 'المهارات'),
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
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'العناصر المختارة',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${_tempSelectedExercises.length + _tempSelectedSkills.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF2196F3),
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
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد تمارين ${type.arabicName}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'أضف تمارين من المكتبة أولاً',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
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
              color: isSelected ? const Color(0xFF2196F3).withOpacity(0.05) : null,
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
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                subtitle: exercise.description != null
                    ? Text(
                  exercise.description!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12.sp),
                )
                    : null,
                secondary: Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getExerciseIcon(type),
                    color: const Color(0xFF2196F3),
                  ),
                ),
                activeColor: const Color(0xFF2196F3),
                checkColor: Colors.white,
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildSkillsList() {
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
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا توجد مهارات',
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'أضف مهارات من المكتبة أولاً',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey[500],
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
                    apparatus.arabicName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2C3E50),
                    ),
                  ),
                ),
                ...skills.map((skill) {
                  final isSelected = _tempSelectedSkills.contains(skill.id);

                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    color: isSelected ? const Color(0xFF2196F3).withOpacity(0.05) : null,
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
                      title: Text(skill.skillName),
                      secondary: Container(
                        width: 48.w,
                        height: 48.h,
                        decoration: BoxDecoration(
                          color: _getApparatusColor(apparatus).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          _getApparatusIcon(apparatus),
                          color: _getApparatusColor(apparatus),
                        ),
                      ),
                      activeColor: const Color(0xFF2196F3),
                      checkColor: Colors.white,
                    ),
                  );
                }).toList(),
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

  IconData _getApparatusIcon(Apparatus apparatus) {
    switch (apparatus) {
      case Apparatus.floor:
        return Icons.sports_gymnastics;
      case Apparatus.beam:
        return Icons.linear_scale;
      case Apparatus.bars:
        return Icons.fitness_center;
      case Apparatus.vault:
        return Icons.directions_run;
    }
  }

  Color _getApparatusColor(Apparatus apparatus) {
    switch (apparatus) {
      case Apparatus.floor:
        return Colors.green;
      case Apparatus.beam:
        return Colors.orange;
      case Apparatus.bars:
        return Colors.blue;
      case Apparatus.vault:
        return Colors.purple;
    }
  }
}