import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/JobSeeker.dart';

class JobSeekerDetailScreen extends StatelessWidget {
  final JobSeeker seeker;

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

  // 🔥 HERO HEADER (UPWORK / TINDER STYLE)
  SliverAppBar _premiumHeader(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      backgroundColor: AppColors.greenCeladon,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.gradientgreen,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  CircleAvatar(
                    radius: 42,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person,
                        size: 42, color: AppColors.greenCeladon),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    seeker.isAnonymous
                        ? "Anonymous Candidate"
                        : seeker.fullName ?? "",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    seeker.desiredPosition,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.location_on,
                          size: 16, color: Colors.white70),
                      const SizedBox(width: 4),
                      Text(
                        seeker.city,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      if (seeker.authenticatedSkills.isNotEmpty) ...[
                        const SizedBox(width: 10),
                        const Icon(Icons.verified,
                            size: 18, color: Colors.white),
                      ],
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

  // 🔥 FULL-WIDTH SKILLS GRID (NO SMALL PILLS)
  // Widget _skillsGrid() {
  //   return _card(
  //     title: "Skills",
  //     child: GridView.builder(
  //       shrinkWrap: true,
  //       physics: const NeverScrollableScrollPhysics(),
  //       itemCount: seeker.skills.length,
  //       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
  //         crossAxisCount: 2,
  //         mainAxisSpacing: 12,
  //         crossAxisSpacing: 12,
  //         childAspectRatio: 3.2,
  //       ),
  //       itemBuilder: (_, i) {
  //         final skill = seeker.skills[i];
  //         final verified =
  //             seeker.authenticatedSkills.contains(skill);

  //         return Container(
  //           decoration: BoxDecoration(
  //             color: verified
  //                 ? AppColors.lightgreen.withOpacity(0.2)
  //                 : Colors.grey.shade200,
  //             borderRadius: BorderRadius.circular(14),
  //           ),
  //           padding: const EdgeInsets.symmetric(horizontal: 14),
  //           child: Row(
  //             children: [
  //               Expanded(
  //                 child: Text(
  //                   skill,
  //                   style: const TextStyle(fontSize: 13),
  //                   overflow: TextOverflow.ellipsis,
  //                 ),
  //               ),
  //               if (verified)
  //                 const Icon(Icons.check_circle,
  //                     size: 16, color: Colors.green),
  //             ],
  //           ),
  //         );
  //       },
  //     ),
  //   );
  // }



Widget _skillsSection() {
  return _card(
    title: "Skills",
    child: Column(
      children: seeker.skills.map((skill) {
        final verified =
            seeker.authenticatedSkills.contains(skill);

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
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
                verified
                    ? Icons.verified
                    : Icons.circle_outlined,
                size: 20,
                color: verified
                    ? Colors.green
                    : Colors.grey,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  skill,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.4,
                  ),
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
    if (seeker.experience == null ||
        seeker.experience!.isEmpty) {
      return const SizedBox();
    }

    return _card(
      title: "Experience",
      child: Text(
        seeker.experience!,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: Colors.black87,
        ),
      ),
    );
  }


Widget _actions(BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: _gradientButton(
          text: "Invite to Apply",
          gradient: AppColors.gradientgreen,
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
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
