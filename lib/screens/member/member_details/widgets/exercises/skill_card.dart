// lib/screens/member/member_details/widgets/skill_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:provider/provider.dart';


class SkillCard extends StatelessWidget {
  final AssignedSkill assignedSkill;
  final VoidCallback onTap;
  final VoidCallback onProgressUpdated;

  const SkillCard({
    super.key,
    required this.assignedSkill,
    required this.onTap,
    required this.onProgressUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final skill = assignedSkill.skill;
    if (skill == null) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final apparatusColor = getApparatusColor(skill.apparatus);
    final progressPercentage = assignedSkill.progress;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Row
                Row(
                  children: [
                    // Thumbnail
                    _SkillThumbnail(
                      skill: skill,
                      apparatusColor: apparatusColor,
                    ),

                    SizedBox(width: 12.w),

                    // Info
                    Expanded(
                      child: _SkillInfo(
                        skill: skill,
                        assignedSkill: assignedSkill,
                        apparatusColor: apparatusColor,
                      ),
                    ),

                    // Actions Menu
                    _SkillActionsMenu(
                      assignedSkill: assignedSkill,
                      onProgressUpdated: onProgressUpdated,
                    ),
                  ],
                ),

                SizedBox(height: 12.h),

                // Progress Bar
                _SkillProgress(
                  progress: progressPercentage,
                  color: apparatusColor,
                ),

                // Notes
                if (assignedSkill.notes?.isNotEmpty ?? false) ...[
                  SizedBox(height: 12.h),
                  _SkillNotes(notes: assignedSkill.notes!),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== Sub Widgets ====================

class _SkillThumbnail extends StatelessWidget {
  final SkillTemplate skill;
  final Color apparatusColor;

  const _SkillThumbnail({
    required this.skill,
    required this.apparatusColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 60.w,
      height: 60.h,
      decoration: BoxDecoration(
        color: apparatusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: skill.thumbnailPath != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.file(
          File(skill.thumbnailPath!),
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(
            getApparatusIcon(skill.apparatus),
            color: apparatusColor,
            size: 28.sp,
          ),
        ),
      )
          : Icon(
        getApparatusIcon(skill.apparatus),
        color: apparatusColor,
        size: 28.sp,
      ),
    );
  }
}

class _SkillInfo extends StatelessWidget {
  final SkillTemplate skill;
  final AssignedSkill assignedSkill;
  final Color apparatusColor;

  const _SkillInfo({
    required this.skill,
    required this.assignedSkill,
    required this.apparatusColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          skill.skillName,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        SizedBox(height: 4.h),

        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            // Apparatus Badge
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: apparatusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Text(
                skill.apparatus.getLocalizedName(context),
                style: TextStyle(
                  fontSize: 11.sp,
                  color: apparatusColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Status Badge
            _StatusBadge(assignedSkill: assignedSkill),
          ],
        ),
      ],
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final AssignedSkill assignedSkill;

  const _StatusBadge({required this.assignedSkill});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (assignedSkill.isCompleted) {
      statusText = l10n.completed;
      statusColor = theme.colorScheme.tertiary;
      statusIcon = Icons.check_circle_rounded;
    } else if (assignedSkill.isInProgress) {
      statusText = l10n.inProgress;
      statusColor = theme.colorScheme.secondary;
      statusIcon = Icons.schedule_rounded;
    } else {
      statusText = l10n.notStarted;
      statusColor = theme.colorScheme.outline;
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 11.sp, color: statusColor),
          SizedBox(width: 3.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 11.sp,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillActionsMenu extends StatelessWidget {
  final AssignedSkill assignedSkill;
  final VoidCallback onProgressUpdated;

  const _SkillActionsMenu({
    required this.assignedSkill,
    required this.onProgressUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return PopupMenuButton<String>(
      icon: Icon(
        Icons.more_vert_rounded,
        color: colorScheme.onSurfaceVariant,
        size: 20.sp,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      color: colorScheme.surface,
      onSelected: (value) {
        switch (value) {
          case 'update_progress':
            _showUpdateProgressDialog(context);
            break;
          case 'add_note':
            _showAddNoteDialog(context);
            break;
          case 'remove':
            _confirmRemoveSkill(context);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'update_progress',
          child: Row(
            children: [
              Icon(
                Icons.trending_up_rounded,
                size: 20.sp,
                color: colorScheme.primary,
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.update,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'add_note',
          child: Row(
            children: [
              Icon(
                Icons.note_add_rounded,
                size: 20.sp,
                color: colorScheme.secondary,
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.addNote,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline_rounded,
                size: 20.sp,
                color: colorScheme.error,
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.remove,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showUpdateProgressDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => UpdateProgressDialog(
        assignedSkill: assignedSkill,
        onProgressUpdated: onProgressUpdated,
      ),
    );
  }

  void _showAddNoteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AddNoteDialog(
        assignedSkill: assignedSkill,
        onNoteAdded: onProgressUpdated,
      ),
    );
  }

  void _confirmRemoveSkill(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => RemoveSkillDialog(
        assignedSkill: assignedSkill,
        onSkillRemoved: onProgressUpdated,
      ),
    );
  }
}

class _SkillProgress extends StatelessWidget {
  final double progress;
  final Color color;

  const _SkillProgress({
    required this.progress,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.progress,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '${progress.toInt()}%',
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),
        ClipRRect(
          borderRadius: BorderRadius.circular(4.r),
          child: LinearProgressIndicator(
            value: progress / 100,
            backgroundColor: color.withOpacity(0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            minHeight: 6.h,
          ),
        ),
      ],
    );
  }
}

class _SkillNotes extends StatelessWidget {
  final String notes;

  const _SkillNotes({required this.notes});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.note_outlined,
            size: 14.sp,
            color: colorScheme.onSurfaceVariant,
          ),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(
              notes,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== Dialogs ====================

class UpdateProgressDialog extends StatefulWidget {
  final AssignedSkill assignedSkill;
  final VoidCallback onProgressUpdated;

  const UpdateProgressDialog({
    super.key,
    required this.assignedSkill,
    required this.onProgressUpdated,
  });

  @override
  State<UpdateProgressDialog> createState() => _UpdateProgressDialogState();
}

class _UpdateProgressDialogState extends State<UpdateProgressDialog> {
  late double _currentProgress;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _currentProgress = widget.assignedSkill.progress;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final apparatusColor = getApparatusColor(widget.assignedSkill.skill!.apparatus);

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        l10n.update,
        style: theme.textTheme.titleLarge,
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.assignedSkill.skill?.skillName ?? '',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurface,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: 20.h),

            // Progress Display
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: apparatusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_currentProgress.toInt()}%',
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: apparatusColor,
                    ),
                  ),

                  SizedBox(height: 12.h),

                  SliderTheme(
                    data: SliderThemeData(
                      activeTrackColor: apparatusColor,
                      inactiveTrackColor: apparatusColor.withOpacity(0.2),
                      thumbColor: apparatusColor,
                      overlayColor: apparatusColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _currentProgress,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      label: '${_currentProgress.toInt()}%',
                      onChanged: (value) {
                        setState(() => _currentProgress = value);
                      },
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 16.h),

            // Quick Select Buttons
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              alignment: WrapAlignment.center,
              children: [0, 25, 50, 75, 100].map((value) {
                final isSelected = _currentProgress == value.toDouble();
                return InkWell(
                  onTap: () => setState(() => _currentProgress = value.toDouble()),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      '$value%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? colorScheme.onPrimary
                            : colorScheme.onSurface,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isUpdating ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isUpdating ? null : _updateProgress,
          child: _isUpdating
              ? SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onPrimary,
            ),
          )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _updateProgress() async {
    setState(() => _isUpdating = true);

    try {
      final provider = context.read<ExerciseAssignmentProvider>();
      await provider.updateMemberSkillProgress(
        widget.assignedSkill.memberId,
        widget.assignedSkill.skillId,
        _currentProgress,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onProgressUpdated();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).updatedSuccessfully} ${_currentProgress.toInt()}%',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUpdating = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorOccurred),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class AddNoteDialog extends StatefulWidget {
  final AssignedSkill assignedSkill;
  final VoidCallback onNoteAdded;

  const AddNoteDialog({
    super.key,
    required this.assignedSkill,
    required this.onNoteAdded,
  });

  @override
  State<AddNoteDialog> createState() => _AddNoteDialogState();
}

class _AddNoteDialogState extends State<AddNoteDialog> {
  late final TextEditingController _controller;
  bool _isAdding = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.assignedSkill.notes);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(l10n.addNote, style: theme.textTheme.titleLarge),
      content: TextField(
        controller: _controller,
        maxLines: 4,
        maxLength: 500,
        style: theme.textTheme.bodyMedium,
        decoration: InputDecoration(
          hintText: l10n.noTeamsSubtitle,
          hintStyle: TextStyle(color: colorScheme.onSurfaceVariant),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.outline),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide(color: colorScheme.primary, width: 2),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isAdding ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isAdding ? null : _addNote,
          child: _isAdding
              ? SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onPrimary,
            ),
          )
              : Text(l10n.save),
        ),
      ],
    );
  }

  Future<void> _addNote() async {
    setState(() => _isAdding = true);

    try {
      final provider = context.read<ExerciseAssignmentProvider>();
      await provider.addNoteToMemberSkill(
        widget.assignedSkill.memberId,
        widget.assignedSkill.skillId,
        _controller.text,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onNoteAdded();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).savedSuccessfully),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAdding = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorOccurred),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class RemoveSkillDialog extends StatefulWidget {
  final AssignedSkill assignedSkill;
  final VoidCallback onSkillRemoved;

  const RemoveSkillDialog({
    super.key,
    required this.assignedSkill,
    required this.onSkillRemoved,
  });

  @override
  State<RemoveSkillDialog> createState() => _RemoveSkillDialogState();
}

class _RemoveSkillDialogState extends State<RemoveSkillDialog> {
  bool _isRemoving = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        l10n.confirm,
        style: theme.textTheme.titleLarge?.copyWith(color: colorScheme.error),
      ),
      content: Text(
        '${l10n.confirmDelete} "${widget.assignedSkill.skill?.skillName}"?',
        style: theme.textTheme.bodyMedium,
      ),
      actions: [
        TextButton(
          onPressed: _isRemoving ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isRemoving ? null : _removeSkill,
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: _isRemoving
              ? SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onError,
            ),
          )
              : Text(l10n.remove),
        ),
      ],
    );
  }

  Future<void> _removeSkill() async {
    setState(() => _isRemoving = true);

    try {
      final provider = context.read<ExerciseAssignmentProvider>();
      await provider.unassignSkillFromMember(
        widget.assignedSkill.memberId,
        widget.assignedSkill.skillId,
      );

      if (mounted) {
        Navigator.pop(context);
        widget.onSkillRemoved();

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).deletedSuccessfully),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isRemoving = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context).errorOccurred),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}