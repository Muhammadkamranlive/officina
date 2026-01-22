import 'package:client/AppColors/AppColors.dart';
import 'package:client/Recruiter/RecruiterJobDetailScreen/recruiterJobDetailScreen.dart';
import 'package:client/Server/Model/JobOfferWithRecruiter.dart';
import 'package:client/Server/Repo/JobList/JobSearchRepository.dart';
import 'package:flutter/material.dart';


class PharmacyListScreen extends StatefulWidget {
  const PharmacyListScreen({super.key});

  @override
  State<PharmacyListScreen> createState() => _PharmacyListScreenState();
}

class _PharmacyListScreenState extends State<PharmacyListScreen> {
  /// SEARCH
  final TextEditingController searchCtrl = TextEditingController();
  final TextEditingController roleSearchCtrl = TextEditingController();
  final TextEditingController skillSearchCtrl = TextEditingController();
  final JobSearchRepository _jobSearchRepo = JobSearchRepository();

  late Future<List<JobOfferWithRecruiter>> _jobsFuture;

  /// FILTER STATE
  String selectedCity = "All";
  List<String> selectedSkills = [];
  List<String> selectedRoles = [];

  /// FILTER DATA
  final List<String> jobRoles = [
    "Gerant",
    "Pharmacist",
    "Physician",
    "Senior Salesperson",
    "Sales Specialist",
    "Intern (Training / Future Recruitment)",
    "Labeling Specialist",
    "Data Entry Specialist",
    "Stock Management Specialist",
  ];

  final List<String> algeriaCities = [
    "All",
    "Algiers",
    "Oran",
    "Constantine",
    "Annaba",
    "Blida",
    "Tizi Ouzou",
    "Bejaia",
    "Setif",
    "Batna",
    "Skikda",
    "Chlef",
    "Mostaganem",
    "Tlemcen",
    "Biskra",
    "Ouargla",
    "Ghardaia",
  ];

  final List<String> pharmacySkills = [
    "Order Receiving & Invoice Entry",
    "Counter Customer Assistance",
    "CHIFA System Proficiency",
    "DAMANCOM System Proficiency",
    "CAMSSP System Proficiency",
    "Inventory Management",
    "Physical Inventory Control",
    "CNAS Claims Submission & Follow-up",
    "CASNOS Claims Submission & Follow-up",
    "CAMSSP Claims Submission & Follow-up",
    "Medication Ordering & Tracking",
    "Parapharmaceutical Ordering & Tracking",
    "Magistral Preparations",
    "Overall Pharmacy Management",
  ];

