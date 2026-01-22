import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/JobSeekerModel/ProfileViewsStats.dart';
import 'package:client/Server/Repo/ProfileViewsRepository.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ProfileViewsScreen extends StatefulWidget {
  const ProfileViewsScreen({super.key});

  @override
  State<ProfileViewsScreen> createState() => _ProfileViewsScreenState();
}

class _ProfileViewsScreenState extends State<ProfileViewsScreen> {
  final repo = ProfileViewsRepository();
  late Future<List<ProfileViewWithRecruiter>> _future;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthProvider>().user!.userId;
    _future = repo.getViewsWithRecruiters(userId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text("Profile Views", style: TextStyle( color: AppColors.darkGreen,fontWeight: FontWeight.w600,)),),
      body: FutureBuilder<List<ProfileViewWithRecruiter>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const _EmptyViewsState();
          }

          final views = snapshot.data!;

          return ListView(
            children: [
              _StatsSection(views: views),
              _ViewsChartSection(views: views),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Who viewed your profile",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              ...views.map(
                (e) => RecruiterViewCard(item: e),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  final List<ProfileViewWithRecruiter> views;

  const _StatsSection({required this.views});

  @override
  Widget build(BuildContext context) {
    final totalViews = views.length;

    final uniqueRecruiters =
        views.map((e) => e.recruiter.userId).toSet().length;

    final today = DateTime.now();
    final todayViews = views.where((v) {
      final d = v.view.createdAt;
      return d.year == today.year &&
          d.month == today.month &&
          d.day == today.day;
    }).length;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          _StatCard(
            title: "Total Views",
            value: totalViews.toString(),
            icon: Icons.remove_red_eye,
            gradient: const [Color(0xff667eea), Color(0xff764ba2)],
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: "Recruiters",
            value: uniqueRecruiters.toString(),
            icon: Icons.business,
            gradient: const [Color(0xff11998e), Color(0xff38ef7d)],
          ),
          const SizedBox(width: 12),
          _StatCard(
            title: "Today",
            value: todayViews.toString(),
            icon: Icons.today,
            gradient: const [Color(0xffff9966), Color(0xffff5e62)],
          ),
        ],
      ),
    );
  }
}
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> gradient;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecruiterViewCard extends StatelessWidget {
  final ProfileViewWithRecruiter item;

  const RecruiterViewCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final r = item.recruiter;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: premiumShadow,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.greenCeladon,
            child: Text(
              r.pharmacyName.isNotEmpty ? r.pharmacyName[0] : "?",
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.pharmacyName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  "${r.city}, ${r.province}",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Text(
            _format(item.view.createdAt),
            style: const TextStyle(
              fontSize: 11,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  String _format(DateTime d) =>
      "${d.day}/${d.month}/${d.year} • ${d.hour}:${d.minute.toString().padLeft(2, '0')}";
}


class _ViewsChartSection extends StatelessWidget {
  final List<ProfileViewWithRecruiter> views;

  const _ViewsChartSection({required this.views});

  @override
  Widget build(BuildContext context) {
    final Map<int, int> dailyCount = {};

    for (final v in views) {
      final day = v.view.createdAt.day;
      dailyCount[day] = (dailyCount[day] ?? 0) + 1;
    }

    return ProfileViewsChart(
      dailyViews: buildLast7Days(views),
    );
  }
}

class ProfileViewsChart extends StatelessWidget {
  final Map<DateTime, int> dailyViews;

  const ProfileViewsChart({
    super.key,
    required this.dailyViews,
  });

  @override
  Widget build(BuildContext context) {
    if (dailyViews.isEmpty) {
      return _EmptyChartCard();
    }

    final dates = dailyViews.keys.toList()..sort();
    final values = dates.map((d) => dailyViews[d]!.toDouble()).toList();

    final maxY = (values.reduce((a, b) => a > b ? a : b) + 1);

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 16, 20, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TITLE
            const Text(
              "Profile Views (Last 7 Days)",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),

            const SizedBox(height: 18),

            /// CHART
            SizedBox(
              height: 220,
              child: LineChart(
                LineChartData(
                  minY: 0,
                  maxY: maxY,

                  /// GRID
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 1,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.black12,
                      strokeWidth: 1,
                      dashArray: [6, 6],
                    ),
                  ),

                  /// AXES
                  titlesData: FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),

                    /// LEFT (COUNTS)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        reservedSize: 30,
                        getTitlesWidget: (value, _) => Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.black54,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),

                    /// BOTTOM (DATES)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 1,
                        getTitlesWidget: (value, _) {
                          final index = value.toInt();
                          if (index < 0 || index >= dates.length) {
                            return const SizedBox.shrink();
                          }
                          final d = dates[index];
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              "${d.day}/${d.month}",
                              style: const TextStyle(
                                fontSize: 11,
                                color: Colors.black54,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),

                  /// BORDER
                  borderData: FlBorderData(show: false),

                  /// LINE
                  lineBarsData: [
                    LineChartBarData(
                      isCurved: true,
                      barWidth: 4,
                      color: AppColors.greenCeladon,
                      isStrokeCapRound: true,

                      dotData: FlDotData(
                        show: true,
                        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
                          radius: 4,
                          color: Colors.white,
                          strokeWidth: 3,
                          strokeColor: AppColors.greenCeladon,
                        ),
                      ),

                      belowBarData: BarAreaData(
                        show: true,
                        gradient: LinearGradient(
                          colors: [
                            AppColors.greenCeladon.withOpacity(.35),
                            AppColors.greenCeladon.withOpacity(.05),
                          ],
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                        ),
                      ),

                      spots: List.generate(
                        values.length,
                        (i) => FlSpot(i.toDouble(), values[i]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Map<DateTime, int> buildLast7Days(List<ProfileViewWithRecruiter> views) {
  final now = DateTime.now();
  final Map<DateTime, int> map = {};

  for (int i = 6; i >= 0; i--) {
    final day = DateTime(now.year, now.month, now.day - i);
    map[day] = 0;
  }

  for (final v in views) {
    final d = v.view.createdAt;
    final key = DateTime(d.year, d.month, d.day);
    if (map.containsKey(key)) {
      map[key] = map[key]! + 1;
    }
  }

  return map;
}

class _EmptyChartCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(26),
          boxShadow: premiumShadow,
        ),
        child: const Center(
          child: Text(
            "No profile views trend yet",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ),
      ),
    );
  }
}

class _EmptyViewsState extends StatelessWidget {
  const _EmptyViewsState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.visibility_off, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            "No profile views yet",
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 8),
          Text(
            "Recruiters will appear here when they view your profile",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
