// ============= Library Screen - Refactored =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/utils/extension.dart';
import 'package:itqan_gym/core/widgets/exercise_card.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:itqan_gym/core/widgets/skill_card.dart';
import 'package:itqan_gym/data/models/exercise_template.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/exercise_library_provider.dart';
import 'package:itqan_gym/providers/skill_library_provider.dart';
import 'package:itqan_gym/screens/library/add_exercise_screen.dart';
import 'package:itqan_gym/screens/library/add_skill_screen.dart';
import 'package:itqan_gym/screens/library/library_tab.dart';
import 'package:provider/provider.dart';

import 'library_tab_bar.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: LibraryTab.tabs.length, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExerciseLibraryProvider>().loadExercises();
      context.read<SkillLibraryProvider>().loadSkills();
    });
  }

  void _onTabChanged(int index) {
    _searchController.clear();
    final tab = LibraryTab.tabs[index];

    if (tab.exerciseType != null) {
      context.read<ExerciseLibraryProvider>().filterByType(tab.exerciseType!);
    } else {
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
          _buildHeader(),
          LibraryTabBar(
            controller: _tabController,
            tabs: LibraryTab.tabs,
            onTap: _onTabChanged,
          ),
          LibrarySearchHeader(
            controller: _searchController,
            onChanged: _onSearchChanged,
            hintText: _getSearchHint(),
          ),
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

  Widget _buildHeader() {
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
      trailing: IconButton(
        onPressed: () => LibraryStatsDialog.show(context),
        icon: Icon(
          Icons.analytics_rounded,
          color: ColorsManager.primaryColor,
          size: SizeApp.iconSize,
        ),
        tooltip: 'إحصائيات',
      ),
      padding: EdgeInsets.all(SizeApp.s16),
      showDivider: true,
    );
  }

  String _getSearchHint() {
    final tab = LibraryTab.tabs[_tabController.index];
    return 'البحث في ${tab.title}...';
  }

  Widget _buildExerciseList(ExerciseType type) {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) return _buildLoadingState();

        final exercises = provider.getExercisesByType(type);

        if (exercises.isEmpty) {
          return LibraryEmptyState(
            category: type.arabicName,
            icon: type.icon,
            iconColor: type.color,
            onAddPressed: () => _navigateToAdd(type: type),
            addButtonText: 'إضافة أول ${type.arabicName}',
          );
        }

        return LibraryListContainer(
          child: Column(
            children: [
              LibraryAddButton(
                onPressed: () => _navigateToAdd(type: type),
                text: 'إضافة ${type.arabicName} جديد',
                icon: Icons.add_rounded,
                color: type.color,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: exercises.length,
                  itemBuilder: (context, index) => _buildExerciseItem(exercises[index]),
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
      builder: (context, provider, _) {
        if (provider.isLoading) return _buildLoadingState();

        if (provider.skills.isEmpty) {
          return LibraryEmptyState(
            category: 'المهارات',
            icon: Icons.star_rounded,
            iconColor: ColorsManager.secondaryColor,
            onAddPressed: () => _navigateToAdd(),
            addButtonText: 'إضافة أول مهارة',
          );
        }

        return LibraryListContainer(
          child: Column(
            children: [
              LibraryAddButton(
                onPressed: () => _navigateToAdd(),
                text: 'إضافة مهارة جديدة',
                icon: Icons.star_rounded,
                color: ColorsManager.secondaryColor,
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: provider.skills.length,
                  itemBuilder: (context, index) => _buildSkillItem(provider.skills[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExerciseItem(ExerciseTemplate exercise) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeApp.s12),
      child: InkWell(
        onTap: () => _navigateToAdd(type: exercise.type, item: exercise),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: ExerciseCard(exercise: exercise),
      ),
    );
  }

  Widget _buildSkillItem(SkillTemplate skill) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeApp.s12),
      child: InkWell(
        onTap: () => _navigateToAdd(skill: skill),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        child: SkillCard(skill: skill),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(ColorsManager.primaryColor),
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

  Future<void> _navigateToAdd({
    ExerciseType? type,
    ExerciseTemplate? item,
    SkillTemplate? skill,
  }) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) {
          if (type != null) {
            return AddExerciseScreen(type: type, exerciseToEdit: item);
          } else {
            return AddSkillScreen(skillToEdit: skill);
          }
        },
      ),
    );

    if (result == true && mounted) {
      if (type != null) {
        context.read<ExerciseLibraryProvider>().refresh();
      } else {
        context.read<SkillLibraryProvider>().refresh();
      }
    }
  }
}