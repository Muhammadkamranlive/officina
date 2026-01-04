import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/routes/app_routes.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:client/Guard/AuthProvider/AuthProvider.dart';

enum AccountFormMode { view, edit, create }

// Add this list of provinces and cities for Algeria
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

class RecruiterAccountScreen extends StatefulWidget {
  final AccountFormMode mode;

  const RecruiterAccountScreen({super.key, required this.mode});

  @override
  State<RecruiterAccountScreen> createState() => _RecruiterAccountScreenState();
}

class _RecruiterAccountScreenState extends State<RecruiterAccountScreen> {
  final _repo = RecruiterRepository();

  final pharmacyNameCtrl = TextEditingController();
  final firstNameCtrl = TextEditingController();
  final lastNameCtrl = TextEditingController();
  final provinceCtrl = TextEditingController();
  final cityCtrl = TextEditingController();
  final streetCtrl = TextEditingController();
  final double inputFieldHeight = 66; // Match your _InputField height

  String? selectedProvince;
  String? selectedCity;

  Recruiter? recruiter;
  bool loading = true;

  bool get isView => widget.mode == AccountFormMode.view;
  bool get isEdit => widget.mode == AccountFormMode.edit;
  bool get isCreate => widget.mode == AccountFormMode.create;

  @override
  void initState() {
    super.initState();
    _loadRecruiter();
  }

  Future<void> _loadRecruiter() async {
    // Get current user from provider
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final uid = user.userId; // get UID from AppUser

    recruiter = await _repo.getByUid(uid);

    if (recruiter != null) {
      pharmacyNameCtrl.text = recruiter!.pharmacyName;
      firstNameCtrl.text = recruiter!.pharmacistFirstName;
      lastNameCtrl.text = recruiter!.pharmacistLastName;
      selectedProvince = recruiter!.province;
      selectedCity = recruiter!.city;
      streetCtrl.text = recruiter!.streetAddress;
    }

    setState(() => loading = false);
  }

  Future<void> _save() async {
    setState(() => loading = true);
    final user = context.read<AuthProvider>().user;

    if (user == null) {
      setState(() => loading = false);
      return;
    }

    final uid = user.userId; // get UID from AppUser
    final data = Recruiter(
      userId: uid,
      pharmacyName: pharmacyNameCtrl.text,
      pharmacistFirstName: firstNameCtrl.text,
      pharmacistLastName: lastNameCtrl.text,
      // province: provinceCtrl.text,
      // city: cityCtrl.text,
      province: selectedProvince ?? '',
      city: selectedCity ?? '',
      streetAddress: streetCtrl.text,
      latitude: recruiter?.latitude ?? 0,
      longitude: recruiter?.longitude ?? 0,
      createdAt: recruiter?.createdAt ?? DateTime.now(),
      isActive: true,
      docId: recruiter?.docId,
    );

    if (isCreate) {
      await _repo.add(data);
    } else {
      await _repo.update(data.docId!, data);
    }

    setState(() => loading = false);
    Navigator.pushNamed(context, AppRoutes.mainShell);
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
              ? "Create Account"
              : isEdit
              ? "Edit Profile"
              : "My Account",
          style: const TextStyle(color: AppColors.darkGreen),
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
                    hint: "Anabella",
                    enabled: !isView,
                    controller: firstNameCtrl,
                  ),
                  const SizedBox(height: 12),
                  _InputField(
                    label: "Last Name",
                    hint: "Angela",
                    enabled: !isView,
                    controller: lastNameCtrl,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _card(
              "Pharmacy & Location",
              Column(
                children: [
                  _InputField(
                    label: "Pharmacy Name",
                    hint: "GreenCare Pharmacy",
                    enabled: !isView,
                    controller: pharmacyNameCtrl,
                  ),
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
            const SizedBox(height: 24),
            if (!isView)
              _customButton(
                text: isCreate ? "Create Account" : "Save Changes",
                onPressed: _save,
                size: MediaQuery.of(context).size,
                gradient: AppColors.gradientdarkgreen,
                shadowColor: AppColors.darkGreen,
              ),
            if (isView)
              OutlinedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const RecruiterAccountScreen(
                        mode: AccountFormMode.edit,
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 12),
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


/* ================= INPUT FIELD (REUSED) ================= */

