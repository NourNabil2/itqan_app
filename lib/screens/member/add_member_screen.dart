
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/models/member.dart';

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

  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم', 'محترف'];

  @override
  void initState() {
    super.initState();
    if (widget.memberToEdit != null) {
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

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  Future<void> _saveMember() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final member = Member(
      id: widget.memberToEdit?.id,
      name: _nameController.text.trim(),
      age: int.parse(_ageController.text),
      level: _selectedLevel,
      photoPath: _photoPath,
      notes: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim() : null,
      isGlobal: true,
    );

    try {
      final provider = Provider.of<MemberLibraryProvider>(context, listen: false);

      if (widget.memberToEdit != null) {
        await provider.updateGlobalMember(member);
      } else {
        await provider.createGlobalMember(member);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.memberToEdit != null
                  ? 'تم تحديث العضو بنجاح'
                  : 'تم إضافة العضو بنجاح',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      log('خطأ: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          widget.memberToEdit != null ? 'تعديل العضو' : 'إضافة عضو للمكتبة',
        ),
        actions: [
          if (widget.memberToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('حذف العضو'),
                    content: const Text(
                        'هل أنت متأكد من حذف هذا العضو من المكتبة؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  final provider = Provider.of<MemberLibraryProvider>(
                      context, listen: false);
                  await provider.deleteGlobalMember(widget.memberToEdit!.id);
                  Navigator.pop(context);
                }
              },
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Photo Section
              Center(
                child: GestureDetector(
                  onTap: _pickPhoto,
                  child: Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                      border: Border.all(
                        color: const Color(0xFF2196F3),
                        width: 2,
                      ),
                      image: _photoPath != null
                          ? DecorationImage(
                        image: FileImage(File(_photoPath!)),
                        fit: BoxFit.cover,
                      )
                          : null,
                    ),
                    child: _photoPath == null
                        ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.camera_alt,
                          size: 32.sp,
                          color: const Color(0xFF2196F3),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'إضافة صورة',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: const Color(0xFF2196F3),
                          ),
                        ),
                      ],
                    )
                        : null,
                  ),
                ),
              ),
              SizedBox(height: 32.h),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم *',
                  hintText: 'أدخل اسم العضو',
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Age Field
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'العمر *',
                  hintText: 'أدخل العمر',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'العمر مطلوب';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 3 || age > 25) {
                    return 'أدخل عمر صحيح (3-25)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Level Selection
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'المستوى *',
                ),
                items: _levels.map((level) {
                  return DropdownMenuItem(
                    value: level,
                    child: Text(level),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedLevel = value!;
                  });
                },
              ),
              SizedBox(height: 16.h),

              // Notes Field
              TextFormField(
                controller: _notesController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'ملاحظات',
                  hintText: 'أي ملاحظات إضافية...',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveMember,
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    widget.memberToEdit != null
                        ? 'حفظ التعديلات'
                        : 'إضافة العضو',
                    style: TextStyle(fontSize: 16.sp),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}