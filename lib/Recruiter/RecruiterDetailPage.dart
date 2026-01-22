import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Model/Recruiter.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:flutter/material.dart';

class RecruiterDetailPage extends StatefulWidget {
  final Recruiter recruiter;

  const RecruiterDetailPage({super.key, required this.recruiter});

  @override
  State<RecruiterDetailPage> createState() => _RecruiterDetailPageState();
}

class _RecruiterDetailPageState extends State<RecruiterDetailPage> {
  late bool isActive;

  @override
  void initState() {
    super.initState();
    isActive = widget.recruiter.isActive;
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.recruiter;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: AppColors.darkGreen),
        title: const Text(
          "Recruiter Profile",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// Header Card
            _headerCard(r),

            const SizedBox(height: 16),

            _infoCard(
              title: "Pharmacy Information",
              children: [
                _infoRow("Pharmacy Name", r.pharmacyName),
                _infoRow("Address", r.streetAddress),
                _infoRow("Province", r.province),
                _infoRow("City", r.city),
              ],
            ),

            const SizedBox(height: 16),

            _infoCard(
              title: "Pharmacist",
              children: [
                _infoRow("First Name", r.pharmacistFirstName),
                _infoRow("Last Name", r.pharmacistLastName),
              ],
            ),

            const SizedBox(height: 16),

            _infoCard(
              title: "Meta Information",
              children: [
                _infoRow("User ID", r.userId),
                _infoRow("Created At", r.createdAt.toLocal().toString()),
                _infoRow("Latitude", r.latitude.toString()),
                _infoRow("Longitude", r.longitude.toString()),
              ],
            ),

            const SizedBox(height: 24),

            /// Action Button
            _statusActionButton(),
          ],
        ),
      ),
    );
  }

  // ================= ACTION =================

  Widget _statusActionButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: _updateStatus,
        style: ElevatedButton.styleFrom(
          elevation: 4,
          backgroundColor: isActive ? AppColors.red: AppColors.greenCeladon,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          isActive ? "Unverify Recruiter" : "Verify Recruiter",
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _updateStatus() async {
    RecruiterRepository recruiterRepository = RecruiterRepository();
    setState(() => isActive = !isActive);

    /// 🔥 Update model
    final updatedRecruiter = Recruiter(
      userId: widget.recruiter.userId,
      pharmacyName: widget.recruiter.pharmacyName,
      pharmacistFirstName: widget.recruiter.pharmacistFirstName,
      pharmacistLastName: widget.recruiter.pharmacistLastName,
      province: widget.recruiter.province,
      city: widget.recruiter.city,
      streetAddress: widget.recruiter.streetAddress,
      latitude: widget.recruiter.latitude,
      longitude: widget.recruiter.longitude,
      createdAt: widget.recruiter.createdAt,
      isActive: isActive, // ✅ new value
      docId: widget.recruiter.docId,
      logoUrl: widget.recruiter.logoUrl,
    );

    await recruiterRepository.update(widget.recruiter.docId!, updatedRecruiter);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          isActive
              ? "Recruiter approved successfully"
              : "Recruiter deactivated",
        ),
      ),
    );
  }

  // ================= UI =================

  Widget _headerCard(Recruiter r) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.darkGreen, AppColors.darkGreen.withOpacity(.8)],
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: Colors.white,
            child: Text(
              r.pharmacyName.isNotEmpty ? r.pharmacyName[0].toUpperCase() : "P",
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.darkGreen,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  r.pharmacyName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "${r.pharmacistFirstName} ${r.pharmacistLastName}",
                  style: const TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
          _statusBadge(),
        ],
      ),
    );
  }

  Widget _statusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isActive ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        isActive ? "Verified" : "Unverified",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

Widget _infoCard({required String title, required List<Widget> children}) {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(.04),
          blurRadius: 12,
          offset: const Offset(0, 6),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    ),
  );
}

Widget _infoRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}
