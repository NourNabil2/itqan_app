import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/member_card.dart';
import 'package:itqan_gym/providers/member_provider.dart';
import 'package:provider/provider.dart';

import 'add_member_screen.dart';

class MemberLibraryScreen extends StatefulWidget {
  const MemberLibraryScreen({super.key});

  @override
  State<MemberLibraryScreen> createState() => _MemberLibraryScreenState();
}

class _MemberLibraryScreenState extends State<MemberLibraryScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsManager.backgroundSurface,
      body: Column(
        children: [
          // Enhanced Search Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.fromLTRB(
                SizeApp.s16,
                SizeApp.s20,
                SizeApp.s16,
                SizeApp.s16
            ),
            child: Container(
              decoration: BoxDecoration(
                color: ColorsManager.defaultSurface,
                borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                border: Border.all(
                  color: ColorsManager.inputBorder.withOpacity(0.3),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: ColorsManager.defaultText,
                ),
                decoration: InputDecoration(
                  hintText: 'البحث عن عضو...',
                  hintStyle: TextStyle(
                    color: ColorsManager.defaultTextSecondary,
                    fontSize: 15.sp,
                  ),
                  prefixIcon: Container(
                    padding: EdgeInsets.all(SizeApp.s12),
                    child: Icon(
                      Icons.search_rounded,
                      color: ColorsManager.primaryColor,
                      size: SizeApp.iconSize,
                    ),
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeApp.s16,
                    vertical: SizeApp.s16,
                  ),
                ),
                onChanged: (query) {
                  Provider.of<MemberLibraryProvider>(context, listen: false)
                      .searchMembers(query);
                },
              ),
            ),
          ),

          // Enhanced Stats Section
          Container(
            margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
            padding: EdgeInsets.all(SizeApp.s16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  ColorsManager.primaryColor.withOpacity(0.08),
                  ColorsManager.primaryColor.withOpacity(0.04),
                ],
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
              ),
              borderRadius: BorderRadius.circular(SizeApp.radiusMed),
              border: Border.all(
                color: ColorsManager.primaryColor.withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Consumer<MemberLibraryProvider>(
              builder: (context, provider, child) {
                return Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(SizeApp.s10),
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(SizeApp.s10),
                      ),
                      child: Icon(
                        Icons.groups_rounded,
                        color: ColorsManager.primaryColor,
                        size: SizeApp.iconSize,
                      ),
                    ),
                    SizedBox(width: SizeApp.s12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجمالي الأعضاء',
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            '${provider.globalMembers.length} عضو نشط',
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeApp.s16,
                        vertical: SizeApp.s8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            ColorsManager.primaryColor,
                            ColorsManager.secondLightColor,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(SizeApp.s12),
                        boxShadow: [
                          BoxShadow(
                            color: ColorsManager.primaryColor.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        '${provider.globalMembers.length}',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),

          SizedBox(height: SizeApp.s16),

          // Members List
          Expanded(
            child: Consumer<MemberLibraryProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 60.w,
                          height: 60.h,
                          padding: EdgeInsets.all(SizeApp.s16),
                          decoration: BoxDecoration(
                            color: ColorsManager.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(SizeApp.radius),
                          ),
                          child: CircularProgressIndicator(
                            color: ColorsManager.primaryColor,
                            strokeWidth: 3,
                          ),
                        ),
                        SizedBox(height: SizeApp.s16),
                        Text(
                          'جاري تحميل الأعضاء...',
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: ColorsManager.defaultTextSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                if (provider.globalMembers.isEmpty) {
                  return _buildEmptyState(context);
                }

                return ListView.builder(
                  padding: EdgeInsets.fromLTRB(
                    SizeApp.s16,
                    0,
                    SizeApp.s16,
                    SizeApp.s20,
                  ),
                  itemCount: provider.globalMembers.length,
                  itemBuilder: (context, index) {
                    return MemberCard(
                      member: provider.globalMembers[index],
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(SizeApp.s32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: ColorsManager.defaultSurface,
                borderRadius: BorderRadius.circular(SizeApp.radius),
                border: Border.all(
                  color: ColorsManager.inputBorder.withOpacity(0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.people_outline_rounded,
                size: 60.sp,
                color: ColorsManager.defaultTextSecondary.withOpacity(0.6),
              ),
            ),
            SizedBox(height: SizeApp.s24),
            Text(
              'لا توجد أعضاء في المكتبة',
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultText,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              'ابدأ بإضافة أول عضو لبناء قاعدة بياناتك',
              style: TextStyle(
                fontSize: 14.sp,
                color: ColorsManager.defaultTextSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeApp.s32),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.primaryColor,
                    ColorsManager.secondLightColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AddGlobalMemberScreen(),
                      ),
                    );
                  },
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeApp.s24,
                      vertical: SizeApp.s16,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          color: Colors.white,
                          size: SizeApp.iconSize,
                        ),
                        SizedBox(width: SizeApp.s8),
                        Text(
                          'إضافة أول عضو',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}