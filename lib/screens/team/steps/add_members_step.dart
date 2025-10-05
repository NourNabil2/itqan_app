import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/data/database/db_helper.dart';
import 'dart:io';
import '../../../data/models/member/member.dart';
import '../../member/widgets/editInfo_notice.dart';
import '../widgets/step_header.dart'; // ✅ استيراد المكونات الجديدة

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
      builder: (_) => const _PickMembersFromLibrarySheet(),
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
        // Header Section
        const StepHeader(
          title: 'أعضاء الفريق',
          subtitle: 'اختر أعضاء الفريق من المكتبة (عضو واحد على الأقل)',
        ),

        // Pick Members Button
        Padding(
          padding: EdgeInsets.symmetric(horizontal: SizeApp.s16, vertical: SizeApp.s16),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _pickFromLibrary,
              icon: Icon(Icons.library_add, size: SizeApp.iconSize),
              label: Text(
                'اختيار أعضاء من المكتبة',
                style: TextStyle(fontSize: 16.sp),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorsManager.primaryColor,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                ),
              ),
            ),
          ),
        ),

        // Members List or Empty State
        Expanded(
          child: _tempMembers.isEmpty ? _buildEmptyState() : _buildMembersList(),
        ),

        // Warning Notice
        if (_tempMembers.isEmpty) _buildWarningNotice(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.group_add,
            size: 80.sp,
            color: ColorsManager.defaultTextSecondary.withOpacity(0.5),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            'لم يتم اختيار أعضاء بعد',
            style: TextStyle(
              fontSize: 18.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            'اختر الأعضاء من المكتبة',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
          SizedBox(height: SizeApp.s24),
          ElevatedButton.icon(
            onPressed: _pickFromLibrary,
            icon: Icon(Icons.library_add, size: SizeApp.iconSize),
            label: const Text('فتح المكتبة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.primaryColor,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList() {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
            itemCount: _tempMembers.length,
            itemBuilder: (context, index) {
              final member = _tempMembers[index];
              return Container(
                margin: EdgeInsets.only(bottom: SizeApp.s12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.all(SizeApp.s12),
                  leading: CircleAvatar(
                    radius: 24.r,
                    backgroundColor: ColorsManager.secondaryColor.withOpacity(0.1),
                    backgroundImage: member.photoPath != null
                        ? FileImage(File(member.photoPath!))
                        : null,
                    child: member.photoPath == null
                        ? Text(
                      member.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.secondaryColor,
                      ),
                    )
                        : null,
                  ),
                  title: Text(
                    member.name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.defaultText,
                    ),
                  ),
                  subtitle: Text(
                    'العمر: ${member.age} • ${member.level}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: ColorsManager.defaultTextSecondary,
                    ),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.remove_circle_rounded,
                      color: ColorsManager.errorFill,
                      size: SizeApp.iconSize,
                    ),
                    onPressed: () => _removeMember(index),
                  ),
                ),
              );
            },
          ),
        ),

        // Add More Button
        Padding(
          padding: EdgeInsets.all(SizeApp.s16),
          child: OutlinedButton.icon(
            onPressed: _pickFromLibrary,
            icon: Icon(Icons.add, size: SizeApp.iconSize),
            label: const Text('إضافة المزيد من المكتبة'),
            style: OutlinedButton.styleFrom(
              foregroundColor: ColorsManager.primaryColor,
              side: BorderSide(color: ColorsManager.primaryColor),
              padding: EdgeInsets.symmetric(vertical: 14.h),
              minimumSize: Size(double.infinity, 50.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWarningNotice() {
    return EditInfoNotice(
      message: 'يجب اختيار عضو واحد على الأقل من المكتبة للمتابعة',
      icon: Icons.info_outline_rounded,
      backgroundColor: ColorsManager.warningFill.withOpacity(0.1),
      textColor: ColorsManager.warningText,
      iconColor: ColorsManager.warningText,
    );
  }
}

class _PickMembersFromLibrarySheet extends StatefulWidget {
  const _PickMembersFromLibrarySheet();

  @override
  State<_PickMembersFromLibrarySheet> createState() => _PickMembersFromLibrarySheetState();
}

class _PickMembersFromLibrarySheetState extends State<_PickMembersFromLibrarySheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final db = DatabaseHelper.instance;
    final members = await db.getAllMembers();
    setState(() {
      _allMembers = members;
      _filteredMembers = members;
      _isLoading = false;
    });
  }

  void _applyFilter(String query) {
    final q = query.trim().toLowerCase();
    setState(() {
      _filteredMembers = q.isEmpty
          ? _allMembers
          : _allMembers.where((m) =>
      m.name.toLowerCase().contains(q) ||
          m.level.toLowerCase().contains(q)
      ).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: EdgeInsets.only(top: SizeApp.s12),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.inputBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          SizedBox(height: SizeApp.s12),

          // Header
          const StepHeader(
            title: 'اختيار أعضاء من المكتبة',
          ),

          SizedBox(height: SizeApp.s12),

          // Search Field - استخدام المصنع المحسن
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
            child: AppTextFieldFactory.search(
              controller: _searchController,
              hintText: 'ابحث بالاسم أو المستوى...',
              onChanged: _applyFilter,
            ),
          ),

          SizedBox(height: SizeApp.s12),

          // Content
          Expanded(
            child: _isLoading ? _buildLoadingState() : _buildContent(),
          ),

          // Bottom Action Buttons
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
      ),
    );
  }

  Widget _buildContent() {
    if (_filteredMembers.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
      itemCount: _filteredMembers.length,
      separatorBuilder: (_, __) => Divider(
        height: 1,
        color: ColorsManager.inputBorder.withOpacity(0.3),
      ),
      itemBuilder: (context, index) {
        final member = _filteredMembers[index];
        final isSelected = _selectedIds.contains(member.id);

        return CheckboxListTile(
          value: isSelected,
          onChanged: (_) {
            setState(() {
              if (isSelected) {
                _selectedIds.remove(member.id);
              } else {
                _selectedIds.add(member.id);
              }
            });
          },
          title: Text(
            member.name,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: ColorsManager.defaultText,
            ),
          ),
          subtitle: Text(
            'العمر: ${member.age} • ${member.level}',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
          secondary: CircleAvatar(
            backgroundColor: ColorsManager.secondaryColor.withOpacity(0.1),
            backgroundImage: member.photoPath != null
                ? FileImage(File(member.photoPath!))
                : null,
            child: member.photoPath == null
                ? Text(
              member.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.secondaryColor,
              ),
            )
                : null,
          ),
          activeColor: ColorsManager.primaryColor,
          checkColor: Colors.white,
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _allMembers.isEmpty ? Icons.group_add : Icons.search_off,
            size: 64.sp,
            color: ColorsManager.defaultTextSecondary.withOpacity(0.5),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            _allMembers.isEmpty
                ? 'لا يوجد أعضاء في المكتبة'
                : 'لا توجد نتائج للبحث',
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (_allMembers.isEmpty) ...[
            SizedBox(height: SizeApp.s8),
            Text(
              'قم بإنشاء أعضاء أولاً',
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(
            color: ColorsManager.inputBorder.withOpacity(0.3),
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: ColorsManager.defaultTextSecondary,
                  side: BorderSide(
                    color: ColorsManager.inputBorder.withOpacity(0.5),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
                child: const Text('إلغاء'),
              ),
            ),

            SizedBox(width: SizeApp.s12),

            Expanded(
              child: ElevatedButton.icon(
                onPressed: _selectedIds.isEmpty ? null : () {
                  final chosen = _allMembers
                      .where((m) => _selectedIds.contains(m.id))
                      .toList();
                  Navigator.pop(context, chosen);
                },
                icon: Icon(Icons.check, size: SizeApp.iconSize),
                label: Text('إضافة (${_selectedIds.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}