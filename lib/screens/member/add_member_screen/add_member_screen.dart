// lib/screens/member/add_global_member/add_global_member_screen.dart
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/services/ad_service.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/editInfo_notice.dart';
import '../widgets/form_action_buttons.dart';
import '../widgets/member_basicInfo_form.dart';
import '../widgets/member_photo_upload.dart';

class AddGlobalMemberScreen extends StatefulWidget {
  final Member? memberToEdit;

  const AddGlobalMemberScreen({super.key, this.memberToEdit});

  @override
  State<AddGlobalMemberScreen> createState() => _AddGlobalMemberScreenState();
}

class _AddGlobalMemberScreenState extends State<AddGlobalMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedLevel = 'مبتدئ';
  String? _photoPath;
  bool _isLoading = false;
  String? _error;

  bool get _isEditing => widget.memberToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) {
      _loadExistingMember();
    }
  }

  void _loadExistingMember() {
    final member = widget.memberToEdit!;
    _nameController.text = member.name;
    _ageController.text = member.age.toString();
      _notesController.text = member.notes ?? '';
    _selectedLevel = member.level;
    _photoPath = member.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? l10n.editMember : l10n.addMemberToLibrary,
        action: _isEditing
            ? IconButton(
          onPressed: _showDeleteDialog,
          icon: Icon(
            Icons.delete_rounded,
            size: 22.sp,
          ),
          style: IconButton.styleFrom(
            foregroundColor: colorScheme.error,
          ),
        )
            : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Error display
                    if (_error != null) ...[
                      ErrorContainer(
                        errors: [_error!],
                        margin: EdgeInsets.only(bottom: SizeApp.s16),
                      ),
                    ],

                    // Photo upload section
                    MemberPhotoUpload(
                      photoPath: _photoPath,
                      memberName: _nameController.text,
                      onPickImage: _handleImagePicker,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: SizeApp.s32),

                    // Basic info form
                    MemberBasicInfoForm(
                      nameController: _nameController,
                      ageController: _ageController,
                      selectedLevel: _selectedLevel,
                      onLevelChanged: (level) {
                        setState(() => _selectedLevel = level);
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Notes field
                    AppTextFieldFactory.textArea(
                      controller: _notesController,
                      hintText: l10n.memberNotesHint,
                      title: l10n.notesOptional,
                      maxLines: 4,
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Info notice
                    EditInfoNotice(
                      message: _isEditing
                          ? l10n.editMemberLibraryNotice
                          : l10n.addMemberLibraryNotice,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          FormActionButtons(
            onSave: _saveMember,
            onCancel: () => Navigator.pop(context),
            isLoading: _isLoading,
            saveText: _isEditing ? l10n.saveChanges : l10n.addMember,
          ),
        ],
      ),
    );
  }

  void _handleImagePicker() {
    MediaPickerHelper.showImageSourceDialog(
      context: context,
      onImageSelected: (imagePath) {
        if (imagePath != null) {
          setState(() => _photoPath = imagePath);
        }
      },
    );
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final age = _ageController.text.trim().isNotEmpty
          ? int.tryParse(_ageController.text)
          : 0;

      final member = Member(
        id: widget.memberToEdit?.id,
        name: _nameController.text.trim(),
        age: age!,
        level: _selectedLevel,
        photoPath: _photoPath,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final provider = context.read<MemberLibraryProvider>();

      if (_isEditing) {
        await provider.updateMember(member);
      } else {
        await provider.createMember(member);
      }

      if (!mounted) return;

      // الإجراء النهائي بعد النجاح (بعد الإعلان أو بدونه)
      void finalize() {
        if (!mounted) return;

        _showSuccessSnackBar(
          _isEditing
              ? AppLocalizations.of(context).memberUpdatedSuccessfully
              : AppLocalizations.of(context).memberAddedSuccessfully,
        );

        // رجّع true علشان الشاشة السابقة تقدر تعمل refresh لو حابّة
        Navigator.pop(context, true);
      }

      // جرّب تعرض إعلان interstitial أولًا
      final shown = await AdsService.instance.showInterstitial(
        onDismissed: finalize,
      );

      // لو الإعلان مش جاهز/فشل → كمل الإجراء فورًا
      if (!shown) {
        finalize();
      }
    } catch (e) {
      if (mounted) {
        _showError(
          '${AppLocalizations.of(context).errorSavingMember}: ${e.toString()}',
        );
      }
      log('Error saving member: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showDeleteDialog() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
          l10n.deleteMember,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          l10n.deleteMemberConfirmation(widget.memberToEdit!.name),
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          FilledButton(
            onPressed: _deleteMember,
            style: FilledButton.styleFrom(
              backgroundColor: colorScheme.error,
              foregroundColor: colorScheme.onError,
            ),
            child: Text(l10n.deletePermanently),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteMember() async {
    Navigator.pop(context); // Close dialog

    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<MemberLibraryProvider>();
      await provider.deleteMember(widget.memberToEdit!.id);

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar(
          AppLocalizations.of(context).memberDeletedPermanently(widget.memberToEdit!.name),
        );
      }
    } catch (e) {
      if (mounted) {
        _showError(
          '${AppLocalizations.of(context).errorDeletingMember}: ${e.toString()}',
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    setState(() => _error = message);
  }

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        ),
      ),
    );
  }
}