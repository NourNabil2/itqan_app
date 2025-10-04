import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/skill_library_provider.dart';
import 'package:itqan_gym/screens/library/widgets/thumbnail_picker.dart';
import 'package:itqan_gym/screens/member/widgets/editInfo_notice.dart';
import 'package:itqan_gym/screens/member/widgets/form_action_buttons.dart';
import 'package:provider/provider.dart';

class AddSkillScreen extends StatefulWidget {
  final SkillTemplate? skillToEdit;

  const AddSkillScreen({super.key, this.skillToEdit});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _technicalAnalysisController = TextEditingController();
  final _preRequisitesController = TextEditingController();
  final _skillProgressionController = TextEditingController();
  final _drillsController = TextEditingController();
  final _physicalPreparationController = TextEditingController();

  Apparatus _selectedApparatus = Apparatus.floor;
  String? _thumbnailPath;
  final List<MediaItem> _mediaGallery = [];
  bool _isLoading = false;
  String? _error;

  bool get _isEditing => widget.skillToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadExistingData();
  }

  void _loadExistingData() {
    final skill = widget.skillToEdit!;
    _selectedApparatus = skill.apparatus;
    _nameController.text = skill.skillName;
    _thumbnailPath = skill.thumbnailPath;
    _technicalAnalysisController.text = skill.technicalAnalysis ?? '';
    _preRequisitesController.text = skill.preRequisites ?? '';
    _skillProgressionController.text = skill.skillProgression ?? '';
    _drillsController.text = skill.drills ?? '';
    _physicalPreparationController.text = skill.physicalPreparation ?? '';
    _mediaGallery.addAll(skill.mediaGallery);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _technicalAnalysisController.dispose();
    _preRequisitesController.dispose();
    _skillProgressionController.dispose();
    _drillsController.dispose();
    _physicalPreparationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final apparatusColor = getApparatusColor(_selectedApparatus);

    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing ? l10n.editSkill : l10n.addNewSkill,
        action: _isEditing ? _buildDeleteButton() : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s16),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header (تم إصلاح المتغير)
                    _buildHeaderSection(context, apparatusColor),

                    SizedBox(height: SizeApp.s20),

                    if (_error != null) ...[
                      _buildErrorContainer(),
                      SizedBox(height: SizeApp.s16),
                    ],

                    _buildApparatusSection(context),

                    SizedBox(height: SizeApp.s24),

                    AppTextField(
                      controller: _nameController,
                      hintText: l10n.skillNameHint,
                      title: l10n.skillName,
                      prefixIcon: Icon(
                        Icons.star_rounded,
                        color: apparatusColor,
                        size: 20.sp,
                      ),
                      validator: _validateName,
                    ),

                    SizedBox(height: SizeApp.s24),

                    _buildSectionHeader(context, l10n.instructionalMedia),

                    SizedBox(height: SizeApp.s16),

                    ThumbnailPicker(
                      thumbnailPath: _thumbnailPath,
                      onPick: _pickThumbnail,
                      onRemove: () => setState(() => _thumbnailPath = null),
                      accentColor: apparatusColor,
                    ),

                    SizedBox(height: SizeApp.s16),

                    MediaGalleryPicker(
                      mediaGallery: _mediaGallery,
                      onAddMedia: _addMedia,
                      onRemoveMedia: (media) {
                        setState(() => _mediaGallery.remove(media));
                      },
                    ),

                    SizedBox(height: SizeApp.s24),

                    _buildSkillDetailsSection(context),

                    SizedBox(height: SizeApp.s24),

                    EditInfoNotice(
                      message: _isEditing
                          ? l10n.changesWillBeSaved
                          : l10n.skillWillBeAddedToLibrary(
                        _selectedApparatus.getLocalizedName(context),
                      ),
                      icon: Icons.info_outline_rounded,
                      backgroundColor: apparatusColor.withOpacity(0.1),
                      textColor: apparatusColor,
                      iconColor: apparatusColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          FormActionButtons(
            onSave: _save,
            onCancel: () => Navigator.pop(context),
            isLoading: _isLoading,
            saveText: _isEditing ? l10n.saveChanges : l10n.addSkill,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Color apparatusColor) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: apparatusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.sports_gymnastics_rounded,
              color: apparatusColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isEditing ? l10n.editSkill : l10n.addNewSkill,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.enterSkillDetails,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorContainer() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.error.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.error, size: 20.sp),
          SizedBox(width: 12.w),
          Expanded(
            child: Text(
              _error!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildApparatusSection(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Icon(Icons.sports_gymnastics_rounded, size: 20.sp, color: colorScheme.primary),
            SizedBox(width: 8.w),
            Text(
              l10n.apparatus,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: colorScheme.onSurface,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          ),
          child: DropdownButton<Apparatus>(
            value: _selectedApparatus,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            icon: Icon(Icons.keyboard_arrow_down_rounded, color: colorScheme.onSurfaceVariant),
            dropdownColor: colorScheme.surface,
            items: Apparatus.values.map((ap) {
              final c = getApparatusColor(ap);
              return DropdownMenuItem(
                value: ap,
                child: Row(
                  children: [
                    Container(
                      width: 10.w,
                      height: 10.h,
                      decoration: BoxDecoration(color: c, shape: BoxShape.circle),
                    ),
                    SizedBox(width: 12.w),
                    Flexible(
                      child: Text(
                        ap.getLocalizedName(context),
                        style: theme.textTheme.bodyLarge,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedApparatus = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(Icons.perm_media_rounded, size: 20.sp, color: colorScheme.primary),
        SizedBox(width: 8.w),
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  Widget _buildSkillDetailsSection(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final fields = [
      {'controller': _technicalAnalysisController, 'title': l10n.technicalAnalysis, 'lines': 4},
      {'controller': _preRequisitesController, 'title': l10n.preRequisites, 'lines': 3},
      {'controller': _skillProgressionController, 'title': l10n.skillProgression, 'lines': 4},
      {'controller': _drillsController, 'title': l10n.skillDrills, 'lines': 4},
      {'controller': _physicalPreparationController, 'title': l10n.physicalPreparation, 'lines': 3},
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: fields.map((field) {
        return Padding(
          padding: EdgeInsets.only(bottom: SizeApp.s16),
          child: AppTextFieldFactory.textArea(
            controller: field['controller'] as TextEditingController,
            title: field['title'] as String,
            hintText: l10n.enter(field['title'] as String),
            maxLines: field['lines'] as int,
          ),
        );
      }).toList(),
    );
  }

  Widget? _buildDeleteButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return IconButton(
      onPressed: _showDeleteDialog,
      icon: Icon(Icons.delete_rounded, size: 22.sp),
      style: IconButton.styleFrom(foregroundColor: colorScheme.error),
      tooltip: l10n.delete,
    );
  }

  String? _validateName(String? value) {
    final l10n = AppLocalizations.of(context);
    if (value == null || value.trim().isEmpty) return l10n.skillNameRequired;
    if (value.trim().length < 3) return l10n.nameMinLength;

    final provider = context.read<SkillLibraryProvider>();
    if (provider.isSkillNameExists(value.trim(), excludeId: widget.skillToEdit?.id)) {
      return l10n.skillNameExists;
    }
    return null;
  }

  void _pickThumbnail() {
    MediaPickerHelper.showImageSourceDialog(
      context: context,
      onImageSelected: (path) {
        if (path != null) setState(() => _thumbnailPath = path);
      },
    );
  }

  void _addMedia(MediaType type) {
    MediaPickerHelper.showMediaTypeDialog(
      context: context,
      isVideo: type == MediaType.video,
      onMediaSelected: (path) {
        if (path != null) {
          setState(() {
            _mediaGallery.add(MediaItem(path: path, type: type));
          });
        }
      },
    );
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final skill = SkillTemplate(
        id: widget.skillToEdit?.id,
        apparatus: _selectedApparatus,
        skillName: _nameController.text.trim(),
        thumbnailPath: _thumbnailPath,
        mediaGallery: _mediaGallery,
        technicalAnalysis: _technicalAnalysisController.text.trim().isNotEmpty
            ? _technicalAnalysisController.text.trim()
            : null,
        preRequisites: _preRequisitesController.text.trim().isNotEmpty
            ? _preRequisitesController.text.trim()
            : null,
        skillProgression: _skillProgressionController.text.trim().isNotEmpty
            ? _skillProgressionController.text.trim()
            : null,
        drills: _drillsController.text.trim().isNotEmpty
            ? _drillsController.text.trim()
            : null,
        physicalPreparation: _physicalPreparationController.text.trim().isNotEmpty
            ? _physicalPreparationController.text.trim()
            : null,
        createdAt: widget.skillToEdit?.createdAt ?? now,
        updatedAt: now,
        assignedTeamsCount: widget.skillToEdit?.assignedTeamsCount ?? 0,
      );

      final provider = context.read<SkillLibraryProvider>();

      if (_isEditing) {
        final ok = await provider.updateSkill(skill);
        if (!ok && provider.errorMessage != null) {
          throw Exception(provider.errorMessage);
        }
      } else {
        final id = await provider.createSkill(skill);
        if (id == null && provider.errorMessage != null) {
          throw Exception(provider.errorMessage);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar(
          _isEditing
              ? AppLocalizations.of(context).skillUpdatedSuccessfully
              : AppLocalizations.of(context).skillAddedSuccessfully,
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        icon: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(color: colorScheme.errorContainer, shape: BoxShape.circle),
          child: Icon(Icons.delete_outline_rounded, size: 32.sp, color: colorScheme.error),
        ),
        title: Text(
          l10n.deleteSkill,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          l10n.deleteSkillConfirmation(widget.skillToEdit!.skillName),
          style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
          textAlign: TextAlign.center,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.cancel)),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _delete();
            },
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

  Future<void> _delete() async {
    setState(() => _isLoading = true);
    try {
      final provider = context.read<SkillLibraryProvider>();
      final ok = await provider.deleteSkill(widget.skillToEdit!.id);
      if (!ok && provider.errorMessage != null) {
        throw Exception(provider.errorMessage);
      }
      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar(AppLocalizations.of(context).skillDeletedPermanently);
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
      ),
    );
  }
}
