// ============= Member Skills Tab - تبويب المهارات (FIXED) =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/empty_state_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/providers/skill_library_provider.dart';
import 'package:itqan_gym/screens/team/widgets/AssignSkillToMembersSheet.dart';
import 'package:itqan_gym/screens/team/widgets/skill_detail_sheet.dart';
import 'package:provider/provider.dart';

import '../widgets/exercises/skill_card.dart';

class MemberSkillsTab extends StatefulWidget {
  final Member member;
  final Function()? onAddSkill;

  const MemberSkillsTab({
    super.key,
    required this.member,
    this.onAddSkill,
  });

  @override
  State<MemberSkillsTab> createState() => _MemberSkillsTabState();
}

class _MemberSkillsTabState extends State<MemberSkillsTab>
    with AutomaticKeepAliveClientMixin {
  List<AssignedSkill> _assignedSkills = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadMemberSkills();
  }

  Future<void> _loadMemberSkills() async {
    setState(() => _isLoading = true);

    try {
      final provider = Provider.of<ExerciseAssignmentProvider>(context, listen: false);
      final skills = await provider.loadMemberSkills(widget.member.id);

      if (mounted) {
        setState(() {
          _assignedSkills = skills;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_assignedSkills.isEmpty) {
      return  EmptyStateWidget(
        iconData: Icons.star_border_rounded,
        title: AppLocalizations.of(context).noSkillsAvailable,
        subtitle: AppLocalizations.of(context).noContentAssigned,
        buttonText: AppLocalizations.of(context).addSkill,
        showButton: false,
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(SizeApp.s16),
      itemCount: _assignedSkills.length,
      itemBuilder: (context, index) {
        final assignedSkill = _assignedSkills[index];
        return SkillCard(
          assignedSkill: assignedSkill,
          onTap: () => _showSkillDetails(assignedSkill),
          onProgressUpdated: _loadMemberSkills,
        );
      },
    );
  }
  void _showSkillDetails(AssignedSkill assignedSkill) {
    if (assignedSkill.skill != null) {
      SkillDetailSheet.show(context, assignedSkill.skill!, null);
    }
  }

}