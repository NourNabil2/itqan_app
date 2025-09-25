import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itqan_gym/data/database/db_helper.dart';
import 'dart:io';
import '../../../data/models/member/member.dart';

class AddMembersStep extends StatefulWidget {
  final List<Member> members;
  final Function(List<Member>) onMembersChanged;

  const AddMembersStep({
    super.key,
    required this.members,
    required this.onMembersChanged,
  });

  @override
  State<AddMembersStep> createState() => _AddMembersStepState();
}

class _AddMembersStepState extends State<AddMembersStep> {
  final List<Member> _tempMembers = [];

  @override
  void initState() {
    super.initState();
    _tempMembers.addAll(widget.members);
  }

  void _addMember() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMemberDialog(
        onAdd: (member) {
          setState(() {
            _tempMembers.add(member);
            widget.onMembersChanged(_tempMembers);
          });
        },
      ),
    );
  }

  void _removeMember(int index) {
    setState(() {
      _tempMembers.removeAt(index);
      widget.onMembersChanged(_tempMembers);
    });
  }

  void _pickFromLibrary() async {
    final picked = await showModalBottomSheet<List<Member>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _PickMembersFromLibrarySheet(), // ← وده تحت
    );

    if (picked != null && picked.isNotEmpty) {
      // امنع التكرار حسب id
      final existingIds = _tempMembers.map((m) => m.id).toSet();
      final newOnes = picked.where((m) => !existingIds.contains(m.id)).toList();

      if (newOnes.isNotEmpty) {
        setState(() {
          _tempMembers.addAll(newOnes);
          widget.onMembersChanged(_tempMembers);
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'أعضاء الفريق',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF2C3E50),
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'أضف أعضاء الفريق (عضو واحد على الأقل)',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(vertical: 16.h),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addMember,
                  icon: const Icon(Icons.person_add),
                  label: const Text('إضافة يدويًا'),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _pickFromLibrary, // ← جديد
                  icon: const Icon(Icons.library_add),
                  label: const Text('اختيار من المكتبة'),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _tempMembers.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.group_add,
                        size: 80.sp,
                        color: Colors.grey[300],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'لم يتم إضافة أعضاء بعد',
                        style: TextStyle(
                          fontSize: 18.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      SizedBox(height: 24.h),
                      ElevatedButton.icon(
                        onPressed: _addMember,
                        icon: const Icon(Icons.person_add),
                        label: const Text('إضافة أول عضو'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  itemCount: _tempMembers.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _tempMembers.length) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        child: OutlinedButton.icon(
                          onPressed: _addMember,
                          icon: const Icon(Icons.add),
                          label: const Text('إضافة عضو آخر'),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                          ),
                        ),
                      );
                    }

                    final member = _tempMembers[index];
                    return Card(
                      margin: EdgeInsets.only(bottom: 12.h),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: const Color(0xFFF5F5F5),
                          backgroundImage: member.photoPath != null
                              ? FileImage(File(member.photoPath!))
                              : null,
                          child: member.photoPath == null
                              ? Text(
                                  member.name[0].toUpperCase(),
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    color: const Color(0xFF2196F3),
                                  ),
                                )
                              : null,
                        ),
                        title: Text(member.name),
                        subtitle:
                            Text('العمر: ${member.age} • ${member.level}'),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _removeMember(index),
                        ),
                      ),
                    );
                  },
                ),
        ),
        if (_tempMembers.isEmpty)
          Container(
            color: Colors.orange.withOpacity(0.1),
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.orange),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    'يجب إضافة عضو واحد على الأقل للمتابعة',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _AddMemberDialog extends StatefulWidget {
  final Function(Member) onAdd;

  const _AddMemberDialog({required this.onAdd});

  @override
  State<_AddMemberDialog> createState() => _AddMemberDialogState();
}

