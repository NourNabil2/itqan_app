import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
import 'package:provider/provider.dart';
import '../../data/models/exercise_template.dart';
import '../../data/models/skill_template.dart';
import '../../providers/exercise_library_provider.dart';
import '../member/widgets/editInfo_notice.dart';
import '../member/widgets/form_action_buttons.dart';

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
    if (_isEditing) {
      _loadExistingExercise();
    }
  }

  void _loadExistingExercise() {
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
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: _isEditing
            ? 'تعديل ${widget.type.arabicName}'
            : 'إضافة ${widget.type.arabicName}',
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
                    // Header Section
                    _buildHeader(),

                    // Form Content
                    Padding(
                      padding: EdgeInsets.all(SizeApp.s16),
                      child: Column(
                        children: [
                          // Error Display
                          if (_error != null) _buildErrorContainer(),

                          // Exercise Type Badge
                          _buildTypeBadge(),

                          SizedBox(height: SizeApp.s24),

                          // Title Field
                          AppTextField(
                            controller: _titleController,
                            hintText: 'مثال: تمرين القفز بالحبل',
                            title: 'عنوان التمرين',
                            prefixIcon: Icon(
                              _getExerciseTypeIcon(),
                              color: _getExerciseTypeColor(),
                              size: SizeApp.iconSize,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'عنوان التمرين مطلوب';
                              }
                              if (value.trim().length < 3) {
                                return 'العنوان يجب أن يحتوي على 3 أحرف على الأقل';
                              }

                              // Check for duplicate titles
                              final provider = context.read<ExerciseLibraryProvider>();
                              if (provider.isExerciseTitleExists(
                                value.trim(),
                                excludeId: widget.exerciseToEdit?.id,
                              )) {
                                return 'يوجد تمرين آخر بنفس العنوان';
                              }

                              return null;
                            },
                          ),

                          SizedBox(height: SizeApp.s16),

                          // Description Field
                          AppTextFieldFactory.textArea(
                            controller: _descriptionController,
                            hintText: 'اشرح كيفية أداء التمرين بالتفصيل...',
                            title: 'الوصف',
                            maxLines: 6,
                          ),

                          SizedBox(height: SizeApp.s24),

                          // Media Section
                          _buildMediaSection(),

                          SizedBox(height: SizeApp.s24),

                          // Info Notice
                          EditInfoNotice(
                            message: _isEditing
                                ? 'سيتم حفظ التعديلات على هذا التمرين في المكتبة'
                                : 'سيتم إضافة هذا التمرين إلى مكتبة ${widget.type.arabicName}',
                            icon: Icons.info_outline_rounded,
                            backgroundColor: _getExerciseTypeColor().withOpacity(0.1),
                            textColor: _getExerciseTypeColor(),
                            iconColor: _getExerciseTypeColor(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          FormActionButtons(
            onSave: _saveExercise,
            onCancel: () => Navigator.pop(context),
            isLoading: _isLoading,
            saveText: _isEditing ? 'حفظ التعديلات' : 'إضافة التمرين',
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteButton() {
    return IconButton(
      onPressed: _showDeleteDialog,
      icon: Icon(
        Icons.delete_rounded,
        color: ColorsManager.errorFill,
        size: SizeApp.iconSize,
      ),
      tooltip: 'حذف التمرين',
    );
  }

  Widget _buildHeader() {
    return SectionHeader(
      title: _isEditing ? 'تعديل التمرين' : 'إضافة تمرين جديد',
      subtitle: 'أدخل تفاصيل التمرين وأضف الوسائط التوضيحية',
      leading: Container(
        padding: EdgeInsets.all(SizeApp.s10),
        decoration: BoxDecoration(
          color: _getExerciseTypeColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.s10),
        ),
        child: Icon(
          _getExerciseTypeIcon(),
          color: _getExerciseTypeColor(),
          size: SizeApp.iconSize,
        ),
      ),
      showDivider: true,
    );
  }

  Widget _buildErrorContainer() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.errorFill.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: ColorsManager.errorFill.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            color: ColorsManager.errorFill,
            size: SizeApp.iconSize,
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Text(
              _error!,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.errorFill,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeBadge() {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s16,
        vertical: SizeApp.s8,
      ),
      decoration: BoxDecoration(
        color: _getExerciseTypeColor().withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        border: Border.all(
          color: _getExerciseTypeColor().withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getExerciseTypeIcon(),
            color: _getExerciseTypeColor(),
            size: 16.sp,
          ),
          SizedBox(width: SizeApp.s8),
          Text(
            widget.type.arabicName,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: _getExerciseTypeColor(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.perm_media_rounded,
              color: ColorsManager.primaryColor,
              size: 16.sp,
            ),
            SizedBox(width: SizeApp.s8),
            Text(
              'الوسائط التوضيحية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.defaultText,
              ),
            ),
          ],
        ),

        SizedBox(height: SizeApp.s16),

        // Thumbnail Section
        _buildThumbnailSection(),

        SizedBox(height: SizeApp.s16),

        // Media Gallery Section
        _buildMediaGallerySection(),
      ],
    );
  }

  Widget _buildThumbnailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الصورة المصغرة',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),

        SizedBox(height: SizeApp.s8),

        if (_thumbnailPath != null) ...[
          Container(
            height: 120.h,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              color: ColorsManager.backgroundCard,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  child: Image.file(
                    File(_thumbnailPath!),
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: double.infinity,
                  ),
                ),
                Positioned(
                  top: SizeApp.s4,
                  right: SizeApp.s4,
                  child: Container(
                    decoration: BoxDecoration(
                      color: ColorsManager.errorFill,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () => setState(() => _thumbnailPath = null),
                      icon: Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 16.sp,
                      ),
                      padding: EdgeInsets.all(SizeApp.s4),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: SizeApp.s8),
        ],

        OutlinedButton.icon(
          onPressed: _pickThumbnail,
          icon: Icon(Icons.image_rounded, size: SizeApp.iconSize),
          label: Text(_thumbnailPath == null ? 'إضافة صورة مصغرة' : 'تغيير الصورة'),
          style: OutlinedButton.styleFrom(
            foregroundColor: _getExerciseTypeColor(),
            side: BorderSide(color: _getExerciseTypeColor()),
            padding: EdgeInsets.symmetric(vertical: 12.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMediaGallerySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'معرض الوسائط',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),

        SizedBox(height: SizeApp.s8),

        // Media buttons
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addMediaToGallery(MediaType.image),
                icon: Icon(Icons.add_photo_alternate_rounded, size: SizeApp.iconSize),
                label: const Text('إضافة صورة'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsManager.primaryColor,
                  side: BorderSide(color: ColorsManager.primaryColor),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
              ),
            ),

            SizedBox(width: SizeApp.s8),

            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => _addMediaToGallery(MediaType.video),
                icon: Icon(Icons.videocam_rounded, size: SizeApp.iconSize),
                label: const Text('إضافة فيديو'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsManager.secondaryColor,
                  side: BorderSide(color: ColorsManager.secondaryColor),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ),

        // Media gallery display
        if (_mediaGallery.isNotEmpty) ...[
          SizedBox(height: SizeApp.s12),
          Wrap(
            spacing: SizeApp.s8,
            runSpacing: SizeApp.s8,
            children: _mediaGallery.map((media) => _buildMediaChip(media)).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildMediaChip(MediaItem media) {
    return Chip(
      avatar: Icon(
        media.type == MediaType.video ? Icons.videocam : Icons.image,
        size: 16.sp,
        color: _getExerciseTypeColor(),
      ),
      label: Text(
        '${media.type == MediaType.video ? 'فيديو' : 'صورة'}: ${media.path.split('/').last}',
        style: TextStyle(fontSize: 12.sp),
      ),
      onDeleted: () => setState(() => _mediaGallery.remove(media)),
      deleteIconColor: ColorsManager.errorFill,
    );
  }

  // Helper Methods
  IconData _getExerciseTypeIcon() {
    switch (widget.type) {
      case ExerciseType.warmup:
        return Icons.whatshot_rounded;
      case ExerciseType.stretching:
        return Icons.accessibility_new_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
      default:
        return Icons.fitness_center_rounded;
    }
  }

  Color _getExerciseTypeColor() {
    switch (widget.type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF5722);
      case ExerciseType.stretching:
        return const Color(0xFF4CAF50);
      case ExerciseType.conditioning:
        return const Color(0xFF2196F3);
      default:
        return ColorsManager.primaryColor;
    }
  }

  // Action Methods
  void _pickThumbnail() {
    ImagePickerHelper.showImageSourceDialog(
      context: context,
      onImageSelected: (imagePath) {
        if (imagePath != null) {
          setState(() => _thumbnailPath = imagePath);
        }
      },
    );
  }

  void _addMediaToGallery(MediaType type) {
    ImagePickerHelper.showImageSourceDialog(
      context: context,
      onImageSelected: (imagePath) {
        if (imagePath != null) {
          setState(() {
            _mediaGallery.add(MediaItem(path: imagePath, type: type));
          });
        }
      },
    );
  }

  Future<void> _saveExercise() async {
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
            content: Text(
              _isEditing
                  ? 'تم تحديث التمرين بنجاح'
                  : 'تم إضافة التمرين بنجاح',
            ),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        ),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: ColorsManager.errorFill,
              size: 24.sp,
            ),
            SizedBox(width: SizeApp.s8),
            Text(
              'حذف التمرين',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.errorFill,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف "${widget.exerciseToEdit!.title}" نهائياً؟\n\nلا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(
            fontSize: 14.sp,
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'إلغاء',
              style: TextStyle(
                color: ColorsManager.defaultTextSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: _deleteExercise,
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
            child: Text(
              'حذف نهائياً',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteExercise() async {
    Navigator.pop(context); // Close dialog

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
          SnackBar(
            content: const Text('تم حذف التمرين نهائياً'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}