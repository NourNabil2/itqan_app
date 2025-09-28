// ============= EditMemberScreen المحدث - نسخة محسنة =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/constants/image_picker_helper.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
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
      appBar: const CustomAppBar(
        title: 'تعديل بيانات العضو',
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
                    // ✅ عرض الأخطاء إن وجدت
                    if (_error != null)
                      ErrorContainer(
                        errors: [_error!],
                        margin: EdgeInsets.only(bottom: SizeApp.s16),
                      ),

                    // ✅ قسم الصورة
                    MemberPhotoUpload(
                      photoPath: _photoPath,
                      memberName: _nameController.text,
                      onPickImage: _pickImage,
                      isLoading: _isLoading,
                    ),

                    SizedBox(height: SizeApp.s24),

                    // ✅ نموذج المعلومات الأساسية
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

                    SizedBox(height: SizeApp.s24),


                    // قسم إضافي للمعلومات الإضافية (اختياري)
                    _buildAdditionalInfoSection(),

                    SizedBox(height: SizeApp.s24),
                    // ✅ ملاحظة المعلومات - محسنة لتأخذ أكثر من سطر
                    const EditInfoNotice(
                      message: 'تعديل هذه البيانات سيؤثر على جميع التمارين والتقييمات المرتبطة بهذا العضو. تأكد من صحة البيانات قبل الحفظ وراجعها جيداً.',
                    ),
                  ],
                ),
              ),
            ),
          ),

          //  أزرار العمليات
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
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusMed),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoRow('تاريخ التسجيل', _formatDate(widget.member.createdAt)),
          _buildInfoRow('آخر تحديث', _formatDate(widget.member.updatedAt)),
          //_buildInfoRow('حالة العضو', widget.member.level ? 'نشط' : 'غير نشط'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: ColorsManager.defaultText,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _pickImage() async {
    try {
      // ✅ استخدام helper للصور مع خيارات متعددة
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
    } catch (e) {
      _showErrorSnackBar('حدث خطأ في اختيار الصورة');
    }
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

      // ✅ تحديث العضو
      await context.read<MemberLibraryProvider>().updateMember(updatedMember);

      if (mounted) {
        Navigator.pop(context, true);
        _showSuccessSnackBar('تم تحديث بيانات العضو بنجاح');
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorsManager.successFill,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        ),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: ColorsManager.errorFill,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        ),
      ),
    );
  }
}