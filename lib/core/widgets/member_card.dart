import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import '../../data/models/member/member.dart';
import '../../screens/member/member_details/member_detail_screen.dart';

class MemberCard extends StatefulWidget {
  final Member member;

  const MemberCard({super.key, required this.member});

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MemberDetailScreen(member: widget.member),
                ),
              );
            },
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              margin: EdgeInsets.only(bottom: SizeApp.s16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? ColorsManager.secondaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: _isPressed ? 20 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: _isPressed ? 1 : 0,
                  ),
                ],
                border: Border.all(
                  color: _isPressed
                      ? ColorsManager.secondaryColor.withOpacity(0.4)
                      : Colors.transparent,
                  width: 2,
                ),
              ),
              child: Column(
                children: [
                  // Header Section مع الصورة والاسم
                  Container(
                    padding: EdgeInsets.all(SizeApp.s16),
                    child: Row(
                      children: [
                        // صورة العضو
                        Hero(
                          tag: 'member_avatar_${widget.member.id}',
                          child: Container(
                            width: isSmallScreen ? 60.w : 70.w,
                            height: isSmallScreen ? 60.h : 70.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(SizeApp.radiusMed),
                              color: widget.member.photoPath == null
                                  ? ColorsManager.secondaryColor.withOpacity(0.15)
                                  : null,
                              image: widget.member.photoPath != null
                                  ? DecorationImage(
                                image: FileImage(File(widget.member.photoPath!)),
                                fit: BoxFit.cover,
                              )
                                  : null,
                              border: Border.all(
                                color: ColorsManager.secondaryColor.withOpacity(0.2),
                                width: 2,
                              ),
                            ),
                            child: widget.member.photoPath == null
                                ? Center(
                              child: Text(
                                widget.member.name[0].toUpperCase(),
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 24.sp : 28.sp,
                                  fontWeight: FontWeight.w700,
                                  color: ColorsManager.secondaryColor,
                                ),
                              ),
                            )
                                : null,
                          ),
                        ),

                        SizedBox(width: SizeApp.s16),

                        // معلومات العضو الأساسية
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.member.name,
                                style: TextStyle(
                                  fontSize: isSmallScreen ? 18.sp : 20.sp,
                                  fontWeight: FontWeight.w700,
                                  color: ColorsManager.defaultText,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),

                              SizedBox(height: 6.h),

                              // صف العمر والمستوى
                              Row(
                                children: [
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: ColorsManager.infoSurface,
                                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.cake_outlined,
                                          size: 12.sp,
                                          color: ColorsManager.infoText,
                                        ),
                                        SizedBox(width: 4.w),
                                        Text(
                                          '${widget.member.age}',
                                          style: TextStyle(
                                            fontSize: 11.sp,
                                            fontWeight: FontWeight.w600,
                                            color: ColorsManager.infoText,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),

                                  SizedBox(width: 8.w),

                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getLevelColor(widget.member.level).withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
                                    ),
                                    child: Text(
                                      widget.member.level,
                                      style: TextStyle(
                                        fontSize: 11.sp,
                                        fontWeight: FontWeight.w600,
                                        color: _getLevelColor(widget.member.level),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        // معدل التقدم الإجمالي
                        // Column(
                        //   children: [
                        //     Container(
                        //       width: 50.w,
                        //       height: 50.h,
                        //       decoration: BoxDecoration(
                        //         color: _getProgressColor(widget.member.overallProgress).withOpacity(0.1),
                        //         borderRadius: BorderRadius.circular(SizeApp.s12),
                        //         border: Border.all(
                        //           color: _getProgressColor(widget.member.overallProgress).withOpacity(0.3),
                        //           width: 2,
                        //         ),
                        //       ),
                        //       child: Stack(
                        //         alignment: Alignment.center,
                        //         children: [
                        //           SizedBox(
                        //             width: 35.w,
                        //             height: 35.h,
                        //             child: CircularProgressIndicator(
                        //               value: widget.member.overallProgress / 100,
                        //               strokeWidth: 3,
                        //               backgroundColor: _getProgressColor(widget.member.overallProgress).withOpacity(0.2),
                        //               valueColor: AlwaysStoppedAnimation<Color>(
                        //                 _getProgressColor(widget.member.overallProgress),
                        //               ),
                        //               strokeCap: StrokeCap.round,
                        //             ),
                        //           ),
                        //           Text(
                        //             '${widget.member.overallProgress.toInt()}%',
                        //             style: TextStyle(
                        //               fontSize: 10.sp,
                        //               fontWeight: FontWeight.w700,
                        //               color: _getProgressColor(widget.member.overallProgress),
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     SizedBox(height: 4.h),
                        //     Text(
                        //       'التقدم',
                        //       style: TextStyle(
                        //         fontSize: 9.sp,
                        //         fontWeight: FontWeight.w500,
                        //         color: ColorsManager.defaultTextSecondary,
                        //       ),
                        //     ),
                        //   ],
                        // ),
                      ],
                    ),
                  ),

                  // Divider خفيف
                  Container(
                    height: 1,
                    margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
                    color: ColorsManager.inputBorder.withOpacity(0.1),
                  ),

                  // Bottom Section - Quick Stats
                  Container(
                    padding: EdgeInsets.all(SizeApp.s16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildStatItem(
                            'الحضور',
                            '${(widget.member.overallProgress ?? 0 * 0.8).toInt()}%',
                            Icons.calendar_today_outlined,
                            ColorsManager.successFill,
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 40.h,
                          color: ColorsManager.inputBorder.withOpacity(0.2),
                        ),

                        Expanded(
                          child: _buildStatItem(
                            'الأداء',
                            '${(widget.member.overallProgress ?? 0 * 0.9).toInt()}%',
                            Icons.trending_up_rounded,
                            ColorsManager.warningFill,
                          ),
                        ),

                        Container(
                          width: 1,
                          height: 40.h,
                          color: ColorsManager.inputBorder.withOpacity(0.2),
                        ),

                        Expanded(
                          child: _buildStatItem(
                            'النشاط',
                            '${widget.member.overallProgress?? 0.toInt()}%',
                            Icons.fitness_center_outlined,
                            ColorsManager.primaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
          ),
          child: Icon(
            icon,
            size: 16.sp,
            color: color,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          value,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          title,
          style: TextStyle(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
            color: ColorsManager.defaultTextSecondary,
          ),
        ),
      ],
    );
  }

  Color _getProgressColor(double progress) {
    if (progress >= 80) return ColorsManager.successFill;
    if (progress >= 60) return ColorsManager.primaryColor;
    if (progress >= 40) return ColorsManager.warningFill;
    return ColorsManager.errorFill;
  }

  Color _getLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'مبتدئ':
        return ColorsManager.infoFill;
      case 'intermediate':
      case 'متوسط':
        return ColorsManager.warningFill;
      case 'advanced':
      case 'متقدم':
        return ColorsManager.successFill;
      case 'expert':
      case 'خبير':
        return ColorsManager.primaryColor;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }
}