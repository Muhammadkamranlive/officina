import 'package:client/AppColors/AppUI.dart';
import 'package:client/Server/Repo/JbViews/JobViews_Repository.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';


class JobStatsSection extends StatefulWidget {
  final String jobId;

  const JobStatsSection({super.key, required this.jobId});

  @override
  State<JobStatsSection> createState() => _JobStatsSectionState();
}

class _JobStatsSectionState extends State<JobStatsSection> {
  final JobViewsRepository _viewsRepo = JobViewsRepository();
  final JobApplicationRepository _appRepo = JobApplicationRepository();

  int totalViews = 0;
  int totalApplications = 0;
  List<int> dailyViews = [];
  List<int> dailyApplications = [];

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    // 🔹 Job Views
    final viewsQuery = await _viewsRepo.collection
        .where('jobId', isEqualTo: widget.jobId)
        .orderBy('createdAt')
        .get();

    final viewDocs = viewsQuery.docs;
    // ignore: avoid_types_as_parameter_names
    totalViews     = viewDocs.fold(0, (sum, doc) => sum + ((doc['counter'] ?? 0) as int));

    // last 5 days for chart
    dailyViews = List.generate(5, (i) => 0);
    for (var doc in viewDocs) {
      final date = (doc['createdAt'] as Timestamp).toDate();
      final index = DateTime.now().difference(date).inDays;
      if (index < 5) dailyViews[4 - index] += (doc['counter'] as int? ?? 0);
    }

    // 🔹 Job Applications
    final applicants = await _appRepo.getApplicantsForJob(widget.jobId);
    totalApplications = applicants.length;

    dailyApplications = List.generate(5, (i) => 0);
    for (var app in applicants) {
      final diff = DateTime.now().difference(app.application.createdAt).inDays;
      if (diff < 5) dailyApplications[4 - diff]++;
    }

    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Column(
      children: [
        _SectionCard(
          title: "Job Views ($totalViews total)",
          child: SizedBox(
            height: 180,
            child: _buildViewsChart(),
          ),
        ),
        _SectionCard(
          title: "Job Applications ($totalApplications total)",
          child: SizedBox(
            height: 180,
            child: _buildApplicationsChart(),
          ),
        ),
      ],
    );
  }

  Widget _buildViewsChart() {
    final gradientColors = [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)];

    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              dailyViews.length,
              (i) => FlSpot(i.toDouble(), dailyViews[i].toDouble()),
            ),
            isCurved: true,
            gradient: LinearGradient(colors: gradientColors),
            barWidth: 4,
            dotData: FlDotData(show: true),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: gradientColors.map((c) => c.withOpacity(0.3)).toList(),
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final labels = ["Mon", "Tue", "Wed", "Thu", "Fri"];
                return Text(labels[value.toInt() % labels.length],
                    style: const TextStyle(fontSize: 10, color: Colors.grey));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }

  Widget _buildApplicationsChart() {
    final barColors = [Color(0xFF2ECC71), Color(0xFF27AE60), Color(0xFF1E8449)];

    return BarChart(
      BarChartData(
        barGroups: List.generate(
          dailyApplications.length,
          (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: dailyApplications[i].toDouble(),
                width: 16,
                borderRadius: BorderRadius.circular(6),
                gradient: LinearGradient(
                  colors: [barColors[i % barColors.length].withOpacity(0.7), barColors[i % barColors.length]],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                ),
              ),
            ],
          ),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final labels = ["Mon", "Tue", "Wed", "Thu", "Fri"];
                return Text(labels[value.toInt() % labels.length],
                    style: const TextStyle(fontSize: 10, color: Colors.grey));
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
            ),
          ),
        ),
        gridData: FlGridData(show: true),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}

/// ------------------- CARD WRAPPER -------------------
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

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
                  fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}
