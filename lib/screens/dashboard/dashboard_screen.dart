import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/theme/text_theme.dart';
import 'package:itqan_gym/screens/settings/screens/settings_screen.dart';
import 'package:itqan_gym/screens/team/teams_tab.dart';
import '../../screens/library/library_screen.dart';
import '../../screens/member/member_library_screen.dart';
import '../member/add_member_screen/add_member_screen.dart';
import 'add_team_screen.dart';


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
    _fadeCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
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
    final l10n = AppLocalizations.of(context);

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    return Scaffold(
      body: SafeArea(
        child: FadeTransition(
          opacity: _fade,
          child: _buildBody(_index),
        ),
      ),

      floatingActionButton: SpeedDial(
        icon: Icons.add,
        activeIcon: Icons.close,
        backgroundColor: Theme.of(context).primaryColor,
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
          // Add member
          SpeedDialChild(
            label: l10n.addMemberToLibrary,
            labelStyle: AppTextTheme.darkTextTheme.bodyMedium,
            labelBackgroundColor: ColorsManager.secondaryColor,
            child: const Icon(
              Icons.person_add,
              color: ColorsManager.backgroundSurface,
            ),
            backgroundColor: ColorsManager.secondaryColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const AddGlobalMemberScreen(),
                ),
              );
            },
          ),
          // Add team
          SpeedDialChild(
            label: l10n.addTeam,
            labelStyle: AppTextTheme.darkTextTheme.bodyMedium,
            labelBackgroundColor: ColorsManager.secondLightColor,
            child: const Icon(
              Icons.group_add,
              color: ColorsManager.backgroundSurface,
            ),
            backgroundColor: ColorsManager.secondLightColor,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CreateTeamFlow(),
                ),
              );
            },
          ),
        ],
      ),

      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

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
        return const TeamsTab();
      case 2:
        return const LibraryScreen();
      case 3:
        return const SettingsScreen();
      default:
        return const SizedBox.shrink();
    }
  }

}