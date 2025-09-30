import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:itqan_gym/core/theme/colors.dart';
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

  @override
  void initState() {
    super.initState();
    _loadChartData();
  }

  Future<void> _loadChartData() async {
    setState(() => _isLoading = true);

    try {
      final provider = context.read<ExerciseAssignmentProvider>();
      final skills = await provider.loadMemberSkills(widget.member.id);

      if (skills.isEmpty) {
        setState(() {
          _chartData = [];
          _isLoading = false;
        });
        return;
      }

      _chartData = _calculateProgressOverTime(skills);
      _improvement = _calculateImprovement();

      // إرسال قيمة التحسن للـ parent widget
      if (widget.onImprovementCalculated != null && _chartData.isNotEmpty) {
        widget.onImprovementCalculated!(_improvement);
      }

      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      debugPrint('Error loading chart data: $e');
      setState(() {
        _isLoading = false;
        _hasError = true;
        _chartData = _generateFallbackData();
      });
    }
  }

  List<FlSpot> _calculateProgressOverTime(List<AssignedSkill> skills) {
    final avgProgress = skills.isEmpty ? 0.0 :
    skills.fold<double>(0, (sum, skill) => sum + skill.progress) / skills.length;
    return _generateProgressCurve(avgProgress);
  }

  List<FlSpot> _generateProgressCurve(double currentProgress) {
    final spots = <FlSpot>[];

    for (int week = 0; week < 6; week++) {
      double progress;

      if (week == 0) {
        progress = 0;
      } else if (week == 5) {
        progress = currentProgress;
      } else {
        final ratio = week / 5.0;
        progress = currentProgress * _easeInOutCubic(ratio);
        final variation = (week % 2 == 0 ? -1 : 1) * (2 + week * 0.5);
        progress = (progress + variation).clamp(0, 100);
      }

      spots.add(FlSpot(week.toDouble(), progress));
    }

    return spots;
  }

  double _easeInOutCubic(double t) {
    return t < 0.5
        ? 4 * t * t * t
        : 1 - pow((-2 * t + 2), 3) / 2;
  }

  double pow(double base, int exponent) {
    double result = 1;
    for (int i = 0; i < exponent; i++) {
      result *= base;
    }
    return result;
  }

  List<FlSpot> _generateFallbackData() {
    final progress = widget.member.overallProgress ?? 50;
    return _generateProgressCurve(progress);
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
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeApp.padding),
      child: Container(
        padding: EdgeInsets.all(SizeApp.s16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 15,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Optional internal header (if needed for standalone use)
            if (_chartData.isNotEmpty && !_isLoading)
              Padding(
                padding: EdgeInsets.only(bottom: SizeApp.padding),
                child: ImprovementBadge(improvement: _improvement),
              ),


            if (_isLoading)
              _buildLoadingState()
            else if (_hasError)
              _buildErrorState()
            else if (_chartData.isEmpty)
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
                color: ColorsManager.inputBorder.withOpacity(0.15),
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
                reservedSize: 45,
                interval: 20,
                getTitlesWidget: (value, meta) {
                  return Padding(
                    padding: EdgeInsets.only(right: 8.w),
                    child: Text(
                      '${value.toInt()}%',
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: ColorsManager.defaultTextSecondary,
                      ),
                    ),
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  final weeks = ['أ1', 'أ2', 'أ3', 'أ4', 'أ5', 'أ6'];
                  final index = value.toInt();
                  if (index >= 0 && index < weeks.length) {
                    return Padding(
                      padding: EdgeInsets.only(top: 8.h),
                      child: Text(
                        weeks[index],
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: ColorsManager.defaultTextSecondary,
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
              bottom: BorderSide(
                color: ColorsManager.inputBorder.withOpacity(0.2),
                width: 1,
              ),
              left: BorderSide(
                color: ColorsManager.inputBorder.withOpacity(0.2),
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
                  ColorsManager.primaryColor,
                  ColorsManager.primaryColor.withOpacity(0.8),
                ],
              ),
              barWidth: 3.5,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: Colors.white,
                    strokeWidth: 3,
                    strokeColor: ColorsManager.primaryColor,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.primaryColor.withOpacity(0.25),
                    ColorsManager.primaryColor.withOpacity(0.05),
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
              tooltipBgColor: ColorsManager.primaryColor,
              tooltipRoundedRadius: 8.r,
              tooltipPadding: EdgeInsets.symmetric(
                horizontal: 12.w,
                vertical: 8.h,
              ),
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final week = spot.x.toInt() + 1;
                  return LineTooltipItem(
                    'الأسبوع $week\n${spot.y.toStringAsFixed(1)}%',
                    TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
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
    return SizedBox(
      height: 220.h,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(ColorsManager.primaryColor),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    final theme = Theme.of(context);

    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: ColorsManager.errorFill.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ColorsManager.errorFill.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 40.sp,
              color: ColorsManager.errorFill,
            ),
            SizedBox(height: SizeApp.s16),
            Text(
              'خطأ في تحميل البيانات',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorsManager.errorText,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            TextButton.icon(
              onPressed: _loadChartData,
              icon: Icon(Icons.refresh, size: 16.sp),
              label: Text('إعادة المحاولة'),
              style: TextButton.styleFrom(
                foregroundColor: ColorsManager.primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final theme = Theme.of(context);

    return Container(
      height: 220.h,
      decoration: BoxDecoration(
        color: ColorsManager.backgroundCard,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: ColorsManager.inputBorder.withOpacity(0.2),
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(16.sp),
              decoration: BoxDecoration(
                color: ColorsManager.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.bar_chart_rounded,
                size: 40.sp,
                color: ColorsManager.primaryColor.withOpacity(0.5),
              ),
            ),
            SizedBox(height: SizeApp.s16),
            Text(
              'لا توجد بيانات كافية',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultTextSecondary,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            Text(
              'سيتم عرض التقدم بعد بداية التدريب على المهارات',
              style: theme.textTheme.bodySmall?.copyWith(
                color: ColorsManager.defaultTextSecondary.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
