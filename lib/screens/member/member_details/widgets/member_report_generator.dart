import 'dart:io';
import 'dart:typed_data';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/data/models/skill_template.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:itqan_gym/core/assets/assets_manager.dart';

class MemberReportGenerator {
  static Future<void> generateAndShareReport({
    required BuildContext context,
    required Member member,
    required List<FlSpot> chartData,
    required double chartMaxY,
    required Map<String, dynamic> statistics,
    required List<AssignedSkill> skills,
  }) async {
    try {
      final l10n = AppLocalizations.of(context);
      final theme = Theme.of(context);
      final colorScheme = theme.colorScheme;

      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(
          child: Card(
            color: colorScheme.surface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            child: Padding(
              padding: EdgeInsets.all(24.w),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(colorScheme.primary),
                    strokeWidth: 3,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    l10n.generatingReport,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: 16.sp,
                      color: colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      // Generate multiple pages
      final pages = <XFile>[];
      final directory = await getTemporaryDirectory();

      // Page 1: Header + Member Info
      final page1Image = await _generatePageImage(
        _ReportPage1(member: member, l10n: l10n),
      );
      final page1Path = '${directory.path}/report_page1_${member.id}.png';
      await File(page1Path).writeAsBytes(page1Image);
      pages.add(XFile(page1Path));

      // Page 2: Chart + Statistics
      if (chartData.isNotEmpty || statistics.isNotEmpty) {
        final page2Image = await _generatePageImage(
          _ReportPage2(
            member: member,
            chartData: chartData,
            chartMaxY: chartMaxY,
            statistics: statistics,
            l10n: l10n,
          ),
        );
        final page2Path = '${directory.path}/report_page2_${member.id}.png';
        await File(page2Path).writeAsBytes(page2Image);
        pages.add(XFile(page2Path));
      }

      // Page 3: Skills + Notes + Footer
      if (skills.isNotEmpty || (member.notes != null && member.notes!.isNotEmpty)) {
        final page3Image = await _generatePageImage(
          _ReportPage3(
            member: member,
            skills: skills,
            l10n: l10n,
          ),
        );
        final page3Path = '${directory.path}/report_page3_${member.id}.png';
        await File(page3Path).writeAsBytes(page3Image);
        pages.add(XFile(page3Path));
      }

      // Close loading dialog
      if (context.mounted) {
        Navigator.pop(context);
      }

      // Share all pages
      await Share.shareXFiles(
        pages,
        text: '${l10n.memberReport}: ${member.name}',
        subject: '${member.name} - ${l10n.progressReport}',
      );

      // Clean up
      for (var page in pages) {
        await File(page.path).delete();
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${AppLocalizations.of(context).errorGeneratingReport}: $e',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
            margin: EdgeInsets.all(16.w),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }


  static Future<Uint8List> _generatePageImage(Widget page) async {
    final controller = ScreenshotController();
    return await controller.captureFromWidget(
      MediaQuery(
        data: const MediaQueryData(),
        child: Material(child: page),
      ),
      delay: const Duration(milliseconds: 200),
      pixelRatio: 2.5,
    );
  }
}

// ============= Page 1: Header + Member Info =============
class _ReportPage1 extends StatelessWidget {
  final Member member;
  final AppLocalizations l10n;

  const _ReportPage1({
    required this.member,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 1080.w,
      height: 736.h,
      color: colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(theme, colorScheme, l10n),
            _buildMemberInfo(theme, colorScheme, l10n),
            _buildPageFooter(1, theme, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h, horizontal: 40.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [colorScheme.primary, colorScheme.primaryContainer],
        ),
      ),
      child: Column(
        children: [
          Image.asset(
            AssetsManager.logo,
            width: 80.w,
            height: 80.h,
            fit: BoxFit.contain,
          ),
          SizedBox(height: 16.h),
          Text(
            'Itqan Gym',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontSize: 28.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              letterSpacing: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.memberProgressReport,
            style: theme.textTheme.bodyLarge?.copyWith(
              fontSize: 16.sp,
              color: colorScheme.onPrimary.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: colorScheme.onPrimary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              DateTime.now().toString().split(' ')[0],
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 14.sp,
                color: colorScheme.onPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberInfo(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 48.w,
                height: 48.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  image: member.photoPath != null
                      ? DecorationImage(
                    image: FileImage(File(member.photoPath!)),
                    fit: BoxFit.cover,
                  )
                      : null,
                  color: member.photoPath == null ? colorScheme.primary.withOpacity(0.1) : null,
                ),
                child: member.photoPath == null
                    ? Center(
                  child: Text(
                    member.name.isNotEmpty ? member.name[0].toUpperCase() : '?',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.w700,
                      color: colorScheme.primary,
                    ),
                  ),
                )
                    : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 14.sp, color: colorScheme.onSurfaceVariant),
                        SizedBox(width: 6.w),
                        Text(
                          '${l10n.memberSince}: ${member.createdAt.toString().split(' ')[0]}',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14.sp,
                            color: colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(child: _buildInfoCard(l10n.age, '${member.age}', Icons.cake, colorScheme.error, theme)),
              SizedBox(width: 16.w),
              Expanded(child: _buildInfoCard(l10n.level, member.level ?? '', Icons.trending_up, colorScheme.primary, theme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, Color color, ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),

      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.w),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 24.sp, color: color),
          ),
          SizedBox(height: 8.h),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildPageFooter(int pageNumber, ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 20.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              'Page $pageNumber',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontSize: 12.sp,
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

// ============= Page 2: Chart + Statistics =============
class _ReportPage2 extends StatelessWidget {
  final Member member;
  final List<FlSpot> chartData;
  final double chartMaxY;
  final Map<String, dynamic> statistics;
  final AppLocalizations l10n;

  const _ReportPage2({
    required this.member,
    required this.chartData,
    required this.chartMaxY,
    required this.statistics,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 1080.w,
      height: 736.h,
      color: colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageHeader(theme, colorScheme, l10n),
            if (chartData.isNotEmpty) _buildChartSection(theme, colorScheme, l10n),
            if (statistics.isNotEmpty) _buildStatistics(theme, colorScheme, l10n),
            _buildPageFooter(2),
          ],
        ),
      ),
    );
  }
  Widget _buildPageFooter(int pageNumber) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 30),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Page $pageNumber',
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildPageHeader(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Row(
        children: [
          Image.asset(
            AssetsManager.logo,
            width: 32.w,
            height: 32.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itqan Gym',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  member.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChartSection(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.show_chart, color: colorScheme.primary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.performanceChart,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ReportPerformanceChart(chartData: chartData, maxY: chartMaxY),
        ],
      ),
    );
  }

  Widget _buildStatistics(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    final totalSkills = statistics['totalSkills'] ?? 0;
    final completedSkills = statistics['completedSkills'] ?? 0;
    final averageProgress = statistics['averageProgress'] ?? 0.0;

    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.secondary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.analytics, color: colorScheme.secondary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.statistics,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Row(
            children: [
              Expanded(child: _buildStatCard(l10n.totalSkills, totalSkills.toString(), Icons.fitness_center, colorScheme.primary, theme)),
              SizedBox(width: 16.w),
              Expanded(child: _buildStatCard(l10n.completed, completedSkills.toString(), Icons.check_circle, colorScheme.secondary, theme)),
              SizedBox(width: 16.w),
              Expanded(child: _buildStatCard(l10n.averageProgress, '${averageProgress.toStringAsFixed(1)}%', Icons.trending_up, colorScheme.tertiary, theme)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon, Color color, ThemeData theme) {

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: color.withOpacity(0.2), width: 1.5),
      ),
      child: Column(
        children: [
          Icon(icon, size: 32.sp, color: color),
          SizedBox(height: 8.h),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 4.h),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 12.sp,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

// ============= Page 3: Skills + Notes + Footer =============
class _ReportPage3 extends StatelessWidget {
  final Member member;
  final List<AssignedSkill> skills;
  final AppLocalizations l10n;

  const _ReportPage3({
    required this.member,
    required this.skills,
    required this.l10n,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 1080.w,
      height: 736.h,
      color: colorScheme.surface,
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildPageHeader(theme, colorScheme, l10n),
            if (skills.isNotEmpty) _buildSkillsSection(theme, colorScheme, l10n),
            if (member.notes != null && member.notes!.isNotEmpty) _buildNotes(theme, colorScheme, l10n),
            _buildFooter(theme, colorScheme, l10n),
          ],
        ),
      ),
    );
  }

  Widget _buildPageHeader(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: colorScheme.primary,
      ),
      child: Row(
        children: [
          Image.asset(
            AssetsManager.logo,
            width: 32.w,
            height: 32.h,
            fit: BoxFit.contain,
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Itqan Gym',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  member.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSkillsSection(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    final topSkills = skills.take(5).toList();

    return Container(
      padding: EdgeInsets.all(32.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.star, color: colorScheme.tertiary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.topSkills,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 24.h),
          ...topSkills.map((skill) => _buildSkillItem(skill, theme, colorScheme)).toList(),
        ],
      ),
    );
  }

  Widget _buildSkillItem(AssignedSkill skill, ThemeData theme, ColorScheme colorScheme) {
    String name = 'Unknown';
    double progress = 0.0;

    try {
      name = skill.skill?.skillName ?? 'Unknown';
      progress = skill.progress;
    } catch (e) {
      debugPrint('Error reading skill: $e');
    }

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 12.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: _getProgressColor(progress, colorScheme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  '${progress.toStringAsFixed(0)}%',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: _getProgressColor(progress, colorScheme),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress / 100,
              backgroundColor: colorScheme.outline.withOpacity(0.2),
              valueColor: AlwaysStoppedAnimation(_getProgressColor(progress, colorScheme)),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }

  Color _getProgressColor(double progress, ColorScheme colorScheme) {
    if (progress >= 80) return colorScheme.secondary;
    if (progress >= 50) return colorScheme.primary;
    if (progress > 0) return colorScheme.tertiary;
    return colorScheme.error;
  }

  Widget _buildNotes(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: colorScheme.tertiary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(Icons.notes, color: colorScheme.tertiary, size: 24.sp),
              ),
              SizedBox(width: 12.w),
              Text(
                l10n.notes,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            member.notes!,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: colorScheme.onSurface,
              height: 1.6,
            ),
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(ThemeData theme, ColorScheme colorScheme, AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.all(32.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colorScheme.onSurface, colorScheme.onSurfaceVariant],
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  'Page 3',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontSize: 12.sp,
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          Text(
            'Itqan Gym',
            style: theme.textTheme.titleLarge?.copyWith(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: colorScheme.onPrimary,
              letterSpacing: 1.2,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 8.h),
          Text(
            l10n.professionalGymnasticsManagement,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontSize: 14.sp,
              color: colorScheme.onPrimary.withOpacity(0.7),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 16.h),
          Text(
            '© 2025 Itqan Gym. All rights reserved.',
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12.sp,
              color: colorScheme.onPrimary.withOpacity(0.6),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ============= Report Performance Chart =============
class ReportPerformanceChart extends StatelessWidget {
  final List<FlSpot> chartData;
  final double maxY;

  const ReportPerformanceChart({
    super.key,
    required this.chartData,
    this.maxY = 100,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (chartData.isEmpty) {
      return Container(
        height: 220.h,
        decoration: BoxDecoration(
          color: colorScheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: colorScheme.onSurface.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.bar_chart_rounded, size: 48.sp, color: colorScheme.primary),
              SizedBox(height: 12.h),
              Text(
                'No chart data available',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontSize: 14.sp,
                  color: colorScheme.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      height: 220.h,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: colorScheme.outline.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.onSurface.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) => FlLine(
              color: colorScheme.outline.withOpacity(0.3),
              strokeWidth: 1,
              dashArray: [5, 5],
            ),
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40.w,
                interval: 20,
                getTitlesWidget: (value, meta) => Padding(
                  padding: EdgeInsets.only(right: 8.w),
                  child: Text(
                    '${value.toInt()}%',
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 12.sp,
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30.h,
                getTitlesWidget: (value, meta) {
                  const weeks = ['W1', 'W2', 'W3', 'W4', 'W5', 'W6'];
                  final index = value.toInt();
                  if (index >= 0 && index < weeks.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        weeks[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.sp,
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: colorScheme.outline.withOpacity(0.3), width: 1.5),
              left: BorderSide(color: colorScheme.outline.withOpacity(0.3), width: 1.5),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: chartData,
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: LinearGradient(colors: [colorScheme.primary, colorScheme.primaryContainer]),
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                  radius: 5,
                  color: colorScheme.surface,
                  strokeWidth: 2,
                  strokeColor: colorScheme.primary,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    colorScheme.primary.withOpacity(0.25),
                    colorScheme.primary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          minY: 0,
          maxY: maxY,
          lineTouchData: const LineTouchData(enabled: false),
        ),
      ),
    );
  }
}