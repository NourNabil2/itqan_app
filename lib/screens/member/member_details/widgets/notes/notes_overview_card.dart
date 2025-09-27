import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/providers/member_provider.dart';

///  Notes Overview Card todo :: use it or remove it
class NotesOverviewCard extends StatelessWidget {
  final MemberNotesProvider notesProvider;
  final VoidCallback onViewAll;

  const NotesOverviewCard({
    super.key,
    required this.notesProvider,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (notesProvider.allNotes.isEmpty) {
      return const SizedBox.shrink();
    }

    final recentNotes = notesProvider.getRecentNotes();
    final highPriorityNotes = notesProvider.getHighPriorityNotes();

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
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
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ملخص الملاحظات',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.defaultText,
                ),
              ),
              TextButton(
                onPressed: onViewAll,
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorsManager.primaryColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s12),

          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'المجموع',
                  '${notesProvider.allNotes.length}',
                  Icons.notes_rounded,
                  ColorsManager.primaryColor,
                ),
              ),
              SizedBox(width: SizeApp.s8),
              Expanded(
                child: _buildStatCard(
                  'حديثة',
                  '${recentNotes.length}',
                  Icons.schedule_rounded,
                  ColorsManager.successFill,
                ),
              ),
              SizedBox(width: SizeApp.s8),
              Expanded(
                child: _buildStatCard(
                  'مهمة',
                  '${highPriorityNotes.length}',
                  Icons.priority_high_rounded,
                  ColorsManager.warningFill,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            size: 20.sp,
            color: color,
          ),
          SizedBox(height: SizeApp.s2 *2 ),
          Text(
            count,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

