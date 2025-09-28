import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/image_picker_helper.dart';
import '../../../data/models/member/member.dart';
import '../widgets/editInfo_notice.dart';
import '../widgets/form_action_buttons.dart';
import '../widgets/member_basicInfo_form.dart';
import '../widgets/member_photo_upload.dart'; // استيراد المكونات المخصصة

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
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: _isEditing ? 'تعديل العضو' : 'إضافة عضو للمكتبة',
        action: _isEditing
            ? IconButton(
          onPressed: _showDeleteDialog,
          icon: Icon(
            Icons.delete_rounded,
            color: ColorsManager.errorFill,
            size: SizeApp.iconSize,
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
                    // Error Display
                    if (_error != null)
                      ErrorContainer(
                        errors: [_error!],
                        margin: EdgeInsets.only(bottom: SizeApp.s16),
                      ),

                    // Photo Upload Section
                    MemberPhotoUpload(
                      photoPath: _photoPath,
                      memberName: _nameController.text,
                      onPickImage: _handleImagePicker,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: SizeApp.s32),

                    // Basic Info Form
                    MemberBasicInfoForm(
                      nameController: _nameController,
                      ageController: _ageController,
                      selectedLevel: _selectedLevel,
                      onLevelChanged: (level) {
                        setState(() {
                          _selectedLevel = level;
                        });
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Notes Field - استخدام المصنع المخصص للملاحظات
                    AppTextFieldFactory.textArea(
                      controller: _notesController,
                      hintText: 'أي ملاحظات أو معلومات إضافية عن العضو...',
                      title: 'ملاحظات (اختياري)',
                      maxLines: 4,
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Info Notice
                    EditInfoNotice(
                      message: _isEditing
                          ? 'سيتم حفظ التعديلات على هذا العضو في المكتبة العامة'
                          : 'سيتم إضافة هذا العضو إلى المكتبة العامة ويمكن إضافته لأي فريق لاحقاً',
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Action Buttons
          FormActionButtons(
            onSave: _saveMember,
            onCancel: () => Navigator.pop(context),
            isLoading: _isLoading,
            saveText: _isEditing ? 'حفظ التعديلات' : 'إضافة العضو',
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
          setState(() {
            _photoPath = imagePath;
          });
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
      final member = Member(
        id: widget.memberToEdit?.id,
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        level: _selectedLevel,
        photoPath: _photoPath,
        notes: _notesController.text.trim().isNotEmpty
            ? _notesController.text.trim()
            : null,
      );

      final provider = Provider.of<MemberLibraryProvider>(context, listen: false);

      if (_isEditing) {
        await provider.updateMember(member);
      } else {
        await provider.createMember(member);
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _isEditing ? 'تم تحديث العضو بنجاح' : 'تم إضافة العضو بنجاح',
            ),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    } catch (e) {
      _showError('حدث خطأ في حفظ بيانات العضو: ${e.toString()}');
      log('خطأ في حفظ العضو: $e');
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
              'حذف العضو',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.errorFill,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من حذف "${widget.memberToEdit!.name}" من المكتبة نهائياً؟\n\nلا يمكن التراجع عن هذا الإجراء.',
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
            onPressed: _deleteMember,
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

  Future<void> _deleteMember() async {
    Navigator.pop(context); // Close dialog

    setState(() {
      _isLoading = true;
    });

    try {
      final provider = Provider.of<MemberLibraryProvider>(context, listen: false);
      await provider.deleteMember(widget.memberToEdit!.id);

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم حذف العضو نهائياً'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    } catch (e) {
      _showError('حدث خطأ في حذف العضو: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    setState(() {
      _error = message;
    });
  }
}