class _AddMemberDialogState extends State<_AddMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedLevel = 'مبتدئ';
  String? _photoPath;

  final List<String> _levels = ['مبتدئ', 'متوسط', 'متقدم', 'محترف'];

  Future<void> _pickPhoto() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photoPath = image.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40.w,
                height: 4.h,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2.r),
                ),
              ),
              SizedBox(height: 20.h),

              Text(
                'إضافة عضو جديد',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20.h),

              // Photo
              GestureDetector(
                onTap: _pickPhoto,
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundColor: Colors.grey[200],
                  backgroundImage:
                      _photoPath != null ? FileImage(File(_photoPath!)) : null,
                  child: _photoPath == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.camera_alt,
                              size: 24.sp,
                              color: Colors.grey[600],
                            ),
                            Text(
                              'صورة',
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        )
                      : null,
                ),
              ),
              SizedBox(height: 20.h),

              // Name
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'الاسم',
                  hintText: 'أدخل اسم العضو',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الاسم مطلوب';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Age
              TextFormField(
                controller: _ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'العمر',
                  hintText: 'أدخل العمر',
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'العمر مطلوب';
                  }
                  final age = int.tryParse(value);
                  if (age == null || age < 3 || age > 20) {
                    return 'أدخل عمر صحيح (3-20)';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.h),

              // Level
              DropdownButtonFormField<String>(
                value: _selectedLevel,
                decoration: const InputDecoration(
                  labelText: 'المستوى',
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
              SizedBox(height: 24.h),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('إلغاء'),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          final member = Member(
                            teamId: '', // Will be set later
                            name: _nameController.text,
                            age: int.parse(_ageController.text),
                            level: _selectedLevel,
                            photoPath: _photoPath,
                          );
                          widget.onAdd(member);
                          Navigator.pop(context);
                        }
                      },
                      child: const Text('إضافة'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}


class _PickMembersFromLibrarySheet extends StatefulWidget {
  const _PickMembersFromLibrarySheet();

  @override
  State<_PickMembersFromLibrarySheet> createState() => _PickMembersFromLibrarySheetState();
}

class _PickMembersFromLibrarySheetState extends State<_PickMembersFromLibrarySheet> {
  final TextEditingController _search = TextEditingController();
  final Set<String> _selectedIds = {};
  List<Member> _all = [];
  List<Member> _filtered = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
    _search.addListener(_applyFilter);
  }

  Future<void> _load() async {
    final db = DatabaseHelper.instance;
    final members = await db.getGlobalMembers(); // يجلب is_global = 1
    setState(() {
      _all = members;
      _filtered = members;
      _loading = false;
    });
  }

  void _applyFilter() {
    final q = _search.text.trim().toLowerCase();
    setState(() {
      _filtered = q.isEmpty
          ? _all
          : _all.where((m) => m.name.toLowerCase().contains(q) || m.level.toLowerCase().contains(q)).toList();
    });
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.r),
          topRight: Radius.circular(16.r),
        ),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
      ),
      padding: EdgeInsets.only(
        left: 16.w,
        right: 16.w,
        top: 12.h,
        bottom: MediaQuery.of(context).viewInsets.bottom + 12.h,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(width: 40.w, height: 4.h, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2.r))),
            SizedBox(height: 12.h),
            Text('اختيار أعضاء من المكتبة', style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w600)),
            SizedBox(height: 12.h),
            TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'ابحث بالاسم أو المستوى...',
              ),
            ),
            SizedBox(height: 12.h),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else
              Flexible(
                child: _filtered.isEmpty
                    ? Padding(
                  padding: EdgeInsets.all(24.w),
                  child: Text('لا يوجد أعضاء في المكتبة', style: TextStyle(color: Colors.grey[600])),
                )
                    : ListView.separated(
                  shrinkWrap: true,
                  itemCount: _filtered.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, i) {
                    final m = _filtered[i];
                    final selected = _selectedIds.contains(m.id);
                    return CheckboxListTile(
                      value: selected,
                      onChanged: (_) {
                        setState(() {
                          if (selected) {
                            _selectedIds.remove(m.id);
                          } else {
                            _selectedIds.add(m.id);
                          }
                        });
                      },
                      title: Text(m.name),
                      subtitle: Text('العمر: ${m.age} • ${m.level}${m.teamId == null ? ' • (من المكتبة)' : ''}'),
                      secondary: CircleAvatar(
                        backgroundColor: const Color(0xFFF5F5F5),
                        backgroundImage: (m.photoPath != null) ? FileImage(File(m.photoPath!)) : null,
                        child: (m.photoPath == null) ? Text(m.name[0].toUpperCase()) : null,
                      ),
                    );
                  },
                ),
              ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('إلغاء'),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIds.isEmpty
                        ? null
                        : () {
                      // رجّع الأعضاء المختارين
                      final chosen = _all.where((m) => _selectedIds.contains(m.id)).toList();
                      Navigator.pop(context, chosen);
                    },
                    icon: const Icon(Icons.check),
                    label: Text('إضافة (${_selectedIds.length})'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

