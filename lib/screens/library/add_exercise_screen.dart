// ============= Add Exercise Screen - Refactored =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
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
    final color = _getTypeColor();

    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: _isEditing ? 'تعديل ${widget.type.getLocalizedName(context)}' : 'إضافة ${widget.type.getLocalizedName(context)}',
        action: _isEditing ? _buildDeleteButton() : null,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    SectionHeader(
                      title: _isEditing ? 'تعديل التمرين' : 'إضافة تمرين جديد',
                      subtitle: 'أدخل تفاصيل التمرين والوسائط',
                      leading: Container(
                        padding: EdgeInsets.all(SizeApp.s10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(SizeApp.s10),
                        ),
                        child: Icon(_getTypeIcon(), color: color, size: SizeApp.iconSize),
                      ),
                      showDivider: true,
                    ),
                    Padding(
                      padding: EdgeInsets.all(SizeApp.s16),
                      child: Column(
                        children: [
                          if (_error != null) FormErrorContainer(error: _error!),

                          TypeBadge(
                            label: widget.type.getLocalizedName(context),
                            icon: _getTypeIcon(),
                            color: color,
                          ),

                          SizedBox(height: SizeApp.s24),

                          AppTextField(
                            controller: _titleController,
                            hintText: 'مثال: تمرين القفز بالحبل',
                            title: 'عنوان التمرين',
                            prefixIcon: Icon(_getTypeIcon(), color: color, size: SizeApp.iconSize),
                            validator: (value) => _validateTitle(value),
                          ),

                          SizedBox(height: SizeApp.s16),

                          AppTextFieldFactory.textArea(
                            controller: _descriptionController,
                            hintText: 'اشرح كيفية أداء التمرين...',
                            title: 'الوصف',
                            maxLines: 6,
                          ),

                          SizedBox(height: SizeApp.s24),

                          const FormSectionHeader(
                            title: 'الوسائط التوضيحية',
                            icon: Icons.perm_media_rounded,
                          ),

                          SizedBox(height: SizeApp.s16),

                          ThumbnailPicker(
                            thumbnailPath: _thumbnailPath,
                            onPick: _pickThumbnail,
                            onRemove: () => setState(() => _thumbnailPath = null),
                            accentColor: color,
                          ),

                          SizedBox(height: SizeApp.s16),

                          MediaGalleryPicker(
                            mediaGallery: _mediaGallery,
                            onAddMedia: _addMedia,
                            onRemoveMedia: (media) => setState(() => _mediaGallery.remove(media)),
                          ),

                          SizedBox(height: SizeApp.s24),

                          EditInfoNotice(
                            message: _isEditing
                                ? 'سيتم حفظ التعديلات في المكتبة'
                                : 'سيتم إضافة التمرين إلى مكتبة ${widget.type.getLocalizedName(context)}',
                            icon: Icons.info_outline_rounded,
                            backgroundColor: color.withOpacity(0.1),
                            textColor: color,
                            iconColor: color,
                          ),
                        ],
                      ),
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
            saveText: _isEditing ? 'حفظ التعديلات' : 'إضافة التمرين',
          ),
        ],
      ),
    );
  }

  Widget? _buildDeleteButton() {
    return IconButton(
      onPressed: _showDeleteDialog,
      icon: Icon(Icons.delete_rounded, color: ColorsManager.errorFill, size: SizeApp.iconSize),
      tooltip: 'حذف',
    );
  }

  String? _validateTitle(String? value) {
    if (value == null || value.trim().isEmpty) return 'عنوان التمرين مطلوب';
    if (value.trim().length < 3) return 'العنوان يجب أن يحتوي على 3 أحرف على الأقل';

    final provider = context.read<ExerciseLibraryProvider>();
    if (provider.isExerciseTitleExists(value.trim(), excludeId: widget.exerciseToEdit?.id)) {
      return 'يوجد تمرين آخر بنفس العنوان';
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
          setState(() => _mediaGallery.add(MediaItem(path: path, type: type)));
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isEditing ? 'تم تحديث التمرين بنجاح' : 'تم إضافة التمرين بنجاح'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteDialog() {
    DeleteConfirmationDialog.show(
      context: context,
      title: 'حذف التمرين',
      itemName: widget.exerciseToEdit!.title,
      onConfirm: _delete,
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
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف التمرين نهائياً'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  IconData _getTypeIcon() {
    switch (widget.type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }

  Color _getTypeColor() {
    switch (widget.type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
    }
  }
}