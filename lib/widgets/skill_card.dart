import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/screens/library/add_skill_screen.dart';
import 'dart:io';
import '../data/models/skill_template.dart';


class SkillCard extends StatelessWidget {
  final SkillTemplate skill;

  const SkillCard({super.key, required this.skill});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AddSkillScreen(skillToEdit: skill),
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Row(
            children: [
              // Thumbnail or Icon
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.r),
                  color: skill.thumbnailPath != null
                      ? null
                      : _getApparatusColor(skill.apparatus).withOpacity(0.1),
                  image: (skill.thumbnailPath != null && File(skill.thumbnailPath!).existsSync())
                      ? DecorationImage(
                    image: FileImage(File(skill.thumbnailPath!)),
                    fit: BoxFit.cover,
                  )
                      : null,
                ),
                child: skill.thumbnailPath == null
                    ? Icon(
                  _getApparatusIcon(skill.apparatus),
                  color: _getApparatusColor(skill.apparatus),
                  size: 28.sp,
                )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      skill.skillName,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF2C3E50),
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: _getApparatusColor(skill.apparatus).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        skill.apparatus.arabicName,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: _getApparatusColor(skill.apparatus),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (skill.assignedTeamsCount > 0) ...[
                      SizedBox(height: 4.h),
                      Text(
                        'معين إلى ${skill.assignedTeamsCount} فريق',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              // Media Count Badge
              if (skill.mediaGallery.isNotEmpty)
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.w,
                    vertical: 4.h,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.photo_library,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        '${skill.mediaGallery.length}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getApparatusColor(Apparatus apparatus) {
    switch (apparatus) {
      case Apparatus.floor:
        return Colors.green;
      case Apparatus.beam:
        return Colors.orange;
      case Apparatus.bars:
        return Colors.blue;
      case Apparatus.vault:
        return Colors.purple;
    }
  }

  IconData _getApparatusIcon(Apparatus apparatus) {
    switch (apparatus) {
      case Apparatus.floor:
        return Icons.sports_gymnastics;
      case Apparatus.beam:
        return Icons.linear_scale;
      case Apparatus.bars:
        return Icons.fitness_center;
      case Apparatus.vault:
        return Icons.directions_run;
    }
  }
}