  @override
  void initState() {
    super.initState();
    _jobsFuture = _jobSearchRepo.getAllJobsWithRecruiter();
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Header(),
              const SizedBox(height: 25),

              const Text(
                "Find a pharmacy job",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              JobSearchBar(
                controller: searchCtrl,
                onChanged: (q) {
                  setState(() {});
                },
                onFilterTap: () {
                  openJobFilters(context, setState);
                },
              ),

              const SizedBox(height: 24),

              const Text(
                "Featured jobs",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 12),
              _FeaturedJobCard(),

              const SizedBox(height: 24),

              const Text(
                "Because you are interested in pharmacy",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),

              const SizedBox(height: 14),

              FutureBuilder<List<JobOfferWithRecruiter>>(
                future: _jobsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 40),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  if (snapshot.hasError) {
                    return const Center(child: Text("Failed to load jobs"));
                  }

                  final jobs = snapshot.data ?? [];

                  if (jobs.isEmpty) {
                    return const Center(child: Text("No jobs available"));
                  }

                  return Column(
                    children: jobs.map((item) {
                      return _JobCard(
                        buttonText: "View Details",
                        job: item,
                      );
                    }).toList(),
                  );
                },
              ),
            
            ],
          ),
        ),
      ),
    );
  }

  void openJobFilters(BuildContext context, StateSetter setStateParent) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final filteredRoles = jobRoles
                .where(
                  (e) => e.toLowerCase().contains(
                    roleSearchCtrl.text.toLowerCase(),
                  ),
                )
                .toList();

            final filteredSkills = pharmacySkills
                .where(
                  (e) => e.toLowerCase().contains(
                    skillSearchCtrl.text.toLowerCase(),
                  ),
                )
                .toList();

            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.8,
              child: Column(
                children: [
                  const SizedBox(height: 10),

                  /// DRAG HANDLE
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  const SizedBox(height: 12),

                  /// HEADER + CLEAR
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        const Text(
                          "Filter Jobs",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () {
                            setModalState(() {
                              selectedCity = "All";
                              selectedRoles.clear();
                              selectedSkills.clear();
                              roleSearchCtrl.clear();
                              skillSearchCtrl.clear();
                            });
                          },
                          child: const Text("Clear All"),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// SCROLL CONTENT
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      children: [
                        _filterSectionTitle("Location"),
                        _locationPicker(setModalState),

                        const SizedBox(height: 16),

                        _filterSectionTitle("Job Title"),
                        _searchBox(
                          controller: roleSearchCtrl,
                          hint: "Search job titles",
                          onChanged: (_) => setModalState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _rolePickerFiltered(setModalState, filteredRoles),

                        const SizedBox(height: 16),

                        _filterSectionTitle("Skills"),
                        _searchBox(
                          controller: skillSearchCtrl,
                          hint: "Search skills",
                          onChanged: (_) => setModalState(() {}),
                        ),
                        const SizedBox(height: 8),
                        _skillsPickerFiltered(setModalState, filteredSkills),
                      ],
                    ),
                  ),

                  /// APPLY BUTTON
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.greenCeladon,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () {
                          setStateParent(() {});
                          Navigator.pop(context);
                        },
                        child: const Text(
                          "Apply Filters",
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _searchBox({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
      ),
    );
  }

  Widget _rolePickerFiltered(StateSetter setModalState, List<String> roles) {
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      children: roles.map((role) {
        final selected = selectedRoles.contains(role);
        return FilterChip(
          label: Text(role),
          selected: selected,
          onSelected: (val) {
            setModalState(() {
              val ? selectedRoles.add(role) : selectedRoles.remove(role);
            });
          },
          selectedColor: AppColors.greenCeladon.withOpacity(0.25),
        );
      }).toList(),
    );
  }

  Widget _skillsPickerFiltered(StateSetter setModalState, List<String> skills) {
    return Column(
      children: skills.map((skill) {
        final selected = selectedSkills.contains(skill);
        return CheckboxListTile(
          dense: true,
          contentPadding: EdgeInsets.zero,
          value: selected,
          title: Text(skill),
          onChanged: (val) {
            setModalState(() {
              val == true
                  ? selectedSkills.add(skill)
                  : selectedSkills.remove(skill);
            });
          },
        );
      }).toList(),
    );
  }

  Widget _filterSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _locationPicker(StateSetter setModalState) {
    return Wrap(
      spacing: 8,
      children: algeriaCities.map((city) {
        final selected = selectedCity == city;
        return ChoiceChip(
          label: Text(city),
          selected: selected,
          onSelected: (_) {
            setModalState(() => selectedCity = city);
          },
          selectedColor: AppColors.greenCeladon,
        );
      }).toList(),
    );
  }
}

class _Header extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.greenCeladon,
          child: Icon(Icons.person),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Alex Johnson",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 19),
            ),
            Text(
              "Candidate",
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.black),
          ),
          child: const Icon(Icons.notifications),
        ),
      ],
    );
  }
}

class JobSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onFilterTap;
  final ValueChanged<String> onChanged;

  const JobSearchBar({
    super.key,
    required this.controller,
    required this.onFilterTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 48,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                icon: Icon(Icons.search, color: Colors.black),
                hintText: "Enter job title or keyword",
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: onFilterTap,
          child: Container(
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.black),
            ),
            child: const Icon(Icons.tune, color: Colors.black),
          ),
        ),
      ],
    );
  }
}

class _FeaturedJobCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.greenCeladon,
        borderRadius: BorderRadius.circular(24),
        boxShadow: premiumShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: Colors.green.shade300,
                child: Icon(Icons.diamond_rounded, color: Colors.black),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Job Seeker",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      "Health First Pharmacy",
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              Icon(Icons.bookmark_border, color: Colors.white),
            ],
          ),
          const SizedBox(height: 14),
          const Text(
            "Part-time / Remote",
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(.25),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  "Apply Now",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                "150K/ year",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ignore: must_be_immutable
// ignore: must_be_immutable
class _JobCard extends StatelessWidget {
  final JobOfferWithRecruiter job;
  final String buttonText;
  
  const _JobCard({
    required this.job,
    required this.buttonText,
  });

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
                const Icon(Icons.bookmark_border),
              ],
            ),
            const SizedBox(height: 12),
            Text(job.jobType, style: const TextStyle(fontSize: 13)),
            const SizedBox(height: 17),
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
              ],
            ),
          ],
        ),
      ),
    );
  }
}
