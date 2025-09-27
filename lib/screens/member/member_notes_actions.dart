// ============= Member Actions - دوال العمليات =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/member/edit_member/edit_member_screen.dart';
import 'package:itqan_gym/screens/member/member_notes/member_notes_screen.dart';
import 'package:provider/provider.dart';

///  Member Notes Actions - عمليات الملاحظات
class MemberNotesActions {
  static void editGeneralNotes({
    required BuildContext context,
    required Member currentMember,
    required Function(Member) onMemberUpdated,
    String? teamId,
  }) {
    final controller = TextEditingController(text: currentMember.notes ?? '');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        ),
        title: Text(
          'تعديل الملاحظة العامة',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: 'اكتب ملاحظة عامة عن العضو...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(SizeApp.s12),
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
              try {
                final updatedMember = currentMember.copyWith(
                  notes: controller.text.trim().isNotEmpty ? controller.text.trim() : null,
                  updatedAt: DateTime.now(),
                );

                final memberLibraryProvider = Provider.of<MemberLibraryProvider>(context, listen: false);
                await memberLibraryProvider.updateMember(updatedMember);

                onMemberUpdated(updatedMember);

                if (teamId != null) {
                  final memberProvider = Provider.of<MemberProvider>(context, listen: false);
                  await memberProvider.loadTeamMembers(teamId);
                }

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم تحديث الملاحظة العامة'),
                    backgroundColor: ColorsManager.successFill,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل في التحديث: $e'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            child: Text('حفظ'),
          ),
        ],
      ),
    );
  }

  static void addDetailedNote({
    required BuildContext context,
    required Member member,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberNotesScreen(member: member),
      ),
    ).then((_) {
      Provider.of<MemberNotesProvider>(context, listen: false)
          .loadMemberNotes(member.id);
    });
  }

  static void viewAllNotes({
    required BuildContext context,
    required Member member,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberNotesScreen(member: member),
      ),
    ).then((_) {
      Provider.of<MemberNotesProvider>(context, listen: false)
          .loadMemberNotes(member.id);
    });
  }

  static void viewNoteDetails({
    required BuildContext context,
    required MemberNote note,
    required VoidCallback onViewAll,
  }) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        ),
        title: Row(
          children: [
            // Use the priority color for the type icon
            Icon(noteType.icon, color: notePriority.color, size: 20.sp),
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
            SizedBox(height: SizeApp.s12),
            Container(
              padding: EdgeInsets.all(SizeApp.s8),
              decoration: BoxDecoration(
                color: ColorsManager.defaultSurface,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'تفاصيل:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 11.sp),
                  ),
                  SizedBox(height: 8.h),

                  // النوع: use the enum's icon; neutral/text color
                  _buildDetailRow('النوع', noteType.arabicName, noteType.icon, ColorsManager.defaultText),

                  // الأولوية: pick an appropriate icon and use the priority color
                  _buildDetailRow('الأولوية', notePriority.arabicName, Icons.flag_rounded, notePriority.color),

                  if (note.createdBy != null)
                    _buildDetailRow('بواسطة', note.createdBy!, Icons.person, ColorsManager.defaultText),

                  _buildDetailRow('التاريخ', MemberUtils.formatDate(note.createdAt), Icons.schedule, ColorsManager.defaultText),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onViewAll();
            },
            child: const Text('عرض الكل'),
          ),
        ],
      ),
    );
  }


  static Widget _buildDetailRow(String label, String value, IconData icon, Color color) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            '$label: $value',
            style: TextStyle(fontSize: 10.sp, color: ColorsManager.defaultText),
          ),
        ],
      ),
    );
  }
}

///  Member Exercise Actions - عمليات التمارين
class MemberExerciseActions {
  static void addNewExercise({
    required BuildContext context,
    required Member member,
  }) {
    // يمكن إضافة navigation لشاشة إضافة تمرين جديد
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم إضافة تمرين جديد للعضو ${member.name}'),
        backgroundColor: ColorsManager.primaryColor,
      ),
    );
  }

  static void editExercise({
    required BuildContext context,
    required Member member,
    required Map<String, dynamic> exercise,
  }) {
    // يمكن إضافة navigation لشاشة تحرير التمرين
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم تحرير تمرين ${exercise['name']}'),
        backgroundColor: ColorsManager.primaryColor,
      ),
    );
  }
}

