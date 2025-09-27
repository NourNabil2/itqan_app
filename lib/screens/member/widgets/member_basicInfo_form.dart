import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';

import 'member_level_dropdown.dart';

/// Member Basic Info Form
class MemberBasicInfoForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final String selectedLevel;
  final Function(String) onLevelChanged;

  const MemberBasicInfoForm({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.selectedLevel,
    required this.onLevelChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Name Field
        AppTextField(
          controller: nameController,
          hintText: 'أدخل اسم العضو',
          title: 'الاسم',
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'الرجاء إدخال اسم العضو';
            }
            if (value.trim().length < 2) {
              return 'الاسم يجب أن يحتوي على حرفين على الأقل';
            }
            return null;
          },
        ),

        SizedBox(height: SizeApp.s16),

        // Age Field
        AppTextFieldFactory.number(
          controller: ageController,
          hintText: 'أدخل عمر العضو',
          title: 'العمر',
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال عمر العضو';
            }
            final age = int.tryParse(value);
            if (age == null) {
              return 'الرجاء إدخال رقم صحيح';
            }
            if (age < 3 || age > 25) {
              return 'العمر يجب أن يكون بين 3 و 25 سنة';
            }
            return null;
          },
        ),

        SizedBox(height: SizeApp.s16),

        // Level Dropdown
        MemberLevelDropdown(
          selectedLevel: selectedLevel,
          onLevelChanged: onLevelChanged,
        ),
      ],
    );
  }
}
