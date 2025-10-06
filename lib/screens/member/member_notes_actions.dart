import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/auth_provider.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:itqan_gym/screens/member/edit_member/edit_member_screen.dart';
import 'package:itqan_gym/screens/member/member_details/widgets/member_report_generator.dart';
import 'package:itqan_gym/screens/member/member_notes/member_notes_screen.dart';
import 'package:itqan_gym/screens/settings/widgets/premium_dialog.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../providers/exercise_assignment_provider.dart';

class MemberNotesActions {
  static void editGeneralNotes({
    required BuildContext context,
    required Member currentMember,
    required Function(Member) onMemberUpdated,
    String? teamId,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final controller = TextEditingController(text: currentMember.notes ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        ),
        title: Text(
          l10n.editGeneralNote,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: controller,
          maxLines: 6,
          decoration: InputDecoration(
            hintText: l10n.generalNoteHint,
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
              l10n.cancel,
              style: TextStyle(
                color: theme.textTheme.bodySmall?.color?.withOpacity(0.7),
              ),
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
                    content: Text(l10n.generalNoteUpdated),
                    backgroundColor: ColorsManager.successFill,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.updateFailed}: $e'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            child: Text(l10n.save),
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
            Icon(noteType.icon, color: notePriority.color, size: 20.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Text(
                note.title,
                style: theme.textTheme.titleLarge?.copyWith(
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
            SizedBox(height: SizeApp.s12),
            Container(
              padding: EdgeInsets.all(SizeApp.s8),
              decoration: BoxDecoration(
                color: theme.cardColor,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.details}:',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 8.h),

                  _buildDetailRow(
                    context,
                    l10n.type,
                    noteType.getLocalizedName(context),
                    noteType.icon,
                    theme.textTheme.bodyLarge?.color ?? Colors.black,
                  ),

                  _buildDetailRow(
                    context,
                    l10n.priority,
                    notePriority.getLocalizedName(context),
                    Icons.flag_rounded,
                    notePriority.color,
                  ),

                  if (note.createdBy != null)
                    _buildDetailRow(
                      context,
                      l10n.by,
                      note.createdBy!,
                      Icons.person,
                      theme.textTheme.bodyLarge?.color ?? Colors.black,
                    ),

                  _buildDetailRow(
                    context,
                    l10n.date,
                    MemberUtils.formatDate(context, note.createdAt),
                    Icons.schedule,
                    theme.textTheme.bodyLarge?.color ?? Colors.black,
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
              onViewAll();
            },
            child: Text(l10n.viewAll),
          ),
        ],
      ),
    );
  }

  static Widget _buildDetailRow(
      BuildContext context,
      String label,
      String value,
      IconData icon,
      Color color,
      ) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: color),
          SizedBox(width: 6.w),
          Text(
            '$label: $value',
            style: theme.textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class MemberExerciseActions {
  static void addNewExercise({
    required BuildContext context,
    required Member member,
  }) {
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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم تحرير تمرين ${exercise['name']}'),
        backgroundColor: ColorsManager.primaryColor,
      ),
    );
  }
}

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

// عدّل التوقيع
// في MemberProfileActions class
  static void showMemberOptions({
    required BuildContext context,
    required Member member,
    String? teamId,
    List<FlSpot>? chartData,
    double? chartMaxY,
    Map<String, dynamic>? statistics,
    List<AssignedSkill>? skills,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final isPremium = authProvider.isPremium;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: theme.cardColor,
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
                color: theme.dividerColor.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: SizeApp.s20),

            // Share option
            _buildOptionTile(
              context: context,
              icon: isPremium ? Icons.share_rounded : Icons.lock_rounded,
              title: isPremium ? l10n.shareProfile : '${l10n.shareProfile} (Premium)',
              color: isPremium ? ColorsManager.primaryColor : ColorsManager.defaultTextSecondary,
              onTap: isPremium
                  ? () {
                Navigator.pop(context);
                _shareMember(
                  context,
                  member,
                  chartData: chartData ?? [],
                  chartMaxY: chartMaxY ?? 100,
                  statistics: statistics,
                  skills: skills,
                );
              }
                  : () {
                Navigator.pop(context);
                PremiumDialog.show(context);
              },
            ),

            if (teamId != null)
              _buildOptionTile(
                context: context,
                icon: Icons.group_remove_rounded,
                title: l10n.removeFromTeam,
                color: ColorsManager.warningFill,
                onTap: () => _showRemoveFromTeamDialog(context, member, teamId),
              ),

            _buildOptionTile(
              context: context,
              icon: Icons.delete_rounded,
              title: l10n.deleteMemberPermanently,
              color: ColorsManager.errorFill,
              onTap: () => _showDeleteDialog(context, member),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _shareMember(
      BuildContext context,
      Member member, {
        List<FlSpot>? chartData,
        double? chartMaxY,
        Map<String, dynamic>? statistics,
        List<AssignedSkill>? skills,
      }) async {
    if (chartData != null && statistics != null && skills != null) {
      await MemberReportGenerator.generateAndShareReport(
        context: context,
        member: member,
        chartData: chartData,
        chartMaxY: chartMaxY ?? 100,
        statistics: statistics,
        skills: skills,
      );
    } else {
      // Fallback...
    }
  }
  static Widget _buildOptionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);

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
        style: theme.textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: title.contains(AppLocalizations.of(context).delete)
              ? color
              : theme.textTheme.bodyLarge?.color,
        ),
      ),
      onTap: () {
        onTap();
      },
    );
  }


  static void _showRemoveFromTeamDialog(BuildContext context, Member member, String teamId) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          l10n.removeFromTeamTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          l10n.removeFromTeamConfirmation(member.name),
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
              try {
                final memberProvider = Provider.of<MemberProvider>(context, listen: false);
                await memberProvider.removeMemberFromTeam(member.id);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.memberRemovedFromTeam(member.name)),
                    backgroundColor: ColorsManager.warningFill,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.updateFailed}: $e'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.warningFill,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.remove),
          ),
        ],
      ),
    );
  }

  static void _showDeleteDialog(BuildContext context, Member member) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: theme.dialogBackgroundColor,
        title: Text(
          l10n.deleteMemberTitle,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: ColorsManager.errorFill,
          ),
        ),
        content: Text(
          l10n.deleteMemberConfirmation(member.name),
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
              try {
                final memberLibraryProvider = Provider.of<MemberLibraryProvider>(context, listen: false);
                await memberLibraryProvider.deleteMember(member.id);

                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.memberDeletedPermanently(member.name)),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${l10n.updateFailed}: $e'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
              foregroundColor: Colors.white,
            ),
            child: Text(l10n.deletePermanently),
          ),
        ],
      ),
    );
  }
}

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

  static String formatDate(BuildContext context, DateTime date) {
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

  static String getStatusText(BuildContext context, double progress) {
    final l10n = AppLocalizations.of(context);

    if (progress >= 80) return l10n.completed;
    if (progress >= 50) return l10n.inProgress;
    if (progress > 0) return l10n.beginning;
    return l10n.notStarted;
  }

  static Color getProgressColor(double progress) {
    if (progress >= 80) return ColorsManager.successFill;
    if (progress >= 50) return ColorsManager.primaryColor;
    if (progress > 0) return ColorsManager.warningFill;
    return ColorsManager.errorFill;
  }
}