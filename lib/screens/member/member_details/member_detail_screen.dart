// ============= MemberDetailScreen المحدث - نسخة محسنة =============
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/member/member_details/taps/member_exercises_tab.dart';
import 'package:itqan_gym/screens/member/member_details/taps/member_progress_tab.dart';
import 'package:itqan_gym/screens/member/member_details/taps/notes_tap.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/member_header_widget.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/progress/progress_summary_card.dart';
import 'package:itqan_gym/screens/member/member_notes_actions.dart';
import 'package:provider/provider.dart' show Provider;

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
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  bool _isLoading = false;
  String? _error;
  late Member _currentMember;

  // Mock data - replace with real data from providers
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
    {
      'name': 'القفز على المهر',
      'progress': 25.0,
      'status': 'بداية',
      'lastUpdated': DateTime.now().subtract(const Duration(days: 5)),
      'color': ColorsManager.warningFill,
      'icon': Icons.play_circle_outline_rounded,
    },
    {
      'name': 'التمارين الحرة',
      'progress': 0.0,
      'status': 'لم يبدأ',
      'lastUpdated': null,
      'color': ColorsManager.errorFill,
      'icon': Icons.radio_button_unchecked_rounded,
    },
  ];

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _currentMember = widget.member;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMemberData();
      _initializeNotesProvider();
    });
  }

  void _initializeNotesProvider() {
    final notesProvider = Provider.of<MemberNotesProvider>(context, listen: false);
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
      final memberLibraryProvider = Provider.of<MemberLibraryProvider>(context, listen: false);
      final updatedMember = memberLibraryProvider.getMemberById(widget.member.id);

      if (updatedMember != null && mounted) {
        final progress = await compute(_calculateProgress, _exerciseProgress);

        setState(() {
          _currentMember = updatedMember.copyWith(overallProgress: progress);
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
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  static double _calculateProgress(List<Map<String, dynamic>> exercises) {
    if (exercises.isEmpty) return 0.0;
    double total = exercises.map((e) => e['progress'] as double).reduce((a, b) => a + b);
    return total / exercises.length;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: 'ملف العضو',
        action: Row(
          children: [
            IconButton(
              onPressed: () => _editMember(),
              icon: Icon(
                Icons.edit_rounded,
                color: ColorsManager.primaryColor,
                size: SizeApp.iconSize,
              ),
            ),
            IconButton(
              onPressed: () => _showMemberOptions(),
              icon: Icon(
                Icons.more_vert_rounded,
                color: ColorsManager.defaultTextSecondary,
                size: SizeApp.iconSize,
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const LoadingSpinner()
          : _error != null
          ? EmptyStateWidget(
        title: 'حدث خطأ',
        subtitle: 'لم نتمكن من تحميل بيانات العضو، يرجى المحاولة مرة أخرى',
        buttonText: 'إعادة المحاولة',
        assetSvgPath: AssetsManager.notFoundIcon,
        onPressed: _loadMemberData,
      )
          : _buildContent(),
    );
  }

  Widget _buildContent() {
    return Column(
      children: [
        RepaintBoundary(child: MemberHeaderWidget(member: widget.member)),
        Container(
          color: Colors.white,
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
            tabs: const [
              Tab(text: 'التقدم'),
              Tab(text: 'التمارين'),
              Tab(text: 'الملاحظات'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              // ✅ استخدام الكلاس الجديد للتقدم
              MemberProgressTab(
                member: _currentMember,
                exerciseProgress: _exerciseProgress,
              ),

              // ✅ استخدام الكلاس الجديد للتمارين
              MemberExercisesTab(
                member: _currentMember,
                exerciseProgress: _exerciseProgress,
                onAddExercise: _addNewExercise,
              ),

              // ✅ استخدام الكلاس الجديد للملاحظات
              MemberNotesTab(
                member: _currentMember,
                onEditGeneralNotes: _editGeneralNotes,
                onAddDetailedNote: _addDetailedNote,
                onViewAllNotes: _viewAllNotes,
                onViewNoteDetails: _viewNoteDetails,
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Functions

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

  void _addNewExercise() {
    MemberExerciseActions.addNewExercise(
      context: context,
      member: _currentMember,
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

  Color _getLevelColor(String level) => MemberUtils.getLevelColor(level);

}