// lib/screens/member_notes/dialogs/note_form_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/data/models/member/member_notes.dart';

class NoteFormDialog extends StatefulWidget {
  final MemberNote? note;
  final Function(String title, String content, String type, String priority) onSave;

  const NoteFormDialog({
    super.key,
    this.note,
    required this.onSave,
  });

  static Future<void> show(
      BuildContext context, {
        MemberNote? note,
        required Function(String, String, String, String) onSave,
      }) {
    return showDialog(
      context: context,
      builder: (_) => NoteFormDialog(note: note, onSave: onSave),
    );
  }

  @override
  State<NoteFormDialog> createState() => _NoteFormDialogState();
}

class _NoteFormDialogState extends State<NoteFormDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late String _selectedType;
  late String _selectedPriority;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
    _selectedType = widget.note?.noteType ?? 'general';
    _selectedPriority = widget.note?.priority ?? 'normal';
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final isEditing = widget.note != null;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      title: Text(
        isEditing ? l10n.editNote : l10n.addNewNote,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width * 0.9,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title field
              AppTextField(
                controller: _titleController,
                hintText: l10n.noteTitle,
                title: l10n.title,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return l10n.enterNoteTitle;
                  }
                  return null;
                },
              ),

              SizedBox(height: 12.h),

              // Content field
              AppTextFieldFactory.textArea(
                controller: _contentController,
                hintText: l10n.writeNoteHere,
                title: l10n.noteContent,
                maxLines: 5,
                validator: (value) {
                  if (value?.trim().isEmpty ?? true) {
                    return l10n.enterNoteContent;
                  }
                  return null;
                },
              ),

              SizedBox(height: 16.h),

              // Type and Priority dropdowns
              Row(
                children: [
                  Expanded(
                    child: _buildTypeDropdown(context),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: _buildPriorityDropdown(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => Navigator.pop(context),
          child: Text(l10n.cancel),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? SizedBox(
            width: 16.w,
            height: 16.h,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: colorScheme.onPrimary,
            ),
          )
              : Text(isEditing ? l10n.update : l10n.save),
        ),
      ],
    );
  }

  Widget _buildTypeDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.type,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: _selectedType,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          items: NoteType.values.map((type) {
            return DropdownMenuItem(
              value: type.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(type.icon, size: 16.sp, color: colorScheme.primary),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      type.getLocalizedName(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedType = value!),
        ),
      ],
    );
  }

  Widget _buildPriorityDropdown(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          l10n.priority,
          style: theme.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
        SizedBox(height: 6.h),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              horizontal: 12.w,
              vertical: 10.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: colorScheme.outline),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10.r),
              borderSide: BorderSide(color: colorScheme.primary, width: 2),
            ),
          ),
          items: NotePriority.values.map((priority) {
            return DropdownMenuItem(
              value: priority.value,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: priority.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Flexible(
                    child: Text(
                      priority.getLocalizedName(context),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          onChanged: (value) => setState(() => _selectedPriority = value!),
        ),
      ],
    );
  }

  Future<void> _handleSave() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();

    if (title.isEmpty || content.isEmpty) return;

    setState(() => _isSaving = true);

    try {
      widget.onSave(title, content, _selectedType, _selectedPriority);
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }
}