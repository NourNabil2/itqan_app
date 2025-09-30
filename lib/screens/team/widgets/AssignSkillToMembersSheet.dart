import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';
import '../../../data/models/skill_template.dart';

class AssignSkillToMembersSheet extends StatefulWidget {
  final SkillTemplate skill;
  final String teamId;

  const AssignSkillToMembersSheet({
    super.key,
    required this.skill,
    required this.teamId,
  });

  static Future<bool?> show(BuildContext context, SkillTemplate skill, String teamId) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => AssignSkillToMembersSheet(skill: skill, teamId: teamId),
    );
  }

  @override
  State<AssignSkillToMembersSheet> createState() => _AssignSkillToMembersSheetState();
}

class _AssignSkillToMembersSheetState extends State<AssignSkillToMembersSheet> {
  final Set<String> _selectedMemberIds = {};
  List<Member> _availableMembers = [];
  List<Member> _assignedMembers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final memberProvider = Provider.of<MemberProvider>(context, listen: false);
      final assignmentProvider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);

      await memberProvider.loadTeamMembers(widget.teamId);
      final teamMembers = memberProvider.members;

      final assignedIds = await assignmentProvider.getSkillAssignedMemberIds(widget.skill.id);

      setState(() {
        _assignedMembers = teamMembers.where((m) => assignedIds.contains(m.id)).toList();
        _availableMembers = teamMembers.where((m) => !assignedIds.contains(m.id)).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في تحميل الأعضاء: $e')),
        );
      }
    }
  }

  List<Member> get _filteredMembers {
    if (_searchQuery.isEmpty) return _availableMembers;
    final q = _searchQuery.toLowerCase();
    return _availableMembers.where((m) {
      final name = m.name.toLowerCase();
      final level = (m.level ?? '').toLowerCase();
      return name.contains(q) || level.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Column(
        children: [
          Container(
            margin: EdgeInsets.only(top: SizeApp.s12),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.inputBorder.withOpacity(0.3),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          _buildHeader(),
          _buildSearchBar(),
          Expanded(child: _isLoading ? const LoadingSpinner() : _buildContent()),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.primaryColor.withOpacity(0.05),
        border: Border(
          bottom: BorderSide(color: ColorsManager.inputBorder.withOpacity(0.2)),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.assignment_ind_rounded, color: ColorsManager.primaryColor, size: 24.sp),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('تعيين المهارة للأعضاء',
                    style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold, color: ColorsManager.defaultText)),
                SizedBox(height: SizeApp.s4),
                Text(widget.skill.skillName,
                    style: TextStyle(fontSize: 14.sp, color: ColorsManager.defaultTextSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      child: TextField(
        controller: _searchController,
        onChanged: (v) => setState(() => _searchQuery = v),
        decoration: InputDecoration(
          hintText: 'البحث عن عضو...',
          prefixIcon: Icon(Icons.search_rounded, color: ColorsManager.defaultTextSecondary),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear_rounded, color: ColorsManager.defaultTextSecondary),
            onPressed: () => setState(() {
              _searchController.clear();
              _searchQuery = '';
            }),
          )
              : null,
          filled: true,
          fillColor: ColorsManager.backgroundCard,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: SizeApp.s16, vertical: SizeApp.s12),
        ),
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_assignedMembers.isNotEmpty) ...[
            _buildSectionTitle('الأعضاء المعينين مسبقاً', Icons.check_circle_rounded),
            SizedBox(height: SizeApp.s8),
            ..._assignedMembers.map(_buildAssignedMemberCard),
            SizedBox(height: SizeApp.s20),
          ],
          if (_filteredMembers.isNotEmpty) ...[
            _buildSectionTitle('الأعضاء المتاحين', Icons.people_rounded),
            SizedBox(height: SizeApp.s8),
            ..._filteredMembers.map(_buildMemberSelectionCard),
          ] else
            _buildEmptyState(),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20.sp, color: ColorsManager.primaryColor),
        SizedBox(width: SizeApp.s8),
        Text(title, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorsManager.defaultText)),
        if (title.contains('المتاحين') && _selectedMemberIds.isNotEmpty) ...[
          const Spacer(),
          Container(
            padding: EdgeInsets.symmetric(horizontal: SizeApp.s12, vertical: SizeApp.s4),
            decoration: BoxDecoration(color: ColorsManager.primaryColor, borderRadius: BorderRadius.circular(SizeApp.radiusSmall)),
            child: Text(
              '${_selectedMemberIds.length} محدد',
              style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAssignedMemberCard(Member member) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s8),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: ColorsManager.successFill.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(color: ColorsManager.successFill.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(color: ColorsManager.successFill.withOpacity(0.2), shape: BoxShape.circle),
            child: Center(
              child: Text(member.name.substring(0, 1),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: ColorsManager.successFill)),
            ),
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(member.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ColorsManager.defaultText)),
              Text('${member.age} سنة • ${member.level}',
                  style: TextStyle(fontSize: 12.sp, color: ColorsManager.defaultTextSecondary)),
            ]),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: SizeApp.s8, vertical: SizeApp.s4),
            decoration: BoxDecoration(color: ColorsManager.successFill, borderRadius: BorderRadius.circular(SizeApp.radiusSmall)),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.check_rounded, size: 14.sp, color: Colors.white),
              SizedBox(width: SizeApp.s4),
              Text('معين', style: TextStyle(fontSize: 12.sp, color: Colors.white, fontWeight: FontWeight.w600)),
            ]),
          ),
          SizedBox(width: SizeApp.s8),
          // Unassign button
          IconButton(
            icon: Icon(
              Icons.close_rounded,
              color: ColorsManager.errorFill,
              size: 20.sp,
            ),
            onPressed: () => _showUnassignConfirmation(member),
            padding: EdgeInsets.all(SizeApp.s4),
            constraints: const BoxConstraints(),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildMemberSelectionCard(Member member) {
    final isSelected = _selectedMemberIds.contains(member.id);
    return GestureDetector(
      onTap: () => setState(() {
        isSelected ? _selectedMemberIds.remove(member.id) : _selectedMemberIds.add(member.id);
      }),
      child: Container(
        margin: EdgeInsets.only(bottom: SizeApp.s8),
        padding: EdgeInsets.all(SizeApp.s12),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor.withOpacity(0.1) : ColorsManager.backgroundCard,
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.inputBorder.withOpacity(0.3),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
                borderRadius: BorderRadius.circular(4.r),
                border: Border.all(
                  color: isSelected ? ColorsManager.primaryColor : ColorsManager.defaultTextSecondary,
                  width: 2,
                ),
              ),
              child: isSelected ? Icon(Icons.check_rounded, size: 16.sp, color: Colors.white) : null,
            ),
            SizedBox(width: SizeApp.s12),
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(color: ColorsManager.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
              child: Center(
                child: Text(
                  member.name.substring(0, 1),
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: ColorsManager.primaryColor),
                ),
              ),
            ),
            SizedBox(width: SizeApp.s12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(member.name, style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: ColorsManager.defaultText)),
                Row(children: [
                  Text('${member.age} سنة', style: TextStyle(fontSize: 12.sp, color: ColorsManager.defaultTextSecondary)),
                  SizedBox(width: SizeApp.s8),
                  if ((member.level).isNotEmpty)
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: SizeApp.s6, vertical: SizeApp.s2),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        member.level,
                        style: TextStyle(fontSize: 10.sp, color: ColorsManager.primaryColor, fontWeight: FontWeight.w600),
                      ),
                    ),
                ]),
              ]),
            ),
            if ((member.overallProgress ?? 0) > 0)
              SizedBox(
                width: 50.w,
                height: 50.w,
                child: Stack(alignment: Alignment.center, children: [
                  CircularProgressIndicator(
                    value: (member.overallProgress ?? 0) / 100,
                    backgroundColor: ColorsManager.inputBorder.withOpacity(0.2),
                    valueColor: AlwaysStoppedAnimation(ColorsManager.primaryColor),
                    strokeWidth: 3,
                  ),
                  Text(
                    '${(member.overallProgress ?? 0).toInt()}%',
                    style: TextStyle(fontSize: 10.sp, fontWeight: FontWeight.bold, color: ColorsManager.primaryColor),
                  ),
                ]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s32),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline_rounded, size: 64.sp, color: ColorsManager.defaultTextSecondary.withOpacity(0.5)),
            SizedBox(height: SizeApp.s16),
            Text(
              _searchQuery.isNotEmpty ? 'لا يوجد أعضاء متطابقين مع البحث' : 'جميع الأعضاء معينين لهذه المهارة',
              style: TextStyle(fontSize: 16.sp, color: ColorsManager.defaultTextSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: ColorsManager.inputBorder.withOpacity(0.3))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizeApp.radiusSmall)),
                  side: BorderSide(color: ColorsManager.inputBorder),
                ),
                child: Text('إلغاء',
                    style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600, color: ColorsManager.defaultTextSecondary)),
              ),
            ),
            SizedBox(width: SizeApp.s12),
            Expanded(
              child: ElevatedButton(
                onPressed: _selectedMemberIds.isEmpty ? null : _assignSkill,
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsManager.primaryColor,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(SizeApp.radiusSmall)),
                ),
                child: Text(
                  _selectedMemberIds.isEmpty ? 'حدد الأعضاء' : 'تعيين (${_selectedMemberIds.length})',
                  style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showUnassignConfirmation(Member member) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('إلغاء التعيين'),
        content: Text('هل تريد إلغاء تعيين هذه المهارة من ${member.name}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
            ),
            child: Text('نعم، إلغاء التعيين'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _unassignSkill(member);
    }
  }

  Future<void> _unassignSkill(Member member) async {
    try {
      final provider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);

      await provider.unassignSkillFromMember(member.id, widget.skill.id);

      // Reload members to update the UI
      await _loadMembers();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم إلغاء تعيين المهارة من ${member.name}'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('حدث خطأ في إلغاء التعيين: ${e.toString()}'),
            backgroundColor: ColorsManager.errorFill,
          ),
        );
      }
    }
  }

  Future<void> _assignSkill() async {
    try {
      final provider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);
      await provider.assignSkillToMembers(widget.skill.id, _selectedMemberIds.toList());

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعيين المهارة لـ ${_selectedMemberIds.length} عضو بنجاح'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حدث خطأ في تعيين المهارة: $e'), backgroundColor: ColorsManager.errorFill),
        );
      }
    }
  }
}