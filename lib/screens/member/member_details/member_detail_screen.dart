// ============= MemberDetailScreen المحدث - Integration =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/member/member_details/taps/member_exercises_tab.dart';
import 'package:itqan_gym/screens/member/member_details/taps/notes_tap.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/member_header_widget.dart';
import 'package:itqan_gym/screens/member/member_notes_actions.dart';
import 'package:provider/provider.dart';

import 'taps/member_progress_tab.dart';

class MemberDetailScreen extends StatefulWidget {
  final Member member;
  final String? teamId;

  const MemberDetailScreen({
    super.key,
    required this.member,
    this.teamId,
  });

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  late Member _currentMember;

  // Mock data - استبدله ببيانات حقيقية
  final List<Map<String, dynamic>> _exerciseProgress = [
    {
      'name': 'التوازن على العارضة',
      'progress': 85.0,
      'status': 'مكتمل',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 2)),
      'color': ColorsManager.successFill,
      'icon': Icons.check_circle_rounded,
    },
    {
      'name': 'تمارين الأرضي',
      'progress': 65.0,
      'status': 'قيد التقدم',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 1)),
      'color': ColorsManager.primaryColor,
      'icon': Icons.schedule_rounded,
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentMember = widget.member;
    _initializeScreen();
  }

  void _initializeScreen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemberData();
      _initializeNotesProvider();
    });
  }

  void _initializeNotesProvider() {
    final notesProvider = context.read<MemberNotesProvider>();
    notesProvider.resetProvider();
    notesProvider.loadMemberNotes(_currentMember.id);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadMemberData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final memberLibraryProvider = context.read<MemberLibraryProvider>();
      final updatedMember = memberLibraryProvider.getMemberById(widget.member.id);

      if (updatedMember != null && mounted) {
        setState(() {
          _currentMember = updatedMember;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'حدث خطأ في تحميل بيانات العضو: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildAppBar(),
      body: _isLoading
          ? const LoadingSpinner()
          : _error != null
          ? _buildErrorState()
          : _buildContent(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return CustomAppBar(
      title: 'ملف العضو',
      action: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: _editMember,
            icon: Icon(
              Icons.edit_rounded,
              color: ColorsManager.primaryColor,
              size: SizeApp.iconSize,
            ),
            tooltip: 'تعديل',
          ),
          IconButton(
            onPressed: _showMemberOptions,
            icon: Icon(
              Icons.more_vert_rounded,
              color: ColorsManager.defaultTextSecondary,
              size: SizeApp.iconSize,
            ),
            tooltip: 'خيارات',
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return EmptyStateWidget(
      title: 'حدث خطأ',
      subtitle: 'لم نتمكن من تحميل بيانات العضو، يرجى المحاولة مرة أخرى',
      buttonText: 'إعادة المحاولة',
      assetSvgPath: AssetsManager.notFoundIcon,
      onPressed: _loadMemberData,
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        // Header with Overall Progress
        RepaintBoundary(
          child: MemberHeaderWidget(
            member: _currentMember,
            onAvatarTap: () {
              // Handle avatar tap
            },
          ),
        ),

        // Tab Bar
        _buildTabBar(),

        // Tab Views
        Expanded(
          child: _buildTabBarView(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return SizedBox(
      height: 60.h,
      child: TabBar(
        controller: _tabController,
        labelColor: ColorsManager.primaryColor,
        unselectedLabelColor: ColorsManager.defaultTextSecondary,
        indicatorColor: ColorsManager.primaryColor,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: [
          Tab(
            icon: Icon(Icons.trending_up_rounded, size: SizeApp.iconSizeSmall),
            text: 'التقدم',
          ),
          Tab(
            icon: Icon(Icons.fitness_center_rounded, size: SizeApp.iconSizeSmall),
            text: 'المهارات',
          ),
          Tab(
            icon: Icon(Icons.note_rounded, size: SizeApp.iconSizeSmall),
            text: 'الملاحظات',
          ),
        ],
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: [
        // Progress Tab - محدث
        MemberProgressTab(
          member: _currentMember,
        ),

        // Skills/Exercises Tab
        MemberSkillsTab(
          member: _currentMember,
          onAddSkill: () {
            // Handle add skill
          },
        ),

        // Notes Tab - محدث
        MemberNotesTab(
          member: _currentMember,
          onEditGeneralNotes: _editGeneralNotes,
          onAddDetailedNote: _addDetailedNote,
          onViewAllNotes: _viewAllNotes,
          onViewNoteDetails: _viewNoteDetails,
        ),
      ],
    );
  }

  // ============= Actions Methods =============

  void _editGeneralNotes() {
    MemberNotesActions.editGeneralNotes(
      context: context,
      currentMember: _currentMember,
      onMemberUpdated: (updatedMember) {
        setState(() {
          _currentMember = updatedMember;
        });
      },
      teamId: widget.teamId,
    );
  }

  void _addDetailedNote() {
    MemberNotesActions.addDetailedNote(
      context: context,
      member: _currentMember,
    );
  }

  void _viewAllNotes() {
    MemberNotesActions.viewAllNotes(
      context: context,
      member: _currentMember,
    );
  }

  void _viewNoteDetails(MemberNote note) {
    MemberNotesActions.viewNoteDetails(
      context: context,
      note: note,
      onViewAll: _viewAllNotes,
    );
  }

  void _editMember() {
    MemberProfileActions.editMember(
      context: context,
      member: _currentMember,
      onSuccess: _loadMemberData,
    );
  }

  void _showMemberOptions() {
    MemberProfileActions.showMemberOptions(
      context: context,
      member: _currentMember,
      teamId: widget.teamId,
    );
  }
}