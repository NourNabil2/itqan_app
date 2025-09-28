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
import 'package:itqan_gym/screens/member/widgets/editInfo_notice.dart';
import 'package:itqan_gym/screens/member/widgets/form_action_buttons.dart';
import 'package:provider/provider.dart';
import '../../data/models/skill_template.dart';
import '../../providers/skill_library_provider.dart';


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
    if (_isEditing) {
      _loadExistingSkill();
    }
  }

  void _loadExistingSkill() {
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
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(title:   _isEditing ? 'تعديل المهارة' : 'إضافة مهارة جديدة', action: _isEditing ? _buildDeleteButton() : null,),
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

                          // Apparatus Section
                          _buildApparatusSection(),

                          SizedBox(height: SizeApp.s24),

                          // Skill Name Field
                          AppTextField(
                            controller: _nameController,
                            hintText: 'مثال: الدورة الخلفية الممدودة',
                            title: 'اسم المهارة',
                            prefixIcon: Icon(
                              Icons.star_rounded,
                              color: _getApparatusColor(),
                              size: SizeApp.iconSize,
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'اسم المهارة مطلوب';
                              }
                              if (value.trim().length < 3) {
                                return 'الاسم يجب أن يحتوي على 3 أحرف على الأقل';
                              }

                              // Check for duplicate names
                              final provider = context.read<SkillLibraryProvider>();
                              if (provider.isSkillNameExists(
                                value.trim(),
                                excludeId: widget.skillToEdit?.id,
                              )) {
                                return 'يوجد مهارة أخرى بنفس الاسم';
                              }

                              return null;
                            },
                          ),

                          SizedBox(height: SizeApp.s24),

                          // Media Section
                          _buildMediaSection(),

                          SizedBox(height: SizeApp.s24),

                          // Skill Details Sections
                          _buildSkillDetailsSection(),

                          SizedBox(height: SizeApp.s24),

                          // Info Notice
                          EditInfoNotice(
                            message: _isEditing
                                ? 'سيتم حفظ التعديلات على هذه المهارة في المكتبة'
                                : 'سيتم إضافة هذه المهارة إلى مكتبة مهارات ${_selectedApparatus.arabicName}',
                            icon: Icons.info_outline_rounded,
                            backgroundColor: _getApparatusColor().withOpacity(0.1),
                            textColor: _getApparatusColor(),
                            iconColor: _getApparatusColor(),
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
            onSave: _saveSkill,
            onCancel: () => Navigator.pop(context),
            isLoading: _isLoading,
            saveText: _isEditing ? 'حفظ التعديلات' : 'إضافة المهارة',
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
      tooltip: 'حذف المهارة',
    );
  }

  Widget _buildHeader() {
    return SectionHeader(
      title: _isEditing ? 'تعديل المهارة' : 'إضافة مهارة جديدة',
      subtitle: 'أدخل تفاصيل المهارة والوسائط التعليمية',
      leading: Container(
        padding: EdgeInsets.all(SizeApp.s10),
        decoration: BoxDecoration(
          color: _getApparatusColor().withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.s10),
        ),
        child: Icon(
          _getApparatusIcon(),
          color: _getApparatusColor(),
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

  Widget _buildApparatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.sports_gymnastics_rounded,
              color: ColorsManager.primaryColor,
              size: 16.sp,
            ),
            SizedBox(width: SizeApp.s8),
            Text(
              'الجهاز',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: ColorsManager.defaultText,
              ),
            ),
          ],
        ),

        SizedBox(height: SizeApp.s12),

        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            border: Border.all(
              color: ColorsManager.inputBorder.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: DropdownButton<Apparatus>(
            value: _selectedApparatus,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultText,
            ),
            items: Apparatus.values.map((apparatus) {
              return DropdownMenuItem<Apparatus>(
                value: apparatus,
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: getApparatusColor(apparatus),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: SizeApp.s12),
                    Text(apparatus.arabicName),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedApparatus = value;
                });
              }
            },
          ),
        ),
      ],
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
              'الوسائط التعليمية',
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
            foregroundColor: _getApparatusColor(),
            side: BorderSide(color: _getApparatusColor()),
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
        color: ColorsManager.primaryColor,
      ),
      label: Text(
        '${media.type == MediaType.video ? 'فيديو' : 'صورة'}: ${media.path.split('/').last}',
        style: TextStyle(fontSize: 12.sp),
      ),
      onDeleted: () => setState(() => _mediaGallery.remove(media)),
      deleteIconColor: ColorsManager.errorFill,
    );
  }

  Widget _buildSkillDetailsSection() {
    return Column(
      children: [
        // Technical Analysis
        AppTextFieldFactory.textArea(
          controller: _technicalAnalysisController,
          hintText: 'وصف تقني مفصل للمهارة وخطوات تنفيذها...',
          title: 'التحليل الفني',
          maxLines: 4,
        ),

        SizedBox(height: SizeApp.s16),

        // Pre-requisites
        AppTextFieldFactory.textArea(
          controller: _preRequisitesController,
          hintText: 'المهارات والقدرات المطلوبة قبل تعلم هذه المهارة...',
          title: 'المتطلبات المسبقة',
          maxLines: 3,
        ),

        SizedBox(height: SizeApp.s16),

        // Skill Progression
        AppTextFieldFactory.textArea(
          controller: _skillProgressionController,
          hintText: 'خطوات التدرج في تعلم المهارة من البداية...',
          title: 'تدرج المهارة',
          maxLines: 4,
        ),

        SizedBox(height: SizeApp.s16),

        // Drills
        AppTextFieldFactory.textArea(
          controller: _drillsController,
          hintText: 'التمرينات التحضيرية والمهارية للمهارة...',
          title: 'التمرينات المهارية (Drills)',
          maxLines: 4,
        ),

        SizedBox(height: SizeApp.s16),

        // Physical Preparation
        AppTextFieldFactory.textArea(
          controller: _physicalPreparationController,
          hintText: 'متطلبات الإعداد البدني والقوة المطلوبة...',
          title: 'الإعداد البدني',
          maxLines: 3,
        ),
      ],
    );
  }

  // Helper Methods
  Color _getApparatusColor() {
    return getApparatusColor(_selectedApparatus);
  }



  IconData _getApparatusIcon() {
    return Icons.sports_gymnastics_rounded;
  }

  // Action Methods
  void _pickThumbnail() {
    MediaPickerHelper.showImageSourceDialog(
      context: context,
      onImageSelected: (imagePath) {
        if (imagePath != null) {
          setState(() => _thumbnailPath = imagePath);
        }
      },
    );
  }

  void _addMediaToGallery(MediaType type) {
    MediaPickerHelper.showImageSourceDialog(
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

  Future<void> _saveSkill() async {
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
        final success = await provider.updateSkill(skill);
        if (!success && provider.errorMessage != null) {
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing
                  ? 'تم تحديث المهارة بنجاح'
                  : 'تم إضافة المهارة بنجاح',
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
              'حذف المهارة',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.errorFill,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف "${widget.skillToEdit!.skillName}" نهائياً؟\n\nلا يمكن التراجع عن هذا الإجراء.',
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
            onPressed: _deleteSkill,
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

  Future<void> _deleteSkill() async {
    Navigator.pop(context); // Close dialog

    setState(() => _isLoading = true);

    try {
      final provider = context.read<SkillLibraryProvider>();
      final success = await provider.deleteSkill(widget.skillToEdit!.id);

      if (!success && provider.errorMessage != null) {
        throw Exception(provider.errorMessage);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('تم حذف المهارة نهائياً'),
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