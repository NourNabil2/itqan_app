import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/enums.dart';

class TeamInfoStep extends StatefulWidget {
  final String teamName;
  final AgeCategory? selectedAgeCategory;              // قيمة ابتدائية من الأب
  final Function(String) onTeamNameChanged;
  final Function(AgeCategory?) onAgeCategoryChanged;   // نبلغ الأب بالتغيير

  const TeamInfoStep({
    super.key,
    required this.teamName,
    required this.selectedAgeCategory,
    required this.onTeamNameChanged,
    required this.onAgeCategoryChanged,
  });

  @override
  State<TeamInfoStep> createState() => _TeamInfoStepState();
}

class _TeamInfoStepState extends State<TeamInfoStep> {
  AgeCategory? _current; // الحالة المحلية

  @override
  void initState() {
    super.initState();
    _current = widget.selectedAgeCategory;
  }

  // لو الأب غيّر القيمة من برّه (مثلاً رجع خطوة للخلف)، نزامن الحالة المحلية
  @override
  void didUpdateWidget(covariant TeamInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAgeCategory != widget.selectedAgeCategory) {
      _current = widget.selectedAgeCategory;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'معلومات الفريق',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2C3E50),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'أدخل اسم الفريق واختر الفئة العمرية',
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
          SizedBox(height: 32.h),

          // Team Name
          Text('اسم الفريق',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          SizedBox(height: 8.h),
          TextFormField(
            initialValue: widget.teamName,
            onChanged: widget.onTeamNameChanged,
            decoration: const InputDecoration(hintText: 'مثال: نجوم الجمباز'),
          ),
          SizedBox(height: 24.h),

          // Age Category
          Text('الفئة العمرية',
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[700])),
          SizedBox(height: 8.h),

          ...AgeCategory.values.map((category) {
            final isSelected = _current == category;
            return Container(
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFF2196F3).withOpacity(0.1) : Colors.white,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(
                  color: isSelected ? const Color(0xFF2196F3) : Colors.grey[300]!,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: RadioListTile<AgeCategory>(
                value: category,
                groupValue: _current,
                onChanged: (v) {
                  setState(() => _current = v);     // يحدّث الـ UI فورًا
                  widget.onAgeCategoryChanged(v);    // يبلّغ الأب
                },
                title: Text(
                  category.arabicName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    color: isSelected ? const Color(0xFF2196F3) : Colors.black,
                  ),
                ),
                subtitle: Text(category.code, style: TextStyle(fontSize: 12.sp, color: Colors.grey[600])),
                activeColor: const Color(0xFF2196F3),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
