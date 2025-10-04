// lib/screens/member_notes/widgets/notes_list_widget.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/extension.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';

class NotesListWidget extends StatelessWidget {
  final List<MemberNote> notes;
  final Function(MemberNote) onNoteDetails;
  final VoidCallback onAddNote;
  final VoidCallback onViewAll;

  const NotesListWidget({
    super.key,
    required this.notes,
    required this.onNoteDetails,
    required this.onAddNote,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    if (notes.isEmpty) {
      return _buildEmptyState(context);
    }

    final displayNotes = notes.take(3).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displayNotes.length,
          separatorBuilder: (_, __) => SizedBox(height: 8.h),
          itemBuilder: (context, index) {
            return NoteCardList(
              note: displayNotes[index],
              onTap: () => onNoteDetails(displayNotes[index]),
            );
          },
        ),
        if (notes.length > 3) ...[
          SizedBox(height: 12.h),
          _buildViewMoreButton(context),
        ],
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 24.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.note_add_outlined,
              size: 32.sp,
              color: colorScheme.primary,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            l10n.noDetailedNotes,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 6.h),
          Text(
            l10n.addFirstNote,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20.h),
          FilledButton.icon(
            onPressed: onAddNote,
            icon: Icon(Icons.add_rounded, size: 18.sp),
            label: Text(l10n.addNote),
            style: FilledButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: 24.w,
                vertical: 12.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMoreButton(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final remainingCount = notes.length - 3;

    return OutlinedButton.icon(
      onPressed: onViewAll,
      icon: Icon(Icons.arrow_forward_rounded, size: 16.sp),
      label: Text('${l10n.viewMore} (+$remainingCount)'),
      style: OutlinedButton.styleFrom(
        foregroundColor: colorScheme.primary,
        side: BorderSide(color: colorScheme.outline),
        padding: EdgeInsets.symmetric(
          horizontal: 20.w,
          vertical: 10.h,
        ),
      ),
    );
  }
}

class NoteCardList extends StatelessWidget {
  final MemberNote note;
  final VoidCallback onTap;

  const NoteCardList({
    super.key,
    required this.note,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Padding(
            padding: EdgeInsets.all(12.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with category
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: _getCategoryColor(colorScheme, note.noteType),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: Icon(
                        _getCategoryIcon(note.noteType),
                        size: 16.sp,
                        color: _getIconColor(colorScheme, note.noteType),
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        _getCategoryLocalizedName(context, note.noteType),
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20.sp,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),

                SizedBox(height: 10.h),

                // Content preview
                Text(
                  note.content,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    height: 1.5,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),

                SizedBox(height: 10.h),

                // Footer with time
                Row(
                  children: [
                    Icon(
                      Icons.access_time_rounded,
                      size: 14.sp,
                      color: colorScheme.onSurfaceVariant.withOpacity(0.7),
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        note.createdAt.timeAgoCtx(context),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withOpacity(0.8),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

  Color _getCategoryColor(ColorScheme colorScheme, String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('تقدم') || categoryLower.contains('progress') || categoryLower.contains('performance')) {
      return colorScheme.tertiaryContainer;
    }

    if (categoryLower.contains('صحة') || categoryLower.contains('health')) {
      return colorScheme.errorContainer;
    }

    if (categoryLower.contains('سلوك') || categoryLower.contains('behavior')) {
      return colorScheme.secondaryContainer;
    }

    return colorScheme.primaryContainer;
  }

  Color _getIconColor(ColorScheme colorScheme, String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('تقدم') || categoryLower.contains('progress') || categoryLower.contains('performance')) {
      return colorScheme.tertiary;
    }

    if (categoryLower.contains('صحة') || categoryLower.contains('health')) {
      return colorScheme.error;
    }

    if (categoryLower.contains('سلوك') || categoryLower.contains('behavior')) {
      return colorScheme.secondary;
    }

    return colorScheme.primary;
  }

  IconData _getCategoryIcon(String category) {
    final categoryLower = category.toLowerCase();

    if (categoryLower.contains('تقدم') || categoryLower.contains('progress') || categoryLower.contains('performance')) {
      return Icons.trending_up_rounded;
    }

    if (categoryLower.contains('صحة') || categoryLower.contains('health')) {
      return Icons.favorite_rounded;
    }

    if (categoryLower.contains('سلوك') || categoryLower.contains('behavior')) {
      return Icons.psychology_rounded;
    }

    return Icons.note_rounded;
  }

  String _getCategoryLocalizedName(BuildContext context, String category) {
    // استخدام الـ category كما هو إذا كان مترجم بالفعل
    // أو يمكن إضافة mapping للترجمة
    return category;
  }
}