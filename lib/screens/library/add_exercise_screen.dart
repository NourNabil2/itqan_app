// lib/screens/library/add_exercise_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/utils/extension.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:itqan_gym/data/models/exercise_template.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/exercise_library_provider.dart';
import 'package:itqan_gym/screens/library/widgets/thumbnail_picker.dart';
import 'package:itqan_gym/screens/member/widgets/editInfo_notice.dart';
import 'package:itqan_gym/screens/member/widgets/form_action_buttons.dart';
import 'package:provider/provider.dart';

class AddExerciseScreen extends StatefulWidget {
  final ExerciseType type;
  final ExerciseTemplate? exerciseToEdit;

  const AddExerciseScreen({
    super.key,
    required this.type,
    this.exerciseToEdit,
  });

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _thumbnailPath;
  final List<MediaItem> _mediaGallery = [];
  bool _isLoading = false;
  String? _error;

  bool get _isEditing => widget.exerciseToEdit != null;

  @override
  void initState() {
    super.initState();
    if (_isEditing) _loadExistingData();
  }

  void _loadExistingData() {
    final exercise = widget.exerciseToEdit!;
    _titleController.text = exercise.title;
    _descriptionController.text = exercise.description ?? '';
    _thumbnailPath = exercise.thumbnailPath;
    if (exercise.mediaGallery != null) {
      _mediaGallery.addAll(exercise.mediaGallery!);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final typeColor = widget.type.color;
    return Scaffold(
      appBar: CustomAppBar(
        title: _isEditing
            ? l10n.editExerciseType(widget.type.getLocalizedName(context))
            : l10n.addExerciseType(widget.type.getLocalizedName(context)),
        action: _isEditing ? _buildDeleteButton() : null,
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
                    // Header Section
                    _buildHeaderSection(context, typeColor),

                    SizedBox(height: SizeApp.s20),

                    // Error Display
                    if (_error != null) ...[
                      _buildErrorContainer(),
                      SizedBox(height: SizeApp.s16),
                    ],

                    // Type Badge
                    _buildTypeBadge(context, typeColor),

                    SizedBox(height: SizeApp.s24),

                    // Title Field
                    AppTextField(
                      controller: _titleController,
                      hintText: l10n.exerciseTitleHint,
                      title: l10n.exerciseTitle,
                      prefixIcon: Icon(
                        widget.type.icon,
                        color: typeColor,
                        size: 20.sp,
                      ),
                      validator: _validateTitle,
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Description Field
                    AppTextFieldFactory.textArea(
                      controller: _descriptionController,
                      hintText: l10n.exerciseDescriptionHint,
                      title: l10n.exerciseDescriptionHint,
                      maxLines: 6,
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Media Section Header
                    _buildSectionHeader(context, l10n.instructionalMedia),

                    SizedBox(height: SizeApp.s16),

                    // Thumbnail Picker
                    ThumbnailPicker(
                      thumbnailPath: _thumbnailPath,
                      onPick: _pickThumbnail,
                      onRemove: () => setState(() => _thumbnailPath = null),
                      accentColor: typeColor,
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Media Gallery
                    MediaGalleryPicker(
                      mediaGallery: _mediaGallery,
                      onAddMedia: _addMedia,
                      onRemoveMedia: (media) {
                        setState(() => _mediaGallery.remove(media));
                      },
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Info Notice
                    EditInfoNotice(
                      message: _isEditing
                          ? l10n.changesWillBeSaved
                          : l10n.exerciseWillBeAddedToLibrary(
                          widget.type.getLocalizedName(context)),
                      icon: Icons.info_outline_rounded,
                      backgroundColor: typeColor.withOpacity(0.1),
                      textColor: typeColor,
                      iconColor: typeColor,
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          FormActionButtons(
            onSave: _save,
            onCancel: () => Navigator.pop(context),
            isLoading: _isLoading,
            saveText: _isEditing ? l10n.saveChanges : l10n.addExercise,
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderSection(BuildContext context, Color typeColor) {
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
              color: typeColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              widget.type.icon,
              color: typeColor,
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
                  _isEditing ? l10n.editExercise : l10n.addNewExercise,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                Text(
                  l10n.enterExerciseDetails,
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
          Icon(
            Icons.error_outline,
            color: colorScheme.error,
            size: 20.sp,
          ),
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

  Widget _buildTypeBadge(BuildContext context, Color typeColor) {
    final theme = Theme.of(context);

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: typeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: typeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(widget.type.icon, color: typeColor, size: 16.sp),
          SizedBox(width: 8.w),
          Text(
            widget.type.getLocalizedName(context),
            style: theme.textTheme.labelLarge?.copyWith(
              color: typeColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      children: [
        Icon(
          Icons.perm_media_rounded,
          size: 20.sp,
          color: colorScheme.primary,
        ),
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

  Widget? _buildDeleteButton() {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context);

    return IconButton(
      onPressed: _showDeleteDialog,
      icon: Icon(Icons.delete_rounded, size: 22.sp),
      style: IconButton.styleFrom(
        foregroundColor: colorScheme.error,
      ),
      tooltip: l10n.delete,
    );
  }

  String? _validateTitle(String? value) {
    final l10n = AppLocalizations.of(context);

    if (value == null || value.trim().isEmpty) {
      return l10n.exerciseTitleRequired;
    }
    if (value.trim().length < 3) {
      return l10n.titleMinLength;
    }

    final provider = context.read<ExerciseLibraryProvider>();
    if (provider.isExerciseTitleExists(
      value.trim(),
      excludeId: widget.exerciseToEdit?.id,
    )) {
      return l10n.exerciseTitleExists;
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
      final exercise = ExerciseTemplate(
        id: widget.exerciseToEdit?.id,
        type: widget.type,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim().isNotEmpty
            ? _descriptionController.text.trim()
            : null,
        thumbnailPath: _thumbnailPath,
        mediaGallery: _mediaGallery,
        createdAt: widget.exerciseToEdit?.createdAt ?? now,
        updatedAt: now,
        assignedTeamsCount: widget.exerciseToEdit?.assignedTeamsCount ?? 0,
      );

      final provider = context.read<ExerciseLibraryProvider>();

      if (_isEditing) {
        final success = await provider.updateExercise(exercise);
        if (!success && provider.errorMessage != null) {
          throw Exception(provider.errorMessage);
        }
      } else {
        final id = await provider.createExercise(exercise);
        if (id == null && provider.errorMessage != null) {
          throw Exception(provider.errorMessage);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar(
          _isEditing
              ? AppLocalizations.of(context).exerciseUpdatedSuccessfully
              : AppLocalizations.of(context).exerciseAddedSuccessfully,
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
          l10n.deleteExercise,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            color: colorScheme.error,
          ),
          textAlign: TextAlign.center,
        ),
        content: Text(
          l10n.deleteExerciseConfirmation(widget.exerciseToEdit!.title),
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
      final provider = context.read<ExerciseLibraryProvider>();
      final success = await provider.deleteExercise(widget.exerciseToEdit!.id);

      if (!success && provider.errorMessage != null) {
        throw Exception(provider.errorMessage);
      }

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar(
          AppLocalizations.of(context).exerciseDeletedPermanently,
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

  void _showSuccessSnackBar(String message) {
    if (!mounted) return;

    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: colorScheme.tertiary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}