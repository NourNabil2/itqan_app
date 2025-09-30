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
  bool _hasRealData = false;

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
          _hasRealData = false;
        });
        return;
      }

      // فحص إذا كان العضو جديد (أقل من 7 أيام)
      final memberAge = DateTime.now().difference(widget.member.createdAt).inDays;

      if (memberAge < 7) {
        // عضو جديد - لا توجد بيانات كافية
        setState(() {
          _chartData = [];
          _isLoading = false;
          _hasRealData = false;
        });
        return;
      }

      // حساب البيانات الحقيقية من التواريخ
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
      setState(() {
        _isLoading = false;
        _hasError = true;
        _chartData = [];
        _hasRealData = false;
      });
    }
  }

  List<FlSpot> _calculateRealProgressOverTime(List<AssignedSkill> skills) {
    if (skills.isEmpty) return [];

    // تجميع المهارات حسب الأسبوع
    final now = DateTime.now();
    final weeklyProgress = <int, List<double>>{};

    for (var skill in skills) {
      final weekDiff = now.difference(skill.assignedAt).inDays ~/ 7;
      if (weekDiff >= 0 && weekDiff < 6) {
        weeklyProgress.putIfAbsent(weekDiff, () => []).add(skill.progress);
      }
    }

    // إذا لم يكن هناك بيانات كافية
    if (weeklyProgress.isEmpty) return [];

    // حساب متوسط التقدم لكل أسبوع
    final spots = <FlSpot>[];
    for (int week = 0; week < 6; week++) {
      if (weeklyProgress.containsKey(week)) {
        final avg = weeklyProgress[week]!.reduce((a, b) => a + b) /
            weeklyProgress[week]!.length;
        spots.add(FlSpot(week.toDouble(), avg));
      }
    }

    // ترتيب النقاط من الأقدم للأحدث
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            SizedBox(height: SizeApp.s16),
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

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.sp),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    ColorsManager.primaryColor,
                    ColorsManager.primaryColor.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12.r),
                boxShadow: [
                  BoxShadow(
                    color: ColorsManager.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                Icons.show_chart_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
            SizedBox(width: SizeApp.s12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مخطط الأداء',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: ColorsManager.defaultText,
                  ),
                ),
                Text(
                  'آخر 6 أسابيع',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: ColorsManager.defaultTextSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
        if (_hasRealData && !_isLoading)
          ImprovementBadge(improvement: _improvement),
      ],
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
    final memberAge = DateTime.now().difference(widget.member.createdAt).inDays;

    String message;
    if (memberAge < 7) {
      message = 'عضو جديد - سيتم عرض البيانات بعد أسبوع من التدريب';
    } else {
      message = 'لا توجد بيانات كافية - ابدأ بتعيين مهارات للعضو';
    }

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
              'لا توجد بيانات للعرض',
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: ColorsManager.defaultTextSecondary,
              ),
            ),
            SizedBox(height: SizeApp.s8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32.w),
              child: Text(
                message,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: ColorsManager.defaultTextSecondary.withOpacity(0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
