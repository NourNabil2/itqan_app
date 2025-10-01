import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:provider/provider.dart';
import '../../../providers/member_provider.dart';

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
    _notesProvider = Provider.of<MemberNotesProvider>(context, listen: false);
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: CustomAppBar(
        title: l10n.memberNotes(widget.member.name),
        action: IconButton(
          onPressed: () => _showAddNoteDialog(),
          icon: Icon(
            Icons.add_rounded,
            color: theme.primaryColor,
            size: SizeApp.iconSize,
          ),
        ),
      ),
      body: Consumer<MemberNotesProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.error != null) {
            return _buildErrorState(provider.error!);
          }

          return Column(
            children: [
              _buildStatsHeader(provider),
              Container(
                color: theme.cardColor,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  labelColor: theme.primaryColor,
                  unselectedLabelColor: theme.textTheme.bodySmall?.color,
                  indicatorColor: theme.primaryColor,
                  labelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: [
                    Tab(text: l10n.allNotesCount(provider.allNotes.length)),
                    Tab(text: l10n.generalNotesCount(provider.getNotesCountByType('general'))),
                    Tab(text: l10n.performanceNotesCount(provider.getNotesCountByType('performance'))),
                    Tab(text: l10n.behaviorNotesCount(provider.getNotesCountByType('behavior'))),
                    Tab(text: l10n.healthNotesCount(provider.getNotesCountByType('health'))),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildNotesTab(provider.allNotes),
                    _buildNotesTab(provider.getNotesByType('general')),
                    _buildNotesTab(provider.getNotesByType('performance')),
                    _buildNotesTab(provider.getNotesByType('behavior')),
                    _buildNotesTab(provider.getNotesByType('health')),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              color: theme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeApp.radius),
            ),
            child: CircularProgressIndicator(
              color: theme.primaryColor,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            l10n.loadingNotes,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.textTheme.bodySmall?.color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SizedBox(height: SizeApp.s20),
        ErrorContainer(
          errors: [error],
          margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
        ),
        const Spacer(),
        EmptyStateWidget(
          title: l10n.errorOccurred,
          subtitle: l10n.couldNotLoadNotes,
          buttonText: l10n.retryAgain,
          assetSvgPath: AssetsManager.notFoundIcon,
          onPressed: () {
            _notesProvider.clearError();
            _loadNotes();
          },
        ),
        const Spacer(),
      ],
    );
  }

  Widget _buildStatsHeader(MemberNotesProvider provider) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final highPriorityCount = provider.getHighPriorityNotes().length;
    final recentNotesCount = provider.allNotes.where((note) =>
    DateTime.now().difference(note.createdAt).inDays <= 7).length;

    return Container(
      color: theme.cardColor,
      padding: EdgeInsets.all(SizeApp.s16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              l10n.totalNotes,
              '${provider.allNotes.length}',
              Icons.note_outlined,
              theme.primaryColor,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: theme.dividerColor.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              l10n.highPriority,
              '$highPriorityCount',
              Icons.priority_high_rounded,
              ColorsManager.errorFill,
            ),
          ),
          Container(
            width: 1,
            height: 40.h,
            color: theme.dividerColor.withOpacity(0.2),
          ),
          Expanded(
            child: _buildStatItem(
              l10n.thisWeek,
              '$recentNotesCount',
              Icons.schedule_rounded,
              ColorsManager.successFill,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            icon,
            size: 20.sp,
            color: color,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
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
        onPressed: () => _showAddNoteDialog(),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeApp.s16),
      itemCount: notes.length,
      itemBuilder: (context, index) {
        return _buildNoteCard(notes[index]);
      },
    );
  }

  Widget _buildNoteCard(MemberNote note) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final noteType = NoteType.values.firstWhere(
          (type) => type.value == note.noteType,
      orElse: () => NoteType.general,
    );

    final priority = NotePriority.values.firstWhere(
          (p) => p.value == note.priority,
      orElse: () => NotePriority.normal,
    );

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
        border: note.priority == 'high'
            ? Border.all(color: ColorsManager.errorFill.withOpacity(0.3), width: 2)
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          onTap: () => _showNoteDetails(note),
          child: Padding(
            padding: EdgeInsets.all(SizeApp.s16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(6.w),
                      decoration: BoxDecoration(
                        color: priority.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Icon(
                        noteType.icon,
                        size: 16.sp,
                        color: priority.color,
                      ),
                    ),
                    SizedBox(width: SizeApp.s8),
                    Expanded(
                      child: Text(
                        note.title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.priority == 'high')
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 6.w,
                          vertical: 2.h,
                        ),
                        decoration: BoxDecoration(
                          color: ColorsManager.errorFill,
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        child: Text(
                          l10n.important,
                          style: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        size: 18.sp,
                        color: theme.iconTheme.color?.withOpacity(0.6),
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text(l10n.edit),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_rounded,
                                size: 16.sp,
                                color: ColorsManager.errorFill,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                l10n.delete,
                                style: TextStyle(color: ColorsManager.errorFill),
                              ),
                            ],
                          ),
                        ),
                      ],
                      onSelected: (value) async {
                        if (value == 'edit') {
                          _showEditNoteDialog(note);
                        } else if (value == 'delete') {
                          _showDeleteNoteDialog(note);
                        }
                      },
                    ),
                  ],
                ),
                SizedBox(height: SizeApp.s12),
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeApp.s12),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: ColorsManager.infoSurface,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        noteType.getLocalizedName(context),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsManager.infoText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (note.createdBy != null) ...[
                      Text(
                        note.createdBy!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        '•',
                        style: TextStyle(
                          color: theme.textTheme.bodySmall?.color,
                        ),
                      ),
                      SizedBox(width: 6.w),
                    ],
                    Text(
                      _formatDate(note.createdAt),
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  void _showAddNoteDialog() {
    _showNoteDialog();
  }

  void _showEditNoteDialog(MemberNote note) {
    _showNoteDialog(note: note);
  }

  void _showNoteDialog({MemberNote? note}) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isEditing = note != null;
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String selectedType = note?.noteType ?? 'general';
    String selectedPriority = note?.priority ?? 'normal';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: theme.dialogBackgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          ),
          title: Text(
            isEditing ? l10n.editNote : l10n.addNewNote,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  controller: titleController,
                  hintText: l10n.noteTitle,
                  title: l10n.title,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterNoteTitle;
                    }
                    return null;
                  },
                ),
                SizedBox(height: SizeApp.s12),
                AppTextFieldFactory.textArea(
                  controller: contentController,
                  hintText: l10n.writeNoteHere,
                  title: l10n.noteContent,
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.enterNoteContent;
                    }
                    return null;
                  },
                ),
                SizedBox(height: SizeApp.s12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.type,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            items: NoteType.values.map((type) => DropdownMenuItem(
                              value: type.value,
                              child: Row(
                                children: [
                                  Icon(type.icon, size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text(type.getLocalizedName(context)),
                                ],
                              ),
                            )).toList(),
                            onChanged: (value) => setDialogState(() => selectedType = value!),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: SizeApp.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.priority,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          DropdownButtonFormField<String>(
                            value: selectedPriority,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: 12.w,
                                vertical: 8.h,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8.r),
                              ),
                            ),
                            items: NotePriority.values.map((priority) => DropdownMenuItem(
                              value: priority.value,
                              child: Row(
                                children: [
                                  Container(
                                    width: 8.w,
                                    height: 8.h,
                                    decoration: BoxDecoration(
                                      color: priority.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  SizedBox(width: 8.w),
                                  Text(priority.getLocalizedName(context)),
                                ],
                              ),
                            )).toList(),
                            onChanged: (value) => setDialogState(() => selectedPriority = value!),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(l10n.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.trim().isNotEmpty &&
                    contentController.text.trim().isNotEmpty) {
                  await _saveNote(
                    note: note,
                    title: titleController.text.trim(),
                    content: contentController.text.trim(),
                    type: selectedType,
                    priority: selectedPriority,
                  );
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: Text(isEditing ? l10n.update : l10n.save),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDetails(MemberNote note) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final noteType = NoteType.values.firstWhere(
          (type) => type.value == note.noteType,
      orElse: () => NoteType.general,
    );

    final notePriority = NotePriority.values.firstWhere(
          (p) => p.value == note.priority,
      orElse: () => NotePriority.normal,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        ),
        title: Row(
          children: [
            Icon(noteType.icon, color: theme.primaryColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                note.title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.content,
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
            SizedBox(height: SizeApp.s16),
            Container(
              padding: EdgeInsets.all(SizeApp.s12),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.noteDetails}:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '${l10n.type}: ${noteType.getLocalizedName(context)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  Text(
                    '${l10n.priority}: ${notePriority.getLocalizedName(context)}',
                    style: theme.textTheme.bodySmall,
                  ),
                  if (note.createdBy != null)
                    Text(
                      '${l10n.trainer}: ${note.createdBy}',
                      style: theme.textTheme.bodySmall,
                    ),
                  Text(
                    '${l10n.date}: ${_formatDate(note.createdAt)}',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.close),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditNoteDialog(note);
            },
            child: Text(l10n.edit),
          ),
        ],
      ),
    );
  }

  void _showDeleteNoteDialog(MemberNote note) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          l10n.deleteNote,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorsManager.errorFill,
          ),
        ),
        content: Text(
          l10n.deleteNoteConfirmation,
          style: theme.textTheme.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNote(note);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.delete),
          ),
        ],
      ),
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            note != null
                ? l10n.noteUpdatedSuccessfully
                : l10n.noteAddedSuccessfully,
          ),
          backgroundColor: ColorsManager.successFill,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            note != null
                ? l10n.errorUpdatingNote
                : l10n.errorAddingNote,
          ),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    }
  }

  Future<void> _deleteNote(MemberNote note) async {
    final l10n = AppLocalizations.of(context);

    try {
      await _notesProvider.deleteNote(note.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noteDeletedSuccessfully),
          backgroundColor: ColorsManager.successFill,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.errorDeletingNote),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return l10n.today;
    } else if (difference.inDays == 1) {
      return l10n.yesterday;
    } else if (difference.inDays < 7) {
      return l10n.daysAgo(difference.inDays);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}