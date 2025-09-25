// lib/screens/teams/create_team_flow.dart
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../../core/utils/enums.dart';
import '../../data/models/team.dart';
import '../../data/models/member/member.dart';
import '../../providers/team_provider.dart';
import '../../data/database/db_helper.dart';
import '../team/steps/add_members_step.dart';
import '../team/steps/select_content_step.dart';
import '../team/steps/team_info_step.dart';


class CreateTeamFlow extends StatefulWidget {
  const CreateTeamFlow({super.key});

  @override
  State<CreateTeamFlow> createState() => _CreateTeamFlowState();
}

class _CreateTeamFlowState extends State<CreateTeamFlow> {
  int _currentStep = 0;

  // حالة التجميعة
  String _teamName = '';
  AgeCategory? _ageCategory;
  final List<Member> _members = [];
  final List<String> _selectedExerciseIds = [];
  final List<String> _selectedSkillIds = [];

  bool _saving = false;

  // تنقّل الخطوات مع فاليديشن بسيط
  void _next() {
    if (_currentStep == 0) {
      if (_teamName.trim().isEmpty || _ageCategory == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('من فضلك أدخل اسم الفريق واختر الفئة العمرية')),
        );
        return;
      }
    }
    if (_currentStep == 1) {
      if (_members.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('أضف عضو واحد على الأقل')),
        );
        return;
      }
    }
    if (_currentStep < 2) {
      setState(() => _currentStep++);
    } else {
      _finish();
    }
  }

  void _back() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      Navigator.pop(context);
    }
  }

  Future<void> _finish() async {
    setState(() => _saving = true);
    try {
      // 1) إنشاء الفريق
      final team = Team(
        name: _teamName.trim(),
        ageCategory: _ageCategory!,      // بقى جاهز من الخطوة 1
        createdAt: DateTime.now(),
      );
      final teamProvider = context.read<TeamProvider>();
      final String newTeamId = await teamProvider.addTeam(team);

      // 2) إضافة الأعضاء وربط الـteamId
      final db = DatabaseHelper.instance;
      for (final m in _members) {
        final member = Member(
          // لو Member عندك له id تلقائي في DB سيبه null/مش تبعته
          teamId: newTeamId,
          name: m.name,
          age: m.age,
          level: m.level,
          photoPath: m.photoPath,
          createdAt: DateTime.now(),
        );
        await db.createMember(member);
      }

      // 3) التعيينات (تمارين/مهارات) – IDs من المكتبتين العالمية
      await teamProvider.assignExercisesToTeam(newTeamId, _selectedExerciseIds);
      await teamProvider.assignSkillsToTeam(newTeamId, _selectedSkillIds);

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الفريق بنجاح')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('حصل خطأ أثناء الحفظ: $e')),
        );
        log('حصل خطأ أثناء الحفظ: $e');
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final steps = [
      TeamInfoStep(
        teamName: _teamName,
        selectedAgeCategory: _ageCategory,
        onTeamNameChanged: (v) => _teamName = v,
        onAgeCategoryChanged: (v) => _ageCategory = v,
      ),
      AddMembersStep(
        members: _members,
        onMembersChanged: (list) {
          _members
            ..clear()
            ..addAll(list);
          setState(() {});
        },
      ),
      SelectContentStep(
        selectedExercises: _selectedExerciseIds,
        selectedSkills: _selectedSkillIds,
        onExercisesChanged: (ids) {
          _selectedExerciseIds
            ..clear()
            ..addAll(ids);
          setState(() {});
        },
        onSkillsChanged: (ids) {
          _selectedSkillIds
            ..clear()
            ..addAll(ids);
          setState(() {});
        },
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فريق جديد'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _back,
        ),
      ),
      body: steps[_currentStep],
      bottomNavigationBar: Container(
        color: Colors.white,
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 16.h),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _back,
                child: Text(_currentStep == 0 ? 'إلغاء' : 'رجوع'),
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: ElevatedButton(
                onPressed: _saving ? null : _next,
                child: _saving
                    ? const SizedBox(
                    width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(_currentStep < 2 ? 'التالي' : 'إنهاء'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
