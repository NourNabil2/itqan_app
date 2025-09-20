import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../data/models/exercise_template.dart';
import '../../providers/exercise_library_provider.dart';

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
  String? _mediaPath;
  MediaType? _mediaType;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.exerciseToEdit != null) {
      _loadExistingExercise();
    }
  }

  void _loadExistingExercise() {
    final exercise = widget.exerciseToEdit!;
    _titleController.text = exercise.title;
    _descriptionController.text = exercise.description ?? '';
    _mediaPath = exercise.mediaPath;
    _mediaType = exercise.mediaType;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _pickMedia() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.image),
              title: const Text('إضافة صورة'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _mediaPath = image.path;
                    _mediaType = MediaType.image;
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.videocam),
              title: const Text('إضافة فيديو'),
              onTap: () async {
                Navigator.pop(context);
                final picker = ImagePicker();
                final video = await picker.pickVideo(source: ImageSource.gallery);
                if (video != null) {
                  setState(() {
                    _mediaPath = video.path;
                    _mediaType = MediaType.video;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _saveExercise() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final exercise = ExerciseTemplate(
      id: widget.exerciseToEdit?.id,
      type: widget.type,
      title: _titleController.text,
      description: _descriptionController.text.isNotEmpty
          ? _descriptionController.text
          : null,
      mediaPath: _mediaPath,
      mediaType: _mediaType,
    );

    try {
      final provider = Provider.of<ExerciseLibraryProvider>(context, listen: false);
      if (widget.exerciseToEdit != null) {
        await provider.updateExercise(exercise);
      } else {
        await provider.createExercise(exercise);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.exerciseToEdit != null
                  ? 'تم تحديث التمرين بنجاح'
                  : 'تم إضافة التمرين بنجاح',
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
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.exerciseToEdit != null
              ? 'تعديل ${widget.type.arabicName}'
              : 'إضافة ${widget.type.arabicName}',
        ),
        actions: [
          if (widget.exerciseToEdit != null)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('حذف التمرين'),
                    content: const Text('هل أنت متأكد من حذف هذا التمرين؟'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('إلغاء'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('حذف', style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                );

                if (confirm == true && mounted) {
                  final provider = Provider.of<ExerciseLibraryProvider>(
                    context,
                    listen: false,
                  );
                  await provider.deleteExercise(widget.exerciseToEdit!.id);
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
              // Type Badge
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  widget.type.arabicName,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF2196F3),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'عنوان التمرين *',
                  hintText: 'مثال: تمرين القفز بالحبل',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'عنوان التمرين مطلوب';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Description Field
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'الوصف',
                  hintText: 'اشرح كيفية أداء التمرين...',
                  alignLabelWithHint: true,
                ),
              ),
              SizedBox(height: 24.h),

              // Media Section
              Text(
                'الوسائط',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 16.h),

              if (_mediaPath != null) ...[
                Container(
                  height: 200.h,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12.r),
                    color: Colors.grey[200],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: _mediaType == MediaType.image
                            ? Image.file(
                          File(_mediaPath!),
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        )
                            : Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.videocam,
                                size: 48.sp,
                                color: Colors.grey[600],
                              ),
                              SizedBox(height: 8.h),
                              Text(
                                'فيديو',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _mediaPath = null;
                              _mediaType = null;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(8.w),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.delete,
                              size: 20.sp,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16.h),
              ],

              OutlinedButton.icon(
                onPressed: _pickMedia,
                icon: const Icon(Icons.add_photo_alternate),
                label: Text(_mediaPath == null ? 'إضافة وسائط' : 'تغيير الوسائط'),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  minimumSize: Size(double.infinity, 48.h),
                ),
              ),

              SizedBox(height: 32.h),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 48.h,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveExercise,
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
                    widget.exerciseToEdit != null
                        ? 'حفظ التعديلات'
                        : 'إضافة التمرين',
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