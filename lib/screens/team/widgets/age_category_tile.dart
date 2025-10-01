import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';

class AgeCategoryTile extends StatelessWidget {
  final AgeCategory category;
  final AgeCategory? selectedCategory;
  final Function(AgeCategory?) onChanged;
  final bool showCode;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? contentPadding;
  final double? borderRadius;
  final Color? selectedColor;
  final Color? unselectedColor;
  final Color? selectedBorderColor;
  final Color? unselectedBorderColor;
  final double? selectedBorderWidth;
  final double? unselectedBorderWidth;
  final TextStyle? titleStyle;
  final TextStyle? codeStyle;
  final bool showShadow;
  final ListTileControlAffinity controlAffinity;

  const AgeCategoryTile({
    super.key,
    required this.category,
    required this.selectedCategory,
    required this.onChanged,
    this.showCode = true,
    this.margin,
    this.contentPadding,
    this.borderRadius,
    this.selectedColor,
    this.unselectedColor,
    this.selectedBorderColor,
    this.unselectedBorderColor,
    this.selectedBorderWidth,
    this.unselectedBorderWidth,
    this.titleStyle,
    this.codeStyle,
    this.showShadow = true,
    this.controlAffinity = ListTileControlAffinity.trailing,
  });

  bool get isSelected => selectedCategory == category;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: SizeApp.s8),
      decoration: BoxDecoration(
        color: isSelected
            ? (selectedColor ?? theme.primaryColor.withOpacity(0.1))
            : (unselectedColor ?? theme.cardColor),
        borderRadius: BorderRadius.circular(
          borderRadius ?? SizeApp.radiusMed,
        ),
        border: Border.all(
          color: isSelected
              ? (selectedBorderColor ?? theme.primaryColor)
              : (unselectedBorderColor ?? theme.dividerColor.withOpacity(0.3)),
          width: isSelected
              ? (selectedBorderWidth ?? 2)
              : (unselectedBorderWidth ?? 1),
        ),
        boxShadow: (showShadow && isSelected)
            ? [
          BoxShadow(
            color: theme.primaryColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: RadioListTile<AgeCategory>(
        value: category,
        groupValue: selectedCategory,
        onChanged: onChanged,
        contentPadding: contentPadding ?? EdgeInsets.symmetric(
          horizontal: SizeApp.s16,
          vertical: SizeApp.s4,
        ),
        title: Text(
          category.getLocalizedName(context),
          style: titleStyle ?? _buildTitleStyle(theme),
        ),
        subtitle: showCode ? _buildCodeWidget(theme) : null,
        activeColor: selectedBorderColor ?? theme.primaryColor,
        controlAffinity: controlAffinity,
      ),
    );
  }

  TextStyle _buildTitleStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 16.sp,
      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
      color: isSelected
          ? (selectedBorderColor ?? theme.primaryColor)
          : theme.textTheme.bodyLarge?.color,
    );
  }

  Widget _buildCodeWidget(ThemeData theme) {
    return Container(
      margin: EdgeInsets.only(top: 4.h),
      padding: EdgeInsets.symmetric(
        horizontal: SizeApp.s8,
        vertical: 2.h,
      ),
      decoration: BoxDecoration(
        color: isSelected
            ? (selectedBorderColor ?? theme.primaryColor).withOpacity(0.1)
            : theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Text(
        category.code,
        style: codeStyle ?? _buildCodeStyle(theme),
      ),
    );
  }

  TextStyle _buildCodeStyle(ThemeData theme) {
    return TextStyle(
      fontSize: 12.sp,
      color: isSelected
          ? (selectedBorderColor ?? theme.primaryColor)
          : theme.textTheme.bodySmall?.color,
      fontWeight: FontWeight.w500,
    );
  }
}

class AgeCategoryGrid extends StatelessWidget {
  final AgeCategory? selectedCategory;
  final Function(AgeCategory?) onChanged;
  final List<AgeCategory>? categories;
  final String? title;
  final bool showTitle;
  final bool showCode;
  final int crossAxisCount;
  final double? childAspectRatio;
  final double mainAxisSpacing;
  final double crossAxisSpacing;
  final EdgeInsetsGeometry? padding;

  const AgeCategoryGrid({
    super.key,
    required this.selectedCategory,
    required this.onChanged,
    this.categories,
    this.title,
    this.showTitle = true,
    this.showCode = true,
    this.crossAxisCount = 2,
    this.childAspectRatio,
    this.mainAxisSpacing = 8.0,
    this.crossAxisSpacing = 8.0,
    this.padding,
  });

  List<AgeCategory> get _categories => categories ?? AgeCategory.values;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          if (showTitle) ...[
            Row(
              children: [
                Icon(
                  Icons.cake_outlined,
                  color: theme.primaryColor,
                  size: 16.sp,
                ),
                SizedBox(width: SizeApp.s6),
                Text(
                  title ?? l10n.ageCategoryTitle,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            SizedBox(height: SizeApp.s8),
          ],

          // Grid
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              childAspectRatio: childAspectRatio ?? 3.5,
              mainAxisSpacing: mainAxisSpacing,
              crossAxisSpacing: crossAxisSpacing,
            ),
            itemCount: _categories.length,
            itemBuilder: (context, index) {
              final category = _categories[index];
              final isSelected = selectedCategory == category;

              return InkWell(
                onTap: () => onChanged(category),
                borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.primaryColor
                        : theme.cardColor,
                    borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                    border: Border.all(
                      color: isSelected
                          ? theme.primaryColor
                          : theme.dividerColor.withOpacity(0.3),
                    ),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: theme.primaryColor.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        category.getLocalizedName(context),
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : theme.textTheme.bodyLarge?.color,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      if (showCode) ...[
                        SizedBox(height: 2.h),
                        Text(
                          category.code,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: isSelected
                                ? Colors.white.withOpacity(0.8)
                                : theme.textTheme.bodySmall?.color,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}