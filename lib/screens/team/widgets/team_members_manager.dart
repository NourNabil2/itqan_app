import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/data/database/db_helper.dart';
import 'package:provider/provider.dart';
import '../../../data/models/member/member.dart';
import '../../../data/models/team.dart';
import '../../../providers/team_provider.dart';
import '../../member/widgets/editInfo_notice.dart';

class TeamMembersManager extends StatefulWidget {
  final Team team;

  const TeamMembersManager({super.key, required this.team});

  @override
  State<TeamMembersManager> createState() => _TeamMembersManagerState();
}

class _TeamMembersManagerState extends State<TeamMembersManager> {
  @override
  void initState() {
    super.initState();
    _loadTeamMembers();
  }

  void _loadTeamMembers() {
    context.read<TeamProvider>().loadTeamMembers(widget.team.id);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TeamProvider>(
      builder: (context, teamProvider, child) {
        if (teamProvider.isLoading) {
          return _buildLoadingState();
        }

        if (teamProvider.teamMembers.isEmpty) {
          return _buildEmptyState();
        }

        return _buildMembersList(teamProvider.teamMembers);
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            'جاري تحميل الأعضاء...',
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeApp.s24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(SizeApp.s20),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.group_add_rounded,
                size: 64.sp,
                color: ColorsManager.primaryColor,
              ),
            ),
            SizedBox(height: SizeApp.s20),
            Text(
              'لا يوجد أعضاء',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              'ابدأ بإضافة أعضاء لهذا الفريق من المكتبة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.defaultTextSecondary,
                height: 1.4,
              ),
            ),
            SizedBox(height: SizeApp.s32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showAddMembersDialog,
                icon: Icon(Icons.library_add_rounded, size: SizeApp.iconSize),
                label: const Text('إضافة أعضاء من المكتبة'),
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
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList(List<Member> members) {
    return Column(
      children: [
        // Add Members Button
        Container(
          color: Colors.white,
          padding: EdgeInsets.all(SizeApp.s16),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _showAddMembersDialog,
                  icon: Icon(Icons.library_add_rounded, size: SizeApp.iconSize),
                  label: const Text('إضافة أعضاء جدد'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.primaryColor,
                    side: BorderSide(color: ColorsManager.primaryColor),
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

        // Members Count
        Container(
          color: ColorsManager.primaryColor.withOpacity(0.1),
          padding: EdgeInsets.symmetric(
            horizontal: SizeApp.s16,
            vertical: SizeApp.s12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'أعضاء الفريق',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.primaryColor,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeApp.s12,
                  vertical: SizeApp.s4,
                ),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${members.length}',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Members List
        Expanded(
          child: ListView.builder(
            padding: EdgeInsets.all(SizeApp.s16),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
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
                    backgroundColor: ColorsManager.primaryColor.withOpacity(0.1),
                    backgroundImage: member.photoPath != null
                        ? FileImage(File(member.photoPath!))
                        : null,
                    child: member.photoPath == null
                        ? Text(
                      member.name[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: ColorsManager.primaryColor,
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
                    onPressed: () => _showRemoveMemberDialog(member),
                    icon: Icon(
                      Icons.remove_circle_outline_rounded,
                      color: ColorsManager.errorFill,
                      size: SizeApp.iconSize,
                    ),
                    tooltip: 'إزالة من الفريق',
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  void _showAddMembersDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AddMembersSheet(team: widget.team),
    ).then((result) {
      if (result == true) {
        _loadTeamMembers();
      }
    });
  }

  void _showRemoveMemberDialog(Member member) {
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
              'إزالة العضو',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.errorFill,
              ),
            ),
          ],
        ),
        content: Text(
          'هل أنت متأكد من إزالة "${member.name}" من الفريق؟',
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
            onPressed: () => _removeMember(member),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
            child: Text(
              'إزالة',
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

  Future<void> _removeMember(Member member) async {
    Navigator.pop(context); // Close dialog

    final teamProvider = context.read<TeamProvider>();
    final success = await teamProvider.removeMemberFromTeam(
      widget.team.id,
      member.id,
    );

    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إزالة ${member.name} من الفريق'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(teamProvider.errorMessage ?? 'خطأ في إزالة العضو'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }
}

class _AddMembersSheet extends StatefulWidget {
  final Team team;

  const _AddMembersSheet({required this.team});

  @override
  State<_AddMembersSheet> createState() => _AddMembersSheetState();
}

class _AddMembersSheetState extends State<_AddMembersSheet> {
  final TextEditingController _searchController = TextEditingController();
  final Set<String> _selectedIds = {};
  List<Member> _allMembers = [];
  List<Member> _filteredMembers = [];
  List<Member> _currentTeamMembers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    final db = DatabaseHelper.instance;
    final allMembers = await db.getAllMembers();
    final teamMembers = await db.getTeamMembers(widget.team.id);

    // Filter out members already in team
    final teamMemberIds = teamMembers.map((m) => m.id).toSet();
    final availableMembers = allMembers.where((m) => !teamMemberIds.contains(m.id)).toList();

    setState(() {
      _allMembers = availableMembers;
      _filteredMembers = availableMembers;
      _currentTeamMembers = teamMembers;
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
          Padding(
            padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
            child: Row(
              children: [
                Icon(
                  Icons.library_add_rounded,
                  color: ColorsManager.primaryColor,
                  size: SizeApp.iconSize,
                ),
                SizedBox(width: SizeApp.s8),
                Expanded(
                  child: Text(
                    'إضافة أعضاء للفريق',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: ColorsManager.defaultText,
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: SizeApp.s16),

          // Search Field
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
            backgroundColor: ColorsManager.primaryColor.withOpacity(0.1),
            backgroundImage: member.photoPath != null
                ? FileImage(File(member.photoPath!))
                : null,
            child: member.photoPath == null
                ? Text(
              member.name[0].toUpperCase(),
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: ColorsManager.primaryColor,
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
                ? 'جميع الأعضاء مضافون للفريق'
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
              'جميع الأعضاء المتاحين مضافون بالفعل لهذا الفريق',
              textAlign: TextAlign.center,
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
                onPressed: _selectedIds.isEmpty ? null : _addSelectedMembers,
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

  Future<void> _addSelectedMembers() async {
    if (_selectedIds.isEmpty) return;

    final teamProvider = context.read<TeamProvider>();
    final success = await teamProvider.addMembersToTeam(
      widget.team.id,
      _selectedIds.toList(),
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إضافة ${_selectedIds.length} عضو للفريق'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(teamProvider.errorMessage ?? 'خطأ في إضافة الأعضاء'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }
}