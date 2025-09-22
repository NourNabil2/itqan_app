import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/screens/dashboard/widgets/age_group_section.dart';
import 'package:provider/provider.dart';

import '../../core/utils/enums.dart';
import '../../core/widgets/team_card.dart';
import '../../providers/team_provider.dart';
import '../../screens/library/library_screen.dart';
import '../../screens/member/member_library_screen.dart';
import '../member/add_member_screen.dart';
import 'add_team_screen.dart';
import 'widgets/logo_box_header.dart'; // يحتوي CreateTeamFlow

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen>
    with SingleTickerProviderStateMixin {
  int _index = 1;
  late final AnimationController _fadeCtrl;
  late final Animation<double> _fade;

  final _icons = const [
    Icons.people_alt_outlined, // Members
    Icons.groups_outlined,     // Teams
    Icons.folder_outlined,     // Library
    Icons.settings_outlined,   // Settings
  ];

  @override
  void initState() {
    super.initState();
    _fadeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 250));
    _fade = CurvedAnimation(parent: _fadeCtrl, curve: Curves.easeInOut);
    _fadeCtrl.forward();
  }

  @override
  void dispose() {
    _fadeCtrl.dispose();
    super.dispose();
  }

  void _changeTab(int i) async {
    await _fadeCtrl.reverse();
    if (!mounted) return;
    setState(() => _index = i);
    _fadeCtrl.forward();
  }

  @override
  Widget build(BuildContext context) {
    // Status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(statusBarColor: Colors.transparent, statusBarIconBrightness: Brightness.dark),
    );

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(opacity: _fade, child: _buildBody(_index)),
      ),


      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: const Color(0xFF2196F3),
        foregroundColor: Colors.white,
        elevation: 6,
        spacing: 6,
        spaceBetweenChildren: 8,
        direction: SpeedDialDirection.up,
        renderOverlay: true,
        overlayColor: Colors.black,
        overlayOpacity: 0.15,
        shape: const StadiumBorder(),
        children: [
          // إضافة عضو للمكتبة
          SpeedDialChild(
            label: 'إضافة عضو',
            labelStyle: TextStyle(fontSize: 14.sp, color: Colors.white),
            labelBackgroundColor: const Color(0xFF4CAF50),
            child: const Icon(Icons.person_add, color: Colors.white),
            backgroundColor: const Color(0xFF4CAF50),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AddGlobalMemberScreen()),
              );
            },
          ),
          // إنشاء فريق
          SpeedDialChild(
            label: 'إضافة فريق',
            labelStyle: TextStyle(fontSize: 14.sp, color: Colors.white),
            labelBackgroundColor: const Color(0xFFFF9800),
            child: const Icon(Icons.group_add, color: Colors.white),
            backgroundColor: const Color(0xFFFF9800),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTeamFlow()),
              );
            },
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      /// Bottom bar
      bottomNavigationBar: AnimatedBottomNavigationBar(
        icons: _icons,
        activeIndex: _index,
        gapLocation: GapLocation.center,
        notchSmoothness: NotchSmoothness.softEdge,
        leftCornerRadius: 18,
        rightCornerRadius: 18,
        backgroundColor: Colors.white,
        activeColor: const Color(0xFF2196F3),
        inactiveColor: Colors.grey[600],
        elevation: 12,
        onTap: _changeTab,
      ),
    );
  }

  Widget _buildBody(int i) {
    switch (i) {
      case 0:
        return const MemberLibraryScreen();
      case 1:
        return _buildTeamsTab();
      case 2:
        return const LibraryScreen();
      case 3:
        return _buildSettingsTab();
      default:
        return const SizedBox.shrink();
    }
  }

  // ===== Teams Tab =====
  Widget _buildTeamsTab() {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, _) {
        if (teamProvider.isLoading) {
          return const LoadingSpinner();
        }

        if (teamProvider.teams.isEmpty) {
          return EmptyStateWidget(
            title: 'لا توجد فرق حتى الآن',
            subtitle: 'ابدأ بإضافة فريقك الأول',
            buttonText: 'إضافة فريق',
            icon: Icons.groups_outlined,
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateTeamFlow()),
              );
            },
          );
        }


        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: LogoBoxHeader(
                title: 'ITQAN',
                subtitle: 'Manage teams & track skills',
                assetLogo: AssetsManager.logo,
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  SizeApp.padding,
                  0,
                  SizeApp.padding,
                  0,
                ),
                child: Text(
                  'Teams',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
            ),
            SliverPadding(
              padding: EdgeInsets.all(SizeApp.padding),
              sliver: SliverList.separated(
                itemCount: AgeCategory.values.length,
                separatorBuilder: (_, __) => SizedBox(height: 8.h),
                itemBuilder: (_, idx) => _buildAgeSection(AgeCategory.values[idx], teamProvider),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildAgeSection(AgeCategory category, TeamProvider provider) {
    final teams = provider.getTeamsByAgeGroup(category);
    if (teams.isEmpty) return const SizedBox.shrink();

    return AgeGroupSection(
      title: category.arabicName,
      count: teams.length,
      initiallyExpanded: true, // أو false لو عايزها مقفولة افتراضياً
      children: teams.map((t) => TeamCard(team: t)).toList(),
    );
  }


  // ===== Settings Tab =====
  Widget _buildSettingsTab() {
    return ListView(
      padding: EdgeInsets.all(16.w),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          margin: EdgeInsets.only(bottom: 20.h),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2196F3), Color(0xFF1976D2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('الإعدادات', style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 4.h),
              Text('تخصيص التطبيق حسب احتياجاتك',
                  style: TextStyle(fontSize: 14.sp, color: Colors.white.withOpacity(0.9))),
            ],
          ),
        ),
        _tile(icon: Icons.language, title: 'اللغة', subtitle: 'العربية', onTap: () {}),
        _tile(icon: Icons.backup, title: 'النسخ الاحتياطي', subtitle: 'حفظ واستعادة البيانات', onTap: () {}),
        _tile(
          icon: Icons.notifications,
          title: 'الإشعارات',
          trailing: Switch(value: true, onChanged: (_) {}, activeColor: const Color(0xFF2196F3)),
          onTap: () {},
        ),
        _tile(
          icon: Icons.dark_mode,
          title: 'الوضع الليلي',
          trailing: Switch(value: false, onChanged: (_) {}, activeColor: const Color(0xFF2196F3)),
          onTap: () {},
        ),
      ],
    );
  }

  Widget _tile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 40.w,
          height: 40.h,
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3).withOpacity(0.12),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: const Icon(Icons.settings, color: Color(0xFF2196F3)),
        ),
        title: Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w500)),
        subtitle: subtitle != null ? Text(subtitle, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])) : null,
        trailing: trailing ?? Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey[400]),
      ),
    );
  }
}
