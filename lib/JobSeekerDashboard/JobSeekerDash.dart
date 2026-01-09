import 'dart:ui';

import 'package:client/JobSeekerDashboard/JobSeekerAccount/JobSeekerAccountScreen.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/routes/app_routes.dart';


final jobData = [
  (
    title: "Pharmacy Technician cvbcvbvcbcvbvcbvcb",
    company: "Care Pharmacy Ltd.",
    type: "Full-time / On-site",
    salary: "180K / year",
    icon: Icons.medical_services,
    button: "View Details",
  ),
  (
    title: "Pharmaceutical Sales",
    company: "MedSupply Corp.",
    type: "Full-time / Remote",
    salary: "200K / year",
    icon: Icons.trending_up,
    button: "Apply Now",
  ),
  (
    title: "Pharmacy Assistant",
    company: "Wellness Pharmacy Group",
    type: "Part-time / On-site",
    salary: "160K / year",
    icon: Icons.local_pharmacy,
    button: "Apply Today",
  ),
];

class JobSeekDashboardScreen extends StatelessWidget {
  const JobSeekDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: _bottomNav(),
      drawer: JobSeekerDrawer(),
      body: SafeArea(
        child: Column(
          children: [
            /// ✅ HEADER (NORMAL – LIKE YOUR REFERENCE)
            _header(),

            /// ✅ CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(top: 16, bottom: 24),
                child: Column(
                  children: [
                    _profileCard(), // moved OUT of header
                    const SizedBox(height: 24),
                    _statsRow(),
                    const SizedBox(height: 24),
                    _skillsSection(),
                    const SizedBox(height: 24),
                    jobSection()
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

Widget _header() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    child: Row(
      children: [
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: const Icon(Icons.menu, color: AppColors.darkGreen),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Hi, Anonymous Candidate",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.darkGreen,
              ),
            ),
            Text(
              "Desired Position: Pharmacist",
              style: TextStyle(fontSize: 13),
            ),
          ],
        ),
        const Spacer(),
        IconButton(
          icon: const Icon(Icons.notifications_none),
          onPressed: () {},
        ),
      ],
    ),
  );
}

Widget _profileCard() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: AppColors.gradientgreen,
        borderRadius: BorderRadius.circular(22),
        boxShadow: premiumShadow,
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white,
            child: Icon(Icons.person, color: AppColors.darkGreen),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "Anonymous Candidate",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Profile strength: 82%",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          Column(
            children: const [
              Text(
                "89",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text("Rank", style: TextStyle(color: Colors.white70)),
            ],
          ),
        ],
      ),
    ),
  );

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
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
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
              onTap: () {
                Navigator.pop(context);
                 Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JobSeekerAccountScreen(
                      mode: AccountFormMode.edit,
                    ),
                  ),
                );
              },
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
              title: "Privacy & Anonymity",
              subtitle: "Control profile visibility",
              onTap: () {},
            ),

            _drawerItem(
              context,
              icon: Icons.logout,
              title: "Logout",
              subtitle: "Sign out",
              isDestructive: true,
              onTap: () {
                Navigator.of(context, rootNavigator: true)
                    .pushNamedAndRemoveUntil(
                  AppRoutes.login,
                  (route) => false,
                );
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

Widget _statsRow() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Row(
      children: [
        Expanded(
          child: _MiniStatCard(
            title: "Matches",
            value: "12",
            icon: Icons.work_outline,
            gradient: AppColors.gradientPink,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            title: "Skills",
            value: "7/14",
            icon: Icons.verified_outlined,
            gradient: AppColors.gradientgreen1,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            title: "Msgs",
            value: "3",
            icon: Icons.chat_bubble_outline,
            gradient: calmBlueGradient,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _MiniStatCard(
            title: "Visible",
            value: "High",
            icon: Icons.visibility_outlined,
            gradient: calmGreenGradient,
          ),
        ),
      ],
    ),
  );
}

class _MiniStatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Gradient gradient;

  const _MiniStatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 88, // 🔑 fixed height = no layout jumps
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: premiumShadow,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Icon(icon, size: 18, color: Colors.white),

          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Colors.white70,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

Widget _skillsSection() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Skill Authentication",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        _skillRow("Gestion de stock", "Auth (3)", Colors.green),
        _skillRow("Conseil au comptoir", "Pending", Colors.orange),
        _skillRow("Système Chifa", "Auth (1)", Colors.green),
        const SizedBox(height: 12),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFFACC15),
            foregroundColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          onPressed: () {},
          child: const Text("Request Authentication"),
        ),
      ],
    ),
  );
}

