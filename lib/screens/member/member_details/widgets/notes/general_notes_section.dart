// lib/screens/member/member_details/widgets/notes/general_notes_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(context),
          SizedBox(height: SizeApp.s12),
          _buildNotesContent(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.edit_note_rounded,
                  size: 18.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: SizeApp.s8),
              Flexible(
                child: Text(
                  l10n.generalCoachNote,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: onEditNotes,
          icon: Icon(
            Icons.edit_rounded,
            size: 20.sp,
            color: colorScheme.primary,
          ),
          tooltip: l10n.edit,
          style: IconButton.styleFrom(
            backgroundColor: colorScheme.primaryContainer.withOpacity(0.3),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesContent(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final hasNotes = member.notes?.isNotEmpty == true;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(minHeight: 60.h),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Text(
        hasNotes ? member.notes! : l10n.noGeneralNoteDescription,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: hasNotes
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
          height: 1.5,
          fontStyle: hasNotes ? FontStyle.normal : FontStyle.italic,
        ),
      ),
    );
  }
}