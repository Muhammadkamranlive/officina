import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/JobStatsSection/JobStatsSection.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerDetailScreen.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplicantViewModel.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Model/JobSeekerModel/JobViews.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JbViews/JobViews_Repository.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Services/ChatService.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecruiterJobDetailScreen extends StatefulWidget {
  final JobOfferWithRecruiter job;
  const RecruiterJobDetailScreen({super.key, required this.job});

  @override
  State<RecruiterJobDetailScreen> createState() =>
      _RecruiterJobDetailScreenState();
}

class _RecruiterJobDetailScreenState extends State<RecruiterJobDetailScreen> {
  bool loading = true;
  final JobViewsRepository _repository = JobViewsRepository();
  final JobApplicationRepository _jobAppRepo = JobApplicationRepository();
  int _selectedTab = 0; // 0 = Applications, 1 = Stats

  AppUser? appUser;
  JobApplicationModel? jobApplication; // ⭐ IMPORTANT
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    appUser = user;
    final jobId = widget.job.jobOffer.docId; // ✅ CORRECT
    var jobs    = await _repository.getByUid(user.userId,jobId!);
    
    if (jobs == null) 
    {
      final view = JobViewsModel(
        userId: user.userId,
        jobId: jobId,
        counter: 1,
        createdAt: DateTime.now(),
      );
       await _repository.add(view);
    }

    // ⭐ If job seeker → check application
    if (user.role == UserRole.jobSeeker) {
      jobApplication = await _jobAppRepo.getJobApplicationForJobSeeker(
        user.userId,
        jobId!,
      );
    }