Widget _skillRow(String title, String status, Color color) {
  IconData statusIcon =
      status.contains("Auth") ? Icons.check_circle :
      status == "Pending" ? Icons.hourglass_top :
      Icons.help_outline;

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

Widget jobSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Featured Jobs",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 12),

      /// 🔑 IMPORTANT: give height
      SizedBox(
         height: 230, // 🔑 slightly taller than card
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
           clipBehavior: Clip.none, // 🔥 VERY IMPORTANT
          scrollDirection: Axis.horizontal,
          itemCount: jobData.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16), // 🔑 width
          itemBuilder: (context, index) {
            return SizedBox(
              width: 320, // 🔑 card width for premium feel
              child: FeaturedJobCard( 
              ),
            );
          },
        ),
      ),
      

      const SizedBox(height: 24),

      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: Text(
          "Job Matches",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),

      const SizedBox(height: 12),

      /// 🔑 IMPORTANT: give height
      SizedBox(
         height: 230, // 🔑 slightly taller than card
        child: ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16),
           clipBehavior: Clip.none, // 🔥 VERY IMPORTANT
          scrollDirection: Axis.horizontal,
          itemCount: jobData.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16), // 🔑 width
          itemBuilder: (context, index) {
            return SizedBox(
              width: 320, // 🔑 card width for premium feel
              child: JobCard(
                title: jobData[index].title,
                company: jobData[index].company,
                type: jobData[index].type,
                salary: jobData[index].salary,
                icon: jobData[index].icon,
                buttonText: jobData[index].button,
              ),
            );
          },
        ),
      ),
      
      const SizedBox(height: 12),
    ],
  );
}

class FeaturedJobCard extends StatelessWidget {
  const FeaturedJobCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.greenCeladon,
        borderRadius: BorderRadius.circular(22),
        boxShadow: premiumShadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Icon(Icons.local_hospital, color: Colors.white),
              ),
              Icon(Icons.bookmark_border, color: Colors.white),
            ],
          ),

          const SizedBox(height: 12),

          const Text(
            "Job Seeker",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Text(
            "Health First Pharmacy",
            style: TextStyle(color: Colors.white70),
          ),

          const SizedBox(height: 12),

          const Text(
            "Part-time / Remote",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 16),

          /// ACTION
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _pillButton("Apply Now", Colors.white, Colors.black),
              const Text(
                "150K / year",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          )
        ],
      ),
    );
  }
}
class JobCard extends StatelessWidget {
  final String title;
  final String company;
  final String type;
  final String salary;
  final IconData icon;
  final String buttonText;

  const JobCard({
    required this.title,
    required this.company,
    required this.type,
    required this.salary,
    required this.icon,
    required this.buttonText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      //margin: const EdgeInsets.symmetric(vertical: 12), // 🔑 space for shadow
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(22),
        boxShadow: premiumShadow
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TOP
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CircleAvatar(
                backgroundColor: AppColors.greenCeladon,
                child: Icon(icon, color: Colors.white),
              ),
              const Icon(Icons.bookmark_border),
            ],
          ),

          const SizedBox(height: 12),

          Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              
            ),
          ),
          Text(
            company,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.black54),
          ),

          const SizedBox(height: 12),

          Text(
            type,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _pillButton(buttonText, AppColors.greenCeladon, Colors.white),
              Text(
                salary,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          )
        ],
      ),
    );
  }
}

Widget _pillButton(String text, Color bg, Color fg) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
    decoration: BoxDecoration(
      color: bg,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      text,
      style: TextStyle(
        color: fg,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),
  );
}


Widget _bottomNav() {
  return BottomNavigationBar(
    currentIndex: 0,
    selectedItemColor: const Color(0xFF0F766E),
    items: const [
      BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.work), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.chat), label: ""),
      BottomNavigationBarItem(icon: Icon(Icons.person), label: ""),
    ],
  );
}