///  Member Profile Actions - عمليات ملف العضو
class MemberProfileActions {
  static void editMember({
    required BuildContext context,
    required Member member,
    required VoidCallback onSuccess,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditMemberScreen(member: member),
      ),
    ).then((result) {
      if (result == true) {
        onSuccess();
      }
    });
  }

  static void showMemberOptions({
    required BuildContext context,
    required Member member,
    String? teamId,
  }) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeApp.radiusMed),
            topRight: Radius.circular(SizeApp.radiusMed),
          ),
        ),
        padding: EdgeInsets.all(SizeApp.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: ColorsManager.inputBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: SizeApp.s20),
            _buildOptionTile(
              context: context,
              icon: Icons.share_rounded,
              title: 'مشاركة الملف',
              color: ColorsManager.primaryColor,
              onTap: () => _shareMember(context, member),
            ),
            if (teamId != null)
              _buildOptionTile(
                context: context,
                icon: Icons.group_remove_rounded,
                title: 'إزالة من الفريق',
                color: ColorsManager.warningFill,
                onTap: () => _showRemoveFromTeamDialog(context, member, teamId),
              ),
            _buildOptionTile(
              context: context,
              icon: Icons.delete_rounded,
              title: 'حذف العضو نهائياً',
              color: ColorsManager.errorFill,
              onTap: () => _showDeleteDialog(context, member),
            ),
          ],
        ),
      ),
    );
  }

  static Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: EdgeInsets.all(SizeApp.s8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.s8),
        ),
        child: Icon(icon, color: color, size: 20.sp),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: title.contains('حذف') ? color : ColorsManager.defaultText,
        ),
      ),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }

  static void _shareMember(BuildContext context, Member member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم مشاركة ملف العضو ${member.name}'),
        backgroundColor: ColorsManager.primaryColor,
      ),
    );
  }

  static void _showRemoveFromTeamDialog(BuildContext context, Member member, String teamId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'إزالة من الفريق',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),
        content: Text(
          'هل أنت متأكد من إزالة ${member.name} من الفريق؟ سيبقى العضو في المكتبة العامة.',
          style: TextStyle(fontSize: 14.sp),
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
              Navigator.pop(context);
              try {
                final memberProvider = Provider.of<MemberProvider>(context, listen: false);
                await memberProvider.removeMemberFromTeam(member.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم إزالة ${member.name} من الفريق'),
                    backgroundColor: ColorsManager.warningFill,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل في إزالة العضو: $e'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.warningFill,
            ),
            child: Text(
              'إزالة',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  static void _showDeleteDialog(BuildContext context, Member member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'حذف العضو',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.errorFill,
          ),
        ),
        content: Text(
          'هل أنت متأكد من حذف ${member.name} نهائياً من المكتبة؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontSize: 14.sp),
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
              Navigator.pop(context);
              try {
                final memberLibraryProvider = Provider.of<MemberLibraryProvider>(context, listen: false);
                await memberLibraryProvider.deleteMember(member.id);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف ${member.name} نهائياً'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('فشل في حذف العضو: $e'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
            ),
            child: Text(
              'حذف نهائياً',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

///  Member Utils - دوال مساعدة
class MemberUtils {
  static Color getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return ColorsManager.infoFill;
      case 'intermediate':
      case 'متوسط':
        return ColorsManager.warningFill;
      case 'advanced':
      case 'متقدم':
        return ColorsManager.successFill;
      case 'expert':
      case 'محترف':
        return ColorsManager.primaryColor;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }

  static String formatDate(DateTime date) {
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

  static String getStatusText(double progress) {
    if (progress >= 80) return 'مكتمل';
    if (progress >= 50) return 'قيد التقدم';
    if (progress > 0) return 'بداية';
    return 'لم يبدأ';
  }

  static Color getProgressColor(double progress) {
    if (progress >= 80) return ColorsManager.successFill;
    if (progress >= 50) return ColorsManager.primaryColor;
    if (progress > 0) return ColorsManager.warningFill;
    return ColorsManager.errorFill;
  }
}