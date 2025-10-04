import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/skill_template.dart';

class SkillCard extends StatelessWidget {
  final SkillTemplate skill;
  final VoidCallback? onTap;

  const SkillCard({
    super.key,
    required this.skill,
    this.onTap,
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
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: theme.dividerColor.withOpacity(0.35),
              width: 1,
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
                  // Thumbnail / Fallback Icon
                  _ThumbBox(
                    thumbnailPath: skill.thumbnailPath,
                    fallbackIcon: getApparatusIcon(skill.apparatus),
                    accent: apparatusColor,
                  ),

                  SizedBox(width: 12.w),

                  // Title + Badge + Assigned count
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title
                        Text(
                          skill.skillName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        SizedBox(height: 6.h),

                        // Apparatus badge
                        _Badge(
                          text: skill.apparatus.getLocalizedName(context),
                          color: apparatusColor,
                        ),

                        // Assigned info
                        if (skill.assignedTeamsCount > 0) ...[
                          SizedBox(height: 6.h),
                          Text(
                            'معيَّن إلى ${skill.assignedTeamsCount} فريق',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.green[700],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Media counter (if any)
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
}

/// صورة مصغّرة مع Fallback أيقونة — بدون IO متزامن داخل build
class _ThumbBox extends StatelessWidget {
  final String? thumbnailPath;
  final IconData fallbackIcon;
  final Color accent;

  const _ThumbBox({
    required this.thumbnailPath,
    required this.fallbackIcon,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final size = 60.w; // مربع متناسق
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
            ? Image.file(
          File(thumbnailPath!),
          fit: BoxFit.cover,
          // أقل تكلفة جودة/ذاكرة للثَمبنيل
          filterQuality: FilterQuality.low,
          errorBuilder: (_, __, ___) => _FallbackIcon(icon: fallbackIcon, color: accent),
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
