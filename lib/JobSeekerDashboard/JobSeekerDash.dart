// ignore: file_names
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/AdminPannel/AdminDashboardScreen.dart';
import 'package:client/JobSeekerDashboard/Drawer/JobSeekerDrawer.dart';
import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
import 'package:client/JobSeekerDashboard/JobSeekerHeader.dart';
import 'package:client/JobSeekerDashboard/SendRequestForSkillVerification.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterSkillVerificationScreen.dart';
import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplicationWithJob.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/Server/Repo/ProfileViewsRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';

import 'package:flutter/material.dart';

import 'package:client/AppColors/AppColors.dart';
import 'package:provider/provider.dart';

class JobSeekDashboardScreen extends StatefulWidget {
  const JobSeekDashboardScreen({super.key});

  @override
  State<JobSeekDashboardScreen> createState() => _JobSeekDashboardScreenState();
}

class _JobSeekDashboardScreenState extends State<JobSeekDashboardScreen> {
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
  final JobApplicationRepository _jobApplicationRepo =
      JobApplicationRepository();
  final ProfileViewsRepository _profileViewsRepo = ProfileViewsRepository();
  final JobOfferRepository _jobOfferRepo = JobOfferRepository();
  JobSeekerModel? _jobSeeker;
  List<JobApplicationWithJob> _applications = [];
  int _totalViews = 0;
  bool _isLoading = true;
  List<JobOffer> _matchingJobs = [];
  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;
    if (user == null) return;

    // Load JobSeeker
    final seeker = await _jobSeekerRepo.getByUid(user.userId);
    // ✅ New: get matching jobs
    final matchingJobs = await _jobOfferRepo.getMatchingJobs(seeker!);
    // Load applications with jobs
    final applications = await _jobApplicationRepo
        .getApplicationsWithJobsForCandidate(user.userId);

    // Load total profile views
    final totalViews = await _profileViewsRepo.getTotalViews(user.userId);

    if (!mounted) return;

