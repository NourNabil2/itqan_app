import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';

class LogoBoxHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final String assetLogo; // مسار لوجو التطبيق

  const LogoBoxHeader({
    super.key,
    required this.title,
    this.subtitle,
    required this.assetLogo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: EdgeInsets.symmetric(vertical: SizeApp.padding * 2, horizontal: SizeApp.padding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(
            assetLogo,
            width: 80.w,
            height: 80.w,
            fit: BoxFit.contain,
          ),
          SizedBox(height: SizeApp.padding),
          Column(
           mainAxisAlignment: MainAxisAlignment.start,
           crossAxisAlignment: CrossAxisAlignment.start,
           children: [
             Text(
               title,
               style: Theme.of(context).textTheme.titleLarge!.copyWith(
                 color: ColorsManager.primaryColor,
                 fontWeight: FontWeight.bold
               ),
               textAlign: TextAlign.center,
             ),
             if (subtitle != null && subtitle!.isNotEmpty) ...[
               SizedBox(height: 6.h),
               Text(
                 subtitle!,
                 style: Theme.of(context).textTheme.labelMedium,
                 textAlign: TextAlign.center,
               ),
             ],
           ],
         ),
        ],
      ),
    );
  }
}
