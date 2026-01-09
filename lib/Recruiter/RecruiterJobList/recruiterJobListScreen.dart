import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
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
  final _repo = JobOfferRepository();

  bool loading = true;
  List<JobOffer> jobs = [];

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    jobs = await _repo.getByUserId(user.userId);
    setState(() => loading = false);
  }

  Future<void> _reloadJobs() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    setState(() => loading = true);
    jobs = await _repo.getByUserId(user.userId);
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
                        itemBuilder: (_, i) => _JobCard(job: jobs[i]),
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
  final JobOffer job;

  const _JobCard({required this.job});

  /// Converts createdAt to "time ago" string
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

  List<String> _visibleSkills(List<String> skills) {
    return skills.take(3).toList();
  }

  String _trimSkill(String skill, {int maxLength = 10}) {
    if (skill.length <= maxLength) return skill;
    return "${skill.substring(0, maxLength)}";
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
                icon: Icons.visibility_outlined,
                label: "View Job",
                onTap: () {
                  Navigator.pop(context);
                  // Navigator.push(
                  //   context,
                  //   MaterialPageRoute(
                  //     builder: (_) => RecruiterJobDetailScreen(job: job),
                  //   ),
                  // );
                },
              ),

              _BottomActionTile(
                icon: Icons.edit_outlined,
                label: "Edit Job",
                onTap: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          JobFormScreen(mode: JobFormMode.edit, jobOffer: job),
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
                onTap: () {
                  Navigator.pop(context);
                  // call delete confirmation
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = job.isActive
        ? _StatusData("Open", Colors.green)
        : _StatusData("Draft", Colors.orange);

    return GestureDetector(
      // onTap: () {
      //   Navigator.push(
      //     context,
      //     MaterialPageRoute(builder: (_) => RecruiterJobDetailScreen(job: job)),
      //   );
      // },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.07),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            // Status Accent Bar
            Container(
              width: 6,
              height: 140,
              decoration: BoxDecoration(
                color: status.color,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(18),
                ),
              ),
            ),

            // Card content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            job.jobTitle,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppUI.textPrimary,
                            ),
                          ),
                        ),
                        _StatusChip(label: status.label, color: status.color),
                        IconButton(
                          icon: const Icon(Icons.more_vert, size: 22),
                          splashRadius: 22,
                          onPressed: () => _openJobActions(context),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Job Type
                    Text(
                      "Job Type: ${job.jobType}",
                      style: const TextStyle(color: AppUI.textSecondary),
                    ),

                    const SizedBox(height: 6),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final skills = job.skills;
                        final children = <Widget>[];

                        double usedWidth = 0;
                        const spacing = 6.0;

                        for (int i = 0; i < skills.length; i++) {
                          final text = skills[i];

                          final textPainter = TextPainter(
                            text: TextSpan(
                              text: text,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            maxLines: 1,
                            textDirection: TextDirection.ltr,
                          )..layout();

                          final chipWidth = textPainter.width + 20; // padding

                          if (usedWidth + chipWidth > constraints.maxWidth) {
                            children.add(
                              const Text(
                                "...",
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: AppUI.textSecondary,
                                ),
                              ),
                            );
                            break;
                          }

                          usedWidth += chipWidth + spacing;

                          children.add(
                            Padding(
                              padding: const EdgeInsets.only(right: spacing),
                              child: _SkillChip(label: text),
                            ),
                          );
                        }

                        return Row(children: children);
                      },
                    ),

                    const SizedBox(height: 12),

                    // Actions
                    Row(
                      children: [
                        // Optional: Add more chips like Views / Applicants
                        _AnalyticsChip(
                          icon: Icons.remove_red_eye_outlined,
                          label: "124 Views",
                          color: Colors.blueGrey,
                        ),
                        const SizedBox(width: 8),
                        _AnalyticsChip(
                          icon: Icons.people_outline,
                          label: "18 Applicants",
                          color: Colors.green,
                        ),
                        const SizedBox(width: 8),
                        _AnalyticsChip(
                          icon: Icons.schedule,
                          label: timeAgo(job.createdAt),
                          color: AppColors.greenCeladon,
                        ),
                      ],
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

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppUI.textSecondary.withOpacity(.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppUI.textSecondary,
        ),
        maxLines: 1,
        overflow: TextOverflow.clip,
      ),
    );
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

/// Status Data Helper
class _StatusData {
  final String label;
  final Color color;
  _StatusData(this.label, this.color);
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