    setState(() => loading = false);
  }

  Future<void> _applyForJob() async {
    if (jobApplication != null) return;

    final job = widget.job.jobOffer;

    final application = JobApplicationModel(
      jobId: job.docId!,
      recruiterId: job.userId,
      candidateId: appUser!.userId,
      createdAt: DateTime.now(),
    );

    await _jobAppRepo.add(application);

    setState(() {
      jobApplication = application;
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();

    if (auth.user == null) return const Row();
    final role        = auth.user!.role;

    if (loading || appUser == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isJobSeeker = appUser!.role == UserRole.recruiter;
    final isJobOwner = appUser!.userId == widget.job.jobOffer.userId;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const JobBannerSection(companyLogo: "assets/avatar.png"),
              const SizedBox(height: 16),
              _JobMainInfo(job: widget.job.jobOffer),
              const SizedBox(height: 16),
              _JobDescription(job: widget.job.jobOffer),
              const SizedBox(height: 16),
              if (role == UserRole.jobSeeker) ...[
                _RecruiterInfoSection(recruiter: widget.job.recruiter),
                const SizedBox(height: 12),
                _jobSeekerActions(),
                const SizedBox(height: 32),
              ],
              if (isJobSeeker && isJobOwner) ...[
                _JobActions(job:  widget.job.jobOffer),
                const SizedBox(height: 32),
                _RecruiterTabs(
                  selectedIndex: _selectedTab,
                  onChanged: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),

                const SizedBox(height: 16),

                if (_selectedTab == 0) ...[
                  //  Applications tab
                  _RecruiterApplicationsSection(
                    jobId: widget.job.jobOffer.docId!,
                  ),
                ] else ...[
                  //  Stats tab
                  JobStatsSection(jobId: widget.job.jobOffer.docId!),
                ],
                const SizedBox(height: 24),
              ]
            
              
           
              // Admin
              else if (role == UserRole.admin) ...[
                _RecruiterInfoSection(recruiter: widget.job.recruiter),
                const SizedBox(height: 12),
                _JobActions(job:  widget.job.jobOffer),
                const SizedBox(height: 32),
                _RecruiterTabs(
                  selectedIndex: _selectedTab,
                  onChanged: (index) {
                    setState(() => _selectedTab = index);
                  },
                ),

                const SizedBox(height: 16),

                if (_selectedTab == 0) ...[
                  //  Applications tab
                  _RecruiterApplicationsSection(
                    jobId: widget.job.jobOffer.docId!,
                  ),
                ] else ...[
                  //  Stats tab
                  JobStatsSection(jobId: widget.job.jobOffer.docId!),
                ],

                const SizedBox(height: 24),
              ]
            
            ],
          ),
        ),
      ),
    );
  }

  Widget _jobSeekerActions() {
    final applied = jobApplication != null;
    final accepted = jobApplication?.isAccepted ?? false;
    final canChat = jobApplication?.canChat ?? false;

    void showSnack(String message) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.greenCeladon,
          duration: const Duration(seconds: 10),
          closeIconColor: AppColors.white,
          showCloseIcon: true,
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // ================= APPLY BUTTON =================
          Expanded(
            child: ElevatedButton(
              onPressed: applied ? null : _applyForJob,
              style: ElevatedButton.styleFrom(
                backgroundColor: applied ? Colors.grey : AppColors.greenCeladon,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Text(
                applied ? "Applied" : "Apply",
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),

          const SizedBox(width: 12),

          // ================= CHAT BUTTON =================
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                if (!applied) {
                  showSnack(
                    "Please apply for this job before starting a chat.",
                  );
                  return;
                }

                if (!accepted) {
                  showSnack(
                    "Your job application has not been viewed or accepted by the recruiter yet. "
                    "You will be able to chat once it is accepted.",
                  );
                  return;
                }

                if (!canChat) {
                  showSnack("Chat is not enabled by the recruiter yet.");
                  return;
                }

                // ✅ OPEN CHAT SCREEN
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: canChat
                    ? AppColors.greenCeladon
                    : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                "Chat",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecruiterApplicationsSection extends StatefulWidget {
  final String jobId;

  const _RecruiterApplicationsSection({required this.jobId});

  @override
  State<_RecruiterApplicationsSection> createState() =>
      _RecruiterApplicationsSectionState();
}

class _RecruiterApplicationsSectionState
    extends State<_RecruiterApplicationsSection> {
  late Future<List<JobApplicantViewModel>> applicantsFuture;
  final JobApplicationRepository _jobAppRepo = JobApplicationRepository();

  @override
  void initState() {
    super.initState();
    applicantsFuture = _jobAppRepo.getApplicantsForJob(widget.jobId);
  }

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: "Job Applicants",
      child: Column(

        children: [
          FutureBuilder<List<JobApplicantViewModel>>(
            future: applicantsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                );
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text("No applicants yet"),
                );
              }

              final applicants = snapshot.data!
                  .where((e) => e.application.status != 'rejected')
                  .toList();

              return ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: applicants.length,
                itemBuilder: (context, index) {
                  final item = applicants[index];
                  final seeker = item.jobSeeker;
                  var app = item.application;

                  return RecruiterApplicantCard(
                    seeker: seeker,

                    onViewProfile: () async {
                      // Only update if not viewed yet
                      if (!app.isViewed && !app.isAccepted && !app.isRejected) {
                        app = app.copyWith(status: 'viewed');
                        await _jobAppRepo.update(app.docId!, app);
                        setState(() {}); // refresh UI
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => JobSeekerDetailScreen(seeker: seeker),
                        ),
                      );
                    },

                    onAccept: () async {
                      if (!app.isAccepted) {
                        app = app.copyWith(status: 'accepted', allowChat: true);
                        await _jobAppRepo.update(app.docId!, app);
                        setState(() {}); // refresh UI
                      }

                      // Open chat
                      final auth = context.read<AuthProvider>();
                      if (auth.user == null) return;

                      final recruiterId = auth.user!.userId;
                      final jobSeekerId = seeker.userId;

                      final chatService = ChatService();
                      final chatId = await chatService.getOrCreateChat(
                        recruiterId,
                        jobSeekerId,
                      );

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            chatId: chatId,
                            otherUserId: jobSeekerId,
                            personName: seeker.isNameVisible
                                ? "${seeker.firstName} ${seeker.lastName}"
                                : "Anonymous Candidate",
                          ),
                        ),
                      );
                    },

                    onReject: () async {
                      // Block invalid states
                      if (app.status == 'rejected') return;

                      final shouldReject = await _confirmReject(context);
                      if (!shouldReject) return;

                      final updatedApp = app.copyWith(
                        status: 'rejected',
                        allowChat: false,
                      );

                      await _jobAppRepo.update(app.docId!, updatedApp);

                      // Refresh list so rejected applicant disappears
                      setState(() {
                        applicantsFuture = _jobAppRepo.getApplicantsForJob(
                          widget.jobId,
                        );
                      });
                    },
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Future<bool> _confirmReject(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              title: const Text("Reject Applicant"),
              content: const Text(
                "Are you sure you want to reject this job seeker?\n\n"
                "Once rejected, you will NOT be able to contact this candidate "
                "for this job again.",
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                  ),
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    "Reject",
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;
  }
}

class RecruiterApplicantCard extends StatelessWidget {
  final JobSeekerModel seeker;
  final VoidCallback onViewProfile;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RecruiterApplicantCard({
    super.key,
    required this.seeker,
    required this.onViewProfile,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final verifiedCount = seeker.verifiedSkillCount;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// HEADER
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.greenCeladon,
                child: const Icon(Icons.person, color: Colors.white),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      seeker.isNameVisible
                          ? "${seeker.firstName} ${seeker.lastName}"
                          : "Anonymous Candidate",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      seeker.desiredPosition,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),

              /// VERIFIED BADGE
              if (verifiedCount > 0)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, size: 14, color: Colors.green),
                      const SizedBox(width: 4),
                      Text(
                        "$verifiedCount Verified",
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 12),

          /// SKILLS
          //  Wrap(
          //     spacing: 6,
          //     runSpacing: 6,
          //     children: seeker.skills.entries
          //         .map((e) => _skillChip(e.key, e.value))
          //         .toList(),
          //   ),
          

          if (seeker.experienceDetails != null) ...[
            const SizedBox(height: 12),
            Text(
              seeker.experienceDetails!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],

          const SizedBox(height: 16),

          /// ACTION BUTTONS (UPWORK STYLE)
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onViewProfile,
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text("View Profile"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: onAccept,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.greenCeladon,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    "Accept",
                    style: TextStyle(color: AppColors.white),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: onReject,
                icon: const Icon(Icons.close, color: Colors.red),
                tooltip: "Reject",
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Widget _skillChip(String skill, String status) {
  Color bg;
  Color iconColor = Colors.white;
  IconData? icon;

  switch (status) {
    case SkillStatus.verified:
      bg = AppColors.lightgreen.withOpacity(0.18);
      icon = Icons.check_circle;
      iconColor = Colors.green;
      break;
    case SkillStatus.pending:
      bg = Colors.orange.withOpacity(0.15);
      icon = Icons.hourglass_bottom;
      iconColor = Colors.orange;
      break;
    case SkillStatus.rejected:
      bg = Colors.red.withOpacity(0.12);
      icon = Icons.cancel;
      iconColor = Colors.red;
      break;
    default:
      bg = Colors.grey.shade200;
  }

  return LayoutBuilder(
    builder: (context, constraints) {
      final maxChipWidth = MediaQuery.of(context).size.width * 0.45;

      return ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxChipWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: Text(
                  skill,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  softWrap: false,
                  style: const TextStyle(fontSize: 11),
                ),
              ),
              if (icon != null) ...[
                const SizedBox(width: 4),
                Icon(icon, size: 12, color: iconColor),
              ],
            ],
          ),
        ),
      );
    },
  );
}

