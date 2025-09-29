// ============= Member Skills Tab - تبويب المهارات (FIXED) =============
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      return EmptyStateWidget(
        title: 'لا توجد مهارات معينة',
        subtitle: 'لم يتم تعيين أي مهارات لهذا العضو بعد',
        buttonText: 'إضافة مهارة',
        onPressed: widget.onAddSkill ?? () => _showAssignSkillDialog(),
        iconData: Icons.sports_gymnastics_rounded,
        buttonIcon: Icons.add_rounded,
      );
    }

    return RefreshIndicator(
      onRefresh: _loadMemberSkills,
      child: ListView.builder(
        padding: EdgeInsets.all(SizeApp.s16),
        itemCount: _assignedSkills.length,
        itemBuilder: (context, index) {
          final assignedSkill = _assignedSkills[index];
          return _buildSkillCard(assignedSkill);
        },
      ),
    );
  }

  Widget _buildSkillCard(AssignedSkill assignedSkill) {
    final skill = assignedSkill.skill;
    if (skill == null) return const SizedBox.shrink();

    final apparatusColor = getApparatusColor(skill.apparatus);
    final progressPercentage = assignedSkill.progress;

    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showSkillDetails(assignedSkill),
          borderRadius: BorderRadius.circular(16.r),
          child: Padding(
            padding: EdgeInsets.all(SizeApp.s16),
            child: Column(
              children: [
                Row(
                  children: [
                    // Skill Icon/Thumbnail
                    Container(
                      width: 60.w,
                      height: 60.h,
                      decoration: BoxDecoration(
                        color: apparatusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: skill.thumbnailPath != null
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(12.r),
                        child: Image.file(
                          File(skill.thumbnailPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              getApparatusIcon(skill.apparatus),
                              color: apparatusColor,
                              size: 28.sp,
                            );
                          },
                        ),
                      )
                          : Icon(
                        getApparatusIcon(skill.apparatus),
                        color: apparatusColor,
                        size: 28.sp,
                      ),
                    ),
                    SizedBox(width: SizeApp.s12),

                    // Skill Info
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            skill.skillName,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorsManager.defaultText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Row(
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: apparatusColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                child: Text(
                                  skill.apparatus.arabicName,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: apparatusColor,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              _buildStatusBadge(assignedSkill),
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Actions
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert_rounded,
                        color: ColorsManager.defaultTextSecondary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'update_progress':
                            _showUpdateProgressDialog(assignedSkill);
                            break;
                          case 'add_note':
                            _showAddNoteDialog(assignedSkill);
                            break;
                          case 'remove':
                            _confirmRemoveSkill(assignedSkill);
                            break;
                        }
                      },
                      itemBuilder: (context) => [
                        PopupMenuItem(
                          value: 'update_progress',
                          child: Row(
                            children: [
                              Icon(Icons.trending_up_rounded, size: 20.sp),
                              SizedBox(width: 12.w),
                              const Text('تحديث التقدم'),
                            ],
                          ),
                        ),
                        PopupMenuItem(
                          value: 'add_note',
                          child: Row(
                            children: [
                              Icon(Icons.note_add_rounded, size: 20.sp),
                              SizedBox(width: 12.w),
                              const Text('إضافة ملاحظة'),
                            ],
                          ),
                        ),
                        const PopupMenuDivider(),
                        PopupMenuItem(
                          value: 'remove',
                          child: Row(
                            children: [
                              Icon(Icons.delete_outline_rounded,
                                  size: 20.sp, color: ColorsManager.errorFill),
                              SizedBox(width: 12.w),
                              Text(
                                'إزالة المهارة',
                                style: TextStyle(color: ColorsManager.errorFill),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Progress Bar
                Container(
                  margin: EdgeInsets.only(top: SizeApp.s12),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'التقدم',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                          ),
                          Text(
                            '${progressPercentage.toInt()}%',
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: apparatusColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      LinearProgressIndicator(
                        value: progressPercentage / 100,
                        backgroundColor: apparatusColor.withOpacity(0.1),
                        valueColor: AlwaysStoppedAnimation<Color>(apparatusColor),
                        borderRadius: BorderRadius.circular(4.r),
                        minHeight: 6.h,
                      ),
                    ],
                  ),
                ),

                // Notes section if exists
                if (assignedSkill.notes != null && assignedSkill.notes!.isNotEmpty)
                  Container(
                    margin: EdgeInsets.only(top: SizeApp.s12),
                    padding: EdgeInsets.all(SizeApp.s8),
                    decoration: BoxDecoration(
                      color: ColorsManager.backgroundCard,
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 14.sp,
                          color: ColorsManager.defaultTextSecondary,
                        ),
                        SizedBox(width: SizeApp.s4),
                        Expanded(
                          child: Text(
                            assignedSkill.notes!,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AssignedSkill assignedSkill) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (assignedSkill.isCompleted) {
      statusText = 'مكتمل';
      statusColor = ColorsManager.successFill;
      statusIcon = Icons.check_circle_rounded;
    } else if (assignedSkill.isInProgress) {
      statusText = 'قيد التقدم';
      statusColor = ColorsManager.warningFill;
      statusIcon = Icons.schedule_rounded;
    } else {
      statusText = 'لم يبدأ';
      statusColor = ColorsManager.defaultTextSecondary;
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(statusIcon, size: 12.sp, color: statusColor),
          SizedBox(width: 4.w),
          Text(
            statusText,
            style: TextStyle(
              fontSize: 12.sp,
              color: statusColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showAssignSkillDialog() {
    // showModalBottomSheet(
    //   context: context,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (context) => AssignSkillToMembersSheet(
    //     member: widget.member,
    //     onSkillsAssigned: () {
    //       _loadMemberSkills();
    //     },
    //   ),
    // );
  }

  void _showSkillDetails(AssignedSkill assignedSkill) {
    if (assignedSkill.skill != null) {
      SkillDetailSheet.show(context, assignedSkill.skill!, null);
    }
  }

  void _showUpdateProgressDialog(AssignedSkill assignedSkill) {
    double currentProgress = assignedSkill.progress;
    String? notes = assignedSkill.notes;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text('تحديث تقدم المهارة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                assignedSkill.skill?.skillName ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: SizeApp.s20),

              // Progress Section
              Container(
                padding: EdgeInsets.all(SizeApp.s16),
                decoration: BoxDecoration(
                  color: getApparatusColor(assignedSkill.skill!.apparatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Column(
                  children: [
                    Text(
                      '${currentProgress.toInt()}%',
                      style: TextStyle(
                        fontSize: 32.sp,
                        fontWeight: FontWeight.bold,
                        color: getApparatusColor(assignedSkill.skill!.apparatus),
                      ),
                    ),
                    SizedBox(height: SizeApp.s8),
                    Slider(
                      value: currentProgress,
                      min: 0,
                      max: 100,
                      divisions: 20,
                      activeColor: getApparatusColor(assignedSkill.skill!.apparatus),
                      inactiveColor: getApparatusColor(assignedSkill.skill!.apparatus).withOpacity(0.2),
                      label: '${currentProgress.toInt()}%',
                      onChanged: (value) {
                        setState(() {
                          currentProgress = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              SizedBox(height: SizeApp.s16),

              // Quick Progress Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildQuickProgressButton('0%', 0, currentProgress, (value) {
                    setState(() => currentProgress = value);
                  }),
                  _buildQuickProgressButton('25%', 25, currentProgress, (value) {
                    setState(() => currentProgress = value);
                  }),
                  _buildQuickProgressButton('50%', 50, currentProgress, (value) {
                    setState(() => currentProgress = value);
                  }),
                  _buildQuickProgressButton('75%', 75, currentProgress, (value) {
                    setState(() => currentProgress = value);
                  }),
                  _buildQuickProgressButton('100%', 100, currentProgress, (value) {
                    setState(() => currentProgress = value);
                  }),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                final provider = Provider.of<ExerciseAssignmentProvider>(
                  context,
                  listen: false,
                );

                try {
                  await provider.updateMemberSkillProgress(
                    widget.member.id,
                    assignedSkill.skillId,
                    currentProgress,
                    notes: notes,
                  );

                  Navigator.pop(context);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('تم تحديث التقدم إلى ${currentProgress.toInt()}%'),
                      backgroundColor: ColorsManager.successFill,
                    ),
                  );

                  _loadMemberSkills();
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('حدث خطأ في تحديث التقدم'),
                      backgroundColor: ColorsManager.errorFill,
                    ),
                  );
                }
              },
              child: const Text('حفظ'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickProgressButton(String label, double value, double currentValue, Function(double) onTap) {
    final isSelected = currentValue == value;
    return InkWell(
      onTap: () => onTap(value),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isSelected ? ColorsManager.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? ColorsManager.primaryColor : ColorsManager.inputBorder,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : ColorsManager.defaultText,
          ),
        ),
      ),
    );
  }

  void _showAddNoteDialog(AssignedSkill assignedSkill) {
    final TextEditingController noteController = TextEditingController(
      text: assignedSkill.notes,
    );

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('إضافة ملاحظة'),
        content: TextField(
          controller: noteController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'أدخل الملاحظة هنا...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<ExerciseAssignmentProvider>(
                context,
                listen: false,
              );

              try {
                await provider.addNoteToMemberSkill(
                  widget.member.id,
                  assignedSkill.skillId,
                  noteController.text,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم حفظ الملاحظة')),
                );

                _loadMemberSkills();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ في حفظ الملاحظة'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }

  void _confirmRemoveSkill(AssignedSkill assignedSkill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('تأكيد الإزالة'),
        content: Text(
          'هل أنت متأكد من إزالة مهارة "${assignedSkill.skill?.skillName}" من هذا العضو؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () async {
              final provider = Provider.of<ExerciseAssignmentProvider>(
                context,
                listen: false,
              );

              try {
                await provider.unassignSkillFromMember(
                  widget.member.id,
                  assignedSkill.skillId,
                );

                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('تم إزالة المهارة'),
                    backgroundColor: ColorsManager.successFill,
                  ),
                );

                _loadMemberSkills();
              } catch (e) {
                Navigator.pop(context);

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('حدث خطأ في إزالة المهارة'),
                    backgroundColor: ColorsManager.errorFill,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorsManager.errorFill,
            ),
            child: const Text('إزالة'),
          ),
        ],
      ),
    );
  }
}