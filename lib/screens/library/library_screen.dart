import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/enums.dart';
import '../../providers/exercise_library_provider.dart';
import '../../providers/skill_library_provider.dart';
import '../../widgets/exercise_card.dart';
import '../../widgets/skill_card.dart';
import 'add_exercise_screen.dart';
import 'add_skill_screen.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(16.w),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'بحث...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (query) {
              if (_tabController.index < 3) {
                Provider.of<ExerciseLibraryProvider>(context, listen: false)
                    .searchExercises(query);
              } else {
                Provider.of<SkillLibraryProvider>(context, listen: false)
                    .searchSkills(query);
              }
            },
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
            onTap: (index) {
              _searchController.clear();
              if (index < 3) {
                final type = [
                  ExerciseType.warmup,
                  ExerciseType.stretching,
                  ExerciseType.conditioning,
                ][index];
                Provider.of<ExerciseLibraryProvider>(context, listen: false)
                    .filterByType(type);
              }
            },
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
    );
  }

  Widget _buildExerciseList(ExerciseType type) {
    return Consumer<ExerciseLibraryProvider>(
      builder: (context, provider, child) {
        final exercises = provider.getExercisesByType(type);

        if (exercises.isEmpty) {
          return _buildEmptyState(type.arabicName);
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: exercises.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAddButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddExerciseScreen(type: type),
                    ),
                  );
                },
              );
            }
            return ExerciseCard(exercise: exercises[index - 1]);
          },
        );
      },
    );
  }

  Widget _buildSkillsList() {
    return Consumer<SkillLibraryProvider>(
      builder: (context, provider, child) {
        if (provider.skills.isEmpty) {
          return _buildEmptyState('المهارات');
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: provider.skills.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _buildAddButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AddSkillScreen(),
                    ),
                  );
                },
              );
            }
            return SkillCard(skill: provider.skills[index - 1]);
          },
        );
      },
    );
  }

  Widget _buildAddButton({required VoidCallback onPressed}) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.add),
        label: const Text('إنشاء جديد'),
        style: OutlinedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          side: const BorderSide(
            color: Color(0xFF2196F3),
            width: 2,
            style: BorderStyle.solid,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String category) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80.sp,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد عناصر في $category',
            style: TextStyle(
              fontSize: 18.sp,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 24.h),
          ElevatedButton.icon(
            onPressed: () {
              if (_tabController.index < 3) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddExerciseScreen(
                      type: [
                        ExerciseType.warmup,
                        ExerciseType.stretching,
                        ExerciseType.conditioning,
                      ][_tabController.index],
                    ),
                  ),
                );
              } else {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddSkillScreen(),
                  ),
                );
              }
            },
            icon: const Icon(Icons.add),
            label: const Text('إضافة أول عنصر'),
          ),
        ],
      ),
    );
  }
}