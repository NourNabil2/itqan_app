import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/exercise_card.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:itqan_gym/core/widgets/skill_card.dart';
import 'package:provider/provider.dart';
import '../../core/utils/enums.dart';
import '../../providers/exercise_library_provider.dart';
import '../../providers/skill_library_provider.dart';
import 'add_exercise_screen.dart';
import 'add_skill_screen.dart';
import 'library_tab_bar.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Tab Configuration
  static const List<LibraryTab> _tabs = [
    LibraryTab(
      title: 'الإحماء',
      icon: Icons.whatshot_rounded,
      exerciseType: ExerciseType.warmup,
    ),
    LibraryTab(
      title: 'الإطالة',
      icon: Icons.accessibility_new_rounded,
      exerciseType: ExerciseType.stretching,
    ),
    LibraryTab(
      title: 'اللياقة',
      icon: Icons.fitness_center_rounded,
      exerciseType: ExerciseType.conditioning,
    ),
    LibraryTab(
      title: 'المهارات',
      icon: Icons.star_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabs.length, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    // Load initial data for all providers
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseLibraryProvider>().loadExercises();
      context.read<SkillLibraryProvider>().loadSkills();
    });
  }

  void _onTabChanged(int index) {
    _searchController.clear();

    if (index < 3) {
      // Exercise tabs
      final type = _tabs[index].exerciseType!;
      context.read<ExerciseLibraryProvider>().filterByType(type);
    } else {
      // Skills tab
      context.read<SkillLibraryProvider>().clearSearch();
    }
  }

  void _onSearchChanged(String query) {
    if (_tabController.index < 3) {
      context.read<ExerciseLibraryProvider>().searchExercises(query);
    } else {
      context.read<SkillLibraryProvider>().searchSkills(query);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      body: Column(
        children: [
          // Library Header
          _buildLibraryHeader(),

          // Tab Bar
          LibraryTabBar(
            controller: _tabController,
            tabs: _tabs,
            onTap: _onTabChanged,
          ),

          // Search Header
          LibrarySearchHeader(
            controller: _searchController,
            onChanged: _onSearchChanged,
            hintText: _getSearchHint(),
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

  Widget _buildLibraryHeader() {
    return SectionHeader(
      title: 'مكتبة التمارين والمهارات',
      subtitle: 'إدارة وتنظيم جميع التمارين والمهارات',
      leading: Container(
        padding: EdgeInsets.all(SizeApp.s8),
        decoration: BoxDecoration(
          color: ColorsManager.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.s8),
        ),
        child: Icon(
          Icons.library_books_rounded,
          color: ColorsManager.primaryColor,
          size: SizeApp.iconSize,
        ),
      ),
      trailing: _buildStatsButton(),
      padding: EdgeInsets.all(SizeApp.s16),
      showDivider: true,
    );
  }

  Widget _buildStatsButton() {
    return IconButton(
      onPressed: _showLibraryStats,
      icon: Icon(
        Icons.analytics_rounded,
        color: ColorsManager.primaryColor,
        size: SizeApp.iconSize,
      ),
      tooltip: 'إحصائيات المكتبة',
    );
  }

  String _getSearchHint() {
    if (_tabController.index < 3) {
      return 'البحث في ${_tabs[_tabController.index].title}...';
    }
    return 'البحث في المهارات...';
  }

  Widget _buildExerciseList(ExerciseType type) {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, child) {
        final exercises = provider.getExercisesByType(type);
        final isLoading = provider.isLoading;

        if (isLoading) {
          return _buildLoadingState();
        }

        if (exercises.isEmpty) {
          return LibraryEmptyState(
            category: type.arabicName,
            icon: _getExerciseTypeIcon(type),
            iconColor: _getExerciseTypeColor(type),
            onAddPressed: () => _navigateToAddExercise(type),
            addButtonText: 'إضافة أول ${type.arabicName}',
          );
        }

        return LibraryListContainer(
          child: Column(
            children: [
              // Add Button
              LibraryAddButton(
                onPressed: () => _navigateToAddExercise(type),
                text: 'إضافة ${type.arabicName} جديد',
                icon: Icons.add_rounded,
                color: _getExerciseTypeColor(type),
              ),

              // Exercises List
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: SizeApp.s12),
                      child: InkWell(
                        onTap: () => _navigateToEditExercise(exercises[index]),
                        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                        child: ExerciseCard(exercise: exercises[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkillsList() {
    return Consumer<SkillLibraryProvider>(
      builder: (context, provider, child) {
        final skills = provider.skills;
        final isLoading = provider.isLoading;

        if (isLoading) {
          return _buildLoadingState();
        }

        if (skills.isEmpty) {
          return LibraryEmptyState(
            category: 'المهارات',
            icon: Icons.star_rounded,
            iconColor: ColorsManager.secondaryColor,
            onAddPressed: _navigateToAddSkill,
            addButtonText: 'إضافة أول مهارة',
          );
        }

        return LibraryListContainer(
          child: Column(
            children: [
              // Add Button
              LibraryAddButton(
                onPressed: _navigateToAddSkill,
                text: 'إضافة مهارة جديدة',
                icon: Icons.star_rounded,
                color: ColorsManager.secondaryColor,
              ),

              // Skills List
              Expanded(
                child: ListView.builder(
                  itemCount: skills.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.only(bottom: SizeApp.s12),
                      child: InkWell(
                        onTap: () => _navigateToEditSkill(skills[index]),
                        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                        child: SkillCard(skill: skills[index]),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            'جاري تحميل المحتوى...',
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // Navigation Methods
  void _navigateToAddExercise(ExerciseType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(type: type),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh data after successful operation
        context.read<ExerciseLibraryProvider>().refresh();
      }
    });
  }

  void _navigateToEditExercise(exercise) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddExerciseScreen(
          type: exercise.type,
          exerciseToEdit: exercise,
        ),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh data after successful operation
        context.read<ExerciseLibraryProvider>().refresh();
      }
    });
  }

  void _navigateToAddSkill() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AddSkillScreen(),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh data after successful operation
        context.read<SkillLibraryProvider>().refresh();
      }
    });
  }

  void _navigateToEditSkill(skill) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddSkillScreen(skillToEdit: skill),
      ),
    ).then((result) {
      if (result == true) {
        // Refresh data after successful operation
        context.read<SkillLibraryProvider>().refresh();
      }
    });
  }

  // Helper Methods
  IconData _getExerciseTypeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  Color _getExerciseTypeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722); // Deep Orange
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50); // Green
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3); // Blue
      default:
        return ColorsManager.primaryColor;
    }
  }

  // Stats Dialog
  void _showLibraryStats() {
    showDialog(
      context: context,
      builder: (context) => _LibraryStatsDialog(),
    );
  }
}

