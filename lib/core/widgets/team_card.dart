import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/CustomIcon.dart';
import 'package:provider/provider.dart';
import '../../data/models/team.dart';
import '../../providers/team_provider.dart';
import '../../screens/team/team_detailes/team_detail_screen.dart';

class TeamCard extends StatefulWidget {
  final Team team;

  const TeamCard({super.key, required this.team});

  @override
  State<TeamCard> createState() => _TeamCardState();
}

class _TeamCardState extends State<TeamCard> with SingleTickerProviderStateMixin {
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
      end: 0.98,
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

  void _handleLongPress() async {
    HapticFeedback.mediumImpact();
    final shouldDelete = await _showDeleteDialog();
    if (shouldDelete == true) {
      await _deleteTeam();
    }
  }

  Future<bool?> _showDeleteDialog() {
    return showDialog<bool>(
      context: context,
      barrierDismissible: true,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.r),
        ),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: 320.w,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: ColorsManager.errorFill.withOpacity(0.1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.r),
                    topRight: Radius.circular(16.r),
                  ),
                  border: Border(
                    bottom: BorderSide(
                      color: ColorsManager.errorFill.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48.w,
                      height: 48.h,
                      decoration: BoxDecoration(
                        color: ColorsManager.errorFill.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(
                          color: ColorsManager.errorFill.withOpacity(0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Icon(
                        Icons.delete_outline_rounded,
                        color: ColorsManager.errorFill,
                        size: 24.sp,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'تأكيد الحذف',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: ColorsManager.defaultText,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'هذا الإجراء لا يمكن التراجع عنه',
                            style: TextStyle(
                              fontSize: 13.sp,
                              color: ColorsManager.defaultTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Content Section
              Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  children: [
                    Text(
                      'هل أنت متأكد من حذف فريق "${widget.team.name}"؟',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: ColorsManager.defaultText,
                        height: 1.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    // Warning container
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(12.w),
                      decoration: BoxDecoration(
                        color: ColorsManager.warningSurface,
                        borderRadius: BorderRadius.circular(8.r),
                        border: Border.all(
                          color: ColorsManager.warningFill.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: ColorsManager.warningFill,
                            size: 18.sp,
                          ),
                          SizedBox(width: 8.w),
                          Expanded(
                            child: Text(
                              'سيتم حذف جميع البيانات المرتبطة بالفريق',
                              style: TextStyle(
                                fontSize: 13.sp,
                                color: ColorsManager.warningText,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Actions Section
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: ColorsManager.defaultSurface,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(16.r),
                    bottomRight: Radius.circular(16.r),
                  ),
                  border: Border(
                    top: BorderSide(
                      color: ColorsManager.inputBorder.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          backgroundColor: Colors.transparent,
                          foregroundColor: ColorsManager.defaultTextSecondary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                            side: BorderSide(
                              color: ColorsManager.inputBorder.withOpacity(0.5),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Text(
                          'إلغاء',
                          style: TextStyle(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorsManager.errorFill,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_rounded,
                              size: 18.sp,
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              'حذف',
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
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
  }

  Future<void> _deleteTeam() async {
    try {
      final teamProvider = Provider.of<TeamProvider>(context, listen: false);
      await teamProvider.deleteTeam(widget.team.id);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حذف الفريق بنجاح'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('خطأ في حذف الفريق: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get screen dimensions for responsive design
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
                PageRouteBuilder(
                  pageBuilder: (context, animation, secondaryAnimation) =>
                      TeamDetailScreen(team: widget.team),
                  transitionsBuilder: (context, animation, secondaryAnimation, child) {
                    return SlideTransition(
                      position: Tween<Offset>(
                        begin: const Offset(1.0, 0.0),
                        end: Offset.zero,
                      ).animate(CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeOutCubic,
                      )),
                      child: child,
                    );
                  },
                  transitionDuration: const Duration(milliseconds: 350),
                ),
              );
            },
            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            onLongPress: _handleLongPress,
            child: Container(
              margin: EdgeInsets.only(bottom: SizeApp.padding),
              constraints: BoxConstraints(
                minHeight: 110.h,
                maxHeight: 170.h,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  topRight: Radius.circular(SizeApp.radiusMed),
                  bottomRight: Radius.circular(SizeApp.radiusMed),
                ),
                color: ColorsManager.defaultSurface,
                boxShadow: [
                  BoxShadow(
                    color: _isPressed
                        ? ColorsManager.primaryColor.withOpacity(0.2)
                        : Colors.black.withOpacity(0.06),
                    blurRadius: _isPressed ? 20 : 12,
                    offset: const Offset(0, 4),
                    spreadRadius: _isPressed ? 2 : 0,
                  ),
                ],
                border: Border.all(
                  color: _isPressed
                      ? ColorsManager.primaryColor.withOpacity(0.3)
                      : ColorsManager.inputBorder.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
              child: Stack(
                children: [
                  // خط ملون على الجانب الأيسر
                  Positioned(
                    left: 0,
                    top: 0,
                    bottom: 0,
                    child: Container(
                      width: 4.w,
                      decoration: BoxDecoration(
                        color: ColorsManager.primaryColor,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(SizeApp.radiusMed),
                          bottomLeft: Radius.circular(SizeApp.radiusMed),
                        ),
                      ),
                    ),
                  ),

                  // Background decorative element - responsive size
                  if (!isSmallScreen) // Hide on very small screens
                    Positioned(
                      right: -20,
                      top: -20,
                      child: Container(
                        width: (screenWidth * 0.25).clamp(80.0, 120.0),
                        height: (screenWidth * 0.25).clamp(80.0, 120.0),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: ColorsManager.primaryColor.withOpacity(0.03),
                        ),
                      ),
                    ),

                  // المحتوى الرئيسي
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallScreen ? SizeApp.s16 : SizeApp.s20,
                      vertical: isSmallScreen ? SizeApp.s12 : SizeApp.s16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // الجزء العلوي - اسم الفريق مع badge
                        Expanded(
                          flex: 2,
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      widget.team.name,
                                      style: Theme.of(context).textTheme.titleMedium,
                                      maxLines: isSmallScreen ? 1 : 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 2.h),
                                    Text(
                                      widget.team.ageCategory.arabicName,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),

                              SizedBox(width: SizeApp.s8),

                              // Circular Progress Badge - responsive size
                              _buildCircularBadge(isSmallScreen),
                            ],
                          ),
                        ),

                        SizedBox(height: SizeApp.s8),

                        // الجزء السفلي - معلومات إضافية
                        Row(
                          children: [
                            // عدد الأعضاء
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: isSmallScreen ? SizeApp.s8 : SizeApp.s12,
                                vertical: isSmallScreen ? 4.h : 6.h,
                              ),
                              decoration: BoxDecoration(
                                color: ColorsManager.successSurface,
                                borderRadius: BorderRadius.circular(SizeApp.s8),
                                border: Border.all(
                                  color: ColorsManager.successText.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomIcon(
                                    assetPath: AssetsManager.iconsTeamIcons,
                                    size: isSmallScreen ? 12.sp : 14.sp,
                                    color: ColorsManager.successText,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    '${widget.team.memberCount} عضو',
                                    style: TextStyle(
                                      fontSize: isSmallScreen ? 10.sp : 11.sp,
                                      fontWeight: FontWeight.w600,
                                      color: ColorsManager.successText,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const Spacer(),

                            // Arrow navigation
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: EdgeInsets.all(isSmallScreen ? 6.w : SizeApp.s8),
                              decoration: BoxDecoration(
                                color: _isPressed
                                    ? ColorsManager.primaryColor.withOpacity(0.15)
                                    : ColorsManager.defaultSurface,
                                borderRadius: BorderRadius.circular(SizeApp.s8),
                                border: Border.all(
                                  color: _isPressed
                                      ? ColorsManager.primaryColor.withOpacity(0.3)
                                      : ColorsManager.inputBorder.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.arrow_forward_rounded,
                                size: isSmallScreen ? 14.sp : SizeApp.iconSizeSmall,
                                color: _isPressed
                                    ? ColorsManager.primaryColor
                                    : ColorsManager.defaultTextSecondary,
                              ),
                            ),
                          ],
                        )
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

  Widget _buildCircularBadge(bool isSmallScreen) {
    final circleSize = isSmallScreen ? 24.0 : 28.0;
    final fontSize = isSmallScreen ? 7.0 : 8.0;

    return Stack(
      alignment: Alignment.center,
      children: [
        SizedBox(
          width: circleSize.w,
          height: circleSize.h,
          child: CircularProgressIndicator(
            value: widget.team.completionPercentage / 100,
            strokeWidth: 2.0,
            backgroundColor: _getPercentageColor(widget.team.completionPercentage).withOpacity(0.15),
            valueColor: AlwaysStoppedAnimation<Color>(
              _getPercentageColor(widget.team.completionPercentage),
            ),
            strokeCap: StrokeCap.round,
          ),
        ),
        Text(
          '${widget.team.completionPercentage}%',
          style: TextStyle(
            fontSize: fontSize.sp,
            fontWeight: FontWeight.w700,
            color: _getPercentageColor(widget.team.completionPercentage),
          ),
        ),
      ],
    );
  }

  // Helper Method
  Color _getPercentageColor(double percentage) {
    if (percentage >= 80) return ColorsManager.successFill;
    if (percentage >= 50) return ColorsManager.warningFill;
    return ColorsManager.errorFill;
  }
}