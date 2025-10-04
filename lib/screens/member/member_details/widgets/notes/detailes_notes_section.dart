// lib/screens/member/member_details/widgets/notes/detailes_notes_section.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import '../../../member_notes/widgets/notes_list_widget.dart';

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
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildHeader(context),
        SizedBox(height: SizeApp.s12),
        _buildNotesListView(),
      ],
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
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.notes_rounded,
                  size: 18.sp,
                  color: colorScheme.secondary,
                ),
              ),
              SizedBox(width: SizeApp.s8),
              Flexible(
                child: Text(
                  l10n.detailedNotes,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton.icon(
              onPressed: onViewAll,
              icon: Icon(
                Icons.list_rounded,
                size: 16.sp,
                color: colorScheme.primary,
              ),
              label: Text(
                l10n.viewAll,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
            IconButton(
              onPressed: onAddNote,
              icon: Icon(
                Icons.add_circle_rounded,
                size: 22.sp,
                color: colorScheme.primary,
              ),
              tooltip: l10n.addNote,
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