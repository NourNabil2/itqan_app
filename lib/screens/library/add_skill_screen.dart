import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../core/utils/enums.dart';
import '../../data/models/skill_template.dart';
import '../../providers/skill_library_provider.dart';

class AddSkillScreen extends StatefulWidget {
  final SkillTemplate? skillToEdit; // ← جديد: وضع التعديل

  const AddSkillScreen({super.key, this.skillToEdit});

  @override
  State<AddSkillScreen> createState() => _AddSkillScreenState();
}

class _AddSkillScreenState extends State<AddSkillScreen> {
  final _formKey = GlobalKey<FormState>();
  Apparatus _apparatus = Apparatus.floor;
  final _nameCtrl = TextEditingController();
  final _taCtrl = TextEditingController();   // Technical analysis
  final _prCtrl = TextEditingController();   // Pre requisites
  final _spCtrl = TextEditingController();   // Skill progression
  final _drCtrl = TextEditingController();   // Drills
  final _ppCtrl = TextEditingController();   // Physical preparation

  String? _thumbnailPath;

  /// [{ 'path': ..., 'mediaType': 'image'|'video' }]
  final List<Map<String, String>> _gallery = [];

  final ImagePicker _picker = ImagePicker();

  bool get isEdit => widget.skillToEdit != null;

