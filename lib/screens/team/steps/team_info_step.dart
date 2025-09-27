import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';
import 'package:itqan_gym/screens/team/widgets/age_category_tile.dart';
import 'package:itqan_gym/screens/team/widgets/step_header.dart';

class TeamInfoStep extends StatefulWidget {
  final String teamName;
  final AgeCategory? selectedAgeCategory;
  final Function(String) onTeamNameChanged;
  final Function(AgeCategory?) onAgeCategoryChanged;

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
  AgeCategory? _currentAgeCategory;
  late TextEditingController _teamNameController;

  @override
  void initState() {
    super.initState();
    _currentAgeCategory = widget.selectedAgeCategory;
    _teamNameController = TextEditingController(text: widget.teamName);
  }

  @override
  void didUpdateWidget(covariant TeamInfoStep oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedAgeCategory != widget.selectedAgeCategory) {
      _currentAgeCategory = widget.selectedAgeCategory;
    }
    if (oldWidget.teamName != widget.teamName) {
      _teamNameController.text = widget.teamName;
    }
  }

  @override
  void dispose() {
    _teamNameController.dispose();
    super.dispose();
  }

  void _onAgeCategoryChanged(AgeCategory? category) {
    setState(() {
      _currentAgeCategory = category;
    });
    widget.onAgeCategoryChanged(category);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Section
          const StepHeader(
            title: 'معلومات الفريق',
            subtitle: 'أدخل اسم الفريق واختر الفئة العمرية',
          ),
          Padding(
            padding: EdgeInsets.all(SizeApp.padding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Team Name Field
                AppTextField(
                  controller: _teamNameController,
                  hintText: 'مثال: نجوم الجمباز',
                  title: 'اسم الفريق',
                  prefixIcon: Icon(
                    Icons.groups_rounded,
                    color: ColorsManager.primaryColor,
                    size: SizeApp.iconSize,
                  ),
                  onChanged: widget.onTeamNameChanged,
                  titleStyle: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: ColorsManager.defaultText,
                  ),
                ),

                SizedBox(height: SizeApp.s24),

                // Age Category Section
                _buildAgeCategorySection(),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildAgeCategorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AgeCategoryGrid(
          selectedCategory: _currentAgeCategory,
          onChanged: _onAgeCategoryChanged,
        )

        // Age Categories List
        // ...AgeCategory.values
        //     .map((category) => AgeCategoryTile(
        //   category: category,
        //   selectedCategory: _currentAgeCategory,
        //   onChanged: _onAgeCategoryChanged,
        // )),
      ],
    );
  }


}

