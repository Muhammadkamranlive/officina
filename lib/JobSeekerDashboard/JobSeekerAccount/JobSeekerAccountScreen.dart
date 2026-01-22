import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterAccountScreen.dart';
import 'package:client/Server/Enums/JobSeekerEnum.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:client/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

const List<String> provinces = [
  'Algiers',
  'Oran',
  'Constantine',
  'Annaba',
  'Blida',
  'Batna',
  'Tlemcen',
  'Setif',
  'Sidi Bel Abbes',
];

const Map<String, List<String>> cities = {
  'Algiers': ['Bab El Oued', 'Kouba', 'El Harrach', 'Birkhadem'],
  'Oran': ['Bir El Djir', 'Es Senia', 'El Hamri'],
  'Constantine': ['El Khroub', 'Didouche Mourad'],
  'Annaba': ['Seraïdi', 'Berrahal'],
  // Add other provinces and their cities
};

class JobSeekerAccountScreen extends StatefulWidget {
  final JobSeekerFormMode mode;

  const JobSeekerAccountScreen({super.key, required this.mode});

  @override
  State<JobSeekerAccountScreen> createState() => _JobSeekerAccountScreenState();
}

class _JobSeekerAccountScreenState extends State<JobSeekerAccountScreen> {
  final _repo = JobSeekerRepository();

  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final educationCtrl = TextEditingController();
  final experienceCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final phoneCtrl = TextEditingController();
  final provinceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final double inputFieldHeight = 66; // Match your _InputField height
  // Add this list of provinces and cities for Algeria

  String? selectedProvince;
  String? selectedCity;

