import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Recruiter/JobseekerList/JobSeekerDetailScreen.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Server/Model/JobSeeker.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

final mockJobSeekers = [
  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Ahmed Benali",
    isAnonymous: false,
    desiredPosition: "Pharmacist",
    city: "Algiers",
    skills: [
      "Inventory Management",
      "Counter Customer Assistance",
      "CHIFA System Proficiency",
      "Medication Ordering & Tracking",
      "Overall Pharmacy Management",
    ],
    authenticatedSkills: [
      "Inventory Management",
      "CHIFA System Proficiency",
      "Overall Pharmacy Management",
    ],
    experience: "6 years as a community pharmacist in Algiers.",
    education: "Doctor of Pharmacy – University of Algiers",
  ),

  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Anonymous",
    isAnonymous: true,
    desiredPosition: "Senior Salesperson",
    city: "Oran",
    skills: [
      "Counter Customer Assistance",
      "Parapharmaceutical Ordering & Tracking",
      "Physical Inventory Control",
    ],
    authenticatedSkills: ["Counter Customer Assistance"],
    experience: "8 years in pharmacy sales and customer relations.",
  ),

  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Yasmine Khelifi",
    isAnonymous: false,
    desiredPosition: "Stock Management Specialist",
    city: "Constantine",
    skills: [
      "Inventory Management",
      "Physical Inventory Control",
      "Medication Ordering & Tracking",
      "CNAS Claims Submission & Follow-up",
    ],
    authenticatedSkills: ["Inventory Management", "Physical Inventory Control"],
    experience: "4 years managing stock and logistics in a large pharmacy.",
  ),

  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Anonymous",
    isAnonymous: true,
    desiredPosition: "Intern",
    city: "Blida",
    skills: [
      "Counter Customer Assistance",
      "Order Receiving & Invoice Entry",
      "Inventory Management",
    ],
    authenticatedSkills: [],
    experience: "Final-year pharmacy student seeking internship.",
    education: "Pharmacy Student – University of Blida",
  ),

  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Mohamed Saidi",
    isAnonymous: false,
    desiredPosition: "Manager",
    city: "Setif",
    skills: [
      "Overall Pharmacy Management",
      "CHIFA System Proficiency",
      "DAMANCOM System Proficiency",
      "CASNOS Claims Submission & Follow-up",
    ],
    authenticatedSkills: [
      "Overall Pharmacy Management",
      "CHIFA System Proficiency",
    ],
    experience: "10 years managing independent pharmacies.",
  ),

  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Nadia Bouzid",
    isAnonymous: false,
    desiredPosition: "Labeling / Data Entry Specialist",
    city: "Tizi Ouzou",
    skills: [
      "Order Receiving & Invoice Entry",
      "Labeling / Data Entry Specialist",
      "CAMSSP Claims Submission & Follow-up",
    ],
    authenticatedSkills: ["Order Receiving & Invoice Entry"],
    experience: "3 years in pharmacy administrative operations.",
  ),

  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Anonymous",
    isAnonymous: true,
    desiredPosition: "Sales Specialist",
    city: "Annaba",
    skills: [
      "Counter Customer Assistance",
      "Parapharmaceutical Ordering & Tracking",
      "Physical Inventory Control",
    ],
    authenticatedSkills: ["Parapharmaceutical Ordering & Tracking"],
    experience: "5 years specializing in parapharmacy sales.",
  ),

  JobSeeker(
    userId: "8vhegVtRGlccuubhX8KnoyEkp8B2",
    fullName: "Rachid Amrani",
    isAnonymous: false,
    desiredPosition: "Physician",
    city: "Batna",
    skills: [
      "Overall Pharmacy Management",
      "Medication Ordering & Tracking",
      "CHIFA System Proficiency",
    ],
    authenticatedSkills: ["Medication Ordering & Tracking"],
    experience: "Physician collaborating with pharmacies for 7 years.",
  ),
];

