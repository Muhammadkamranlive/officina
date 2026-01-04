import 'package:client/AppColors/AppUI.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class JobStatsSection extends StatelessWidget {
  const JobStatsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SectionCard(
          title: "Job Views",
          child: Column(
            children: [
              const SizedBox(height: 12),
              _buildViewsChart(),
            ],
          ),
        ),
        _SectionCard(
          title: "Job Applications",
          child: Column(
            children: [
              const SizedBox(height: 32),
              _buildApplicationsChart(),
            ],
          ),
        ),
      
      ],
    );
  }

  /// ------------------- LINE CHART (Views) -------------------
  Widget _buildViewsChart() {
    final gradientColors = [Color(0xFF2ECC71),Color(0xFF27AE60),Color(0xFF1E8449)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  tooltipBgColor: Colors.white,
                  tooltipRoundedRadius: 8,
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      return LineTooltipItem(
                        "${spot.y.toInt()} views",
                        const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12),
                      );
                    }).toList();
                  },
                ),
                handleBuiltInTouches: true,
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 2,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text("${value.toInt()}",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) {
                      final labels = ["Mon", "Tue", "Wed", "Thu", "Fri"];
                      return Text(labels[value.toInt() % labels.length],
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey));
                    },
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: const [
                    FlSpot(0, 5),
                    FlSpot(1, 10),
                    FlSpot(2, 7),
                    FlSpot(3, 12),
                    FlSpot(4, 8),
                  ],
                  isCurved: true,
                  gradient: LinearGradient(colors: gradientColors),
                  color: Colors.blue, // fallback color
                  barWidth: 4,
                  dotData: FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: gradientColors
                          .map((c) => c.withOpacity(0.3))
                          .toList(),
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// ------------------- BAR CHART (Applications) -------------------
  Widget _buildApplicationsChart() {
    final barColors = [Color(0xFF2ECC71),Color(0xFF27AE60),Color(0xFF1E8449)];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        const SizedBox(height: 12),
        SizedBox(
          height: 180,
          child: BarChart(
            BarChartData(
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  tooltipBgColor: Colors.white,
                  tooltipPadding: const EdgeInsets.all(6),
                  tooltipRoundedRadius: 8,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                        "${rod.toY.toInt()} applications",
                        const TextStyle(
                            color: Colors.black87,
                            fontWeight: FontWeight.bold,
                            fontSize: 12));
                  },
                ),
              ),
              alignment: BarChartAlignment.spaceAround,
              maxY: 12,
              gridData: FlGridData(
                show: true,
                drawHorizontalLine: true,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.withOpacity(0.1),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 2,
                    getTitlesWidget: (value, meta) {
                      return Text("${value.toInt()}",
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey));
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final labels = ["Mon", "Tue", "Wed", "Thu", "Fri"];
                      return Text(labels[value.toInt() % labels.length],
                          style: const TextStyle(
                              fontSize: 10, color: Colors.grey));
                    },
                  ),
                ),
              ),
              barGroups: [
                _buildBar(0, 5, barColors[0]),
                _buildBar(1, 7, barColors[1]),
                _buildBar(2, 6, barColors[0]),
                _buildBar(3, 9, barColors[1]),
                _buildBar(4, 8, barColors[0]),
              ],
            ),
          ),
        ),
      ],
    );
  }

  BarChartGroupData _buildBar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 16,
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.7), color],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
      ],
    );
  }
}

/// ------------------- CARD WRAPPER -------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
