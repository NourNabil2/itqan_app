import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';

/// General Notes Section كمكون منفصل
class GeneralNotesSection extends StatelessWidget {
  final Member member;
  final VoidCallback onEditNotes;

  const GeneralNotesSection({
    super.key,
    required this.member,
    required this.onEditNotes,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: SizeApp.s12),
          _buildNotesContent(),
        ],
      ),
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
                color: ColorsManager.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.edit_note_rounded,
                size: 16.sp,
                color: ColorsManager.primaryColor,
              ),
            ),
            SizedBox(width: SizeApp.s8),
            Text(
              'ملاحظة المدرب العامة',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
          ],
        ),
        IconButton(
          onPressed: onEditNotes,
          icon: Icon(
            Icons.edit_rounded,
            size: 20.sp,
            color: ColorsManager.primaryColor,
          ),
        ),
      ],
    );
  }

  Widget _buildNotesContent() {
    final hasNotes = member.notes?.isNotEmpty == true;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: ColorsManager.defaultSurface,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Text(
        hasNotes
            ? member.notes!
            : 'لا توجد ملاحظة عامة.\nيمكنك إضافة ملاحظة عامة عن العضو هنا.',
        style: TextStyle(
          fontSize: 14.sp,
          color: hasNotes
              ? ColorsManager.defaultText
              : ColorsManager.defaultTextSecondary,
          height: 1.5,
          fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
        ),
      ),
    );
  }
}
