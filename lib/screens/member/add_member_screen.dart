import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_buton.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../data/models/member/member.dart';

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

  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم', 'محترف'];
  final ImagePicker _picker = ImagePicker();

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
                    if (_error != null)
                      ErrorContainer(
                        errors: [_error!],
                        margin: EdgeInsets.only(bottom: SizeApp.s16),
                      ),

                    // Profile Photo Section
                    _buildPhotoSection(),

                    SizedBox(height: SizeApp.s32),

                    // Name Field
                    AppTextField(
                      controller: _nameController,
                      hintText: 'أدخل اسم العضو',
                      title: 'الاسم',
                      prefixIcon: Icon(
                        Icons.person_outline_rounded,
                        color: ColorsManager.primaryColor,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'الرجاء إدخال اسم العضو';
                        }
                        if (value.trim().length < 2) {
                          return 'الاسم يجب أن يحتوي على حرفين على الأقل';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Age Field
                    AppTextFieldFactory.number(
                      controller: _ageController,
                      hintText: 'أدخل عمر العضو',
                      title: 'العمر',
                      prefixIcon: Icon(
                        Icons.cake_outlined,
                        color: ColorsManager.primaryColor,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عمر العضو';
                        }
                        final age = int.tryParse(value);
                        if (age == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        if (age < 3 || age > 25) {
                          return 'العمر يجب أن يكون بين 3 و 25 سنة';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Level Dropdown
                    _buildLevelDropdown(),

                    SizedBox(height: SizeApp.s16),

                    // Notes Field
                    AppTextFieldFactory.textArea(
                      controller: _notesController,
                      hintText: 'أي ملاحظات أو معلومات إضافية عن العضو...',
                      title: 'ملاحظات (اختياري)',
                      maxLines: 4,
                    ),

                    SizedBox(height: SizeApp.s24),

                    // Info Card
                    Container(
                      padding: EdgeInsets.all(SizeApp.s16),
                      decoration: BoxDecoration(
                        color: ColorsManager.infoSurface,
                        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                        border: Border.all(
                          color: ColorsManager.infoText.withOpacity(0.2),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: ColorsManager.infoText,
                            size: SizeApp.iconSize,
                          ),
                          SizedBox(width: SizeApp.s12),
                          Expanded(
                            child: Text(
                              _isEditing
                                  ? 'سيتم حفظ التعديلات على هذا العضو في مكتبة الأعضاء العامة'
                                  : 'سيتم إضافة هذا العضو إلى مكتبة الأعضاء العامة ويمكن إضافته لأي فريق لاحقاً',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: ColorsManager.infoText,
                                fontWeight: FontWeight.w500,
                                height: 1.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                AppButton(
                  text: _isEditing ? 'حفظ التعديلات' : 'إضافة العضو',
                  onPressed: _saveMember,
                  isLoading: _isLoading,
                  leadingIcon: _isEditing ? Icons.save_rounded : Icons.person_add_rounded,
                  horizontalPadding: 0,
                ),

                SizedBox(height: SizeApp.s12),

                AppOutlinedButton(
                  text: 'إلغاء',
                  onPressed: () => Navigator.pop(context),
                  horizontalPadding: 0,
                  verticalPadding: 12,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Center(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.bottomRight,
            children: [
              Hero(
                tag: 'member_photo_${widget.memberToEdit?.id ?? 'new'}',
                child: Container(
                  width: 120.w,
                  height: 120.h,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeApp.radius),
                    gradient: _photoPath == null
                        ? LinearGradient(
                      colors: [
                        ColorsManager.secondaryColor,
                        ColorsManager.secondaryColor.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                        : null,
                    image: _photoPath != null
                        ? DecorationImage(
                      image: FileImage(File(_photoPath!)),
                      fit: BoxFit.cover,
                    )
                        : null,
                    boxShadow: [
                      BoxShadow(
                        color: ColorsManager.secondaryColor.withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: _photoPath == null
                      ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt_rounded,
                        size: 40.sp,
                        color: Colors.white,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'إضافة صورة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                      : null,
                ),
              ),

              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorsManager.primaryColor.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18.r),
                    onTap: _showImagePickerOptions,
                    child: Icon(
                      _photoPath != null ? Icons.edit_rounded : Icons.camera_alt_rounded,
                      color: Colors.white,
                      size: 18.sp,
                    ),
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s12),

          Text(
            _photoPath != null ? 'اضغط لتغيير الصورة' : 'اضغط لإضافة صورة (اختياري)',
            style: TextStyle(
              fontSize: 13.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.trending_up_rounded,
              color: ColorsManager.primaryColor,
              size: 16.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              'المستوى',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
          ],
        ),

        SizedBox(height: SizeApp.s8),

        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
          decoration: BoxDecoration(
            color: ColorsManager.backgroundSurface,
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            border: Border.all(
              color: ColorsManager.inputBorder.withOpacity(0.5),
              width: 1.5,
            ),
          ),
          child: DropdownButton<String>(
            value: _selectedLevel,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultText,
            ),
            items: _levels.map((level) {
              return DropdownMenuItem<String>(
                value: level,
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _getLevelColor(level),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: SizeApp.s12),
                    Text(level),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedLevel = value;
                });
              }
            },
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(String level) {
    switch (level) {
      case 'مبتدئ':
        return ColorsManager.infoFill;
      case 'متوسط':
        return ColorsManager.warningFill;
      case 'متقدم':
        return ColorsManager.successFill;
      case 'محترف':
        return ColorsManager.primaryColor;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }

  void _showImagePickerOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(SizeApp.radiusMed),
            topRight: Radius.circular(SizeApp.radiusMed),
          ),
        ),
        padding: EdgeInsets.all(SizeApp.s20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: ColorsManager.inputBorder.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),

            SizedBox(height: SizeApp.s20),

            Text(
              'اختر صورة للعضو',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),

            SizedBox(height: SizeApp.s20),

            Row(
              children: [
                Expanded(
                  child: _buildImageOption(
                    'الكاميرا',
                    Icons.camera_alt_rounded,
                    ColorsManager.primaryColor,
                        () => _pickImage(ImageSource.camera),
                  ),
                ),

                SizedBox(width: SizeApp.s16),

                Expanded(
                  child: _buildImageOption(
                    'المعرض',
                    Icons.photo_library_rounded,
                    ColorsManager.secondaryColor,
                        () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),

            if (_photoPath != null) ...[
              SizedBox(height: SizeApp.s12),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _removePhoto,
                  icon: Icon(
                    Icons.delete_rounded,
                    color: ColorsManager.errorFill,
                    size: 18.sp,
                  ),
                  label: Text(
                    'إزالة الصورة',
                    style: TextStyle(
                      color: ColorsManager.errorFill,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: ColorsManager.errorFill),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                ),
              ),
            ],

            SizedBox(height: SizeApp.s10),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption(String title, IconData icon, Color color, VoidCallback onTap) {
    return Material(
      color: color.withOpacity(0.1),
      borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      child: InkWell(
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        onTap: () {
          Navigator.pop(context);
          onTap();
        },
        child: Container(
          padding: EdgeInsets.symmetric(vertical: SizeApp.s20),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(SizeApp.s12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(SizeApp.s12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32.sp,
                ),
              ),
              SizedBox(height: SizeApp.s8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        setState(() {
          _photoPath = image.path;
        });
      }
    } catch (e) {
      _showError('حدث خطأ في اختيار الصورة: ${e.toString()}');
    }
  }

  void _removePhoto() {
    Navigator.pop(context);
    setState(() {
      _photoPath = null;
    });
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
        isGlobal: true,
      );

      final provider = Provider.of<MemberLibraryProvider>(context, listen: false);

      if (_isEditing) {
        await provider.updateGlobalMember(member);
      } else {
        await provider.createGlobalMember(member);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
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
          'هل أنت متأكد من حذف "${widget.memberToEdit!.name}" من مكتبة الأعضاء نهائياً؟\n\nلا يمكن التراجع عن هذا الإجراء.',
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
      await provider.deleteGlobalMember(widget.memberToEdit!.id);

      if (mounted) {
        Navigator.pop(context, true); // Return to previous screen
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