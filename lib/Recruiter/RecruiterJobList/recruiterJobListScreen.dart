import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';

import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JobList/JobSearchRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';

import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecruiterJobListScreen extends StatefulWidget {
  const RecruiterJobListScreen({super.key});

  @override
  State<RecruiterJobListScreen> createState() => _RecruiterJobListScreenState();
}

class _RecruiterJobListScreenState extends State<RecruiterJobListScreen> {
  final _repo = JobSearchRepository();

  bool loading = true;
  List<JobOfferWithRecruiter> jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    jobs = await _repo.getAllJobsWithRecruiters(user.userId);
    setState(() => loading = false);
  }

  Future<void> _reloadJobs() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => loading = true);
    jobs = await _repo.getAllJobsWithRecruiters(user.userId);
    setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 12),
            const DashboardHeader(),

            Expanded(
              child: RefreshIndicator(
                onRefresh: _reloadJobs,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : jobs.isEmpty
                    ? ListView(children: [_EmptyState()])
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                        itemCount: jobs.length,
                        itemBuilder: (_, i) =>
                            _JobCard(job: jobs[i], buttonText: "View Details"),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _JobCard extends StatelessWidget {
  final JobOfferWithRecruiter job;
  final String buttonText;

  const _JobCard({required this.job, required this.buttonText});

  Future<void> _deleteJob(BuildContext context) async {
    final shouldDelete = await _confirmDeleteJob(context);
    if (!shouldDelete) return;

    final jobAppRepo = JobApplicationRepository();

    // 2️⃣ Delete the job itself
    await jobAppRepo.delete(job.jobOffer.docId!);

    // 3️⃣ Refresh recruiter job list
    context
        .findAncestorStateOfType<_RecruiterJobListScreenState>()
        ?._reloadJobs();
  }

  static const Map<String, IconData> jobTitleIcons = {
    "Gerant": Icons.business,
    "Pharmacist": Icons.local_pharmacy,
    "Physician": Icons.medical_services,
    "Senior Salesperson": Icons.person_outline,
    "Sales Specialist": Icons.person_add,
    "Intern (Training / Future Recruitment)": Icons.school,
    "Labeling Specialist": Icons.label,
    "Data Entry Specialist": Icons.keyboard,
    "Stock Management Specialist": Icons.inventory,
  };

  String formatSalary(String salary) {
    final value = int.tryParse(salary.replaceAll(',', '').trim());

    if (value == null) return salary;

    if (value >= 1000000) {
      return "${(value / 1000000).toStringAsFixed(1).replaceAll('.0', '')}M / Year";
    } else if (value >= 1000) {
      return "${(value / 1000).toStringAsFixed(0)}K / Year";
    }

    return "$value / Year";
  }

  String timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);

    if (diff.inMinutes < 1) return "Just now";
    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hours ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";
    if (diff.inDays < 30) return "${(diff.inDays / 7).floor()} weeks ago";
    if (diff.inDays < 365) return "${(diff.inDays / 30).floor()} months ago";
    return "${(diff.inDays / 365).floor()} years ago";
  }

  @override
  Widget build(BuildContext context) {
    final icon =
        jobTitleIcons[job.jobTitle] ?? Icons.work_outline; // fallback icon

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => RecruiterJobDetailScreen(job: job)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.greenCeladon,
                  child: Icon(icon, color: Colors.white),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        job.jobTitle,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        job.pharmacyName,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                ),

                IconButton(
                  icon: const Icon(Icons.more_vert, size: 22),
                  splashRadius: 22,
                  onPressed: () => _openJobActions(context),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
             children: [
              Text(
              "Job Type: ${job.jobType}",
              style: const TextStyle(fontSize: 13),
              ),
              const Spacer(),
              _StatusChip(label: job.jobOffer.isActive? "Open":"Close", color: job.jobOffer.isActive?AppColors.greenCeladon:AppColors.pinkO)
             ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.greenCeladon,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    buttonText,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  formatSalary(job.salary),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                 Text(
                  timeAgo(job.createdAt),
                  style: const TextStyle(color: AppColors.textLight),
                ),
               
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openJobActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _BottomActionTile(
                icon: Icons.edit_outlined,
                label: "Edit Job",
                onTap: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => JobFormScreen(
                        mode: JobFormMode.edit,
                        jobOffer: job.jobOffer,
                      ),
                    ),
                  );

                  if (updated == true) {
                    context
                        .findAncestorStateOfType<_RecruiterJobListScreenState>()
                        ?._reloadJobs();
                  }
                },
              ),

              _BottomActionTile(
                icon: Icons.delete_outline,
                label: "Delete Job",
                isDestructive: true,
                onTap: () async {
                  Navigator.pop(context);
                  await _deleteJob(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<bool> _confirmDeleteJob(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Delete Job"),
              content: const Text(
                "Do you really want to delete this job?\n\n"
                "This action is permanent and you will NOT be able "
                "to recover this job.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  
                  style: ElevatedButton.styleFrom(backgroundColor:AppColors.red,iconColor: AppColors.white),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text("Delete",style: TextStyle(color: AppColors.white),),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class _BottomActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  const _BottomActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? Colors.red : AppUI.textPrimary;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 8),
      leading: Icon(icon, color: color),
      title: Text(
        label,
        style: TextStyle(fontWeight: FontWeight.w600, color: color),
      ),
      onTap: onTap,
    );
  }
}

/// Status Chip
class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// Analytics Chip
class _AnalyticsChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _AnalyticsChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}


class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.work_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No job offers yet",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Create your first job offer to get started",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

// enum JobStatus { draft, published, closed }

class DashboardHeader extends StatefulWidget {
  const DashboardHeader({super.key});

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  final _repoRecruiter = RecruiterRepository();
  Recruiter? _profile; // 🔥 store profile
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
          const CircleAvatar(
            radius: 24,
            backgroundImage: AssetImage('assets/avatar.png'),
          ),

          const SizedBox(width: 14),

          // Info Section
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Posted Jobs",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.darkGreen,
                ),
              ),
              const SizedBox(height: 4),

              Row(
                children: [
                  Image.asset(
                    'assets/logo.png',
                    width: 18, // set your desired width
                    height: 18, // set your desired height
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _profile?.pharmacyName ?? "—",
                    style: const TextStyle(
                      color: AppColors.darkGreen,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(
                    Icons.location_on,
                    size: 18,
                    color: AppColors.green,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    _profile?.city ?? '',
                    style: const TextStyle(
                      color: AppColors.green,
                      fontSize: 12,
                    ),
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
