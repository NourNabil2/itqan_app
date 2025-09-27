import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: 'ملاحظات ${widget.member.name}',
        action: IconButton(
          onPressed: () => _showAddNoteDialog(),
          icon: Icon(
            Icons.add_rounded,
            color: ColorsManager.primaryColor,
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
              // Stats Header
              _buildStatsHeader(provider),

              // Tabs
              Container(
                color: Colors.white,
                child: TabBar(
                  controller: _tabController,
                  isScrollable: true,
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
                    Tab(text: 'الكل (${provider.allNotes.length})'),
                    Tab(text: 'عام (${provider.getNotesCountByType('general')})'),
                    Tab(text: 'الأداء (${provider.getNotesCountByType('performance')})'),
                    Tab(text: 'السلوك (${provider.getNotesCountByType('behavior')})'),
                    Tab(text: 'الصحة (${provider.getNotesCountByType('health')})'),
                  ],
                ),
              ),

              // Tab Content
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60.w,
            height: 60.h,
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              color: ColorsManager.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(SizeApp.radius),
            ),
            child: CircularProgressIndicator(
              color: ColorsManager.primaryColor,
              strokeWidth: 3,
            ),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            'جاري تحميل الملاحظات...',
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Column(
      children: [
        SizedBox(height: SizeApp.s20),
        ErrorContainer(
          errors: [error],
          margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
        ),
        const Spacer(),
        EmptyStateWidget(
          title: 'حدث خطأ',
          subtitle: 'لم نتمكن من تحميل الملاحظات، يرجى المحاولة مرة أخرى',
          buttonText: 'إعادة المحاولة',
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
    final highPriorityCount = provider.getHighPriorityNotes().length;
    final recentNotesCount = provider.allNotes.where((note) =>
    DateTime.now().difference(note.createdAt).inDays <= 7).length;

    return Container(
      color: Colors.white,
      padding: EdgeInsets.all(SizeApp.s16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              'إجمالي الملاحظات',
              '${provider.allNotes.length}',
              Icons.note_outlined,
              ColorsManager.primaryColor,
            ),
          ),

          Container(
            width: 1,
            height: 40.h,
            color: ColorsManager.inputBorder.withOpacity(0.2),
          ),

          Expanded(
            child: _buildStatItem(
              'عالية الأولوية',
              '$highPriorityCount',
              Icons.priority_high_rounded,
              ColorsManager.errorFill,
            ),
          ),

          Container(
            width: 1,
            height: 40.h,
            color: ColorsManager.inputBorder.withOpacity(0.2),
          ),

          Expanded(
            child: _buildStatItem(
              'هذا الأسبوع',
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
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: ColorsManager.defaultTextSecondary,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNotesTab(List<MemberNote> notes) {
    if (notes.isEmpty) {
      return EmptyStateWidget(
        title: 'لا توجد ملاحظات',
        subtitle: 'لم يتم إضافة أي ملاحظات من هذا النوع بعد',
        buttonText: 'إضافة ملاحظة',
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
        color: Colors.white,
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
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.defaultText,
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
                          'مهم',
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
                        color: ColorsManager.defaultTextSecondary,
                      ),
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit_rounded, size: 16.sp),
                              SizedBox(width: 8.w),
                              Text('تعديل'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete_rounded, size: 16.sp, color: ColorsManager.errorFill),
                              SizedBox(width: 8.w),
                              Text('حذف', style: TextStyle(color: ColorsManager.errorFill)),
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: ColorsManager.defaultText,
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
                        noteType.arabicName,
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
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsManager.defaultTextSecondary,
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text('•', style: TextStyle(color: ColorsManager.defaultTextSecondary)),
                      SizedBox(width: 6.w),
                    ],

                    Text(
                      _formatDate(note.createdAt),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: ColorsManager.defaultTextSecondary,
                      ),
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
    final isEditing = note != null;
    final titleController = TextEditingController(text: note?.title ?? '');
    final contentController = TextEditingController(text: note?.content ?? '');
    String selectedType = note?.noteType ?? 'general';
    String selectedPriority = note?.priority ?? 'normal';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          ),
          title: Text(
            isEditing ? 'تعديل الملاحظة' : 'إضافة ملاحظة جديدة',
            style: TextStyle(
              fontSize: 18.sp,
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
                  hintText: 'عنوان الملاحظة',
                  title: 'العنوان',
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال عنوان الملاحظة';
                    }
                    return null;
                  },
                ),

                SizedBox(height: SizeApp.s12),

                AppTextFieldFactory.textArea(
                  controller: contentController,
                  hintText: 'اكتب الملاحظة هنا...',
                  title: 'المحتوى',
                  maxLines: 4,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'الرجاء إدخال محتوى الملاحظة';
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
                          Text('النوع', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4.h),
                          DropdownButtonFormField<String>(
                            value: selectedType,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
                            ),
                            items: NoteType.values.map((type) => DropdownMenuItem(
                              value: type.value,
                              child: Row(
                                children: [
                                  Icon(type.icon, size: 16.sp),
                                  SizedBox(width: 8.w),
                                  Text(type.arabicName),
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
                          Text('الأولوية', style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600)),
                          SizedBox(height: 4.h),
                          DropdownButtonFormField<String>(
                            value: selectedPriority,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
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
                                  Text(priority.arabicName),
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
              child: Text(
                'إلغاء',
                style: TextStyle(color: ColorsManager.defaultTextSecondary),
              ),
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
                backgroundColor: ColorsManager.primaryColor,
              ),
              child: Text(
                isEditing ? 'تحديث' : 'حفظ',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNoteDetails(MemberNote note) {
    final noteType = NoteType.values.firstWhere(
          (type) => type.value == note.noteType,
      orElse: () => NoteType.general,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        ),
        title: Row(
          children: [
            Icon(noteType.icon, color: ColorsManager.primaryColor),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                note.title,
                style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
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
              style: TextStyle(fontSize: 14.sp, height: 1.4),
            ),
            SizedBox(height: SizeApp.s16),
            Container(
              padding: EdgeInsets.all(SizeApp.s12),
              decoration: BoxDecoration(
                color: ColorsManager.defaultSurface,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('تفاصيل الملاحظة:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12.sp)),
                  SizedBox(height: 4.h),
                  Text('النوع: ${noteType.arabicName}', style: TextStyle(fontSize: 11.sp)),
                  Text('الأولوية: ${NotePriority.values.firstWhere((p) => p.value == note.priority).arabicName}', style: TextStyle(fontSize: 11.sp)),
                  if (note.createdBy != null) Text('المدرب: ${note.createdBy}', style: TextStyle(fontSize: 11.sp)),
                  Text('التاريخ: ${_formatDate(note.createdAt)}', style: TextStyle(fontSize: 11.sp)),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showEditNoteDialog(note);
            },
            child: Text('تعديل'),
          ),
        ],
      ),
    );
  }

  void _showDeleteNoteDialog(MemberNote note) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حذف الملاحظة',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.errorFill,
          ),
        ),
        content: Text('هل أنت متأكد من حذف هذه الملاحظة؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(color: ColorsManager.defaultTextSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _deleteNote(note);
            },
            style: ElevatedButton.styleFrom(backgroundColor: ColorsManager.errorFill),
            child: Text('حذف', style: TextStyle(color: Colors.white)),
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
    try {
      if (note != null) {
        // Update existing note
        final updatedNote = note.copyWith(
          title: title,
          content: content,
          noteType: type,
          priority: priority,
          updatedAt: DateTime.now(),
        );
        await _notesProvider.updateNote(updatedNote);
      } else {
        // Add new note
        final newNote = MemberNote(
          memberId: widget.member.id,
          title: title,
          content: content,
          noteType: type,
          priority: priority,
          createdBy: 'المدرب الحالي', // Get from user session
        );
        await _notesProvider.addNote(newNote);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(note != null ? 'تم تحديث الملاحظة بنجاح' : 'تم إضافة الملاحظة بنجاح'),
          backgroundColor: ColorsManager.successFill,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في ${note != null ? 'تحديث' : 'إضافة'} الملاحظة'),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    }
  }

  Future<void> _deleteNote(MemberNote note) async {
    try {
      await _notesProvider.deleteNote(note.id);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم حذف الملاحظة بنجاح'),
          backgroundColor: ColorsManager.successFill,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('حدث خطأ في حذف الملاحظة'),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'اليوم';
    } else if (difference.inDays == 1) {
      return 'أمس';
    } else if (difference.inDays < 7) {
      return 'منذ ${difference.inDays} أيام';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}