    setState(() {
      _jobSeeker = seeker;
      _applications = applications;
      _totalViews = totalViews;
      _isLoading = false;
      _matchingJobs = matchingJobs;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: const Color.fromRGBO(232, 245, 233, 1),
      drawer: JobSeekerDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            /// ✅ HEADER
            JobSeekerHeader(),

            /// ✅ CONTENT
            Expanded(
              child: RefreshIndicator(
                onRefresh: _loadDashboardData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.only(top: 16, bottom: 24),
                  child: Column(
                    children: [
                      _profileCard(),
                      const SizedBox(height: 24),
                      _statsGrid(),
                      const SizedBox(height: 24),
                      _skillsSection(),
                      const SizedBox(height: 24),
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

  /// Profile card with real data
  Widget _profileCard() {
    final seeker = _jobSeeker!;
    final experience = seeker.experienceDetails ?? "No experience info";
    final profileStrength =
        seeker.verifiedSkillCount /
        (seeker.skills.length == 0 ? 1 : seeker.skills.length);
    final rank = "#${_applications.length}";
    final matches = _matchingJobs.length.toString();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: AppColors.gradientgreen,
          borderRadius: BorderRadius.circular(28),
          boxShadow: premiumShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// TOP ROW
            Row(
              children: [
                CircleAvatar(
                  radius: 36,
                  backgroundColor: Colors.white,
                  backgroundImage: seeker.logoUrl != null
                      ? NetworkImage(seeker.logoUrl!)
                      : null,
                  child: seeker.logoUrl == null
                      ? const Icon(
                          Icons.person,
                          size: 36,
                          color: AppColors.darkGreen,
                        )
                      : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        seeker.isNameVisible
                            ? "${seeker.firstName} ${seeker.lastName}"
                            : "Anonymous Candidate",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "${seeker.desiredPosition}",
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                PillButton(
                  text: "Edit Profile",
                  backgroundColor: AppColors.white,
                  textColor: AppColors.darkGreen,
                  onTap: () {

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const JobSeekerAccountScreen(
                          mode: JobSeekerFormMode.edit,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            const SizedBox(height: 18),

            /// STATS
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _ProfileMetric(
                  label: "Profile Strength",
                  value: "${(profileStrength * 100).toInt()}%",
                ),
                _ProfileMetric(label: "Job Applications", value: rank),
                _ProfileMetric(label: "Matches", value: matches),
              ],
            ),

            const SizedBox(height: 16),

            /// PROGRESS
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: profileStrength,
                minHeight: 8,
                backgroundColor: Colors.white24,
                valueColor: const AlwaysStoppedAnimation(Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Stats grid with real data
  Widget _statsGrid() {
    final seeker = _jobSeeker!;
    final verifiedSkills =
        "${seeker.verifiedSkillCount} / ${seeker.skills.length}";
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1.25,
        children: [
          _BigStatCard(
            title: "Job Matches",
            value: _matchingJobs.length.toString(),
            subtitle: "Based on your profile",
            icon: Icons.work_outline,
            gradient: AppColors.gradientPink,
          ),
          _BigStatCard(
            title: "Skills Verified",
            value: verifiedSkills,
            subtitle: "Improve visibility",
            icon: Icons.verified_outlined,
            gradient: AppColors.gradientgreen1,
          ),
          _BigStatCard(
            title: "Profile Views",
            value: _totalViews.toString(),
            subtitle: "Recruiters viewed you",
            icon: Icons.visibility_outlined,
            gradient: calmBlueGradient,
          ),
          _BigStatCard(
            title: "Profile Visibility",
            value: seeker.isNameVisible ? "High" : "Anonymous",
            subtitle: "Privacy Mode",
            icon: Icons.visibility_off_outlined,
            gradient: calmGreenGradient,
          ),
        ],
      ),
    );
  }

  /// Skills section with dynamic data
  Widget _skillsSection() {
    final seeker = _jobSeeker!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Skill Authentication",
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFACC15),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () {
                  // Handle request authentication
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          const SendSkillVerificationRequestScreen(),
                    ),
                  );
                },
                child: const Text("Request Authentication"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...seeker.skills.entries.map((e) {
            Color color;
            String statusText;
            if (e.value == SkillStatus.verified) {
              color = Colors.green;
              statusText = "Auth (1)";
            } else if (e.value == SkillStatus.pending) {
              color = Colors.orange;
              statusText = "Pending";
            } else {
              color = Colors.red;
              statusText = "Rejected";
            }
            return _skillRow(e.key, statusText, color);
          }).toList(),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ProfileMetric extends StatelessWidget {
  final String label;
  final String value;

  const _ProfileMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _BigStatCard extends StatelessWidget {
  final String title, value, subtitle;
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
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(28),
        boxShadow: premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 26),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

Widget _skillRow(String title, String status, Color color) {
  IconData statusIcon = status.contains("Auth")
      ? Icons.check_circle
      : status == "Pending"
      ? Icons.hourglass_top
      : Icons.help_outline;

  return Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: premiumShadow,
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
          child: Icon(statusIcon, color: color, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(title)),
        Text(
          status,
          style: TextStyle(color: color, fontWeight: FontWeight.w600),
        ),
      ],
    ),
  );
}

class PillButton extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback onTap;

  const PillButton({
    super.key,
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}





// Widget jobSection() {
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Text(
//           "Featured Jobs",
//           style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
//         ),
//       ),
//       const SizedBox(height: 12),

//       /// 🔑 IMPORTANT: give height
//       SizedBox(
//         height: 230, // 🔑 slightly taller than card
//         child: ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           clipBehavior: Clip.none, // 🔥 VERY IMPORTANT
//           scrollDirection: Axis.horizontal,
//           itemCount: jobData.length,
//           separatorBuilder: (_, __) => const SizedBox(width: 16), // 🔑 width
//           itemBuilder: (context, index) {
//             return SizedBox(
//               width: 320, // 🔑 card width for premium feel
//               child: FeaturedJobCard(),
//             );
//           },
//         ),
//       ),

//       const SizedBox(height: 24),

//       const Padding(
//         padding: EdgeInsets.symmetric(horizontal: 16),
//         child: Text(
//           "Job Matches",
//           style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//       ),

//       const SizedBox(height: 12),

//       /// 🔑 IMPORTANT: give height
//       SizedBox(
//         height: 230, // 🔑 slightly taller than card
//         child: ListView.separated(
//           padding: const EdgeInsets.symmetric(horizontal: 16),
//           clipBehavior: Clip.none, // 🔥 VERY IMPORTANT
//           scrollDirection: Axis.horizontal,
//           itemCount: jobData.length,
//           separatorBuilder: (_, __) => const SizedBox(width: 16), // 🔑 width
//           itemBuilder: (context, index) {
//             return SizedBox(
//               width: 320, // 🔑 card width for premium feel
//               child: JobCard(
//                 title: jobData[index].title,
//                 company: jobData[index].company,
//                 type: jobData[index].type,
//                 salary: jobData[index].salary,
//                 icon: jobData[index].icon,
//                 buttonText: jobData[index].button,
//               ),
//             );
//           },
//         ),
//       ),

//       const SizedBox(height: 12),
//     ],
//   );
// }

// class FeaturedJobCard extends StatelessWidget {
//   const FeaturedJobCard({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(18),
//       decoration: BoxDecoration(
//         color: AppColors.greenCeladon,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: premiumShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TOP
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: const [
//               CircleAvatar(
//                 backgroundColor: Colors.white24,
//                 child: Icon(Icons.local_hospital, color: Colors.white),
//               ),
//               Icon(Icons.bookmark_border, color: Colors.white),
//             ],
//           ),

//           const SizedBox(height: 12),

//           const Text(
//             "Job Seeker",
//             style: TextStyle(
//               fontSize: 18,
//               fontWeight: FontWeight.w700,
//               color: Colors.white,
//             ),
//           ),
//           const Text(
//             "Health First Pharmacy",
//             style: TextStyle(color: Colors.white70),
//           ),

//           const SizedBox(height: 12),

//           const Text(
//             "Part-time / Remote",
//             style: TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
//           ),

//           const SizedBox(height: 16),

//           /// ACTION
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _pillButton("Apply Now", Colors.white, Colors.black),
//               const Text(
//                 "150K / year",
//                 style: TextStyle(
//                   color: Colors.white,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

// class JobCard extends StatelessWidget {
//   final String title;
//   final String company;
//   final String type;
//   final String salary;
//   final IconData icon;
//   final String buttonText;

//   const JobCard({
//     required this.title,
//     required this.company,
//     required this.type,
//     required this.salary,
//     required this.icon,
//     required this.buttonText,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       //margin: const EdgeInsets.symmetric(vertical: 12), // 🔑 space for shadow
//       decoration: BoxDecoration(
//         color: AppColors.card,
//         borderRadius: BorderRadius.circular(22),
//         boxShadow: premiumShadow,
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           /// TOP
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               CircleAvatar(
//                 backgroundColor: AppColors.greenCeladon,
//                 child: Icon(icon, color: Colors.white),
//               ),
//               const Icon(Icons.bookmark_border),
//             ],
//           ),

//           const SizedBox(height: 12),

//           Text(
//             title,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//           ),
//           Text(
//             company,
//             maxLines: 1,
//             overflow: TextOverflow.ellipsis,
//             style: const TextStyle(color: Colors.black54),
//           ),

//           const SizedBox(height: 12),

//           Text(type, style: const TextStyle(fontWeight: FontWeight.w500)),

//           const SizedBox(height: 16),

//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               _pillButton(buttonText, AppColors.greenCeladon, Colors.white),
//               Text(salary, style: const TextStyle(fontWeight: FontWeight.w700)),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
// }

