import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';


class NoteCard extends StatelessWidget {
  final MemberNote note;
  final VoidCallback onTap;

  const NoteCard({
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final noteType = NoteType.values.firstWhere(
          (type) => type.value == note.noteType,
      orElse: () => NoteType.general,
    );

    final priority = NotePriority.values.firstWhere(
          (p) => p.value == note.priority,
      orElse: () => NotePriority.normal,
    );

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: priority.color.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(SizeApp.s12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: priority.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Icon(
                        noteType.icon,
                        size: 12.sp,
                        color: priority.color,
                      ),
                    ),
                    SizedBox(width: SizeApp.s8),
                    Expanded(
                      child: Text(
                        note.title,
                        style: TextStyle(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.defaultText,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (note.priority == 'high')
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
                        decoration: BoxDecoration(
                          color: ColorsManager.errorFill,
                          borderRadius: BorderRadius.circular(2.r),
                        ),
                        child: Text(
                          'مهم',
                          style: TextStyle(
                            fontSize: 8.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                SizedBox(height: SizeApp.s8),
                Text(
                  note.content,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorsManager.defaultText,
                    height: 1.3,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: SizeApp.s8),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: ColorsManager.infoSurface,
                        borderRadius: BorderRadius.circular(3.r),
                      ),
                      child: Text(
                        noteType.arabicName,
                        style: TextStyle(
                          fontSize: 9.sp,
                          fontWeight: FontWeight.w500,
                          color: ColorsManager.infoText,
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _formatDate(note.createdAt),
                      style: TextStyle(
                        fontSize: 9.sp,
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