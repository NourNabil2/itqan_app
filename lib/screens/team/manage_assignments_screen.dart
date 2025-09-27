import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
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
  String? _errorMessage;

  static const List<AssignmentTab> _tabs = [
    AssignmentTab(
      title: 'الإحماء',
      icon: Icons.whatshot_rounded,
      exerciseType: ExerciseType.warmup,
      color: Color(0xFFFF5722),
    ),
    AssignmentTab(
      title: 'الإطالة',
      icon: Icons.accessibility_new_rounded,
      exerciseType: ExerciseType.stretching,
      color: Color(0xFF4CAF50),
    ),
    AssignmentTab(
      title: 'اللياقة',
      icon: Icons.fitness_center_rounded,
      exerciseType: ExerciseType.conditioning,
      color: Color(0xFF2196F3),
    ),
    AssignmentTab(
      title: 'المهارات',
      icon: Icons.star_rounded,
      color: Color(0xFF9C27B0),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: widget.team.name,
        action: _buildSaveButton(),
      ),
      body: Column(
        children: [
          // Header Section
          _buildHeaderSection(),

          // Error Display
          if (_errorMessage != null) _buildErrorContainer(),

          // Tab Bar
          _buildTabBar(),

          // Selected Count Banner
          _buildSelectedCountBanner(),

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

  Widget _buildSaveButton() {
    return TextButton.icon(
      onPressed: _isLoading ? null : _saveAssignments,
      icon: _isLoading
          ? SizedBox(
        width: 16.w,
        height: 16.h,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      )
          : Icon(Icons.check_rounded, size: SizeApp.iconSize),
      label: Text(
        _isLoading ? 'جاري الحفظ...' : 'حفظ',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14.sp,
        ),
      ),
      style: TextButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: ColorsManager.primaryColor,
        padding: EdgeInsets.symmetric(
          horizontal: SizeApp.s16,
          vertical: SizeApp.s8,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        ),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return SectionHeader(
      title: 'تعيين المحتوى للفريق',
      subtitle: 'اختر التمارين والمهارات المناسبة لـ ${widget.team.name}',
      leading: Container(
        padding: EdgeInsets.all(SizeApp.s8),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.s8),
        ),
        child: Icon(
          Icons.assignment_rounded,
          color: ColorsManager.primaryColor,
          size: SizeApp.iconSize,
        ),
      ),
      padding: EdgeInsets.all(SizeApp.s16),
      showDivider: true,
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      margin: EdgeInsets.all(SizeApp.s16),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.errorFill.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.errorFill.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: ColorsManager.errorFill,
            size: SizeApp.iconSize,
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.errorFill,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _errorMessage = null),
            icon: Icon(
              Icons.close_rounded,
              color: ColorsManager.errorFill,
              size: 18.sp,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: ColorsManager.primaryColor,
        unselectedLabelColor: ColorsManager.defaultTextSecondary,
        indicatorColor: ColorsManager.primaryColor,
        indicatorWeight: 3,
        labelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 13.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: _tabs.map((tab) {
          return Tab(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(tab.icon, size: 16.sp),
                SizedBox(width: SizeApp.s4),
                Text(tab.title),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildSelectedCountBanner() {
    final totalSelected = _selectedExercises.length + _selectedSkills.length;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: totalSelected > 0
          ? ColorsManager.primaryColor.withOpacity(0.1)
          : ColorsManager.backgroundCard,
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s16,
        vertical: SizeApp.s12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.checklist_rounded,
                color: ColorsManager.primaryColor,
                size: 16.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'العناصر المختارة',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: SizeApp.s12,
              vertical: SizeApp.s4,
            ),
            decoration: BoxDecoration(
              color: totalSelected > 0
                  ? ColorsManager.primaryColor
                  : ColorsManager.defaultTextSecondary,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              '$totalSelected',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
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
        final tabColor = _tabs.firstWhere((tab) => tab.exerciseType == type).color;

        if (exercises.isEmpty) {
          return _buildEmptyState(
            title: 'لا توجد تمارين ${type.arabicName}',
            icon: _tabs.firstWhere((tab) => tab.exerciseType == type).icon,
            color: tabColor,
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(SizeApp.s16),
          itemCount: exercises.length,
          itemBuilder: (context, index) {
            final exercise = exercises[index];
            final isSelected = _selectedExercises.contains(exercise.id);

            return _buildExerciseCard(exercise, isSelected, tabColor);
          },
        );
      },
    );
  }

  Widget _buildSkillsList() {
    return Consumer<SkillLibraryProvider>(
      builder: (context, provider, child) {
        final skills = provider.skills;
        const tabColor = Color(0xFF9C27B0);

        if (skills.isEmpty) {
          return _buildEmptyState(
            title: 'لا توجد مهارات',
            icon: Icons.star_rounded,
            color: tabColor,
          );
        }

        // Group skills by apparatus
        final skillsByApparatus = <Apparatus, List<SkillTemplate>>{};
        for (final skill in skills) {
          skillsByApparatus.putIfAbsent(skill.apparatus, () => []).add(skill);
        }

        return ListView.builder(
          padding: EdgeInsets.all(SizeApp.s16),
          itemCount: skillsByApparatus.length,
          itemBuilder: (context, index) {
            final apparatus = skillsByApparatus.keys.elementAt(index);
            final apparatusSkills = skillsByApparatus[apparatus]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Apparatus Header
                Container(
                  margin: EdgeInsets.only(
                    bottom: SizeApp.s12,
                    top: index == 0 ? 0 : SizeApp.s20,
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s12,
                    vertical: SizeApp.s8,
                  ),
                  decoration: BoxDecoration(
                    color: getApparatusColor(apparatus).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        getApparatusIcon(apparatus),
                        color: getApparatusColor(apparatus),
                        size: 16.sp,
                      ),
                      SizedBox(width: SizeApp.s8),
                      Text(
                        apparatus.arabicName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          color: getApparatusColor(apparatus),
                        ),
                      ),
                    ],
                  ),
                ),

                // Skills List
                ...apparatusSkills.map((skill) {
                  final isSelected = _selectedSkills.contains(skill.id);
                  return _buildSkillCard(skill, isSelected);
                }).toList(),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildExerciseCard(ExerciseTemplate exercise, bool isSelected, Color accentColor) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      decoration: BoxDecoration(
        color: isSelected ? accentColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: isSelected
              ? accentColor.withOpacity(0.3)
              : ColorsManager.inputBorder.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
        contentPadding: EdgeInsets.all(SizeApp.s12),
        title: Text(
          exercise.title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),
        subtitle: exercise.description != null
            ? Padding(
          padding: EdgeInsets.only(top: SizeApp.s4),
          child: Text(
            exercise.description!,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsManager.defaultTextSecondary,
              height: 1.3,
            ),
          ),
        )
            : null,
        secondary: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          ),
          child: Icon(
            _getExerciseIcon(exercise.type),
            color: accentColor,
            size: 24.sp,
          ),
        ),
        activeColor: accentColor,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildSkillCard(SkillTemplate skill, bool isSelected) {
    final apparatusColor = getApparatusColor(skill.apparatus);

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s8),
      decoration: BoxDecoration(
        color: isSelected ? apparatusColor.withOpacity(0.05) : Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: isSelected
              ? apparatusColor.withOpacity(0.3)
              : ColorsManager.inputBorder.withOpacity(0.2),
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
        contentPadding: EdgeInsets.all(SizeApp.s12),
        title: Text(
          skill.skillName,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),
        secondary: Container(
          width: 48.w,
          height: 48.h,
          decoration: BoxDecoration(
            color: apparatusColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          ),
          child: Icon(
            getApparatusIcon(skill.apparatus),
            color: apparatusColor,
            size: 24.sp,
          ),
        ),
        activeColor: apparatusColor,
        checkColor: Colors.white,
        controlAffinity: ListTileControlAffinity.trailing,
      ),
    );
  }

  Widget _buildEmptyState({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s20),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 64.sp,
              color: color.withOpacity(0.6),
            ),
          ),
          SizedBox(height: SizeApp.s20),
          Text(
            title,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            'لا يوجد محتوى متاح للتعيين',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getExerciseIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }

  Future<void> _saveAssignments() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);

      final exerciseSuccess = await teamProvider.assignExercisesToTeam(
        widget.team.id,
        _selectedExercises.toList(),
      );

      final skillSuccess = await teamProvider.assignSkillsToTeam(
        widget.team.id,
        _selectedSkills.toList(),
      );

      if (exerciseSuccess && skillSuccess) {
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('تم حفظ التعيينات بنجاح'),
              backgroundColor: ColorsManager.successFill,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
          );
        }
      } else {
        throw Exception(teamProvider.errorMessage ?? 'خطأ في حفظ التعيينات');
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}

// Helper Classes
class AssignmentTab {
  final String title;
  final IconData icon;
  final ExerciseType? exerciseType;
  final Color color;

  const AssignmentTab({
    required this.title,
    required this.icon,
    required this.color,
    this.exerciseType,
  });
}