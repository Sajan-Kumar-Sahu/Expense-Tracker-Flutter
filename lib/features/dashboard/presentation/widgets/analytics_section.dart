import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../../../data/mock/mock_data.dart';

/// Doughnut chart preview showing expense breakdown by category.
class AnalyticsSection extends StatefulWidget {
  const AnalyticsSection({super.key});

  @override
  State<AnalyticsSection> createState() => _AnalyticsSectionState();
}

class _AnalyticsSectionState extends State<AnalyticsSection> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.r),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
        ),
        boxShadow: isDark
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Expense Breakdown',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 16.sp,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  'June 2024',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              // Doughnut chart
              SizedBox(
                width: 140.r,
                height: 140.r,
                child: PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (event, pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex =
                              pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 3,
                    centerSpaceRadius: 40.r,
                    sections: MockData.analyticsCategories
                        .asMap()
                        .entries
                        .map((entry) {
                      final isTouched = entry.key == _touchedIndex;
                      return PieChartSectionData(
                        value: entry.value.percentage,
                        color: Color(entry.value.colorHex),
                        radius: isTouched ? 40.r : 34.r,
                        title: '',
                        badgeWidget: isTouched
                            ? _BadgeWidget(
                                label: '${entry.value.percentage.toInt()}%',
                                color: Color(entry.value.colorHex),
                              )
                            : null,
                        badgePositionPercentageOffset: 1.2,
                      );
                    }).toList(),
                  ),
                ),
              ),
              SizedBox(width: 20.w),

              // Legend
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: MockData.analyticsCategories
                      .map(
                        (cat) => Padding(
                          padding: EdgeInsets.only(bottom: 10.h),
                          child: Row(
                            children: [
                              Container(
                                width: 12.r,
                                height: 12.r,
                                decoration: BoxDecoration(
                                  color: Color(cat.colorHex),
                                  borderRadius: BorderRadius.circular(3.r),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Expanded(
                                child: Text(
                                  cat.label,
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.onSurface
                                        .withValues(alpha: 0.75),
                                  ),
                                ),
                              ),
                              Text(
                                '${cat.percentage.toInt()}%',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  fontWeight: FontWeight.w700,
                                  color: Color(cat.colorHex),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 700.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0, delay: 700.ms, duration: 600.ms);
  }
}

class _BadgeWidget extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeWidget({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.r),
        boxShadow: [
          BoxShadow(color: color.withValues(alpha: 0.4), blurRadius: 4),
        ],
      ),
      child: Text(
        label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 10.sp,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
