import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/EditJob/JobFormScreen.dart';
import 'package:client/Recruiter/JobStatsSection/JobStatsSection.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Model/JobSeekerModel/JobViews.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/JbViews/JobViews_Repository.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecruiterJobDetailScreen extends StatefulWidget {
  final JobOfferWithRecruiter job;
  const RecruiterJobDetailScreen({super.key, required this.job});

  @override
  State<RecruiterJobDetailScreen> createState() => _RecruiterJobDetailScreenState();
}

class _RecruiterJobDetailScreenState extends State<RecruiterJobDetailScreen> {
  bool loading = true;
  final JobViewsRepository _repository = JobViewsRepository();
  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  Future<void> _loadJobs() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    var jobs = await _repository.getByUid(user.userId);
    final jobId = widget.job.jobOffer.docId; // ✅ CORRECT
    if(jobs==null)
    {
      final view= JobViewsModel(userId: user.userId, jobId: jobId ?? '', counter: 1, createdAt: DateTime.now());
      await _repository.add(view);
    }
     setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              const JobBannerSection(companyLogo: "assets/avatar.png"),
              const SizedBox(height: 16),
              _JobMainInfo(job: widget.job.jobOffer),
              const SizedBox(height: 16),
              _JobDescription(job: widget.job.jobOffer,),
              const SizedBox(height: 16),
              _RecruiterInfoSection(recruiter: widget.job.recruiter),
              const SizedBox(height: 12),
              const JobStatsSection(),
              const SizedBox(height: 24),
              _JobActions(job:widget.job.jobOffer),
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
          _infoRow(Icons.person, "${recruiter.pharmacistFirstName} ${recruiter.pharmacistLastName}" ),
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
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: job.skills.map((s) => _SkillChip(s)).toList(),
      ),
    );
  }
}



class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip(this.label);
 
  static const  Map<String, IconData> skillIcons = {
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

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.greenCeladon.withOpacity(.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.greenCeladon.withOpacity(.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: AppColors.greenCeladon),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
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
