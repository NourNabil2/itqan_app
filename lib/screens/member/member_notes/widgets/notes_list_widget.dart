import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';

import 'note_card_widget.dart';

class NotesListWidget extends StatelessWidget {
  final List<MemberNote> notes;
  final Function(MemberNote) onNoteDetails;
  final VoidCallback onAddNote;
  final VoidCallback onViewAll;

  const NotesListWidget({
    required this.notes,
    required this.onNoteDetails,
    required this.onAddNote,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    final recentNotes = notes.take(3).toList();

    if (recentNotes.isEmpty) {
      return Container(
        padding: EdgeInsets.all(SizeApp.s20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          border: Border.all(
            color: ColorsManager.inputBorder.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.note_add_outlined,
              size: 40.sp,
              color: ColorsManager.defaultTextSecondary.withOpacity(0.6),
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              'لا توجد ملاحظات مفصلة',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: ColorsManager.defaultTextSecondary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'ابدأ بإضافة ملاحظات مفصلة حول الأداء والسلوك',
              style: TextStyle(
                fontSize: 12.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeApp.s12),
            ElevatedButton.icon(
              onPressed: onAddNote,
              icon: Icon(Icons.add_rounded, size: 16.sp),
              label: Text(
                'إضافة أول ملاحظة',
                style: TextStyle(fontSize: 12.sp),
              ),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeApp.s16,
                  vertical: SizeApp.s8,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // ✅ ListView محسن مع itemExtent
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          cacheExtent: 80.h, // ارتفاع ثابت للأداء
          itemCount: recentNotes.length,
          separatorBuilder: (_, __) => SizedBox(height: SizeApp.s8),
          itemBuilder: (context, index) {
            return RepaintBoundary(
              child: NoteCard(
                note: recentNotes[index],
                onTap: () => onNoteDetails(recentNotes[index]),
              ),
            );
          },
        ),

        if (notes.length > 3)
          Container(
            margin: EdgeInsets.only(top: SizeApp.s8),
            child: OutlinedButton.icon(
              onPressed: onViewAll,
              icon: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 18.sp,
              ),
              label: Text(
                'عرض ${notes.length - 3} ملاحظة أخرى',
                style: TextStyle(fontSize: 12.sp),
              ),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeApp.s16,
                  vertical: SizeApp.s8,
                ),
                minimumSize: Size(double.infinity, 36.h),
              ),
            ),
          ),
      ],
    );
  }
}