  static const List<String> desiredPositions = [
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

  bool isNameVisible = true;
  String? desiredPosition;

  JobSeekerModel? jobSeeker;
  bool loading = true;

  /// skill → status
  Map<String, String> skills = {};

  bool get isView => widget.mode == JobSeekerFormMode.view;
  bool get isEdit => widget.mode == JobSeekerFormMode.edit;
  bool get isCreate => widget.mode == JobSeekerFormMode.create;

  static const List<String> predefinedSkills = [
    "Order reception and invoice entry",
    "Counter customer consultation",
    "Chifa system proficiency",
    "Damancom system proficiency",
    "CAMSSP system proficiency",
    "Stock management",
    "Physical inventory",
    "CNAS forms submission and follow-up",
    "CASNOS forms submission and follow-up",
    "CAMSSP forms submission and follow-up",
    "Medication ordering and tracking",
    "Parapharmaceutical products ordering and tracking",
    "Compounding preparations",
    "Overall pharmacy management",
  ];

  @override
  void initState() {
    super.initState();
    _load();
  }

  String? _phoneError;

  bool _isValidAlgerianPhone(String phone) {
    final regex = RegExp(r'^[567]\d{8}$');
    return regex.hasMatch(phone);
  }

  bool _validatePhone() {
    final phone = phoneCtrl.text.trim();

    if (phone.isEmpty) {
      _phoneError = "Phone number is required";
      return false;
    }

    if (phone.length != 9) {
      _phoneError = "Phone number must be 9 digits";
      return false;
    }

    if (!_isValidAlgerianPhone(phone)) {
      _phoneError = "Phone must start with 5, 6, or 7 (Algeria only)";
      return false;
    }

    _phoneError = null;
    return true;
  }

  Future<void> _load() async {
    try {
      final user = context.read<AuthProvider>().user;

      if (user == null) {
        if (mounted) {
          setState(() => loading = false);
        }
        return;
      }

      // ✅ Email always from auth
      emailCtrl.text = user.email ?? '';

      jobSeeker = await _repo.getByUid(user.userId);

      if (jobSeeker != null) {
        firstNameCtrl.text = jobSeeker!.firstName;
        lastNameCtrl.text = jobSeeker!.lastName;
        educationCtrl.text = jobSeeker!.educationBackground ?? '';
        experienceCtrl.text = jobSeeker!.experienceDetails ?? '';
        desiredPosition = jobSeeker!.desiredPosition;
        isNameVisible = jobSeeker!.isNameVisible;
        skills = Map.from(jobSeeker!.skills);
        // selectedProvince    = jobSeeker!.province;
        // selectedCity        = jobSeeker!.city;
        // streetCtrl.text     = jobSeeker!.streetAddress;
        // ✅ Strip +213 safely for UI
        if (user.phone != null && user.phone!.startsWith("+213")) {
          phoneCtrl.text = user.phone!.replaceFirst("+213", "");
        } else {
          phoneCtrl.text = jobSeeker!.phoneNumber.replaceFirst("+213", "");
        }
      }
    } catch (e) {
      debugPrint("JobSeeker load error: $e");
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Future<void> _save() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;
    bool phoneValid = _validatePhone();

    if (!phoneValid) {
      setState(() {}); // refresh UI to show error
      return;
    }

    if (firstNameCtrl.text.trim().isEmpty ||
        lastNameCtrl.text.trim().isEmpty ||
        emailCtrl.text.trim().isEmpty ||
        desiredPosition == null ||
        skills.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all required fields")),
      );
      return;
    }
    final data = JobSeekerModel(
      userId: user.userId,
      firstName: firstNameCtrl.text.trim(),
      lastName: lastNameCtrl.text.trim(),
      isNameVisible: isNameVisible,
      email: emailCtrl.text.trim(),
      province: selectedProvince ?? '',
      city: selectedCity ?? '',
      streetAddress: streetCtrl.text,
      latitude: jobSeeker?.latitude ?? 0,
      longitude: jobSeeker?.longitude ?? 0,
      // ✅ ALWAYS correct format
      phoneNumber: "+213${phoneCtrl.text.trim()}",
      desiredPosition: desiredPosition!,
      skills: skills,
      educationBackground: educationCtrl.text.trim().isEmpty
          ? null
          : educationCtrl.text.trim(),
      experienceDetails: experienceCtrl.text.trim().isEmpty
          ? null
          : experienceCtrl.text.trim(),
      createdAt: jobSeeker?.createdAt ?? DateTime.now(),
      isActive: jobSeeker?.isActive ?? 'Pending',
      docId: jobSeeker?.docId,
    );

    if (isCreate) {
      await _repo.add(data);
    } else {
      await _repo.update(data.docId!, data);
    }

    Navigator.pushNamed(context, AppRoutes.jobSeekerDash);
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Text(
          isCreate
              ? "Create Profile"
              : isEdit
              ? "Edit Profile"
              : "My Profile",
          style: const TextStyle(color: AppColors.darkGreen, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _card(
              "Personal Information",
              Column(
                children: [
                  _InputField(
                    label: "First Name",
                    hint: "Ahmed",
                    enabled: !isView,
                    controller: firstNameCtrl,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    label: "Last Name",
                    hint: "Ben Ali",
                    enabled: !isView,
                    controller: lastNameCtrl,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    label: "Email",
                    hint: "",
                    enabled: true,
                    controller: emailCtrl,
                  ),
                  const SizedBox(height: 12),
                  _phoneField(),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: isNameVisible,
                    onChanged: isView
                        ? null
                        : (v) => setState(() => isNameVisible = v),
                    title: const Text("Show my name to recruiters"),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _card(
              "Location Information",
              Column(
                children: [
                  const SizedBox(height: 12),
                  _provinceDropdown(),
                  const SizedBox(height: 12),
                  _cityDropdown(),
                  const SizedBox(height: 12),
                  _InputField(
                    label: "Street Address",
                    hint: "12 Rue Didouche Mourad",
                    enabled: !isView,
                    controller: streetCtrl,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _card("Job Title", Column(children: [_desiredPositionField()])),
            const SizedBox(height: 10),
            _card(
              "Skills",
              Column(
                children: [
                  ...skills.entries.map(_skillTile),
                  if (!isView)
                    TextButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text("Add Skill"),
                      onPressed: _openSkillBottomSheet,
                    ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            _card(
              "Background",
              Column(
                children: [
                  _InputField(
                    label: "Education",
                    hint: "Pharmacy Degree",
                    enabled: !isView,
                    controller: educationCtrl,
                    maxLines: 2,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    label: "Experience",
                    hint: "5 years in retail pharmacy",
                    enabled: !isView,
                    controller: experienceCtrl,
                    maxLines: 3,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            if (!isView)
              _customButton(
                text: isCreate ? "Create Profile" : "Save Changes",
                onPressed: _save,
                size: MediaQuery.of(context).size,
                gradient: AppColors.gradientdarkgreen,
                shadowColor: AppColors.darkGreen,
              ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _skillTile(MapEntry<String, String> entry) {
    Color color;
    switch (entry.value) {
      case SkillStatus.verified:
        color = Colors.green;
        break;
      case SkillStatus.rejected:
        color = Colors.red;
        break;
      default:
        color = Colors.orange;
    }

    return ListTile(
      title: Text(entry.key),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Chip(
            label: Text(entry.value),
            backgroundColor: color,
            labelStyle: TextStyle(color: AppColors.white),
          ),
          if (!isView)
            IconButton(
              icon: const Icon(Icons.close, size: 18),
              onPressed: () {
                setState(() => skills.remove(entry.key));
              },
            ),
        ],
      ),
    );
  }

  /// 🔹 Bottom Sheet to add/remove skills (toggle, realtime)
  void _openSkillBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.45,
          child: Column(
            children: [
              const SizedBox(height: 12),

              // drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Select Skills",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              Expanded(
                child: StatefulBuilder(
                  builder: (context, setSheetState) {
                    return ListView.separated(
                      itemCount: predefinedSkills.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final skill = predefinedSkills[index];
                        final isSelected = skills.containsKey(skill);

                        return ListTile(
                          title: Text(skill),
                          trailing: isSelected
                              ? const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                )
                              : const Icon(
                                  Icons.circle_outlined,
                                  color: Colors.grey,
                                ),
                          onTap: () {
                            setSheetState(() {
                              setState(() {
                                // 🔹 update parent UI in real-time
                                if (isSelected) {
                                  skills.remove(skill);
                                } else {
                                  skills[skill] = SkillStatus.pending;
                                }
                              });
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _card(String title, Widget child) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.04), blurRadius: 12),
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

  Widget _phoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(2),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            gradient: AppColors.gradientgreen,
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Image.asset(
                  "assets/dz.png",
                  width: 28,
                  height: 20,
                  fit: BoxFit.cover,
                ),
                const SizedBox(width: 8),

                const Text(
                  "+213",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 10),

                Expanded(
                  child: TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(9),
                    ],
                    onChanged: (_) {
                      setState(() => _phoneError = null);
                    },
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: "5XXXXXXXX",
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        if (_phoneError != null)
          Padding(
            padding: const EdgeInsets.only(top: 6, left: 6),
            child: Text(
              _phoneError!,
              style: const TextStyle(color: Colors.red, fontSize: 12),
            ),
          ),
      ],
    );
  }

  Widget _desiredPositionField() {
    return GestureDetector(
      onTap: isView ? null : _openDesiredPositionSheet,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: AppColors.gradientgreen,
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                desiredPosition ?? "Select Desired Position",
                style: TextStyle(
                  color: desiredPosition == null ? Colors.grey : Colors.black,
                  fontSize: 14,
                ),
              ),
              const Icon(Icons.arrow_drop_down),
            ],
          ),
        ),
      ),
    );
  }

  void _openDesiredPositionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.45, // 👈 fixed height
          child: Column(
            children: [
              const SizedBox(height: 12),

              // drag handle
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade400,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 16),
              const Text(
                "Select Desired Position",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 12),

              // scrollable list
              Expanded(
                child: ListView.separated(
                  itemCount: desiredPositions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final position = desiredPositions[index];
                    return ListTile(
                      title: Text(position),
                      trailing: desiredPosition == position
                          ? const Icon(Icons.check, color: Colors.green)
                          : null,
                      onTap: () {
                        setState(() => desiredPosition = position);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _provinceDropdown() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen,
      ),
      child: Container(
        height: inputFieldHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: DropdownButtonFormField<String>(
          value: selectedProvince,
          decoration: InputDecoration(
            labelText: "Province",
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 12,
            ),
          ),
          hint: const Text("Select Province"),
          items: provinces
              .map((p) => DropdownMenuItem(value: p, child: Text(p)))
              .toList(),
          onChanged: isView
              ? null
              : (val) {
                  setState(() {
                    selectedProvince = val;
                    selectedCity = null;
                  });
                },
        ),
      ),
    );
  }

  Widget _cityDropdown() {
    final availableCities = selectedProvince != null
        ? (cities[selectedProvince!] as List<String>?) ?? []
        : <String>[];

    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen,
      ),
      child: Container(
        height: inputFieldHeight,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12),
        alignment: Alignment.center,
        child: DropdownButtonFormField<String>(
          value: selectedCity,
          decoration: InputDecoration(
            labelText: "City",
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 4,
              vertical: 12,
            ),
          ),
          hint: const Text("Select City"),
          items: availableCities
              .map((c) => DropdownMenuItem<String>(value: c, child: Text(c)))
              .toList(),
          onChanged: isView
              ? null
              : (val) {
                  setState(() {
                    selectedCity = val;
                  });
                },
        ),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String label;
  final String hint;
  final bool enabled;
  final int maxLines;
  final TextEditingController controller;

  const _InputField({
    required this.label,
    required this.hint,
    required this.enabled,
    required this.controller,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: AppColors.gradientgreen,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(
          controller: controller,
          enabled: enabled,
          maxLines: maxLines,
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ),
    );
  }
}
