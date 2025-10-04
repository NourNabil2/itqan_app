// lib/screens/member_notes/dialogs/delete_note_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';

class DeleteNoteDialog extends StatelessWidget {
  final VoidCallback onConfirm;

  const DeleteNoteDialog({
    super.key,
    required this.onConfirm,
  });

  static Future<void> show(
      BuildContext context, {
        required VoidCallback onConfirm,
      }) {
    return showDialog(
      context: context,
      builder: (_) => DeleteNoteDialog(onConfirm: onConfirm),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      icon: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: colorScheme.errorContainer,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.delete_outline_rounded,
          size: 32.sp,
          color: colorScheme.error,
        ),
      ),
      title: Text(
        l10n.deleteNote,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.error,
        ),
        textAlign: TextAlign.center,
      ),
      content: Text(
        l10n.deleteNoteConfirmation,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
        textAlign: TextAlign.center,
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          style: FilledButton.styleFrom(
            backgroundColor: colorScheme.error,
            foregroundColor: colorScheme.onError,
          ),
          child: Text(l10n.delete),
        ),
      ],
    );
  }
}