import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/full_screen_media_viewer.dart';
import 'package:itqan_gym/core/widgets/video_player_widget.dart';
import 'package:itqan_gym/core/widgets/Loading_widget.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/screens/team/widgets/AssignSkillToMembersSheet.dart';
import 'package:provider/provider.dart';
import '../../../data/models/skill_template.dart';

class SkillDetailSheet extends StatefulWidget {
  final SkillTemplate skill;
  final String? teamId;

  const SkillDetailSheet({
    super.key,
    required this.skill,
    this.teamId,
  });

  @override
  State<SkillDetailSheet> createState() => _SkillDetailSheetState();

  static void show(BuildContext context, SkillTemplate skill, String? teamId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkillDetailSheet(skill: skill, teamId: teamId),
    );
  }
}

class _SkillDetailSheetState extends State<SkillDetailSheet> {
  late Future<List<Member>> _membersFuture;

  @override
  void initState() {
    super.initState();
    _loadAssignedMembers();
  }

  void _loadAssignedMembers() {
    if (widget.teamId != null) {
      setState(() {
        _membersFuture = Provider.of<ExerciseAssignmentProvider>(context, listen: false)
            .loadSkillMembers(widget.skill.id);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: BoxDecoration(
        color: ColorsManager.backgroundSurface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        children: [
          // Modern Handle
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 36.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: ColorsManager.inputBorder.withOpacity(0.4),
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),

          // Header with Gradient
          _buildModernHeader(context),

          // Content
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(SizeApp.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Assigned Members Section (NEW)
                  if (widget.teamId != null) _buildAssignedMembersSection(context),

                  // Thumbnail Section
                  if (widget.skill.thumbnailPath != null) _buildThumbnailSection(context),

                  // Media Gallery
                  if (widget.skill.mediaGallery.isNotEmpty) _buildMediaGallerySection(context),

                  // Info Cards Grid
                  _buildInfoCardsGrid(),

                  SizedBox(height: SizeApp.s16),

                  // Technical Analysis
                  if (widget.skill.technicalAnalysis != null) _buildModernDetailSection(
                    'التحليل الفني',
                    widget.skill.technicalAnalysis!,
                    Icons.psychology_rounded,
                    getApparatusColor(widget.skill.apparatus),
                  ),

                  // Pre-requisites
                  if (widget.skill.preRequisites != null) _buildModernDetailSection(
                    'المتطلبات المسبقة',
                    widget.skill.preRequisites!,
                    Icons.checklist_rounded,
                    const Color(0xFF9C27B0),
                  ),

                  // Skill Progression
                  if (widget.skill.skillProgression != null) _buildModernDetailSection(
                    'تدرج المهارة',
                    widget.skill.skillProgression!,
                    Icons.trending_up_rounded,
                    const Color(0xFF4CAF50),
                  ),

                  // Drills
                  if (widget.skill.drills != null) _buildModernDetailSection(
                    'التمرينات المهارية',
                    widget.skill.drills!,
                    Icons.sports_gymnastics_rounded,
                    const Color(0xFF2196F3),
                  ),

                  // Physical Preparation
                  if (widget.skill.physicalPreparation != null) _buildModernDetailSection(
                    'الإعداد البدني',
                    widget.skill.physicalPreparation!,
                    Icons.fitness_center_rounded,
                    const Color(0xFFFF5722),
                  ),

                  SizedBox(height: SizeApp.s70),
                ],
              ),
            ),
          ),

          // Floating Close Button
          _buildFloatingCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildModernHeader(BuildContext context) {
    final apparatusColor = getApparatusColor(widget.skill.apparatus);

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            apparatusColor.withOpacity(0.15),
            apparatusColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      padding: EdgeInsets.all(SizeApp.s20),
      child: Row(
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(14.sp),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: apparatusColor.withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              getApparatusIcon(widget.skill.apparatus),
              color: apparatusColor,
              size: 28.sp,
            ),
          ),
          SizedBox(width: SizeApp.s16),

          // Title + Badge
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.skill.skillName,
                  style: TextStyle(
                    fontSize: 22.sp,
                    fontWeight: FontWeight.w700,
                    color: ColorsManager.defaultText,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: SizeApp.s8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [apparatusColor, apparatusColor.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20.r),
                    boxShadow: [
                      BoxShadow(
                        color: apparatusColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(getApparatusIcon(widget.skill.apparatus), color: Colors.white, size: 14.sp),
                      SizedBox(width: 6.w),
                      Text(
                        widget.skill.apparatus.arabicName,
                        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Assignment Button (if teamId is available)
          if (widget.teamId != null) ...[
            SizedBox(width: SizeApp.s8),
            IconButton(
              tooltip: 'تعيين للأعضاء',
              onPressed: () => _showAssignmentSheet(context),
              icon: Container(
                padding: EdgeInsets.all(10.sp),
                decoration: BoxDecoration(
                  color: ColorsManager.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.person_add_rounded, color: ColorsManager.primaryColor, size: 20.sp),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAssignedMembersSection(BuildContext context) {
    return FutureBuilder<List<Member>>(
      future: _membersFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingSection();
        }

        final members = snapshot.data ?? [];

        if (members.isEmpty) {
          return _buildEmptyMembersSection(context);
        }

        return Container(
          margin: EdgeInsets.only(bottom: SizeApp.s20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(8.sp),
                    decoration: BoxDecoration(
                      color: ColorsManager.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Icon(
                      Icons.groups_rounded,
                      color: ColorsManager.primaryColor,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: SizeApp.s8),
                  Text(
                    'الأعضاء المعينون (${members.length})',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: ColorsManager.defaultText,
                    ),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: () => _showAssignmentSheet(context),
                    icon: Icon(Icons.add_circle_outline_rounded, size: 16.sp),
                    label: Text('إضافة', style: TextStyle(fontSize: 14.sp)),
                  ),
                ],
              ),
              SizedBox(height: SizeApp.s12),
              Container(
                height: 100.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: members.length,
                  itemBuilder: (context, index) => _buildMemberCard(members[index]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(Member member) {
    final apparatusColor = getApparatusColor(widget.skill.apparatus);

    return Container(
      width: 150.w,
      margin: EdgeInsets.only(left: SizeApp.s12),
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: apparatusColor.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Avatar
          Container(
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: apparatusColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                member.name.substring(0, 1),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: apparatusColor,
                ),
              ),
            ),
          ),
          SizedBox(height: SizeApp.s8),
          // Name
          Text(
            member.name,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeApp.s4),
          // Age & Level
          Text(
            '${member.age} سنة • ${member.level}',
            style: TextStyle(
              fontSize: 11.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyMembersSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: ColorsManager.backgroundCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_add_rounded,
            size: 48.sp,
            color: ColorsManager.defaultTextSecondary.withOpacity(0.5),
          ),
          SizedBox(height: SizeApp.s12),
          Text(
            'لم يتم تعيين أي عضو لهذه المهارة',
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          ElevatedButton.icon(
            onPressed: () => _showAssignmentSheet(context),
            icon: Icon(Icons.person_add_rounded, size: 18.sp),
            label: Text('تعيين أعضاء'),
            style: ElevatedButton.styleFrom(
              backgroundColor: getApparatusColor(widget.skill.apparatus),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(
                horizontal: SizeApp.s16,
                vertical: SizeApp.s8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      padding: EdgeInsets.all(SizeApp.s16),
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation(getApparatusColor(widget.skill.apparatus)),
        ),
      ),
    );
  }

  Future<void> _showAssignmentSheet(BuildContext context) async {
    if (widget.teamId == null) return;

    final result = await AssignSkillToMembersSheet.show(
      context,
      widget.skill,
      widget.teamId!,
    );

    if (result == true) {
      // Reload assigned members
      _loadAssignedMembers();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('تم تعيين المهارة للأعضاء بنجاح'),
            backgroundColor: ColorsManager.successFill,
          ),
        );
      }
    }
  }

  Widget _buildThumbnailSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: getApparatusColor(widget.skill.apparatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.image_rounded,
                  color: getApparatusColor(widget.skill.apparatus),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'الصورة المصغرة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.defaultText,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          GestureDetector(
            onTap: () => FullScreenMediaViewer.show(
              context,
              filePath: widget.skill.thumbnailPath!,
              isVideo: false,
              accentColor: getApparatusColor(widget.skill.apparatus),
            ),
            child: Hero(
              tag: 'skill_thumbnail_${widget.skill.id}',
              child: Container(
                height: 220.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.file(
                        File(widget.skill.thumbnailPath!),
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            color: ColorsManager.backgroundCard,
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image_rounded,
                                    size: 56.sp,
                                    color: ColorsManager.defaultTextSecondary.withOpacity(0.3),
                                  ),
                                  SizedBox(height: SizeApp.s12),
                                  Text(
                                    'لا يمكن عرض الصورة',
                                    style: TextStyle(
                                      fontSize: 14.sp,
                                      color: ColorsManager.defaultTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      // Overlay gradient
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 60.h,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.5),
                              ],
                            ),
                          ),
                          padding: EdgeInsets.all(12.sp),
                          child: Row(
                            children: [
                              Icon(
                                Icons.zoom_in_rounded,
                                color: Colors.white,
                                size: 20.sp,
                              ),
                              SizedBox(width: 6.w),
                              Text(
                                'اضغط للتكبير',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallerySection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  color: getApparatusColor(widget.skill.apparatus).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.perm_media_rounded,
                  color: getApparatusColor(widget.skill.apparatus),
                  size: 18.sp,
                ),
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'معرض الوسائط',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: ColorsManager.defaultText,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: getApparatusColor(widget.skill.apparatus).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${widget.skill.mediaGallery.length}',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: getApparatusColor(widget.skill.apparatus),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          SizedBox(
            height: 140.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: widget.skill.mediaGallery.length,
              itemBuilder: (context, index) {
                final media = widget.skill.mediaGallery[index];
                return _buildModernMediaPreview(media, context, index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernMediaPreview(MediaItem media, BuildContext context, int index) {
    final isVideo = media.type == MediaType.video;

    return GestureDetector(
      onTap: () => FullScreenMediaViewer.show(
        context,
        filePath: media.path,
        isVideo: isVideo,
        accentColor: getApparatusColor(widget.skill.apparatus),
      ),
      child: Container(
        width: 160.w,
        margin: EdgeInsets.only(right: SizeApp.s12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.r),
          child: Stack(
            fit: StackFit.expand,
            children: [
              isVideo
                  ? VideoPlayerWidget(
                videoPath: media.path,
                accentColor: getApparatusColor(widget.skill.apparatus),
                height: 140.h,
                width: 160.w,
              )
                  : Image.file(
                File(media.path),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: ColorsManager.backgroundCard,
                    child: Icon(
                      Icons.broken_image_rounded,
                      size: 40.sp,
                      color: ColorsManager.defaultTextSecondary.withOpacity(0.3),
                    ),
                  );
                },
              ),
              // Type Badge
              Positioned(
                top: 8.h,
                right: 8.w,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isVideo ? Icons.play_circle_filled : Icons.image,
                        color: Colors.white,
                        size: 12.sp,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        isVideo ? 'فيديو' : 'صورة',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCardsGrid() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildModernInfoCard(
                  'الجهاز',
                  widget.skill.apparatus.arabicName,
                  getApparatusIcon(widget.skill.apparatus),
                  getApparatusColor(widget.skill.apparatus),
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildModernInfoCard(
                  'الفرق',
                  '${widget.skill.assignedTeamsCount ?? 0}',
                  Icons.groups_rounded,
                  ColorsManager.primaryColor,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          Row(
            children: [
              Expanded(
                child: _buildModernInfoCard(
                  'الإضافة',
                  _formatShortDate(widget.skill.createdAt),
                  Icons.calendar_today_rounded,
                  ColorsManager.secondaryColor,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildModernInfoCard(
                  'التحديث',
                  _formatShortDate(widget.skill.updatedAt),
                  Icons.update_rounded,
                  const Color(0xFF9C27B0),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModernInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(12.sp),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withOpacity(0.1),
            color.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 22.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 15.sp,
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.sp,
              color: ColorsManager.defaultTextSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildModernDetailSection(String title, String content, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(
          color: color.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.sp),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.8)],
                  ),
                  borderRadius: BorderRadius.circular(10.r),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18.sp),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s16),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingCloseButton(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            // Close Button
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: getApparatusColor(widget.skill.apparatus),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.check_circle_rounded, size: 20.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'إغلاق',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Assign Members Button (if teamId available)
            if (widget.teamId != null) ...[
              SizedBox(width: SizeApp.s12),
              Expanded(
                flex: 3,
                child: OutlinedButton.icon(
                  onPressed: () => _showAssignmentSheet(context),
                  icon: Icon(Icons.person_add_rounded),
                  label: Text('تعيين للأعضاء'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColorsManager.primaryColor,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                    side: BorderSide(color: ColorsManager.primaryColor),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatShortDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}