class PremiumSkillChip extends StatefulWidget {
  final String skill;
  final String status;

  const PremiumSkillChip({
    super.key,
    required this.skill,
    required this.status,
  });

  @override
  State<PremiumSkillChip> createState() => _PremiumSkillChipState();
}

class _PremiumSkillChipState extends State<PremiumSkillChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _ChipStyle style = _resolveStyle(widget.status);

    return Tooltip(
      message: widget.skill,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          final double glow = widget.status == SkillStatus.verified
              ? 0.25 + (_controller.value * 0.25)
              : 0;

          return Container(
            constraints: const BoxConstraints(maxWidth: 170),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              gradient: style.gradient,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: style.borderColor),
              boxShadow: [
                if (widget.status == SkillStatus.verified)
                  BoxShadow(
                    color: style.iconColor.withOpacity(glow),
                    blurRadius: 8,
                    spreadRadius: 0.5,
                  ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(
                    widget.skill,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                if (style.icon != null) ...[
                  const SizedBox(width: 6),
                  Icon(style.icon, size: 13, color: style.iconColor),
                ],
              ],
            ),
          );
        },
      ),
    );
  }
}

class _ChipStyle {
  final Gradient gradient;
  final Color borderColor;
  final Color iconColor;
  final IconData? icon;

  _ChipStyle({
    required this.gradient,
    required this.borderColor,
    required this.iconColor,
    this.icon,
  });
}

