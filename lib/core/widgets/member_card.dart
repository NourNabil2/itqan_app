import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/services/ad_service.dart';
import 'package:itqan_gym/core/theme/colors.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/member/member_card_model.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:itqan_gym/screens/member/member_details/member_detail_screen.dart';
import 'package:provider/provider.dart';

class MemberCard extends StatefulWidget {
  final Member member;
  final VoidCallback? onTap;
  final bool loadDynamicData;

  const MemberCard({
    super.key,
    required this.member,
    this.onTap,
    this.loadDynamicData = true,
  });

  @override
  State<MemberCard> createState() => _MemberCardState();
}

class _MemberCardState extends State<MemberCard> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  MemberCardData? _cardData;
  bool _isLoadingData = false;

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

    if (widget.loadDynamicData) {
      _loadMemberData();
    }
  }

  Future<void> _loadMemberData() async {
    if (_isLoadingData || !mounted) return;

    setState(() => _isLoadingData = true);

    try {
      final provider = context.read<ExerciseAssignmentProvider>();

      final results = await Future.wait([
        provider.loadMemberSkills(widget.member.id),
        provider.getMemberStatistics(widget.member.id),
      ]);

      final skills = results[0] as List<AssignedSkill>;
      final stats = results[1] as Map<String, dynamic>;

      final skillsProgress = skills.isEmpty ? 0.0 :
      skills.fold<double>(0, (sum, skill) => sum + skill.progress) / skills.length;

      final exerciseStats = stats['exercises'] ?? {};

      if (mounted) {
        setState(() {
          _cardData = MemberCardData(
            skillsCount: skills.length,
            skillsProgress: skillsProgress,
            attendanceDays: stats['attendanceDays'] ?? 0,
            attendanceRate: stats['attendanceRate']?.toDouble() ?? 0,
            completedExercises: exerciseStats['completed'] ?? 0,
            lastActivity: stats['lastActivity'] != null
                ? DateTime.tryParse(stats['lastActivity'])
                : null,
          );
          _isLoadingData = false;
        });
      }
    } catch (e) {
      debugPrint('Error loading member card data: $e');
      if (mounted) {
        setState(() => _isLoadingData = false);
      }
    }
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
    final theme = Theme.of(context);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 360;

    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: GestureDetector(
            onTap: () async {
              HapticFeedback.lightImpact();

              // حاول عرض الإعلان البيني أولاً
              final shown = await AdsService.instance.showInterstitial(
                onDismissed: () {
                  // بعد ما يتقفل الإعلان، نفذ الإجراء الأصلي
                  if (widget.onTap != null) {
                    widget.onTap!();
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MemberDetailScreen(member: widget.member),
                      ),
                    );
                  }
                },
              );

              // لو الإعلان مش جاهز أو ما اتعرضش
              if (!shown) {
                if (widget.onTap != null) {
                  widget.onTap!();
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          MemberDetailScreen(member: widget.member),
                    ),
                  );
                }
              }
            },

            onTapDown: _handleTapDown,
            onTapUp: _handleTapUp,
            onTapCancel: _handleTapCancel,
            child: Container(
              margin: EdgeInsets.only(bottom: SizeApp.s16),
              decoration: BoxDecoration(
                color: theme.cardColor,
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
                  _buildHeader(isSmallScreen, theme),
                  _buildDivider(theme),
                  _buildStats(isSmallScreen, theme),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(bool isSmallScreen, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(SizeApp.padding),
      child: Row(
        children: [
          _buildAvatar(isSmallScreen),
          SizedBox(width: SizeApp.s16),
          Expanded(
            child: _buildMemberInfo(isSmallScreen, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatar(bool isSmallScreen) {
    final hasPhoto = widget.member.photoPath != null;

    return Hero(
      tag: 'member_avatar_${widget.member.id}',
      child: Container(
        width: isSmallScreen ? 60.w : 70.w,
        height: isSmallScreen ? 60.h : 70.h,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeApp.radiusMed),
          gradient: !hasPhoto ? LinearGradient(
            colors: [
              ColorsManager.secondaryColor.withOpacity(0.3),
              ColorsManager.secondaryColor.withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ) : null,
          image: hasPhoto
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
        child: !hasPhoto
            ? Center(
          child: Text(
            widget.member.name.isNotEmpty
                ? widget.member.name[0].toUpperCase()
                : '?',
            style: TextStyle(
              fontSize: isSmallScreen ? 24.sp : 28.sp,
              fontWeight: FontWeight.w700,
              color: ColorsManager.secondaryColor,
            ),
          ),
        )
            : null,
      ),
    );
  }

  Widget _buildMemberInfo(bool isSmallScreen, ThemeData theme) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                widget.member.name,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: isSmallScreen ? 18.sp : 20.sp,
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_isLoadingData)
              SizedBox(
                width: 16.w,
                height: 16.h,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    theme.primaryColor.withOpacity(0.6),
                  ),
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Wrap(
          spacing: 8.w,
          runSpacing: 4.h,
          children: [
            if (widget.member.age != null)
              _buildBadge(
                icon: Icons.cake_outlined,
                text: l10n.yearsOld(widget.member.age!),
                color: ColorsManager.infoText,
                backgroundColor: ColorsManager.infoSurface,
              ),
            _buildBadge(
              text: widget.member.level,
              color: _getLevelColor(widget.member.level),
              backgroundColor: _getLevelColor(widget.member.level).withOpacity(0.15),
            ),
            if (_cardData != null && _cardData!.skillsCount > 0)
              _buildBadge(
                icon: Icons.star,
                text: l10n.skillsCount(_cardData!.skillsCount),
                color: ColorsManager.warningText,
                backgroundColor: ColorsManager.warningSurface,
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBadge({
    IconData? icon,
    required String text,
    required Color color,
    required Color backgroundColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 8.w,
        vertical: 4.h,
      ),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(SizeApp.radiusSmall),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12.sp, color: color),
            SizedBox(width: 4.w),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(ThemeData theme) {
    return Container(
      height: 1,
      margin: EdgeInsets.symmetric(horizontal: SizeApp.s16),
      color: theme.dividerColor.withOpacity(0.1),
    );
  }

  Widget _buildStats(bool isSmallScreen, ThemeData theme) {
    final l10n = AppLocalizations.of(context);
    final skillsCount = _cardData?.skillsCount ?? 0;
    final skillsProgress = _cardData?.skillsProgress ?? 0;
    final lastActivityDays = _calculateDaysSinceActivity();

    return Container(
      padding: EdgeInsets.all(SizeApp.s16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              title: l10n.skills,
              value: skillsCount.toString(),
              icon: Icons.star_rounded,
              color: ColorsManager.warningFill,
              theme: theme,
            ),
          ),
          _buildStatDivider(theme),
          Expanded(
            child: _buildStatItem(
              title: l10n.progress,
              value: '${skillsProgress.toInt()}%',
              icon: Icons.trending_up_rounded,
              color: ColorsManager.successFill,
              theme: theme,
            ),
          ),
          _buildStatDivider(theme),
          Expanded(
            child: _buildStatItem(
              title: l10n.activity,
              value: _formatLastActivity(lastActivityDays),
              icon: Icons.schedule_rounded,
              color: _getActivityColor(lastActivityDays),
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required ThemeData theme,
  }) {
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
          style: theme.textTheme.bodyLarge?.copyWith(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          title,
          style: theme.textTheme.bodySmall?.copyWith(
            fontSize: 10.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatDivider(ThemeData theme) {
    return Container(
      width: 1,
      height: 40.h,
      color: theme.dividerColor.withOpacity(0.2),
    );
  }

  int _calculateDaysSinceActivity() {
    if (_cardData?.lastActivity == null) return -1;
    return DateTime.now().difference(_cardData!.lastActivity!).inDays;
  }

  String _formatLastActivity(int days) {
    final l10n = AppLocalizations.of(context);

    if (days < 0) return l10n.new_;
    if (days == 0) return l10n.today;
    if (days == 1) return l10n.yesterday;
    if (days <= 7) return l10n.daysCount(days);
    if (days <= 30) return l10n.weeksCount((days / 7).floor());
    return l10n.moreThan30Days;
  }

  Color _getActivityColor(int days) {
    if (days < 0) return ColorsManager.defaultTextSecondary;
    if (days <= 3) return ColorsManager.successFill;
    if (days <= 7) return ColorsManager.primaryColor;
    if (days <= 14) return ColorsManager.warningFill;
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
      case 'محترف':
        return ColorsManager.primaryColor;
      default:
        return ColorsManager.defaultTextSecondary;
    }
  }
}