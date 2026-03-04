// lib/core/widgets/skill_card.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/skill_template.dart';

class SkillCard extends StatelessWidget {
  final SkillTemplate skill;
  final VoidCallback? onTap;
  final bool showSystemBadge; // ✅ إظهار علامة المهارة الجاهزة

  const SkillCard({
    super.key,
    required this.skill,
    this.onTap,
    this.showSystemBadge = true, // ✅
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final apparatusColor = getApparatusColor(skill.apparatus);

    return RepaintBoundary(
      key: ValueKey('skill_${skill.id}'),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: skill.isSystem
                ? colorScheme.surfaceContainerHighest.withOpacity(0.5) // ✅ لون مميز للجاهزة
                : theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: skill.isSystem
                  ? apparatusColor.withOpacity(0.5) // ✅ حدود أقوى للجاهزة
                  : theme.dividerColor.withOpacity(0.35),
              width: skill.isSystem ? 1.5 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12.r),
            onTap: onTap,
            child: Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Thumbnail مع دعم الروابط البعيدة
                  _ThumbBox(
                    thumbnailPath: skill.thumbnailPath,
                    isNetworkUrl: skill.isSystem, // ✅
                    fallbackIcon: getApparatusIcon(skill.apparatus),
                    accent: apparatusColor,
                  ),

                  SizedBox(width: 12.w),

                  // المحتوى
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ✅ شارة المهارة الجاهزة
                        if (skill.isSystem && showSystemBadge) ...[
                          _SystemBadge(),
                          SizedBox(height: 4.h),
                        ],

                        // Title
                        Text(
                          skill.skillName,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: skill.isSystem
                                ? colorScheme.primary
                                : colorScheme.onSurface,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Apparatus badge + Difficulty
                        Wrap(
                          spacing: 6.w,
                          children: [
                            _Badge(
                              text: skill.apparatus.getLocalizedName(context),
                              color: apparatusColor,
                            ),
                            if (skill.difficultyLevel != null) ...[
                              _Badge(
                                text: _getDifficultyText(skill.difficultyLevel!),
                                color: _getDifficultyColor(skill.difficultyLevel!),
                              ),
                            ],
                          ],
                        ),

                        // Assigned info (للمحلية فقط)
                        if (!skill.isSystem && skill.assignedTeamsCount > 0) ...[
                          SizedBox(height: 6.h),
                          Text(
                            'معيّن إلى ${skill.assignedTeamsCount} فريق',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],

                        // ✅ وصف مختصر للمهارة الجاهزة
                        if (skill.isSystem && skill.description != null) ...[
                          SizedBox(height: 6.h),
                          Text(
                            skill.description!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // ✅ أيقونة الفيديو للمهارات الجاهزة
                  if (skill.isSystem && skill.videoUrl != null) ...[
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.play_circle_fill_rounded,
                        color: Colors.red,
                        size: 24.sp,
                      ),
                    ),
                  ],

                  // Media counter
                  if (skill.mediaGallery.isNotEmpty) ...[
                    SizedBox(width: 8.w),
                    _MediaChip(count: skill.mediaGallery.length),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _getDifficultyText(String level) {
    switch (level) {
      case 'beginner':
        return 'مبتدئ';
      case 'intermediate':
        return 'متوسط';
      case 'advanced':
        return 'متقدم';
      default:
        return level;
    }
  }

  Color _getDifficultyColor(String level) {
    switch (level) {
      case 'beginner':
        return Colors.green;
      case 'intermediate':
        return Colors.orange;
      case 'advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

// ✅ شارة المهارة الجاهزة
class _SystemBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_rounded,
            size: 12.sp,
            color: Colors.blue,
          ),
          SizedBox(width: 4.w),
          Text(
            'مهارة مرجعية',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.blue,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ThumbBox extends StatelessWidget {
  final String? thumbnailPath;
  final bool isNetworkUrl; // ✅
  final IconData fallbackIcon;
  final Color accent;

  const _ThumbBox({
    required this.thumbnailPath,
    this.isNetworkUrl = false, // ✅
    required this.fallbackIcon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final size = 60.w;
    final radius = 10.r;
    final hasPath = (thumbnailPath ?? '').trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: hasPath ? null : accent.withOpacity(0.1),
          border: Border.all(
            color: accent.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(radius),
        ),
        child: hasPath
            ? isNetworkUrl
            ? Image.network( // ✅ للروابط البعيدة
          thumbnailPath!,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (_, __, ___) =>
              _FallbackIcon(icon: fallbackIcon, color: accent),
        )
            : Image.file( // للملفات المحلية
          File(thumbnailPath!),
          fit: BoxFit.cover,
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) =>
              _FallbackIcon(icon: fallbackIcon, color: accent),
        )
            : _FallbackIcon(icon: fallbackIcon, color: accent),
      ),
    );
  }
}

class _FallbackIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FallbackIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(icon, color: color, size: 28.sp),
    );
  }
}

class _Badge extends StatelessWidget {
  final String text;
  final Color color;

  const _Badge({required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withOpacity(0.22), width: 1),
      ),
      child: Text(
        text,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MediaChip extends StatelessWidget {
  final int count;
  const _MediaChip({required this.count});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.photo_library_rounded, size: 14.sp, color: color),
          SizedBox(width: 4.w),
          Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}