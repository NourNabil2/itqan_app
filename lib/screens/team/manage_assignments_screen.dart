import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/enums.dart';
import '../../data/models/team.dart';
import '../../data/models/exercise_template.dart';
import '../../data/models/skill_template.dart';
import '../../providers/exercise_library_provider.dart';
import '../../providers/skill_library_provider.dart';
import '../../providers/team_provider.dart';

class ManageAssignmentsScreen extends StatefulWidget {
  final Team team;

  const ManageAssignmentsScreen({super.key, required this.team});

  @override
  State<ManageAssignmentsScreen> createState() => _ManageAssignmentsScreenState();
}

class _ManageAssignmentsScreenState extends State<ManageAssignmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final Set<String> _selectedExercises = {};
  final Set<String> _selectedSkills = {};
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadCurrentAssignments();
  }

  void _loadCurrentAssignments() async {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    await teamProvider.loadTeamContent(widget.team.id);

    setState(() {
      _selectedExercises.addAll(
        teamProvider.teamExercises.map((e) => e.id),
      );
      _selectedSkills.addAll(
        teamProvider.teamSkills.map((s) => s.id),
      );
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _saveAssignments() async {
    setState(() => _isLoading = true);

    try {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);

      await teamProvider.assignExercisesToTeam(
        widget.team.id,
        _selectedExercises.toList(),
      );

      await teamProvider.assignSkillsToTeam(
        widget.team.id,
        _selectedSkills.toList(),
      );

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التعيينات بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حفظ التعيينات: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('إدارة التعيينات'),
            Text(
              widget.team.name,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton.icon(
            onPressed: _isLoading ? null : _saveAssignments,
            icon: const Icon(Icons.check),
            label: const Text('حفظ'),
          ),
        ],
      ),
      body: Column(
        children: [
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
          // Selected Count
          Container(
            color: const Color(0xFF2196F3).withOpacity(0.1),
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'العناصر المختارة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2196F3),
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Text(
                    '${_selectedExercises.length + _selectedSkills.length}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
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
        ],
      ),
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
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            final isSelected = _selectedExercises.contains(exercise.id);

            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              color: isSelected ? const Color(0xFF2196F3).withOpacity(0.05) : null,
              child: CheckboxListTile(
                value: isSelected,
                onChanged: (value) {
                  setState(() {
                    if (value == true) {
                      _selectedExercises.add(exercise.id);
                    } else {
                      _selectedExercises.remove(exercise.id);
                    }
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
                    color: _getExerciseColor(type).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Icon(
                    _getExerciseIcon(type),
                    color: _getExerciseColor(type),
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
                Container(
                  margin: EdgeInsets.only(bottom: 8.h, top: index == 0 ? 0 : 16.h),
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: _getApparatusColor(apparatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    apparatus.arabicName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: _getApparatusColor(apparatus),
                    ),
                  ),
                ),
                ...skills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill.id);

                  return Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    color: isSelected ? const Color(0xFF2196F3).withOpacity(0.05) : null,
                    child: CheckboxListTile(
                      value: isSelected,
                      onChanged: (value) {
                        setState(() {
                          if (value == true) {
                            _selectedSkills.add(skill.id);
                          } else {
                            _selectedSkills.remove(skill.id);
                          }
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

  Color _getExerciseColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Colors.orange;
      case ExerciseType.stretching:
        return Colors.blue;
      case ExerciseType.conditioning:
        return Colors.purple;
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