/// ✅ Library Stats Dialog - مربع حوار الإحصائيات
class _LibraryStatsDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      ),
      title: Row(
        children: [
          Icon(
            Icons.analytics_rounded,
            color: ColorsManager.primaryColor,
            size: SizeApp.iconSize,
          ),
          SizedBox(width: SizeApp.s8),
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
        builder: (context, exerciseProvider, skillProvider, child) {
          return SizedBox(
            width: double.maxFinite,
            child: GridView.count(
              shrinkWrap: true,
              crossAxisCount: 2,
              childAspectRatio: 1.2,
              mainAxisSpacing: SizeApp.s12,
              crossAxisSpacing: SizeApp.s12,
              children: [
                LibraryStatsCard(
                  title: 'الإحماء',
                  count: exerciseProvider.getExercisesByType(ExerciseType.warmup).length,
                  icon: Icons.whatshot_rounded,
                  color: const Color(0xFFFF5722),
                ),
                LibraryStatsCard(
                  title: 'الإطالة',
                  count: exerciseProvider.getExercisesByType(ExerciseType.stretching).length,
                  icon: Icons.accessibility_new_rounded,
                  color: const Color(0xFF4CAF50),
                ),
                LibraryStatsCard(
                  title: 'اللياقة',
                  count: exerciseProvider.getExercisesByType(ExerciseType.conditioning).length,
                  icon: Icons.fitness_center_rounded,
                  color: const Color(0xFF2196F3),
                ),
                LibraryStatsCard(
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