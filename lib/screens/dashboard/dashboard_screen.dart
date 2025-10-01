import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/theme/text_theme.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/screens/dashboard/widgets/age_group_section.dart';
import 'package:itqan_gym/screens/settings/screens/settings_screen.dart';
import 'package:provider/provider.dart';

import '../../core/utils/enums.dart';
import '../../core/widgets/team_card.dart';
import '../../providers/team_provider.dart';
import '../../screens/library/library_screen.dart';
import '../../screens/member/member_library_screen.dart';
import '../member/add_member_screen/add_member_screen.dart';
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
        backgroundColor:Theme.of(context).primaryColor,
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
            labelStyle: AppTextTheme.darkTextTheme.bodyMedium,
            labelBackgroundColor: ColorsManager.secondaryColor,
            child: const Icon(Icons.person_add, color: ColorsManager.backgroundSurface),
            backgroundColor: ColorsManager.secondaryColor,
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
            labelStyle: AppTextTheme.darkTextTheme.bodyMedium,
            labelBackgroundColor: ColorsManager.secondLightColor,
            child: const Icon(Icons.group_add, color: ColorsManager.backgroundSurface),
            backgroundColor: ColorsManager.secondLightColor,
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
        backgroundColor: Theme.of(context).cardColor,
        activeColor: Theme.of(context).primaryColor,
        inactiveColor: Theme.of(context).hintColor,
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
        return const SettingsScreen();
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

        return CustomScrollView(
          slivers: [
            const SliverToBoxAdapter(
              child: LogoBoxHeader(
                title: 'ITQAN',
                subtitle: 'Manage teams & track skills',
                assetLogo: AssetsManager.logo,
              ),
            ),

            // حالة: لا توجد فرق
            if (teamProvider.teams.isEmpty)
              SliverFillRemaining(
                hasScrollBody: false,
                child: EmptyStateWidget(
                  title: 'لا توجد فرق بعد',
                  subtitle: 'ابدأ بإنشاء أول فريق لك لتنظيم الأعضاء والتمارين.',
                  buttonText: 'إنشاء فريق',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CreateTeamFlow()),
                    );
                  },
                  assetSvgPath: AssetsManager.iconsTeamIcons, // أو استخدم iconData
                  buttonIcon: Icons.group_add,
                ),
              )
            else ...[
              // عنوان القسم
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeApp.padding),
                  child: Row(
                    children: [
                      // Divider على الجهة اليسرى
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),

                      // مسافة صغيرة
                      const SizedBox(width: 8),

                      // النص في المنتصف
                      Text(
                        'Teams',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),

                      // مسافة صغيرة
                      const SizedBox(width: 8),

                      // Divider على الجهة اليمنى
                      Expanded(
                        child: Divider(
                          thickness: 1,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),


              // الليست
              SliverPadding(
                padding: EdgeInsets.all(SizeApp.padding),
                sliver: SliverList.separated(
                  itemCount: AgeCategory.values.length,
                  separatorBuilder: (_, __) => SizedBox(height: 8.h),
                  itemBuilder: (_, idx) =>
                      _buildAgeSection(AgeCategory.values[idx], teamProvider),
                ),
              ),
            ],
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


}
