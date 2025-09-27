// ============= Member Notes Widgets - كلاسات منفصلة =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import '../../../member_notes/widgets/notes_list_widget.dart';

/// Simple Detailed Notes Section - النسخة المبسطة
class DetailedNotesSection extends StatelessWidget {
  final MemberNotesProvider notesProvider;
  final VoidCallback onAddNote;
  final VoidCallback onViewAll;
  final Function(MemberNote) onNoteDetails;

  const DetailedNotesSection({
    super.key,
    required this.notesProvider,
    required this.onAddNote,
    required this.onViewAll,
    required this.onNoteDetails,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildHeader(),
        SizedBox(height: SizeApp.s12),
        _buildNotesListView(),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(6.w),
              decoration: BoxDecoration(
                color: ColorsManager.secondaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.notes_rounded,
                size: 16.sp,
                color: ColorsManager.secondaryColor,
              ),
            ),
            SizedBox(width: SizeApp.s8),
            Text(
              'الملاحظات المفصلة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
          ],
        ),
        Row(
          children: [
            TextButton.icon(
              onPressed: onViewAll,
              icon: Icon(
                Icons.list_rounded,
                size: 16.sp,
                color: ColorsManager.primaryColor,
              ),
              label: Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: ColorsManager.primaryColor,
                ),
              ),
            ),
            IconButton(
              onPressed: onAddNote,
              icon: Icon(
                Icons.add_circle_rounded,
                size: 20.sp,
                color: ColorsManager.primaryColor,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesListView() {
    return RepaintBoundary(
      child: NotesListWidget(
        notes: notesProvider.allNotes,
        onNoteDetails: onNoteDetails,
        onAddNote: onAddNote,
        onViewAll: onViewAll,
      ),
    );
  }
}



