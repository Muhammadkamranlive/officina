import 'package:client/AdminPannel/AdminAccountScreen.dart';
import 'package:client/AdminPannel/AdminHeader.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/Drawer/JobSeekerDrawer.dart';

import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Recruiter/RecruiterDetailPage.dart';
import 'package:client/Server/Enums/AdminEnum.dart' show AdminFormMode;
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  final JobOfferRepository jobRepo = JobOfferRepository();
  final RecruiterRepository recruiterRepo = RecruiterRepository();
  final JobApplicationRepository jobApplicationRepo =
      JobApplicationRepository();
  final JobSeekerRepository jobSeekerRepository = JobSeekerRepository();
  final SkillVerificationRequestRepository skillRepository =
      SkillVerificationRequestRepository();

  List<JobOffer> jobs = [];
  List<JobOffer> activejobs = [];
  List<Recruiter> recruiters = [];
  List<JobApplicationModel> applications = [];
  List<JobSeekerModel> jobSeekers = [];
  List<SkillVerificationRequest> skillVerifications = [];

  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() {
      loading = true;
    });
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profile = await jobRepo.getAll();
    final recruiterList = await recruiterRepo.getAllFromCollection();
    final applicationList = await jobApplicationRepo.getAllFromCollection();
    final jobSeekerList = await jobSeekerRepository.getAllFromCollection();
    final skillVerificationList = await skillRepository.getAllFromCollection();

    setState(() {
      jobs = profile;
      activejobs = profile.where((job) => job.isActive).toList();
      recruiters = recruiterList;
      applications = applicationList;
      jobSeekers = jobSeekerList;
      skillVerifications = skillVerificationList;

      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AdminDrawer(),
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,

        child: SafeArea(
          child: Column(
            children: [
              AdminHeader(),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadProfile,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        DailyProgressCard(jobs: jobs, loading: false),
                        const SizedBox(height: 20),
                        _statsCards(
                          recruiters,
                          jobSeekers,
                          activejobs,
                          applications,
                          skillVerifications,
                        ),
                        const SizedBox(height: 16),
                        _recruiterVerification(recruiters),
                        const SizedBox(height: 16),
                        _recentPayments(),
                        const SizedBox(height: 16),
                        _jobBarChart(
                          recruiters,
                          jobSeekers,
                          activejobs,
                          applications,
                          skillVerifications,
                        ),
                        const SizedBox(height: 16),
                        _activityLineChart(
                          recruiters,
                          jobSeekers,
                          activejobs,
                          applications,
                          skillVerifications,
                        ),
                        const SizedBox(height: 16),
                        _bottomCards(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statsCards(
    List<Recruiter> recruiters,
    List<JobSeekerModel> jobSeekers,
    List<JobOffer> activeJobs,
    List<JobApplicationModel> applications,
    List<SkillVerificationRequest> skillVerifications,
  ) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _BigStatCard(
                title: "Active Jobs",
                value: activeJobs.length.toString(),
                subtitle: "Open positions",
                icon: Icons.work_outline_rounded,
                gradient: AppColors.gradientOrange,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStatCard(
                title: "Skill Requests",
                value: skillVerifications.length.toString(),
                subtitle: "Pending verification",
                icon: Icons.verified_user_rounded,
                gradient: AppColors.gradientPink,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _BigStatCard(
                title: "Recruiters",
                value: recruiters.length.toString(),
                subtitle: "Registered employers",
                icon: Icons.business_center,
                gradient: AppColors.gradientgreen,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _BigStatCard(
                title: "Job Seekers",
                value: jobSeekers.length.toString(),
                subtitle: "Active candidates",
                icon: Icons.people_alt_rounded,
                gradient: AppColors.gradientgreen1,
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ---------------- RECRUITER VERIFICATION ----------------
  Widget _recruiterVerification(List<Recruiter> recruiters) {
    final inactiveRecruiters = recruiters.where((r) => !r.isActive).toList();
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recruiter Verification",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          SizedBox(
            height: 220,
            child: ListView.separated(
              itemCount: inactiveRecruiters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final recruiter = inactiveRecruiters[index];

                return InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            RecruiterDetailPage(recruiter: recruiter),
                      ),
                    );
                  },
                  child: _recruiterRow(
                    recruiter.pharmacyName,
                    recruiter.pharmacistFirstName,
                    recruiter.city,
                    recruiter.isActive,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _recruiterRow(
    String name,
    String owner,
    String location,
    bool approved,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// Pharmacy avatar
          CircleAvatar(
            radius: 18,
            backgroundColor: approved
                ? Colors.teal.withOpacity(.15)
                : Colors.pink.withOpacity(.15),
            child: Image.asset(
              'assets/logo.png',
              width: 18, // set your desired width
              height: 18, // set your desired height
              fit: BoxFit.contain,
            ),
          ),

          const SizedBox(width: 12),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  "$owner • $location",
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          /// Status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: approved
                  ? Colors.teal.withOpacity(.15)
                  : Colors.pink.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              approved ? "Approved" : "Pending",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: approved ? Colors.teal : Colors.pink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PAYMENTS ----------------
  Widget _recentPayments() {
    final payments = [
      ("PharmaCenter", "\$199", "02/12/2024", "Credit Card"),
      ("VitalPharm", "\$299", "01/28/2024", "Credit Card"),
      ("MedLife", "\$99", "01/20/2024", "Credit Card"),
      // imagine 100+ records here
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recent Payments",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          /// 👇 Scrollable list
          SizedBox(
            height: 220,
            child: ListView.separated(
              itemCount: payments.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final p = payments[index];
                return _payment(p.$1, p.$2, p.$3, p.$4);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _payment(String name, String amount, String date, String method) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          /// Payment icon
          CircleAvatar(
            radius: 18,
            backgroundColor: Colors.indigo.withOpacity(.15),
            child: const Icon(Icons.payment, size: 18, color: Colors.indigo),
          ),

          const SizedBox(width: 12),

          /// Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  date,
                  style: const TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
            ),
          ),

          /// Amount
          Text(
            amount,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),

          const SizedBox(width: 10),

          /// Method badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.teal.withOpacity(.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              method,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Colors.teal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _jobBarChart(
    List<Recruiter> recruiters,
    List<JobSeekerModel> jobSeekers,
    List<JobOffer> activeJobs,
    List<JobApplicationModel> applications,
    List<SkillVerificationRequest> skillVerifications,
  ) {
    final int openJobs = activeJobs.where((j) => j.isActive == true).length;
    final int closedJobs = activeJobs.where((j) => j.isActive == false).length;
    final int skillRequests = skillVerifications.length;

    final maxValue = [
      openJobs,
      closedJobs,
      skillRequests,
    ].reduce((a, b) => a > b ? a : b);

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: const [
              Icon(Icons.bar_chart_rounded, size: 18, color: Colors.indigo),
              SizedBox(width: 6),
              Text(
                "Platform Activity",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Jobs and skill verification overview",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          /// Chart
          SizedBox(
            height: 180,
            child: BarChart(
              BarChartData(
                maxY: maxValue == 0 ? 5 : maxValue.toDouble() + 2,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      interval: maxValue <= 5
                          ? 1
                          : (maxValue / 4).ceilToDouble(),
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, _) {
                        switch (value.toInt()) {
                          case 0:
                            return _xLabel("Open Jobs");
                          case 1:
                            return _xLabel("Closed Jobs");
                          case 2:
                            return _xLabel("Skill Requests");
                          default:
                            return const SizedBox.shrink();
                        }
                      },
                    ),
                  ),
                ),

                barGroups: [
                  _bar(0, openJobs, [Colors.blue, Colors.blueAccent]),
                  _bar(1, closedJobs, [Colors.grey, Colors.black54]),
                  _bar(2, skillRequests, [
                    Colors.purple,
                    Colors.deepPurpleAccent,
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, int value, List<Color> colors) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: value.toDouble(),
          width: 18,
          borderRadius: BorderRadius.circular(6),
          gradient: LinearGradient(colors: colors),
        ),
      ],
    );
  }

  Widget _xLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Text(
        text,
        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _activityLineChart(
    List<Recruiter> recruiters,
    List<JobSeekerModel> jobSeekers,
    List<JobOffer> activeJobs,
    List<JobApplicationModel> applications,
    List<SkillVerificationRequest> skillVerifications,
  ) {
    final int recruiterCount = recruiters.length;
    final int jobSeekerCount = jobSeekers.length;

    /// Create smooth relative trend (5 points)
    List<FlSpot> _generateTrend(int total) {
      if (total == 0) {
        return const [
          FlSpot(0, 0),
          FlSpot(1, 0),
          FlSpot(2, 0),
          FlSpot(3, 0),
          FlSpot(4, 0),
        ];
      }

      return [
        FlSpot(0, total * 0.2),
        FlSpot(1, total * 0.4),
        FlSpot(2, total * 0.6),
        FlSpot(3, total * 0.8),
        FlSpot(4, total.toDouble()),
      ];
    }

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: const [
              Icon(Icons.show_chart_rounded, size: 18, color: Colors.indigo),
              SizedBox(width: 6),
              Text(
                "User Activity",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Job seekers vs recruiters (relative trend)",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          /// Chart
          SizedBox(
            height: 180,
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 4,
                minY: 0,
                maxY:
                    [
                      recruiterCount,
                      jobSeekerCount,
                    ].reduce((a, b) => a > b ? a : b).toDouble() +
                    2,

                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),

                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, _) => Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
                  rightTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  topTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                ),

                lineBarsData: [
                  /// 🔵 Job Seekers
                  LineChartBarData(
                    spots: _generateTrend(jobSeekerCount),
                    isCurved: true,
                    barWidth: 3,
                    gradient: const LinearGradient(
                      colors: [Colors.blue, Colors.blueAccent],
                    ),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.blue.withOpacity(.25),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  /// 🟣 Recruiters
                  LineChartBarData(
                    spots: _generateTrend(recruiterCount),
                    isCurved: true,
                    barWidth: 3,
                    gradient: const LinearGradient(
                      colors: [Colors.purple, Colors.deepPurpleAccent],
                    ),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.purple.withOpacity(.20),
                          Colors.transparent,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// Legend
          Row(
            children: const [
              _LegendDot(color: Colors.blue, label: "Job Seekers"),
              SizedBox(width: 16),
              _LegendDot(color: Colors.purple, label: "Recruiters"),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- BOTTOM ----------------
  Widget _bottomCards() {
    return Row(
      children: [
        _miniCard("Reported Issues", "12", Icons.error, Colors.pink),
        const SizedBox(width: 12),
        _miniCard("Total Earnings", "\$", Icons.attach_money, Colors.teal),
      ],
    );
  }

  Widget _miniCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: _card(
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title),
                Text(
                  value,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- CARD BASE ----------------
  Widget _card({required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: premiumShadow,
      ),
      child: child,
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Gradient gradient;

  const _BigStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(24),
            boxShadow: premiumShadow,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              /// ICON
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.18),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),

              const SizedBox(height: 12),

              /// VALUE
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              /// TITLE
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),

              /// SUBTITLE
              Text(
                subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        );
      },
    );
  }
}



class DailyProgressCard extends StatefulWidget {
  final List<JobOffer> jobs;
  final bool loading;

  const DailyProgressCard({
    super.key,
    required this.jobs,
    required this.loading,
  });

  @override
  State<DailyProgressCard> createState() => _DailyProgressCardState();
}

class _DailyProgressCardState extends State<DailyProgressCard> {
  @override
  Widget build(BuildContext context) {
    if (widget.loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }

    final activeJobs = widget.jobs.where((job) => job.isActive == true).length;
    final totalJobs = widget.jobs.length;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: AppColors.gradientgreen1,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Job Offer Status Overview",
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  "You currently have $activeJobs of $totalJobs jobs open",
                  style: TextStyle(color: AppColors.white),
                ),
                const SizedBox(height: 14),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.lightgreen,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const AdminAccountScreen(
                          mode: AdminFormMode.edit,
                        ),
                      ),
                    );
                  },
                  child: const Text(
                    "Manage Account",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          jobStatusCircle(active: activeJobs, total: widget.jobs.length),
        ],
      ),
    );
  }
}

Widget jobStatusCircle({required int active, required int total}) {
  final double ratio = total == 0 ? 0 : active / total;

  return TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: ratio),
    duration: const Duration(milliseconds: 1000),
    curve: Curves.easeOutCubic,
    builder: (_, value, __) {
      return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 70,
            width: 70,
            child: CircularProgressIndicator(
              value: value,
              strokeWidth: 7,
              color: const Color(0xFF97F56C),
              backgroundColor: Colors.white24,
            ),
          ),

          // Center content (counts, not %)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "$active/$total",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                "Active",
                style: TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ],
      );
    },
  );
}
