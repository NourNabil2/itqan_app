// lib/screens/member/member_details/widgets/progress/performance_chart.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/language/app_localizations.dart';
import 'package:itqan_gym/core/utils/app_size.dart';
import 'package:itqan_gym/core/widgets/badges/ImprovementBadge.dart';
import 'package:itqan_gym/data/models/member/member.dart';
import 'package:itqan_gym/providers/exercise_assignment_provider.dart';
import 'package:provider/provider.dart';

class PerformanceChart extends StatefulWidget {
  final Member member;
  final Function(double improvement)? onImprovementCalculated;

  const PerformanceChart({
    super.key,
    required this.member,
    this.onImprovementCalculated,
  });

  @override
  State<PerformanceChart> createState() => _PerformanceChartState();
}

class _PerformanceChartState extends State<PerformanceChart> {
  List<FlSpot> _chartData = [];
  bool _isLoading = false;
  bool _hasError = false;
  double _improvement = 0;
  bool _hasRealData = false;

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    if (!mounted) return;

    setState(() => _isLoading = true);

    try {
      final provider = context.read<ExerciseAssignmentProvider>();
      final skills = await provider.loadMemberSkills(widget.member.id);

      if (!mounted) return;

      if (skills.isEmpty) {
        setState(() {
          _chartData = [];
          _isLoading = false;
          _hasRealData = false;
        });
        return;
      }

      final memberAge = DateTime.now().difference(widget.member.createdAt).inDays;

      if (memberAge < 7) {
        setState(() {
          _chartData = [];
          _isLoading = false;
          _hasRealData = false;
        });
        return;
      }

      _chartData = _calculateRealProgressOverTime(skills);
      _hasRealData = _chartData.length >= 2;

      if (_hasRealData) {
        _improvement = _calculateImprovement();
        widget.onImprovementCalculated?.call(_improvement);
      }

      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      debugPrint('Error loading chart data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasError = true;
          _chartData = [];
          _hasRealData = false;
        });
      }
    }
  }

  List<FlSpot> _calculateRealProgressOverTime(List<AssignedSkill> skills) {
    if (skills.isEmpty) return [];

    final now = DateTime.now();
    final weeklyProgress = <int, List<double>>{};

    for (var skill in skills) {
      final weekDiff = now.difference(skill.assignedAt).inDays ~/ 7;
      if (weekDiff >= 0 && weekDiff < 6) {
        weeklyProgress.putIfAbsent(weekDiff, () => []).add(skill.progress);
      }
    }

    if (weeklyProgress.isEmpty) return [];

    final spots = <FlSpot>[];
    for (int week = 0; week < 6; week++) {
      if (weeklyProgress.containsKey(week)) {
        final avg = weeklyProgress[week]!.reduce((a, b) => a + b) /
            weeklyProgress[week]!.length;
        spots.add(FlSpot(week.toDouble(), avg));
      }
    }

    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  double _calculateImprovement() {
    if (_chartData.length < 2) return 0;
    final first = _chartData.first.y;
    final last = _chartData.last.y;
    if (first == 0) return last;
    return ((last - first) / first) * 100;
  }

  double _calculateMaxY() {
    if (_chartData.isEmpty) return 100;
    final maxValue = _chartData.map((e) => e.y).reduce((a, b) => a > b ? a : b);
    return ((maxValue / 20).ceil() * 20).toDouble().clamp(20, 100);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeApp.padding),
      child: Container(
        padding: EdgeInsets.all(SizeApp.s16),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: colorScheme.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: colorScheme.shadow.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_hasRealData && !_isLoading) ...[
              ImprovementBadge(improvement: _improvement),
              SizedBox(height: SizeApp.s16),
            ],
            if (_isLoading)
              _buildLoadingState()
            else if (_hasError)
              _buildErrorState()
            else if (!_hasRealData || _chartData.isEmpty)
                _buildEmptyState()
              else
                _buildChart(),
          ],
        ),
      ),
    );
  }

  Widget _buildChart() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final maxY = _calculateMaxY();

    return SizedBox(
      height: 220.h,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 20,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: colorScheme.outlineVariant,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40.w,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(right: 6.w),
                    child: Text(
                      '${value.toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 10.sp,
                      ),
                      maxLines: 1,
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28.h,
                getTitlesWidget: (value, meta) {
                  final weeks = [
                    l10n.week(1),
                    l10n.week(2),
                    l10n.week(3),
                    l10n.week(4),
                    l10n.week(5),
                    l10n.week(6),
                  ];
                  final index = value.toInt();
                  if (index >= 0 && index < weeks.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 6.h),
                      child: Text(
                        weeks[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: colorScheme.onSurfaceVariant,
                          fontSize: 10.sp,
                        ),
                        maxLines: 1,
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
              bottom: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
              left: BorderSide(
                color: colorScheme.outlineVariant,
                width: 1,
              ),
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: _chartData,
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.primary.withOpacity(0.8),
                ],
              ),
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: colorScheme.surface,
                    strokeWidth: 3,
                    strokeColor: colorScheme.primary,
                  );
                },
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
          lineTouchData: LineTouchData(
            enabled: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: colorScheme.primary,
              tooltipRoundedRadius: 8.r,
              tooltipPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final week = spot.x.toInt() + 1;
                  return LineTooltipItem(
                    '${l10n.week(week)}\n${spot.y.toStringAsFixed(1)}%',
                    TextStyle(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 220.h,
      child: Center(
        child: CircularProgressIndicator(
          color: colorScheme.primary,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);

    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(20.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 36.sp,
                color: colorScheme.error,
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.errorLoadingData,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onErrorContainer,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 8.h),
              TextButton.icon(
                onPressed: _loadChartData,
                icon: Icon(Icons.refresh, size: 14.sp),
                label: Text(
                  l10n.retryAgain,
                  style: TextStyle(fontSize: 12.sp),
                ),
                style: TextButton.styleFrom(
                  foregroundColor: colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final l10n = AppLocalizations.of(context);
    final memberAge = DateTime.now().difference(widget.member.createdAt).inDays;

    final message = memberAge < 7
        ? l10n.newMemberDataAfterWeek
        : l10n.insufficientDataAssignSkills;

    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(14.w),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  size: 32.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                l10n.noDataToDisplay,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              SizedBox(height: 6.h),
              Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontSize: 11.sp,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}