const List<String> pharmacySkills = [
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
const List<String> algeriaCities = [
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
const List<String> jobRoles = [
  "Manager",
  "Pharmacist",
  "Physician",
  "Senior Salesperson",
  "Sales Specialist",
  "Intern",
  "Labeling / Data Entry Specialist",
  "Stock Management Specialist",
];

class JobSeekerProfilesScreen extends StatefulWidget {
  const JobSeekerProfilesScreen({super.key});

  @override
  State<JobSeekerProfilesScreen> createState() =>
      _JobSeekerProfilesScreenState();
}

class _JobSeekerProfilesScreenState extends State<JobSeekerProfilesScreen> {
  String selectedCity = "All";
  List<String> selectedSkills = [];

  // 🔹 MOCK DATA (replace with API)

  List<JobSeeker> get filteredSeekers {
    return mockJobSeekers.where((seeker) {
      final matchesCity = selectedCity == "All" || seeker.city == selectedCity;

      final matchesSkills =
          selectedSkills.isEmpty ||
          selectedSkills.every(seeker.skills.contains);

      return matchesCity && matchesSkills;
    }).toList();
  }

  String searchQuery = "";
  List<String> selectedRoles = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              DashboardHeader(),

              /// TITLE
              const Text(
                "Available Job Seekers",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Browse candidates matching your needs",
                style: TextStyle(color: Colors.grey),
              ),

              const SizedBox(height: 16),

              /// 🔍 SEARCH INPUT
              Container(
                margin: const EdgeInsets.only(bottom: 14),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: TextField(
                  onChanged: (value) {
                    setState(() => searchQuery = value.toLowerCase());
                  },
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: AppColors.darkGreen),
                    hintText: "Search by name, skill or role",
                  ),
                ),
              ),

              /// FILTERS
              _filtersRow(),

              const SizedBox(height: 12),

              /// RESULT COUNT
              Text(
                "${filteredSeekers.length} profiles found",
                style: const TextStyle(fontSize: 13, color: Colors.grey),
              ),

              const SizedBox(height: 12),

              /// LIST
              Expanded(
                child: ListView.builder(
                  itemCount: filteredSeekers.length,
                  itemBuilder: (_, index) {
                    return JobSeekerCard(seeker: filteredSeekers[index]);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rolesFilter() {
    return _filterButton(
      icon: Icons.work_outline,
      label: selectedRoles.isEmpty ? "Roles" : "${selectedRoles.length} roles",
      onTap: () {
        showModalBottomSheet(
          context: context,
          backgroundColor: Colors.white,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
          ),
          builder: (_) {
            return SizedBox(
              height: MediaQuery.of(context).size.height * 0.55,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Select Job Roles",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: ListView.builder(
                        itemCount: jobRoles.length,
                        itemBuilder: (_, index) {
                          final role = jobRoles[index];
                          final selected = selectedRoles.contains(role);

                          return CheckboxListTile(
                            contentPadding: EdgeInsets.zero,
                            value: selected,
                            title: Text(role),
                            onChanged: (val) {
                              setState(() {
                                val == true
                                    ? selectedRoles.add(role)
                                    : selectedRoles.remove(role);
                              });
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// 🔹 FILTERS ROW
  Widget _filtersRow() {
    return Row(
      children: [
        Expanded(
          child: _filterButton(
            icon: Icons.location_on_outlined,
            label: selectedCity,
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                ),
                builder: (_) {
                  return SizedBox(
                    height: MediaQuery.of(context).size.height * 0.55,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          const Text(
                            "Select Location",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// LIST
                          Expanded(
                            child: ListView.separated(
                              itemCount: algeriaCities.length,
                              separatorBuilder: (_, __) =>
                                  Divider(color: Colors.grey.shade200),
                              itemBuilder: (_, index) {
                                final city = algeriaCities[index];
                                final isSelected = selectedCity == city;

                                return InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: () {
                                    setState(() => selectedCity = city);
                                    Navigator.pop(context);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 12,
                                      horizontal: 8,
                                    ),
                                    child: Row(
                                      children: [
                                        /// ICON
                                        Container(
                                          width: 36,
                                          height: 36,
                                          decoration: BoxDecoration(
                                            color: isSelected
                                                ? AppColors.greenCeladon
                                                      .withOpacity(0.2)
                                                : Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.location_on,
                                            size: 18,
                                            color: isSelected
                                                ? AppColors.green
                                                : Colors.grey,
                                          ),
                                        ),

                                        const SizedBox(width: 12),

                                        /// CITY NAME
                                        Expanded(
                                          child: Text(
                                            city,
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ),

                                        /// CHECK
                                        if (isSelected)
                                          const Icon(
                                            Icons.check_circle,
                                            color: AppColors.green,
                                            size: 18,
                                          ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        const SizedBox(width: 5),

        Expanded(child: _rolesFilter()),
        const SizedBox(width: 5),
        Expanded(
          child: _filterButton(
            icon: Icons.tune,
            label: "Skills",
            onTap: () {
              showModalBottomSheet(
                context: context,
                backgroundColor: Colors.white,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                builder: (_) {
                  return SizedBox(
                    height:
                        MediaQuery.of(context).size.height *
                        0.6, // 🔥 FIXED HEIGHT
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          /// HEADER
                          const Text(
                            "Select Skills",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          const SizedBox(height: 12),

                          /// SCROLLABLE CONTENT
                          Expanded(
                            child: ListView.builder(
                              itemCount: pharmacySkills.length,
                              itemBuilder: (_, index) {
                                final skill = pharmacySkills[index];
                                final selected = selectedSkills.contains(skill);

                                return CheckboxListTile(
                                  contentPadding: EdgeInsets.zero,
                                  value: selected,
                                  title: Text(skill),
                                  onChanged: (val) {
                                    setState(() {
                                      val == true
                                          ? selectedSkills.add(skill)
                                          : selectedSkills.remove(skill);
                                    });
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: AppColors.darkGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 13),
              ),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 18),
          ],
        ),
      ),
    );
  }
}

class JobSeekerCard extends StatelessWidget {
  final JobSeeker seeker;

  const JobSeekerCard({super.key, required this.seeker});

  @override
  Widget build(BuildContext context) {
    final hasVerifiedSkills = seeker.authenticatedSkills.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
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
                      seeker.isAnonymous
                          ? "Anonymous Candidate"
                          : seeker.fullName ?? "—",
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      seeker.desiredPosition,
                      style: const TextStyle(
                        color: AppColors.darkGreen,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (hasVerifiedSkills)
                const Icon(Icons.verified, color: Colors.green),
            ],
          ),

          const SizedBox(height: 10),

          /// LOCATION
          Row(
            children: [
              const Icon(Icons.location_on, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              Text(seeker.city, style: const TextStyle(fontSize: 12)),
            ],
          ),

          const SizedBox(height: 12),

          /// SKILLS
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: seeker.skills.map((skill) {
              final isVerified = seeker.authenticatedSkills.contains(skill);

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isVerified
                      ? AppColors.lightgreen.withOpacity(0.15)
                      : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(skill, style: const TextStyle(fontSize: 11)),
                    if (isVerified) ...[
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.check_circle,
                        size: 12,
                        color: Colors.green,
                      ),
                    ],
                  ],
                ),
              );
            }).toList(),
          ),

          if (seeker.experience != null) ...[
            const SizedBox(height: 12),
            Text(
              seeker.experience!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 12),
            ),
          ],

          const SizedBox(height: 14),

          /// ACTIONS
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => JobSeekerDetailScreen(seeker: seeker),
                      ),
                    );
                  },
                  child: const Text("View Profile"),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
  child: ElevatedButton(
    onPressed: () async {
      final auth = context.read<AuthProvider>();

      if (auth.user == null) return;

      final recruiterId = auth.user!.userId;
      final jobSeekerId = seeker.userId; // ✅ SAFE

      final chatService = ChatService();

      final chatId = await chatService.getOrCreateChat(
       recruiterId,jobSeekerId
      );

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserId: jobSeekerId,
            personName: seeker.isAnonymous
                ? "Anonymous Candidate"
                : (seeker.fullName ?? "Candidate"),
          ),
        ),
      );
    },
    child: const Text("Chat"),
  ),
),

            ],
          ),
        ],
      ),
    );
  }
}

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
                "Job Seeker Profiles",
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
