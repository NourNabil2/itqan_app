import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/screens/team/manage_assignments_screen.dart';
import 'package:provider/provider.dart';
import '../../data/models/team.dart';
import '../../providers/team_provider.dart';
import '../../providers/member_provider.dart';


class TeamDetailScreen extends StatefulWidget {
  final Team team;

  const TeamDetailScreen({super.key, required this.team});

  @override
  State<TeamDetailScreen> createState() => _TeamDetailScreenState();
}

class _TeamDetailScreenState extends State<TeamDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTeamData();
  }

  void _loadTeamData() {
    final teamProvider = Provider.of<TeamProvider>(context, listen: false);
    final memberProvider = Provider.of<MemberProvider>(context, listen: false);

    teamProvider.selectTeam(widget.team);
    memberProvider.loadTeamMembers(widget.team.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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
            Text(widget.team.name),
            Text(
              widget.team.ageCategory.arabicName,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF2196F3),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF2196F3),
          tabs: const [
            Tab(text: 'الأعضاء'),
            Tab(text: 'المحتوى'),
            Tab(text: 'التقدم'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMembersTab(),
          _buildContentTab(),
          _buildProgressTab(),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return Consumer<MemberProvider>(
      builder: (context, memberProvider, child) {
        if (memberProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (memberProvider.members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.group_rounded,
                  size: 80.sp,
                  color: Colors.grey[300],
                ),
                SizedBox(height: 16.h),
                Text(
                  'لا يوجد أعضاء',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: EdgeInsets.all(16.w),
          itemCount: memberProvider.members.length,
          itemBuilder: (context, index) {
            final member = memberProvider.members[index];
            return Card(
              margin: EdgeInsets.only(bottom: 12.h),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF2196F3).withOpacity(0.1),
                  child: Text(
                    member.name[0].toUpperCase(),
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2196F3),
                    ),
                  ),
                ),
                title: Text(member.name),
                subtitle: Text('العمر: ${member.age} • ${member.level}'),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContentTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        final exercises = teamProvider.teamExercises;
        final skills = teamProvider.teamSkills;

        if (exercises.isEmpty && skills.isEmpty) {
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
                  'لم يتم تعيين محتوى بعد',
                  style: TextStyle(
                    fontSize: 18.sp,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 24.h),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ManageAssignmentsScreen(
                          team: widget.team,
                        ),
                      ),
                    ).then((_) => _loadTeamData());
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('إدارة التعيينات'),
                ),
              ],
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Action Button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ManageAssignmentsScreen(
                      team: widget.team,
                    ),
                  ),
                ).then((_) => _loadTeamData());
              },
              icon: const Icon(Icons.edit),
              label: const Text('إدارة التعيينات'),
              style: OutlinedButton.styleFrom(
                minimumSize: Size(double.infinity, 48.h),
              ),
            ),
            SizedBox(height: 24.h),

            // Exercises by Type
            for (final type in ExerciseType.values) ...[
              if (exercises.any((e) => e.type == type)) ...[
                _buildSectionHeader(type.arabicName),
                ...exercises
                    .where((e) => e.type == type)
                    .map((exercise) => Card(
                  margin: EdgeInsets.only(bottom: 8.h),
                  child: ListTile(
                    leading: Icon(
                      _getExerciseIcon(type),
                      color: _getExerciseColor(type),
                    ),
                    title: Text(exercise.title),
                    subtitle: exercise.description != null
                        ? Text(
                      exercise.description!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    )
                        : null,
                  ),
                ))
                    .toList(),
                SizedBox(height: 16.h),
              ],
            ],

            // Skills by Apparatus
            if (skills.isNotEmpty) ...[
              _buildSectionHeader('المهارات'),
              for (final apparatus in Apparatus.values) ...[
                if (skills.any((s) => s.apparatus == apparatus)) ...[
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    child: Text(
                      apparatus.arabicName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                  ),
                  ...skills
                      .where((s) => s.apparatus == apparatus)
                      .map((skill) => Card(
                    margin: EdgeInsets.only(bottom: 8.h),
                    child: ListTile(
                      leading: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: _getApparatusColor(apparatus)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Icon(
                          _getApparatusIcon(apparatus),
                          color: _getApparatusColor(apparatus),
                          size: 20.sp,
                        ),
                      ),
                      title: Text(skill.skillName),
                    ),
                  ))
                      .toList(),
                ],
              ],
            ],
          ],
        );
      },
    );
  }

  Widget _buildProgressTab() {
    return Center(
      child: Text(
        'قريباً: تتبع التقدم',
        style: TextStyle(
          fontSize: 18.sp,
          color: Colors.grey[600],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: const Color(0xFF2C3E50),
        ),
      ),
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