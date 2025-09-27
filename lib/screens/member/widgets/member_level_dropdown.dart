import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';

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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'المستوى',
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: ColorsManager.defaultText,
          ),
        ),

        SizedBox(height: SizeApp.s8),

        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: SizeApp.s16),
          decoration: BoxDecoration(
            color: ColorsManager.backgroundSurface,
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
            border: Border.all(
              color: ColorsManager.inputBorder.withOpacity(0.5),
              width: 1,
            ),
          ),
          child: DropdownButton<String>(
            value: selectedLevel,
            isExpanded: true,
            underline: const SizedBox.shrink(),
            style: TextStyle(
              fontSize: 16.sp,
              color: ColorsManager.defaultText,
            ),
            items: levels.map((level) {
              return DropdownMenuItem<String>(
                value: level,
                child: Row(
                  children: [
                    Container(
                      width: 8.w,
                      height: 8.h,
                      decoration: BoxDecoration(
                        color: _getLevelColor(level),
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: SizeApp.s12),
                    Text(level),
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

  Color _getLevelColor(String level) {
    switch (level) {
      case 'مبتدئ':
        return ColorsManager.infoFill;
      case 'متوسط':
        return ColorsManager.warningFill;
      case 'متقدم':
        return ColorsManager.successFill;
      case 'محترف':
        return ColorsManager.primaryColor;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }
}