_ChipStyle _resolveStyle(String status) {
  switch (status) {
    case SkillStatus.verified:
      return _ChipStyle(
        gradient: const LinearGradient(
          colors: [Color(0xFFE6F6F2), Color(0xFFD1FAE5)],
        ),
        borderColor: const Color(0xFF10B981),
        iconColor: const Color(0xFF059669),
        icon: Icons.verified,
      );

    case SkillStatus.pending:
      return _ChipStyle(
        gradient: const LinearGradient(
          colors: [Color(0xFFFFF7ED), Color(0xFFFED7AA)],
        ),
        borderColor: const Color(0xFFF59E0B),
        iconColor: const Color(0xFFD97706),
        icon: Icons.hourglass_bottom,
      );

    case SkillStatus.rejected:
      return _ChipStyle(
        gradient: const LinearGradient(
          colors: [Color(0xFFFEF2F2), Color(0xFFFECACA)],
        ),
        borderColor: const Color(0xFFEF4444),
        iconColor: const Color(0xFFDC2626),
        icon: Icons.cancel,
      );

    default:
      return _ChipStyle(
        gradient: const LinearGradient(
          colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
        ),
        borderColor: const Color(0xFFE2E8F0),
        iconColor: Colors.grey,
      );
  }
}

class _RecruiterTabs extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _RecruiterTabs({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppUI.card,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            _TabButton(
              text: "Applicants",
              active: selectedIndex == 0,
              onTap: () => onChanged(0),
            ),
            _TabButton(
              text: "Stats",
              active: selectedIndex == 1,
              onTap: () => onChanged(1),
            ),
          ],
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  final String text;
  final bool active;
  final VoidCallback onTap;

  const _TabButton({
    required this.text,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: active ? AppColors.greenCeladon : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: active ? Colors.white : AppUI.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class JobBannerSection extends StatelessWidget {
  final String? bannerImage; // asset or network
  final String? companyLogo; // asset or network

  const JobBannerSection({super.key, this.bannerImage, this.companyLogo});

  bool get hasBanner => bannerImage != null && bannerImage!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        /// Banner (Image OR Gradient)
        Container(
          height: 180,
          decoration: BoxDecoration(
            gradient: hasBanner ? null : AppColors.gradientgreen,
            image: hasBanner
                ? DecorationImage(
                    image: _resolveImage(bannerImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
        ),

        /// Soft overlay (always looks premium)
        Container(height: 180, color: Colors.black.withOpacity(.15)),

        /// Back button
        Positioned(
          top: 40,
          left: 16,
          child: _circleIcon(
            icon: Icons.arrow_back,
            onTap: () => Navigator.pop(context),
          ),
        ),

        /// Company Logo
        Positioned(
          bottom: -30,
          left: 16,
          child: _CompanyLogo(logo: companyLogo),
        ),
      ],
    );
  }

  ImageProvider _resolveImage(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }

  Widget _circleIcon({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.black),
      ),
    );
  }
}

class _RecruiterInfoSection extends StatelessWidget {
  final Recruiter recruiter;

  const _RecruiterInfoSection({required this.recruiter});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: "Recruiter Information",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _infoRow(
            Icons.person,
            "${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}",
          ),
          _infoRow(Icons.local_pharmacy, recruiter.pharmacyName),
          _infoRow(Icons.location_city, recruiter.city),
          _infoRow(Icons.location_city_sharp, recruiter.province),
          _infoRow(Icons.location_on, recruiter.streetAddress),
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String? value) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.greenCeladon),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompanyLogo extends StatelessWidget {
  final String? logo;

  const _CompanyLogo({this.logo});

  bool get hasLogo => logo != null && logo!.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      width: 70,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.12), blurRadius: 10),
        ],
      ),
      child: hasLogo
          ? ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image(image: _resolveImage(logo!), fit: BoxFit.contain),
            )
          : const Icon(Icons.local_pharmacy, size: 32, color: Colors.green),
    );
  }

  ImageProvider _resolveImage(String path) {
    if (path.startsWith('http')) {
      return NetworkImage(path);
    }
    return AssetImage(path);
  }
}