  @override
  void initState() {
    super.initState();
    // Prefill in edit mode
    final s = widget.skillToEdit;
    if (s != null) {
      _apparatus = s.apparatus;
      _nameCtrl.text = s.skillName;
      _thumbnailPath = s.thumbnailPath;
      _taCtrl.text = s.technicalAnalysis ?? '';
      _prCtrl.text = s.preRequisites ?? '';
      _spCtrl.text = s.skillProgression ?? '';
      _drCtrl.text = s.drills ?? '';
      _ppCtrl.text = s.physicalPreparation ?? '';

      // حوّل MediaItem -> Map<String,String> لعرضه في Chips
      _gallery.addAll(
        s.mediaGallery.map((m) => {
          'path': m.path,
          'mediaType': m.type == MediaType.video ? 'video' : 'image',
        }),
      );
      setState(() {});
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _taCtrl.dispose();
    _prCtrl.dispose();
    _spCtrl.dispose();
    _drCtrl.dispose();
    _ppCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickThumbnail() async {
    final x = await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) {
      setState(() => _thumbnailPath = x.path);
    }
  }

  Future<void> _addMediaToGallery({required bool isVideo}) async {
    final x = isVideo
        ? await _picker.pickVideo(source: ImageSource.gallery)
        : await _picker.pickImage(source: ImageSource.gallery);
    if (x != null) {
      setState(() {
        _gallery.add({
          'path': x.path,
          'mediaType': isVideo ? 'video' : 'image',
        });
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // حوّل List<Map> -> List<MediaItem>
    final mediaItems = _gallery.map((m) => MediaItem(
      path: m['path']!,
      type: m['mediaType'] == 'video' ? MediaType.video : MediaType.image,
    )).toList();

    final provider = context.read<SkillLibraryProvider>();
    final now = DateTime.now();

    if (isEdit) {
      // تحديث
      final old = widget.skillToEdit!;
      final updated = SkillTemplate(
        id: old.id, // احتفظ بنفس الـUUID
        apparatus: _apparatus,
        skillName: _nameCtrl.text.trim(),
        thumbnailPath: _thumbnailPath,
        mediaGallery: mediaItems,
        technicalAnalysis: _taCtrl.text.trim().isEmpty ? null : _taCtrl.text.trim(),
        preRequisites: _prCtrl.text.trim().isEmpty ? null : _prCtrl.text.trim(),
        skillProgression: _spCtrl.text.trim().isEmpty ? null : _spCtrl.text.trim(),
        drills: _drCtrl.text.trim().isEmpty ? null : _drCtrl.text.trim(),
        physicalPreparation: _ppCtrl.text.trim().isEmpty ? null : _ppCtrl.text.trim(),
        createdAt: old.createdAt, // لا تغيّر تاريخ الإنشاء
        updatedAt: now,
        assignedTeamsCount: old.assignedTeamsCount,
      );
      await provider.updateSkill(updated);
    } else {
      // إنشاء جديد
      final skill = SkillTemplate(
        apparatus: _apparatus,
        skillName: _nameCtrl.text.trim(),
        thumbnailPath: _thumbnailPath,
        mediaGallery: mediaItems,
        technicalAnalysis: _taCtrl.text.trim().isEmpty ? null : _taCtrl.text.trim(),
        preRequisites: _prCtrl.text.trim().isEmpty ? null : _prCtrl.text.trim(),
        skillProgression: _spCtrl.text.trim().isEmpty ? null : _spCtrl.text.trim(),
        drills: _drCtrl.text.trim().isEmpty ? null : _drCtrl.text.trim(),
        physicalPreparation: _ppCtrl.text.trim().isEmpty ? null : _ppCtrl.text.trim(),
        createdAt: now,
        updatedAt: now,
      );
      await provider.createSkill(skill);
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'تعديل مهارة' : 'إضافة مهارة'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              onPressed: () async {
                final ok = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('حذف المهارة'),
                    content: const Text('هل أنت متأكد من حذف هذه المهارة؟'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('إلغاء')),
                      TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('حذف')),
                    ],
                  ),
                );
                if (ok == true) {
                  await context.read<SkillLibraryProvider>().deleteSkill(widget.skillToEdit!.id);
                  if (mounted) Navigator.pop(context);
                }
              },
            ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
            // Apparatus
            DropdownButtonFormField<Apparatus>(
              value: _apparatus,
              decoration: const InputDecoration(labelText: 'الجهاز'),
              items: Apparatus.values.map((a) {
                return DropdownMenuItem(value: a, child: Text(a.arabicName));
              }).toList(),
              onChanged: (v) => setState(() => _apparatus = v!),
            ),
            SizedBox(height: 12.h),

            // Skill name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'اسم المهارة *'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'الاسم مطلوب' : null,
            ),
            SizedBox(height: 12.h),

            // Thumbnail
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickThumbnail,
                  icon: const Icon(Icons.image),
                  label: const Text('صورة مصغرة'),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    _thumbnailPath ?? 'لم يتم اختيار صورة',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            // Gallery
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () => _addMediaToGallery(isVideo: false),
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('إضافة صورة'),
                ),
                SizedBox(width: 8.w),
                OutlinedButton.icon(
                  onPressed: () => _addMediaToGallery(isVideo: true),
                  icon: const Icon(Icons.videocam),
                  label: const Text('إضافة فيديو'),
                ),
              ],
            ),
            if (_gallery.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: _gallery.map((m) {
                  return Chip(
                    label: Text('${m['mediaType']}: ${m['path']!.split('/').last}'),
                    onDeleted: () => setState(() => _gallery.remove(m)),
                  );
                }).toList(),
              ),
            ],
            SizedBox(height: 16.h),

            // Five sections
            _sectionField(_taCtrl, 'التحليل الفني'),
            _sectionField(_prCtrl, 'المتطلبات المسبقة'),
            _sectionField(_spCtrl, 'تدرّج المهارة'),
            _sectionField(_drCtrl, 'التمرينات المهارية (Drills)'),
            _sectionField(_ppCtrl, 'الإعداد البدني'),

            SizedBox(height: 24.h),
            ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(Icons.save),
              label: Text(isEdit ? 'تحديث' : 'حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionField(TextEditingController c, String label) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: TextFormField(
        controller: c,
        maxLines: 4,
        decoration: const InputDecoration(
          alignLabelWithHint: true,
          border: OutlineInputBorder(),
          // labelText نمررها من الأعلى:
        ).copyWith(labelText: label),
      ),
    );
  }
}
