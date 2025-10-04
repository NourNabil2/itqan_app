// lib/screens/member/edit_member/edit_member_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/extension.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import '../widgets/editInfo_notice.dart';
import '../widgets/form_action_buttons.dart';
import '../widgets/member_basicInfo_form.dart';
import '../widgets/member_photo_upload.dart';

class EditMemberScreen extends StatefulWidget {
  final Member member;

  const EditMemberScreen({
    super.key,
    required this.member,
  });

  @override
  State<EditMemberScreen> createState() => _EditMemberScreenState();
}

class _EditMemberScreenState extends State<EditMemberScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedLevel = 'مبتدئ';
  String? _photoPath;
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _nameController.text = widget.member.name;
    if (widget.member.age != null) {
      _ageController.text = widget.member.age.toString();
    }
    _selectedLevel = widget.member.level;
    _photoPath = widget.member.photoPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: l10n.editMemberData,
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
                    // Error container
                    if (_error != null) ...[
                      ErrorContainer(
                        errors: [_error!],
                        margin: EdgeInsets.only(bottom: SizeApp.s16),
                      ),
                    ],

                    // Photo section
                    MemberPhotoUpload(
                      photoPath: _photoPath,
                      memberName: _nameController.text,
                      onPickImage: _pickImage,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Basic info form
                    MemberBasicInfoForm(
                      nameController: _nameController,
                      ageController: _ageController,
                      selectedLevel: _selectedLevel,
                      onLevelChanged: (level) {
                        setState(() => _selectedLevel = level);
                      },
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Additional info section
                    _buildAdditionalInfoSection(),

                    SizedBox(height: SizeApp.s24),

                    // Notice
                    EditInfoNotice(
                      message: l10n.editMemberNotice,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action buttons
          FormActionButtons(
            onSave: _updateMember,
            onCancel: () => Navigator.pop(context),
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(color: colorScheme.outlineVariant),
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
          Text(
            l10n.additionalInfo,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: colorScheme.onSurface,
            ),
          ),
          SizedBox(height: 12.h),
          _buildInfoRow(
            l10n.registrationDate,
            widget.member.createdAt.dMy(),
          ),
          SizedBox(height: 8.h),
          _buildInfoRow(
            l10n.lastUpdate,
            widget.member.updatedAt.timeAgoCtx(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          flex: 3,
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  void _pickImage() async {
    try {
      MediaPickerHelper.showImageSourceDialog(
        context: context,
        onImageSelected: (imagePath) {
          if (imagePath != null) {
            setState(() => _photoPath = imagePath);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showErrorSnackBar(AppLocalizations.of(context).errorPickingImage);
      }
    }
  }

  Future<void> _updateMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final age = _ageController.text.trim().isNotEmpty
          ? int.tryParse(_ageController.text)
          : null;

      final updatedMember = widget.member.copyWith(
        name: _nameController.text.trim(),
        age: age,
        level: _selectedLevel,
        photoPath: _photoPath,
        updatedAt: DateTime.now(),
      );

      await context.read<MemberLibraryProvider>().updateMember(updatedMember);

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar(
          AppLocalizations.of(context).memberDataUpdatedSuccessfully,
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = '${AppLocalizations.of(context).errorUpdatingMemberData}: ${e.toString()}';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
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

  void _showErrorSnackBar(String message) {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        ),
      ),
    );
  }
}