class _InfoChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color? color;

  const _InfoChip(this.label, this.icon, {this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppUI.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.withOpacity(.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: c),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(color: c, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _JobDescription extends StatelessWidget {
  final JobOffer job;
  const _JobDescription({required this.job});

  @override
  Widget build(BuildContext context) {
    if (job.skills.isEmpty) return const SizedBox.shrink();

    return _SectionCard(
      title: "Required Skills",
      child: SizedBox(
        width: double.infinity, // ✅ gives bounded width
        child: Wrap(
          spacing: 6,
          runSpacing: 6,
          children: job.skills.map((s) => _SkillChip(s)).toList(),
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip(this.label);

  static const Map<String, IconData> skillIcons = {
    "Order reception and invoice entry": Icons.receipt_long,
    "Counter customer consultation": Icons.support_agent,
    "Chifa system proficiency": Icons.computer,
    "Damancom system proficiency": Icons.storage,
    "CAMSSP system proficiency": Icons.security,
    "Stock management": Icons.inventory_2,
    "Physical inventory": Icons.fact_check,
    "CNAS forms submission and follow-up": Icons.assignment,
    "CASNOS forms submission and follow-up": Icons.assignment_turned_in,
    "CAMSSP forms submission and follow-up": Icons.verified_user,
    "Medication ordering and tracking": Icons.medication,
    "Parapharmaceutical products ordering and tracking": Icons.shopping_cart,
    "Compounding preparations": Icons.science,
    "Overall pharmacy management": Icons.local_pharmacy,
  };

  @override
  Widget build(BuildContext context) {
    final icon = skillIcons[label] ?? Icons.star_outline;

    return LayoutBuilder(
      builder: (context, constraints) {
        return ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: constraints.maxWidth, // ✅ take all available space
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.greenCeladon.withOpacity(.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: AppColors.greenCeladon.withOpacity(.25),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon, size: 18, color: AppColors.greenCeladon),
                const SizedBox(width: 8),

                /// Text adapts to available width
                Expanded(
                  child: Text(
                    label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: false,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _JobMainInfo extends StatelessWidget {
  final JobOffer job;
  const _JobMainInfo({required this.job});
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

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 32),

        /// Job Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            job.jobTitle,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 12),

        /// Chips
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Wrap(
            spacing: 10,

            children: [
              _InfoChip(job.jobType, Icons.work_outline),
              _InfoChip(
                job.isActive ? "Open" : "Draft",
                Icons.check_circle,
                color: job.isActive ? Colors.green : Colors.orange,
              ),
              _InfoChip(
                formatSalary(job.salary),
                Icons.monetization_on_sharp,
                color: job.isActive ? Colors.green : Colors.orange,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity, // full width
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16), // let it stretch
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _JobActions extends StatelessWidget {
  final JobOffer job;
  const _JobActions({required this.job});

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _customButton(
              text: "Edit Job",
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        JobFormScreen(mode: JobFormMode.edit, jobOffer: job),
                  ),
                );
              },
              size: size,
              gradient: AppColors.gradientdarkgreen,
              shadowColor: AppColors.green,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _customButton(
              text: "Close Job",
              onPressed: () {
                // Navigate to applicants screen
              },
              size: size,
              gradient: AppColors.gradientRed,
              shadowColor: AppColors.red,
            ),
          ),
        ],
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
