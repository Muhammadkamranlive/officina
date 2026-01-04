import 'package:client/AppColors/AppColors.dart';
import 'package:client/Authentication/Login/login.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerProfilesScreen.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Recruiter/RecruiterPayment/RecruiterPayment.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/routes/app_routes.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PremiumDashboardScreen extends StatefulWidget {
  const PremiumDashboardScreen({super.key});

  @override
  State<PremiumDashboardScreen> createState() => _PremiumDashboardScreenState();
}

class _PremiumDashboardScreenState extends State<PremiumDashboardScreen> {
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

    final profile = await jobRepo.getByUserId(user.userId);

    setState(() {
      jobs = profile;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const ProfileDrawer(),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ FIXED HEADER (NOT SCROLLING)
            const DashboardHeader(),

            // ✅ SCROLLABLE CONTENT
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadProfile,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      DailyProgressCard(jobs: jobs, loading: loading),
                      const SizedBox(height: 24),
                      ProjectOverviewSection(jobs: jobs),
                      const SizedBox(height: 24),
                      const TodayTaskSection(),
                      const SizedBox(height: 24),
                      // UpcomingTaskSection(),
                      // SizedBox(height: 24),
                      TaskDetailsSection(jobs: jobs,laoding: loading),
                      // SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
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

class ProfileDrawer extends StatelessWidget {
  const ProfileDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final recruiter = context.read<AuthProvider>().user;

    return Drawer(
      elevation: 0,
      backgroundColor: AppColors.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 🔥 PREMIUM HEADER
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 34,
                    backgroundImage: AssetImage('assets/avatar.png'),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    "My Account",
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    recruiter?.email ?? "",
                    style: const TextStyle(
                      color: AppColors.white,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ⚙️ MANAGE Payments
            _drawerAction(
              context,
              icon: Icons.payment_outlined,
              title: "Payments",
              subtitle: "See Subscription Payments",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RecruiterPayment()),
                );
              },
            ),
            // ⚙️ MANAGE ACCOUNT (CARD STYLE)
            _drawerAction(
              context,
              icon: Icons.settings_outlined,
              title: "Manage Account",
              subtitle: "Edit profile & Pharmacy Detail",
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const RecruiterAccountScreen(
                      mode: AccountFormMode.edit,
                    ),
                  ),
                );
              },
            ),

            // 🚪 LOGOUT (DESTRUCTIVE)
            _drawerAction(
              context,
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out of your account",
              isDestructive: true,
              onTap: () {
                 Navigator.of(
                  context,
                  rootNavigator: true,
                ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
                    },
            ),

            const Spacer(),

            // FOOTER
            const Padding(
              padding: EdgeInsets.only(left: 20, bottom: 16),
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

  // 🔹 Premium drawer item
  Widget _drawerAction(
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

class ProjectOverviewSection extends StatefulWidget {
  final List<JobOffer> jobs;
  const ProjectOverviewSection({super.key, required this.jobs});

  @override
  State<ProjectOverviewSection> createState() => _ProjectOverviewSectionState();
}

class _ProjectOverviewSectionState extends State<ProjectOverviewSection> {
  @override
  Widget build(BuildContext context) {
    // Replace these with real values from your data source
    final int totalPositions = widget.jobs.length;
    final int filledPositions = widget.jobs.where((x) => x.isActive == false).length;
    final int openPositions = totalPositions - filledPositions;
    final int applications = 5;

    final int filledPercent = totalPositions == 0
        ? 0
        : ((filledPositions / totalPositions) * 100).round();

    final int openPercent = totalPositions == 0
        ? 0
        : ((openPositions / totalPositions) * 100).round();

    return Row(
      children: [
        Expanded(
          child: OverviewCard(
            icon: Icons.work_outline,
            title: "Open Jobs",
            subtitle: "$openPositions of $totalPositions open",
            value: "$openPercent%",
            progress: "$openPercent%",
            color: AppColors.gradientOrange,
          ),
        ),

        /// Filled Positions (PERCENTAGE)
        SizedBox(width: 12),
        Expanded(
          child: OverviewCard(
            icon: Icons.check_circle_outline,
            title: "Filled Positions",
            subtitle: "$filledPositions of $totalPositions filled",
            value: "$filledPercent%",
            progress: "$filledPercent%",
            color: AppColors.gradientPink,
          ),
        ),
      ],
    );
  }
}

class OverviewCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String progress;
  final Gradient color;
  final IconData icon;

  const OverviewCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Text(
                progress,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 4),

          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontSize: 12,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}


class TodayTaskSection extends StatelessWidget {
  const TodayTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    final int totalCandidates = 10;
    final int reviewedCandidates = 4;
    final int remainingCandidates = totalCandidates - reviewedCandidates;

    final double reviewProgress =
        totalCandidates == 0 ? 0 : remainingCandidates / totalCandidates;

    final int totalMessages = 10;
    final int readMessages = 4;
    final int unreadMessages = totalMessages - readMessages;

    final double chatProgress =
        totalMessages == 0 ? 0 : unreadMessages / totalMessages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title("Today’s Hiring Activity"),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 150,
                child: TaskCard(
                  title:
                      "Review Profiles\nReviewed: $reviewedCandidates/$totalCandidates",
                  progress: reviewProgress,
                  icon: Icons.assignment_ind_outlined,
                  color: const Color(0xFF4AA3FF),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: SizedBox(
                height: 150,
                child: TaskCard(
                  title:
                      "Chat\nRead: $readMessages/$totalMessages",
                  progress: chatProgress,
                  icon: Icons.chat_bubble_outline,
                  color: const Color(0xFF8E6BFF),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}


class TaskCard extends StatelessWidget {
  final String title;
  final double progress;
  final Color color;
  final IconData icon;

  const TaskCard({
    super.key,
    required this.title,
    required this.progress,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color, color.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.35),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// 🔹 ICON + % ROW
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              Text(
                "${(progress * 100).toInt()}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          /// 🔹 TITLE (SAFE)
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),

          const Spacer(), // ⭐ KEY FOR EQUAL HEIGHT
          /// 🔹 PROGRESS BAR
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white30,
              valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class TaskDetailsSection extends StatefulWidget {
  final List<JobOffer> jobs;
  final bool laoding;
  const TaskDetailsSection({super.key, required this.jobs,required this.laoding});

  @override
  State<TaskDetailsSection> createState() => _TaskDetailsSectionState();
}

class _TaskDetailsSectionState extends State<TaskDetailsSection> {
  @override
  Widget build(BuildContext context) {
    if (widget.laoding ) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: LinearProgressIndicator(),
      );
    }
    if(widget.jobs.isEmpty){
      return SizedBox(height: 10,);
    }
    // Example data – replace with real values
    final int totalJobs = widget.jobs.length;
    final int filledJobs = widget.jobs.where((x) => x.isActive == false).length;
    final int openJobs = totalJobs - filledJobs;
    final int candidates = 10;
    // ignore: non_constant_identifier_names
    final int InterviewsCandidates = 2;

    final candidatePercentage = totalJobs == 0
        ? 0
        : (InterviewsCandidates / candidates) * 100;
    final double filledPercent = candidates == 0
        ? 0
        : (filledJobs / totalJobs) * 100;
    final double openPercent = totalJobs == 0
        ? 0
        : (openJobs / totalJobs) * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "All Time Job Offers Statistics",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),

        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              const SizedBox(height: 20),

              /// 🔵🟠 DONUT CHART
              SizedBox(
                height: 180,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 4,
                    centerSpaceRadius: 50,
                    sections: [
                      PieChartSectionData(
                        value: filledPercent,
                        color: AppColors.darkGreen,
                        title: "${filledPercent.round()}%",
                        radius: 55,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: openPercent,
                        color: AppColors.greenCeladon,
                        title: "${openPercent.round()}%",
                        radius: 55,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PieChartSectionData(
                        value: openPercent,
                        color: AppColors.lightgreen,
                        title: "${candidatePercentage.round()}%",
                        radius: 55,
                        titleStyle: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              /// 📌 LEGEND / EXPLANATION (THIS IS CRITICAL)
              _legendItem(
                color: AppColors.darkGreen,
                title: "Filled Positions",
                description: "$filledJobs of $totalJobs jobs filled",
              ),
              const SizedBox(height: 8),
              _legendItem(
                color: AppColors.greenCeladon,
                title: "Open Positions",
                description: "$openJobs of $totalJobs jobs still open",
              ),
              const SizedBox(height: 8),
              _legendItem(
                color: AppColors.lightgreen,
                title: "Candidates",
                description: "$filledJobs of $totalJobs Candidates Interviewed",
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendItem({
    required Color color,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 14,
          height: 14,
          margin: const EdgeInsets.only(top: 4),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              Text(
                description,
                style: const TextStyle(color: Colors.black54, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _title(String title) {
    return Text(
      title,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
    );
  }
}

class UpcomingTaskSection extends StatelessWidget {
  const UpcomingTaskSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _titleWithAction("Upcoming Hiring Actions", "See all"),
        const SizedBox(height: 12),

        _upcomingTaskTile(
          title: "Hiring Staff Pharmacist",
          date: DateTime.now()
              .add(const Duration(days: 2))
              .toString()
              .substring(0, 10),
          icon: Icons.person_add_alt,
        ),

        _upcomingTaskTile(
          title: "Staff Pharmacist Vacancy",
          date: DateTime.now()
              .add(const Duration(days: 4))
              .toString()
              .substring(0, 10),
          icon: Icons.person_add_alt,
        ),

        _upcomingTaskTile(
          title: "Staff Pharmacist Opportunity",
          date: DateTime.now()
              .add(const Duration(days: 6))
              .toString()
              .substring(0, 10),
          icon: Icons.person_add_alt,
        ),
      ],
    );
  }
}

Widget _upcomingTaskTile({
  required String title,
  required String date,
  required IconData icon,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: AppColors.green.withOpacity(.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.green),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),
            ],
          ),
        ),
        const Icon(Icons.more_vert, color: Colors.grey),
      ],
    ),
  );
}

Widget _titleWithAction(String title, String action) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
      Text(
        action,
        style: const TextStyle(
          color: AppColors.green,
          fontWeight: FontWeight.w500,
        ),
      ),
    ],
  );
}

Widget _title(String text) => Text(
  text,
  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
);

class _LogoutButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: _customButton(
        text: "Logout",
        onPressed: () {
          Navigator.of(
            context,
            rootNavigator: true,
          ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
        },
        size: size,
        gradient: AppColors.gradientgreen,
        shadowColor: AppColors.green,
      ),
    );
  }
}

// Custom Button Widget
Widget _customButton({
  required String text,
  required void Function()? onPressed,
  required Size size,
  required Gradient gradient,
  required Color shadowColor,
}) {
  return Container(
    decoration: BoxDecoration(
      gradient: gradient,
      borderRadius: BorderRadius.circular(14),
      boxShadow: [
        BoxShadow(
          color: shadowColor.withOpacity(0.4),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.transparent, // important
        shadowColor: Colors.transparent, // remove default shadow
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w600, // SemiBold = premium
          color: Colors.white,
          letterSpacing: 0.3,
        ),
      ),
    ),
  );
}
