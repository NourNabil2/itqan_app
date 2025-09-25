import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/widgets/app_buton.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/core/widgets/error_container_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:provider/provider.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/custom_app_bar.dart';
import '../../providers/member_provider.dart';

class EditMemberScreen extends StatefulWidget {
  final Member member;
  final bool isGlobalMember;

  const EditMemberScreen({
    super.key,
    required this.member,
    this.isGlobalMember = false,
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

  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم', 'خبير'];

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  void _initializeData() {
    _nameController.text = widget.member.name;
    _ageController.text = widget.member.age.toString();
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
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      appBar: CustomAppBar(
        title: 'تعديل بيانات العضو',
        action: widget.isGlobalMember ? null : IconButton(
          onPressed: _showDeleteDialog,
          icon: Icon(
            Icons.delete_rounded,
            color: ColorsManager.errorFill,
            size: SizeApp.iconSize,
          ),
        ),
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

                    SizedBox(height: SizeApp.s24),

                    // Name Field
                    AppTextField(
                      controller: _nameController,
                      hintText: 'أدخل اسم العضو',
                      title: 'الاسم',
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
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'الرجاء إدخال عمر العضو';
                        }
                        final age = int.tryParse(value);
                        if (age == null) {
                          return 'الرجاء إدخال رقم صحيح';
                        }
                        if (age < 3 || age > 18) {
                          return 'العمر يجب أن يكون بين 3 و 18 سنة';
                        }
                        return null;
                      },
                    ),

                    SizedBox(height: SizeApp.s16),

                    // Level Dropdown
                    _buildLevelDropdown(),

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
                              'تعديل هذه البيانات سيؤثر على جميع التمارين والتقييمات المرتبطة بهذا العضو',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: ColorsManager.infoText,
                                fontWeight: FontWeight.w500,
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
                  text: 'حفظ التغييرات',
                  onPressed: _updateMember,
                  isLoading: _isLoading,
                  leadingIcon: Icons.save_rounded,
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
              Container(
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
                    ? Center(
                  child: Text(
                    _nameController.text.isNotEmpty
                        ? _nameController.text[0].toUpperCase()
                        : '؟',
                    style: TextStyle(
                      fontSize: 40.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                )
                    : null,
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
                child: IconButton(
                  onPressed: _pickImage,
                  padding: EdgeInsets.zero,
                  icon: Icon(
                    Icons.camera_alt_rounded,
                    color: Colors.white,
                    size: 18.sp,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: SizeApp.s12),

          Text(
            'اضغط على الكاميرا لتغيير الصورة',
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
        Text(
          'المستوى',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
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
              width: 1,
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
      case 'خبير':
        return ColorsManager.primaryColor;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }

  void _pickImage() async {
    // Implement image picking logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('سيتم فتح معرض الصور'),
        backgroundColor: ColorsManager.primaryColor,
      ),
    );
  }

  void _updateMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final updatedMember = widget.member.copyWith(
        name: _nameController.text.trim(),
        age: int.parse(_ageController.text),
        level: _selectedLevel,
        photoPath: _photoPath,
        updatedAt: DateTime.now(),
      );

      if (widget.isGlobalMember) {
        await context
            .read<MemberLibraryProvider>()
            .updateGlobalMember(updatedMember);
      } else {
        await context
            .read<MemberProvider>()
            .updateMember(updatedMember);
      }

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تحديث بيانات العضو بنجاح'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _error = 'حدث خطأ في تحديث بيانات العضو: ${e.toString()}';
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
          'هل أنت متأكد من حذف "${widget.member.name}" نهائياً؟\n\nسيتم حذف جميع البيانات والتقييمات المرتبطة بهذا العضو ولا يمكن التراجع عن هذا الإجراء.',
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
    // اقفل الـDialog أولاً
    Navigator.of(context).pop();

    setState(() => _isLoading = true);
    try {
        // حذف من مكتبة الأعضاء العامة
        await context.read<MemberLibraryProvider>().deleteGlobalMember(widget.member.id);

        // حذف عضو فريق عادي
        await context.read<MemberProvider>().deleteMember(widget.member.id, widget.member.teamId!);


      if (!mounted) return;
      // ارجع للشاشة السابقة بعد الحذف
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('تم حذف العضو نهائياً'),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('فشل حذف العضو: $e'),
          backgroundColor: ColorsManager.errorFill,
        ),
      );
    }
  }


}