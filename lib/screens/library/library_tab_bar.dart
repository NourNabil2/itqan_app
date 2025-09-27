// ============= Library Custom Widgets - مكونات مخصصة للمكتبة =============
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/utils/enums.dart';
import 'package:itqan_gym/core/widgets/app_text_feild.dart';

/// ✅ Library Tab Bar - شريط تبويب المكتبة
class LibraryTabBar extends StatelessWidget {
  final TabController controller;
  final Function(int) onTap;
  final List<LibraryTab> tabs;

  const LibraryTabBar({
    super.key,
    required this.controller,
    required this.onTap,
    required this.tabs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        labelColor: ColorsManager.primaryColor,
        unselectedLabelColor: ColorsManager.defaultTextSecondary,
        indicatorColor: ColorsManager.primaryColor,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
        ),
        tabs: tabs.map((tab) => Tab(
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                tab.icon,
                size: 18.sp,
              ),
              SizedBox(width: SizeApp.s6),
              Text(tab.title),
            ],
          ),
        )).toList(),
        onTap: onTap,
      ),
    );
  }
}

/// ✅ Library Tab Data
class LibraryTab {
  final String title;
  final IconData icon;
  final ExerciseType? exerciseType;

  const LibraryTab({
    required this.title,
    required this.icon,
    this.exerciseType,
  });
}

/// ✅ Library Add Button - زر الإضافة
class LibraryAddButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;
  final bool isOutlined;
  final Color? color;
  final EdgeInsetsGeometry? margin;

  const LibraryAddButton({
    super.key,
    required this.onPressed,
    this.text = 'إنشاء جديد',
    this.icon = Icons.add_rounded,
    this.isOutlined = true,
    this.color,
    this.margin,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? ColorsManager.primaryColor;

    return Container(
      margin: margin ?? EdgeInsets.only(bottom: SizeApp.s16),
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: SizeApp.iconSize),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          foregroundColor: buttonColor,
          side: BorderSide(
            color: buttonColor,
            width: 2,
          ),
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          ),
        ),
      )
          : ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: SizeApp.iconSize),
        label: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 16.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          ),
        ),
      ),
    );
  }
}

/// ✅ Library Empty State - حالة عدم وجود عناصر
class LibraryEmptyState extends StatelessWidget {
  final String category;
  final String? message;
  final IconData? icon;
  final VoidCallback? onAddPressed;
  final String? addButtonText;
  final Color? iconColor;
  final Color? textColor;

  const LibraryEmptyState({
    super.key,
    required this.category,
    this.message,
    this.icon,
    this.onAddPressed,
    this.addButtonText,
    this.iconColor,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(SizeApp.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty Icon
            Container(
              padding: EdgeInsets.all(SizeApp.s24),
              decoration: BoxDecoration(
                color: (iconColor ?? ColorsManager.defaultTextSecondary).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon ?? Icons.folder_open_rounded,
                size: 64.sp,
                color: iconColor ?? ColorsManager.defaultTextSecondary.withOpacity(0.5),
              ),
            ),

            SizedBox(height: SizeApp.s24),

            // Title
            Text(
              message ?? 'لا توجد عناصر في $category',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: textColor ?? ColorsManager.defaultText,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: SizeApp.s8),

            // Subtitle
            Text(
              'ابدأ بإضافة العناصر لتظهر هنا',
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            SizedBox(height: SizeApp.s32),

            // Add Button
            if (onAddPressed != null)
              LibraryAddButton(
                onPressed: onAddPressed!,
                text: addButtonText ?? 'إضافة أول عنصر',
                isOutlined: false,
              ),
          ],
        ),
      ),
    );
  }
}

/// ✅ Library Search Header - رأس البحث
class LibrarySearchHeader extends StatelessWidget {
  final TextEditingController controller;
  final Function(String) onChanged;
  final String hintText;
  final EdgeInsetsGeometry? padding;

  const LibrarySearchHeader({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'البحث في المكتبة...',
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: padding ?? EdgeInsets.fromLTRB(
        SizeApp.s16,
        SizeApp.s20,
        SizeApp.s16,
        SizeApp.s16,
      ),
      child: AppTextFieldFactory.search(
        controller: controller,
        hintText: hintText,
        fillColor: ColorsManager.backgroundCard,
        focusedFillColor: ColorsManager.backgroundCard,
        onChanged: onChanged,
      ),
    );
  }
}

/// ✅ Library Section Header - رأس القسم
class LibrarySectionHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData? icon;
  final Color? iconColor;
  final Widget? trailing;
  final EdgeInsetsGeometry? padding;

  const LibrarySectionHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.iconColor,
    this.trailing,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? EdgeInsets.all(SizeApp.s16),
      color: Colors.white,
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: EdgeInsets.all(SizeApp.s8),
              decoration: BoxDecoration(
                color: (iconColor ?? ColorsManager.primaryColor).withOpacity(0.1),
                borderRadius: BorderRadius.circular(SizeApp.s8),
              ),
              child: Icon(
                icon,
                color: iconColor ?? ColorsManager.primaryColor,
                size: SizeApp.iconSize,
              ),
            ),
            SizedBox(width: SizeApp.s12),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w700,
                    color: ColorsManager.defaultText,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: ColorsManager.defaultTextSecondary,
                    ),
                  ),
                ],
              ],
            ),
          ),

          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

/// ✅ Library List Container - حاوية القائمة
class LibraryListContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final bool addBackground;

  const LibraryListContainer({
    super.key,
    required this.child,
    this.padding,
    this.addBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    Widget content = Padding(
      padding: padding ?? EdgeInsets.all(SizeApp.s16),
      child: child,
    );

    if (addBackground) {
      content = Container(
        color: ColorsManager.backgroundSurface,
        child: content,
      );
    }

    return content;
  }
}

/// ✅ Library Stats Card - بطاقة الإحصائيات
class LibraryStatsCard extends StatelessWidget {
  final String title;
  final int count;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const LibraryStatsCard({
    super.key,
    required this.title,
    required this.count,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(SizeApp.radiusMed),
      child: Container(
        padding: EdgeInsets.all(SizeApp.s16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          border: Border.all(
            color: color.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(SizeApp.s8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(SizeApp.s8),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 20.sp,
                  ),
                ),
                Text(
                  '$count',
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),

            SizedBox(height: SizeApp.s8),

            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
          ],
        ),
      ),
    );
  }
}