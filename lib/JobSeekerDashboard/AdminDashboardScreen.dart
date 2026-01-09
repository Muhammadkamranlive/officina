import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/routes/app_routes.dart';
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
  List<JobOffer> jobs = [];
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

    setState(() {
      jobs = profile;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: JobSeekerDrawer(),
      backgroundColor: AppColors.background,
      body: Container(
        color: AppColors.background,

        child: SafeArea(
          child: Column(
            children: [
              DashboardHeader(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      DailyProgressCard(jobs: jobs, loading: false),
                      const SizedBox(height: 20),
                      _statsCards(),
                      const SizedBox(height: 16),
                      _recruiterVerification(),
                      const SizedBox(height: 16),
                      _recentPayments(),
                      const SizedBox(height: 16),
                      _jobBarChart(),
                      const SizedBox(height: 16),
                      _activityLineChart(),
                      const SizedBox(height: 16),
                      _bottomCards(),
                      
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- STATS ----------------
  Widget _statsCards() {
    return Column(
      children: [
        Row(
          children: [
            _statCard("Total Recruiters", "1,245", Icons.person, Colors.teal),
            const SizedBox(width: 12),
            _statCard("Total Job Seekers", "3,678", Icons.people, Colors.pink),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _statCard("Active Job Listings", "854", Icons.work, Colors.blue),
            const SizedBox(width: 12),
            _statCard(
              "Total Revenue",
              "\$12,450",
              Icons.attach_money,
              Colors.purple,
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard(String title, String value, IconData icon, Color color) {
    return Expanded(
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.15),
              child: Icon(icon, color: color),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Color(0xFF2E2E48))),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2E2E48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- RECRUITER VERIFICATION ----------------
  Widget _recruiterVerification() {
    final recruiters = [
      ("ABC Pharmacy", "Dr. Khaled Ahmed", "Algiers", false),
      ("MediPlus", "Nadia Louati", "Oran", false),
      ("HealthCare Pharma", "Samir Belhadi", "Constantine", true),
      // imagine 100+ records here
    ];

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Recruiter Verification",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),

          /// 👇 Scrollable section
          SizedBox(
            height: 220, // fixed height = scrollable
            child: ListView.separated(
              itemCount: recruiters.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final r = recruiters[index];
                return _recruiterRow(r.$1, r.$2, r.$3, r.$4);
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
            child: Icon(
              Icons.local_pharmacy,
              size: 18,
              color: approved ? Colors.teal : Colors.pink,
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

  // ---------------- CHARTS ----------------
  Widget _chartsRow() {
    return Row(
      children: [
        Expanded(child: _jobBarChart()),
        const SizedBox(width: 16),
        Expanded(child: _activityLineChart()),
      ],
    );
  }

  Widget _jobBarChart() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: const [
              Icon(Icons.bar_chart, size: 18, color: Colors.indigo),
              SizedBox(width: 6),
              Expanded(
                child: Text(
                  "Job Listings",
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Open vs closed positions",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          /// Chart container
          Container(
            height: 170,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: BarChart(
              BarChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                barGroups: [
                  BarChartGroupData(
                    x: 0,
                    barRods: [
                      BarChartRodData(
                        toY: 450,
                        gradient: const LinearGradient(
                          colors: [Colors.indigo, Colors.blueAccent],
                        ),
                        width: 14,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 1,
                    barRods: [
                      BarChartRodData(
                        toY: 200,
                        gradient: const LinearGradient(
                          colors: [Colors.pink, Colors.pinkAccent],
                        ),
                        width: 14,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                  BarChartGroupData(
                    x: 2,
                    barRods: [
                      BarChartRodData(
                        toY: 150,
                        gradient: const LinearGradient(
                          colors: [Colors.teal, Colors.tealAccent],
                        ),
                        width: 14,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _activityLineChart() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// Header
          Row(
            children: const [
              Icon(Icons.show_chart, size: 18, color: Colors.indigo),
              SizedBox(width: 6),
              Text(
                "User Activity",
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            "Daily active users",
            style: TextStyle(fontSize: 12, color: Colors.black54),
          ),
          const SizedBox(height: 16),

          /// Chart container
          Container(
            height: 170,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.indigo.withOpacity(.05),
              borderRadius: BorderRadius.circular(14),
            ),
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(show: false),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 2),
                      FlSpot(1, 4),
                      FlSpot(2, 3),
                      FlSpot(3, 5),
                      FlSpot(4, 4),
                    ],
                    isCurved: true,
                    barWidth: 3,
                    gradient: const LinearGradient(
                      colors: [Colors.indigo, Colors.blueAccent],
                    ),
                    dotData: FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          Colors.indigo.withOpacity(.25),
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

class JobSeekerDrawer extends StatelessWidget {
  const JobSeekerDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          children: [
            /// HEADER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: AppColors.gradientgreen1,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "My Profile",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            _drawerItem(
              context,
              icon: Icons.person_outline,
              title: "Edit Profile",
              subtitle: "Personal & professional info",
              onTap: () {},
            ),

            _drawerItem(
              context,
              icon: Icons.verified_outlined,
              title: "Skills Authentication",
              subtitle: "Verify your skills",
              onTap: () {},
            ),

            _drawerItem(
              context,
              icon: Icons.work_outline,
              title: "My Applications",
              subtitle: "Track job applications",
              onTap: () {},
            ),

            _drawerItem(
              context,
              icon: Icons.chat_bubble_outline,
              title: "Messages",
              subtitle: "Recruiter conversations",
              onTap: () {},
            ),

            _drawerItem(
              context,
              icon: Icons.lock_outline,
              title: "Account Setting",
              subtitle: "Control profile visibility",
              onTap: () {
                 
              },
            ),

            _drawerItem(
              context,
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out",
              isDestructive: true,
              onTap: () {
                Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
              },
            ),

            const Spacer(),

            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                "© 2025 OFFICINA",
                style: TextStyle(color: Colors.black45, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final color = isDestructive ? Colors.redAccent : AppColors.darkGreen;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final _repoRecruiter = RecruiterRepository();
  Recruiter? _profile; //store profile
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final profile = await _repoRecruiter.getByUid(user.userId);

    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          GestureDetector(
            onTap: () {
              Scaffold.of(context).openDrawer();
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(Icons.menu, color: AppColors.darkGreen),
            ),
          ),

          const SizedBox(width: 10),

          // Info Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hi, ${_profile?.pharmacistFirstName} ${_profile?.pharmacistLastName}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 18, // set your desired width
                    height: 18, // set your desired height
                    fit: BoxFit.contain,
                  ),

                  SizedBox(width: 7),
                  Text(
                    _profile?.pharmacyName ?? "—",
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 7),
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    _profile?.city ?? '',
                    style: TextStyle(color: AppColors.green, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),

          const Spacer(),

          // Notification Button
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              );
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none,
                color: AppColors.darkGreen,
              ),
            ),
          ),
        ],
      ),
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
                        builder: (_) => const RecruiterAccountScreen(
                          mode: AccountFormMode.edit,
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
