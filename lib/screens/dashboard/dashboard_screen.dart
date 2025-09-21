import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/team_card.dart';
import 'package:itqan_gym/screens/library/library_screen.dart';
import 'package:itqan_gym/screens/member/member_library_screen.dart';
import 'package:provider/provider.dart';
import '../../providers/team_provider.dart';
import 'add_team_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 1; // Teams tab selected by default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Coach Dashboard',
          style: TextStyle(
            color: Color(0xFF2C3E50),
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _buildBody(),
      floatingActionButton: _selectedIndex == 1
          ? FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateTeamFlow(),
            ),
          );
        },
        backgroundColor: const Color(0xFF2196F3),
        icon: const Icon(Icons.add),
        label: const Text('Add Team'),
      )
          : null,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF2196F3),
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.groups_outlined),
            activeIcon: Icon(Icons.groups),
            label: 'Teams',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center_outlined),
            activeIcon: Icon(Icons.fitness_center),
            label: 'Library',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up_outlined),
            activeIcon: Icon(Icons.trending_up),
            label: 'Skills',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return _buildDashboardTab();
      case 1:
        return _buildTeamsTab();
      case 2:
        return _buildWorkoutsTab();
      case 3:
        return _buildSkillsTab();
      case 4:
        return _buildSettingsTab();
      default:
        return _buildTeamsTab();
    }
  }

  Widget _buildDashboardTab() {
    return const MemberLibraryScreen();
  }

  Widget _buildTeamsTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        if (teamProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Teams',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'Age Groups',
                style: TextStyle(fontSize: 16.sp, color: Colors.grey[600]),
              ),
              SizedBox(height: 16.h),

              // ✅ اعتمد مباشرة على الـenum
              ...AgeCategory.values.map((cat) {
                final teams = teamProvider.getTeamsByAgeGroup(cat);
                if (teams.isEmpty) return const SizedBox.shrink();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2196F3).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Text(
                        // عنوان المجموعة: الاسم العربي من الـenum
                        cat.arabicName,
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF2196F3),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    ...teams.map((team) => TeamCard(team: team)),
                    SizedBox(height: 16.h),
                  ],
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildWorkoutsTab() {
    return const LibraryScreen();
  }

  Widget _buildSkillsTab() {
    return Center(
      child: Text(
        'Skills Overview',
        style: TextStyle(fontSize: 18.sp),
      ),
    );
  }

  Widget _buildSettingsTab() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        ListTile(
          leading: const Icon(Icons.language),
          title: const Text('Language'),
          trailing: const Text('English'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.backup),
          title: const Text('Backup & Restore'),
          onTap: () {},
        ),
        ListTile(
          leading: const Icon(Icons.notifications),
          title: const Text('Notifications'),
          trailing: Switch(
            value: true,
            onChanged: (value) {},
          ),
        ),
      ],
    );
  }
}