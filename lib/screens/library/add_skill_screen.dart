// ============= Add Skill Screen - Refactored =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/section_header.dart';
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
    final color = getApparatusColor(_selectedApparatus);

    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: _isEditing ? 'تعديل المهارة' : 'إضافة مهارة جديدة',
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
                      title: _isEditing ? 'تعديل المهارة' : 'إضافة مهارة جديدة',
                      subtitle: 'أدخل تفاصيل المهارة والوسائط التعليمية',
                      leading: Container(
                        padding: EdgeInsets.all(SizeApp.s10),
                        decoration: BoxDecoration(
                          color: color.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(SizeApp.s10),
                        ),
                        child: Icon(
                          Icons.sports_gymnastics_rounded,
                          color: color,
                          size: SizeApp.iconSize,
                        ),
                      ),
                      showDivider: true,
                    ),
                    Padding(
                      padding: EdgeInsets.all(SizeApp.s16),
                      child: Column(
                        children: [
                          if (_error != null) FormErrorContainer(error: _error!),

                          _buildApparatusSection(),

                          SizedBox(height: SizeApp.s24),

                          AppTextField(
                            controller: _nameController,
                            hintText: 'مثال: الدورة الخلفية الممدودة',
                            title: 'اسم المهارة',
                            prefixIcon: Icon(Icons.star_rounded, color: color, size: SizeApp.iconSize),
                            validator: (value) => _validateName(value),
                          ),

                          SizedBox(height: SizeApp.s24),

                          FormSectionHeader(
                            title: 'الوسائط التعليمية',
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

                          _buildSkillDetailsSection(),

                          SizedBox(height: SizeApp.s24),

                          EditInfoNotice(
                            message: _isEditing
                                ? 'سيتم حفظ التعديلات في المكتبة'
                                : 'سيتم إضافة المهارة إلى مكتبة ${_selectedApparatus.arabicName}',
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
            saveText: _isEditing ? 'حفظ التعديلات' : 'إضافة المهارة',
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

  Widget _buildApparatusSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FormSectionHeader(
          title: 'الجهاز',
          icon: Icons.sports_gymnastics_rounded,
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
            items: Apparatus.values.map((apparatus) {
              return DropdownMenuItem(
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
              if (value != null) setState(() => _selectedApparatus = value);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSkillDetailsSection() {
    final fields = [
      {'controller': _technicalAnalysisController, 'title': 'التحليل الفني', 'lines': 4},
      {'controller': _preRequisitesController, 'title': 'المتطلبات المسبقة', 'lines': 3},
      {'controller': _skillProgressionController, 'title': 'تدرج المهارة', 'lines': 4},
      {'controller': _drillsController, 'title': 'التمرينات المهارية', 'lines': 4},
      {'controller': _physicalPreparationController, 'title': 'الإعداد البدني', 'lines': 3},
    ];

    return Column(
      children: fields.map((field) {
        return Padding(
          padding: EdgeInsets.only(bottom: SizeApp.s16),
          child: AppTextFieldFactory.textArea(
            controller: field['controller'] as TextEditingController,
            title: field['title'] as String,
            hintText: 'أدخل ${field['title']}...',
            maxLines: field['lines'] as int,
          ),
        );
      }).toList(),
    );
  }

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) return 'اسم المهارة مطلوب';
    if (value.trim().length < 3) return 'الاسم يجب أن يحتوي على 3 أحرف على الأقل';

    final provider = context.read<SkillLibraryProvider>();
    if (provider.isSkillNameExists(value.trim(), excludeId: widget.skillToEdit?.id)) {
      return 'يوجد مهارة أخرى بنفس الاسم';
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
    MediaPickerHelper.showImageSourceDialog(
      context: context,
      onImageSelected: (path) {
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
            content: Text(_isEditing ? 'تم تحديث المهارة بنجاح' : 'تم إضافة المهارة بنجاح'),
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
      title: 'حذف المهارة',
      itemName: widget.skillToEdit!.skillName,
      onConfirm: _delete,
    );
  }

  Future<void> _delete() async {
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
          const SnackBar(
            content: Text('تم حذف المهارة نهائياً'),
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
}