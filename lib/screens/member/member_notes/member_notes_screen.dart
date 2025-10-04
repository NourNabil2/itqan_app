// lib/screens/member_notes/member_notes_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/delete_note_dialog.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/note_card_widget.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/note_details_dialog.dart';
import 'package:itqan_gym/screens/member/member_notes/widgets/note_form_dialog.dart';
import 'package:provider/provider.dart';

class MemberNotesScreen extends StatefulWidget {
  final Member member;

  const MemberNotesScreen({super.key, required this.member});

  @override
  State<MemberNotesScreen> createState() => _MemberNotesScreenState();
}

class _MemberNotesScreenState extends State<MemberNotesScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late MemberNotesProvider _notesProvider;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _notesProvider = context.read<MemberNotesProvider>();
    _loadNotes();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadNotes() async {
    await _notesProvider.loadMemberNotes(widget.member.id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.memberNotes(widget.member.name),
        action: IconButton(
          onPressed: _handleAddNote,
          icon: Icon(Icons.add_rounded, size: 24.sp),
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer,
            foregroundColor: colorScheme.primary,
          ),
        ),
      ),
      body: Consumer<MemberNotesProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return Column(
            children: [
              _buildStatsHeader(provider),
              _buildTabBar(provider),
              Expanded(
                child: _buildTabBarView(provider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: CircularProgressIndicator(
              color: colorScheme.primary,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.loadingNotes,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(20.w),
              decoration: BoxDecoration(
                color: colorScheme.errorContainer,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.error_outline,
                size: 48.sp,
                color: colorScheme.error,
              ),
            ),
            SizedBox(height: 20.h),
            Text(
              l10n.errorOccurred,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              error,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 24.h),
            FilledButton.icon(
              onPressed: () {
                _notesProvider.clearError();
                _loadNotes();
              },
              icon: Icon(Icons.refresh, size: 18.sp),
              label: Text(l10n.retryAgain),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsHeader(MemberNotesProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    final highPriorityCount = provider.getHighPriorityNotes().length;
    final recentNotesCount = provider.allNotes
        .where((note) => DateTime.now().difference(note.createdAt).inDays <= 7)
        .length;

    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              l10n.totalNotes,
              '${provider.allNotes.length}',
              Icons.note_outlined,
              colorScheme.primary,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: _buildStatItem(
              l10n.highPriority,
              '$highPriorityCount',
              Icons.priority_high_rounded,
              colorScheme.error,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: colorScheme.outlineVariant,
          ),
          Expanded(
            child: _buildStatItem(
              l10n.thisWeek,
              '$recentNotesCount',
              Icons.schedule_rounded,
              colorScheme.tertiary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: EdgeInsets.all(10.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Icon(icon, size: 22.sp, color: color),
        ),
        SizedBox(height: 8.h),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        SizedBox(height: 2.h),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildTabBar(MemberNotesProvider provider) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return TabBar(
      controller: _tabController,
      isScrollable: true,
      labelColor: colorScheme.primary,
      unselectedLabelColor: colorScheme.onSurfaceVariant,
      indicatorColor: colorScheme.primary,
      indicatorWeight: 3,
      labelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
      unselectedLabelStyle: theme.textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w500,
      ),
      tabs: [
        Tab(text: l10n.allNotesCount(provider.allNotes.length)),
        Tab(text: l10n.generalNotesCount(provider.getNotesCountByType('general'))),
        Tab(text: l10n.performanceNotesCount(provider.getNotesCountByType('performance'))),
        Tab(text: l10n.behaviorNotesCount(provider.getNotesCountByType('behavior'))),
        Tab(text: l10n.healthNotesCount(provider.getNotesCountByType('health'))),
      ],
    );
  }

  Widget _buildTabBarView(MemberNotesProvider provider) {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildNotesTab(provider.allNotes),
        _buildNotesTab(provider.getNotesByType('general')),
        _buildNotesTab(provider.getNotesByType('performance')),
        _buildNotesTab(provider.getNotesByType('behavior')),
        _buildNotesTab(provider.getNotesByType('health')),
      ],
    );
  }

  Widget _buildNotesTab(List<MemberNote> notes) {
    final l10n = AppLocalizations.of(context);

    if (notes.isEmpty) {
      return EmptyStateWidget(
        title: l10n.noNotes,
        subtitle: l10n.noNotesOfThisType,
        buttonText: l10n.addNote,
        assetSvgPath: AssetsManager.iconsNoteIcon,
        onPressed: _handleAddNote,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotes,
      child: ListView.builder(
        padding: EdgeInsets.all(16.w),
        itemCount: notes.length,
        itemBuilder: (context, index) {
          return NoteCard(
            note: notes[index],
            onTap: () => _handleNoteDetails(notes[index]),
            onEdit: () => _handleEditNote(notes[index]),
            onDelete: () => _handleDeleteNote(notes[index]),
          );
        },
      ),
    );
  }

  // ==================== Handlers ====================

  void _handleAddNote() {
    NoteFormDialog.show(
      context,
      onSave: (title, content, type, priority) async {
        await _saveNote(
          title: title,
          content: content,
          type: type,
          priority: priority,
        );
      },
    );
  }

  void _handleEditNote(MemberNote note) {
    NoteFormDialog.show(
      context,
      note: note,
      onSave: (title, content, type, priority) async {
        await _saveNote(
          note: note,
          title: title,
          content: content,
          type: type,
          priority: priority,
        );
      },
    );
  }

  void _handleNoteDetails(MemberNote note) {
    NoteDetailsDialog.show(
      context,
      note: note,
      onEdit: () => _handleEditNote(note),
    );
  }

  void _handleDeleteNote(MemberNote note) {
    DeleteNoteDialog.show(
      context,
      onConfirm: () => _deleteNote(note),
    );
  }

  Future<void> _saveNote({
    MemberNote? note,
    required String title,
    required String content,
    required String type,
    required String priority,
  }) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      if (note != null) {
        final updatedNote = note.copyWith(
          title: title,
          content: content,
          noteType: type,
          priority: priority,
          updatedAt: DateTime.now(),
        );
        await _notesProvider.updateNote(updatedNote);
      } else {
        final newNote = MemberNote(
          memberId: widget.member.id,
          title: title,
          content: content,
          noteType: type,
          priority: priority,
          createdBy: l10n.currentTrainer,
        );
        await _notesProvider.addNote(newNote);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              note != null ? l10n.noteUpdatedSuccessfully : l10n.noteAddedSuccessfully,
            ),
            backgroundColor: colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              note != null ? l10n.errorUpdatingNote : l10n.errorAddingNote,
            ),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Future<void> _deleteNote(MemberNote note) async {
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;

    try {
      await _notesProvider.deleteNote(note.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noteDeletedSuccessfully),
            backgroundColor: colorScheme.tertiary,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingNote),
            backgroundColor: colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }
}