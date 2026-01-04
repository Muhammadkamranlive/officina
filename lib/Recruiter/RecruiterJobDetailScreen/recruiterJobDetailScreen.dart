import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/JobStatsSection/JobStatsSection.dart';
import 'package:client/Server/Model/JobOffer.dart';

import 'package:flutter/material.dart';

class RecruiterJobDetailScreen extends StatelessWidget {
  final JobOffer job;
  const RecruiterJobDetailScreen({super.key, required this.job});
  
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const JobBannerSection(companyLogo: "assets/avatar.png"),
              const SizedBox(height: 16),
              _JobMainInfo(job: job),
              const SizedBox(height: 16),
              _JobDescription(job: job,),
              const SizedBox(height: 12),
              const JobStatsSection(),
              const SizedBox(height: 24),
              _JobActions(job:job),
              const SizedBox(height: 32),
            ],
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
    return _SectionCard(
      title: "Required Skills",
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            
            const SizedBox(height: 12),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: job.skills.map((skill) => _SkillChip(skill)).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;
  const _SkillChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label),
    );
  }
}
class _JobMainInfo extends StatelessWidget {
  final JobOffer job;
  const _JobMainInfo({required this.job});

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

        const SizedBox(height: 6),

        /// Location
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              //const Icon(Icons.location_on_outlined, size: 18, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                "",
                style: const TextStyle(color: AppUI.textSecondary),
              ),
            ],
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
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
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
                      builder: (_) => JobFormScreen(
                        mode: JobFormMode.edit,
                        jobOffer: job,
                      ),
                    ),
                  );
                },
                size: size,
                gradient: AppColors.gradientdarkgreen,
                shadowColor: AppColors.green),
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
                shadowColor: AppColors.red),
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
    required Color shadowColor
  }) {
    return  Container(
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
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



// class _SectionCard extends StatelessWidget {
//   final String title;
//   final Widget child;

//   const _SectionCard({required this.title, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       margin: const EdgeInsets.symmetric(horizontal: 16),
//       decoration: BoxDecoration(
//         color: AppUI.card,
//         borderRadius: BorderRadius.circular(AppUI.radius),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(.04),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 12),
//           child,
//         ],
//       ),
//     );
//   }
// }
