import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Enums/UserRole.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:provider/provider.dart';

class JobSeekerDetailScreen extends StatelessWidget {
  final JobSeekerModel seeker;

  const JobSeekerDetailScreen({super.key, required this.seeker});

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _premiumHeader(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _skillsSection(),
                  const SizedBox(height: 20),
                  _experienceCard(),
                  const SizedBox(height: 20),
                  _educationCard(),
                  const SizedBox(height: 24),
                  _actions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

SliverAppBar _premiumHeader(BuildContext context) {
  final bool hasVerifiedSkills = seeker.verifiedSkillCount > 0;

  return SliverAppBar(
    expandedHeight: 270,
    pinned: true,
    elevation: 0,
    backgroundColor: AppColors.greenCeladon,
    flexibleSpace: FlexibleSpaceBar(
      collapseMode: CollapseMode.parallax,
      background: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.gradientgreen,
        ),
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Avatar
                CircleAvatar(
                  radius: 42,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 42,
                    color: AppColors.greenCeladon,
                  ),
                ),

                const SizedBox(height: 12),

                // Name
                Text(
                  seeker.isNameVisible
                      ? "${seeker.firstName} ${seeker.lastName}"
                      : "Anonymous Candidate",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                // Position
                Text(
                  seeker.desiredPosition,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 12),

                // Chips
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _infoChip(
                      icon: Icons.location_on,
                      text: "${seeker.city}, ${seeker.province}",
                    ),
                    _infoChip(
                      icon: Icons.phone,
                      text: "+213",
                    ),
                    _statusChip(hasVerifiedSkills),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}

Widget _infoChip({required IconData icon, required String text}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: Colors.white.withOpacity(0.15),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.white),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

Widget _statusChip(bool isVerified) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(
      color: isVerified
          ? Colors.white
          : AppColors.textLight,
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isVerified ? Icons.verified : Icons.warning_rounded,
          size: 14,
          color: isVerified ? AppColors.greenCeladon : Colors.white,
        ),
        const SizedBox(width: 6),
        Text(
          isVerified ? "Verified Skills" : "Unverified",
          style: TextStyle(
            color: isVerified
                ? AppColors.greenCeladon
                : Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );
}

  Widget _skillsSection() {
    return _card(
      title: "Skills",
      child: Column(
        children: seeker.skills.entries.map((entry) {
          final skillName = entry.key;
          final status = entry.value;

          final verified = status == SkillStatus.verified;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
            decoration: BoxDecoration(
              color: verified
                  ? AppColors.lightgreen.withOpacity(0.15)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  verified ? Icons.verified : Icons.circle_outlined,
                  size: 20,
                  color: verified ? Colors.green : Colors.grey,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    skillName,
                    style: const TextStyle(fontSize: 14, height: 1.4),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // 🔥 EXPERIENCE CARD (READABLE & PREMIUM)
  Widget _experienceCard() {
    if (seeker.experienceDetails == null || seeker.experienceDetails!.isEmpty) {
      return const SizedBox();
    }

    return _card(
      title: "Experience",
      child: Text(
        seeker.experienceDetails!,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _educationCard() {
    if (seeker.educationBackground == null ||
        seeker.educationBackground!.isEmpty) {
      return const SizedBox();
    }

    return _card(
      title: "Education",
      child: Text(
        seeker.educationBackground!,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _actions(BuildContext context) {
    final auth = context.read<AuthProvider>();

    if (auth.user == null) return const Row();
    final role        = auth.user!.role;
    if(role==UserRole.admin)
    {
      return Row(
      children: [
        Expanded(
          child: _gradientButton(
            text: "Block Profile",
            gradient: AppColors.gradientPink,
            onTap: () {},
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _gradientButton(
            text: "Chat",
            gradient: AppColors.gradientgreen1,
            onTap: () {},
          ),
        ),
      ],
    );
  
    }
    return Row(
      children: [
        // Expanded(
        //   child: _gradientButton(
        //     text: "Invite to Apply",
        //     gradient: AppColors.gradientgreen,
        //     onTap: () {},
        //   ),
        // ),
        const SizedBox(width: 12),
        Expanded(
          child: _gradientButton(
            text: "Chat",
            gradient: AppColors.gradientgreen1,
            onTap: () {},
          ),
        ),
      ],
    );
  
  }

  Widget _gradientButton({
    required String text,
    required Gradient gradient,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // 🔥 REUSABLE PREMIUM CARD
  Widget _card({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
