import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';

/// Level Selection Dropdown
class MemberLevelDropdown extends StatelessWidget {
  final String selectedLevel;
  final Function(String) onLevelChanged;
  final List<String> levels;

  const MemberLevelDropdown({
    super.key,
    required this.selectedLevel,
    required this.onLevelChanged,
    this.levels = const ['مبتدئ', 'متوسط', 'متقدم', 'محترف'],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.level,
          style: theme.textTheme.labelLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: colorScheme.outline.withOpacity(0.5),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: colorScheme.onSurface.withOpacity(0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: DropdownButton<String>(
            value: selectedLevel,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 16.sp,
              color: colorScheme.onSurface,
            ),
            dropdownColor: colorScheme.surfaceContainerHighest,
            icon: Icon(Icons.arrow_drop_down_rounded, color: colorScheme.onSurfaceVariant),
            items: levels.map((level) {
              return DropdownMenuItem<String>(
                value: level,
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _getLevelColor(level, colorScheme),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Text(
                      level,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) {
                onLevelChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  Color _getLevelColor(String level, ColorScheme colorScheme) {
    switch (level) {
      case 'مبتدئ':
        return colorScheme.secondary;
      case 'متوسط':
        return colorScheme.tertiary;
      case 'متقدم':
        return colorScheme.primary;
      case 'محترف':
        return colorScheme.onSecondary;
      default:
        return colorScheme.onSurfaceVariant;
    }
  }
}