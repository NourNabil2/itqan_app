import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/full_screen_media_viewer.dart';
import 'package:itqan_gym/core/widgets/video_player_widget.dart';
import '../../../data/models/skill_template.dart';

class SkillDetailSheet extends StatelessWidget {
  final SkillTemplate skill;

  const SkillDetailSheet({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
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

          // Header
          _buildHeader(),

          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.all(SizeApp.s16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Thumbnail Section
                  if (skill.thumbnailPath != null) _buildThumbnailSection(context),

                  // Media Gallery Section
                  if (skill.mediaGallery.isNotEmpty) _buildMediaGallerySection(),

                  // Technical Analysis
                  if (skill.technicalAnalysis != null) _buildDetailSection(
                    'التحليل الفني',
                    skill.technicalAnalysis!,
                    Icons.psychology_rounded,
                    getApparatusColor(skill.apparatus),
                  ),

                  // Pre-requisites
                  if (skill.preRequisites != null) _buildDetailSection(
                    'المتطلبات المسبقة',
                    skill.preRequisites!,
                    Icons.checklist_rounded,
                    const Color(0xFF9C27B0),
                  ),

                  // Skill Progression
                  if (skill.skillProgression != null) _buildDetailSection(
                    'تدرج المهارة',
                    skill.skillProgression!,
                    Icons.trending_up_rounded,
                    const Color(0xFF4CAF50),
                  ),

                  // Drills
                  if (skill.drills != null) _buildDetailSection(
                    'التمرينات المهارية',
                    skill.drills!,
                    Icons.sports_gymnastics_rounded,
                    const Color(0xFF2196F3),
                  ),

                  // Physical Preparation
                  if (skill.physicalPreparation != null) _buildDetailSection(
                    'الإعداد البدني',
                    skill.physicalPreparation!,
                    Icons.fitness_center_rounded,
                    const Color(0xFFFF5722),
                  ),

                  // Stats Section
                  _buildStatsSection(),

                  SizedBox(height: SizeApp.s20),
                ],
              ),
            ),
          ),

          // Close Button
          _buildCloseButton(context),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final apparatusColor = getApparatusColor(skill.apparatus);

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: apparatusColor.withOpacity(0.1),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeApp.radiusMed),
          topRight: Radius.circular(SizeApp.radiusMed),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(SizeApp.s12),
            decoration: BoxDecoration(
              color: apparatusColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(SizeApp.s10),
            ),
            child: Icon(
              getApparatusIcon(skill.apparatus),
              color: apparatusColor,
              size: 24.sp,
            ),
          ),
          SizedBox(width: SizeApp.s12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  skill.skillName,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: apparatusColor,
                  ),
                ),
                SizedBox(height: SizeApp.s4),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s8,
                    vertical: SizeApp.s4,
                  ),
                  decoration: BoxDecoration(
                    color: apparatusColor,
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  ),
                  child: Text(
                    skill.apparatus.arabicName,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnailSection(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الصورة المصغرة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          GestureDetector(
            onTap: () => FullScreenMediaViewer.show(
              context,
              filePath: skill.thumbnailPath!,
              isVideo: false,
              accentColor: getApparatusColor(skill.apparatus),
            ),
            child: Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                color: ColorsManager.backgroundCard,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                child: Image.file(
                  File(skill.thumbnailPath!),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                        color: ColorsManager.defaultTextSecondary.withOpacity(0.1),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.broken_image_rounded,
                              size: 48.sp,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                            SizedBox(height: SizeApp.s8),
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
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaGallerySection() {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معرض الوسائط (${skill.mediaGallery.length})',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w600,
              color: ColorsManager.defaultText,
            ),
          ),
          SizedBox(height: SizeApp.s12),
          SizedBox(
            height: 100.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: skill.mediaGallery.length,
              itemBuilder: (context, index) {
                final media = skill.mediaGallery[index];
                return _buildMediaPreview(media,context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMediaPreview(MediaItem media,BuildContext context) {
    final isVideo = media.type == MediaType.video;

    return GestureDetector(
      onTap: () => FullScreenMediaViewer.show(
        context,
        filePath: media.path,
        isVideo: isVideo,
        accentColor: getApparatusColor(skill.apparatus),
      ),
      child: Container(
        width: 120.w,
        margin: EdgeInsets.only(right: SizeApp.s8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          color: ColorsManager.backgroundCard,
        ),
        child: isVideo
            ? VideoPlayerWidget(
          videoPath: media.path,
          accentColor: getApparatusColor(skill.apparatus),
          height: 100.h,
          width: 120.w,
        )
            : ClipRRect(
          borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          child: Image.file(
            File(media.path),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                  color: ColorsManager.defaultTextSecondary.withOpacity(0.1),
                ),
                child: Center(
                  child: Icon(
                    Icons.broken_image_rounded,
                    size: 32.sp,
                    color: ColorsManager.defaultTextSecondary,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, String content, IconData icon, Color color) {
    return Container(
      margin: EdgeInsets.only(bottom: SizeApp.s16),
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: color.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: color,
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s12),
          Text(
            content,
            style: TextStyle(
              fontSize: 14.sp,
              color: ColorsManager.defaultTextSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsSection() {
    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: ColorsManager.primaryColor,
                size: 20.sp,
              ),
              SizedBox(width: SizeApp.s8),
              Text(
                'معلومات المهارة',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: ColorsManager.defaultText,
                ),
              ),
            ],
          ),
          SizedBox(height: SizeApp.s16),

          // Info Grid
          Row(
            children: [
              Expanded(
                child: _buildInfoCard(
                  'الجهاز',
                  skill.apparatus.arabicName,
                  getApparatusIcon(skill.apparatus),
                  getApparatusColor(skill.apparatus),
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildInfoCard(
                  'الفرق المعينة',
                  '${skill.assignedTeamsCount ?? 0}',
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
                child: _buildInfoCard(
                  'تاريخ الإضافة',
                  _formatDate(skill.createdAt),
                  Icons.add_circle_outline_rounded,
                  ColorsManager.secondaryColor,
                ),
              ),
              SizedBox(width: SizeApp.s12),
              Expanded(
                child: _buildInfoCard(
                  'آخر تحديث',
                  _formatDate(skill.updatedAt),
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

  Widget _buildInfoCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.all(SizeApp.s12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 20.sp,
          ),
          SizedBox(height: SizeApp.s8),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeApp.s4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10.sp,
              color: ColorsManager.defaultTextSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildCloseButton(BuildContext context) {
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
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: getApparatusColor(skill.apparatus),
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 16.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
              ),
            ),
            child: Text(
              'إغلاق',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Helper Methods
  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  static void show(BuildContext context, SkillTemplate skill) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => SkillDetailSheet(skill: skill),
    );
  }
}