import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/data/models/exercise_template.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseTemplate exercise;
  final VoidCallback? onTap; // ✅ أحسن من عمل Navigator جوه الكارد

  const ExerciseCard({
    super.key,
    required this.exercise,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final typeColor = _typeColor(exercise.type);
    final divider = theme.dividerColor.withOpacity(0.35);

    return RepaintBoundary(
      key: ValueKey('ex_${exercise.id}'),
      child: Material(
        color: Colors.transparent,
        child: Ink(
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: divider, width: 1),
            // ظل خفيف جداً (أرخص رسوميًا)
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
                  // Leading (نوع التمرين)
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                      color: typeColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(10.r),
                      border: Border.all(color: typeColor.withOpacity(0.22), width: 1),
                    ),
                    child: Icon(_typeIcon(exercise.type), color: typeColor, size: 22.sp),
                  ),

                  SizedBox(width: 12.w),

                  // Title + Description + Badges
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // العنوان
                        Text(
                          exercise.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textDirection: Directionality.of(context),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),

                        // الوصف (اختياري)
                        if ((exercise.description ?? '').trim().isNotEmpty) ...[
                          SizedBox(height: 4.h),
                          Text(
                            exercise.description!.trim(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.textTheme.bodySmall?.color?.withOpacity(0.8),
                              height: 1.2,
                            ),
                          ),
                        ],

                        // شارة التعيين (اختياري)
                        if (exercise.assignedTeamsCount > 0) ...[
                          SizedBox(height: 6.h),
                          _Badge(
                            text: 'معيَّن إلى ${exercise.assignedTeamsCount} فريق',
                            color: Colors.green,
                          ),
                        ],
                      ],
                    ),
                  ),

                  // Trailing (وسيط مرفق؟)
                  if (exercise.mediaPath != null) ...[
                    SizedBox(width: 8.w),
                    _MediaDot(
                      isVideo: exercise.mediaType == MediaType.video,
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _typeColor(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return const Color(0xFFFF8A00); // برتقالي دافي
      case ExerciseType.stretching:
        return const Color(0xFF3B82F6); // أزرق مريح
      case ExerciseType.conditioning:
        return const Color(0xFF8B5CF6); // بنفسجي
    }
  }

  IconData _typeIcon(ExerciseType type) {
    switch (type) {
      case ExerciseType.warmup:
        return Icons.directions_run_rounded;
      case ExerciseType.stretching:
        return Icons.self_improvement_rounded;
      case ExerciseType.conditioning:
        return Icons.fitness_center_rounded;
    }
  }
}

/// شارة صغيرة خفيفة الأداء
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
          color: color.darken(0.1),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// مؤشر وسائط بسيط بديل للأيقونة داخل دائرة
class _MediaDot extends StatelessWidget {
  final bool isVideo;
  const _MediaDot({required this.isVideo});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.onSurfaceVariant;
    return Tooltip(
      message: isVideo ? 'فيديو' : 'صورة',
      child: Container(
        width: 28.w,
        height: 28.w,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withOpacity(0.08),
          border: Border.all(color: color.withOpacity(0.25)),
        ),
        child: Icon(
          isVideo ? Icons.videocam_rounded : Icons.image_rounded,
          size: 16.sp,
          color: color,
        ),
      ),
    );
  }
}

/// امتداد بسيط لتغميق اللون
extension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final h = (hsl.lightness - amount).clamp(0.0, 1.0);
    return hsl.withLightness(h).toColor();
  }
}
