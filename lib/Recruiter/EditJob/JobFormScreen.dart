import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:client/Server/Repo/Receuiter/JobOfferRepository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';

enum JobFormMode { create, edit }

class JobFormScreen extends StatefulWidget {
  final JobFormMode mode;
  final JobOffer? jobOffer;

  const JobFormScreen({super.key, required this.mode, this.jobOffer});

  @override
  State<JobFormScreen> createState() => _JobFormScreenState();
}

class _JobFormScreenState extends State<JobFormScreen> {
  final _repo = JobOfferRepository();
  final _repoNotiifcations = NotificationRepository();
  final descCtrl = TextEditingController();
  String? jobTitle;
  String? jobType;

  final jobTitles = [
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

  final jobTypes = ["Full Time", "Part Time", "Replacement"];

  final skills = [
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

  final Set<String> selectedSkills = {};
  final skillSearchCtrl = TextEditingController();
  final salaryCtrl = TextEditingController();

  String skillQuery = "";

  bool loading = true;

  bool get isCreate => widget.mode == JobFormMode.create;
  bool get isEdit => widget.mode == JobFormMode.edit;

  @override
  void initState() {
    super.initState();
    _loadJobOffer();
  }

  bool _validateForm() {
    if (jobTitle == null || jobTitle!.isEmpty) {
      _showError("Please select a job title.");
      return false;
    }

    if (jobType == null || jobType!.isEmpty) {
      _showError("Please select a job type.");
      return false;
    }

    if (salaryCtrl.text.trim().isEmpty) {
      _showError("Please enter the salary.");
      return false;
    }

    if (selectedSkills.isEmpty) {
      _showError("Please add at least one skill.");
      return false;
    }

    return true;
  }

  void _loadJobOffer() {
    if (widget.jobOffer != null) {
      final job = widget.jobOffer!;
      jobTitle = job.jobTitle;
      jobType = job.jobType;
      salaryCtrl.text = job.salary;
      selectedSkills.addAll(job.skills);
    }
    setState(() => loading = false);
  }

  Future<void> _saveJob({required bool post}) async {
    // 🔥 VALIDATION FIRST
    if (!_validateForm()) return;

    setState(() => loading = true);
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final job = JobOffer(
      docId: widget.jobOffer?.docId,
      userId: user.userId,
      jobTitle: jobTitle ?? '',
      jobType: jobType ?? '',

      skills: selectedSkills.toList(),
      salary: salaryCtrl.text.trim(),
      createdAt: widget.jobOffer?.createdAt ?? DateTime.now(),
      // 🔥 CORE LOGIC
      isDraft: !post,
      isActive: post,
    );

    if (isCreate) {
      await _repo.add(job);
      // 🔥 CREATE NOTIFICATION
      final notification = NotificationModel(
        userId: user.userId,
        type: 'job_post',
        title: 'Job Posted',
        description: 'You posted a new job: ${job.jobTitle}',
        targetId: null,
        targetType: null,
        route: null,
        isRead: false,
        createdAt: DateTime.now(),
      );

      await _repoNotiifcations.add(notification);
    } else {
      await _repo.update(job.docId!, job);
    }

    setState(() => loading = false);
    Navigator.pop(context); // Return to previous screen
  }

  void _openSkillSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              height: MediaQuery.of(context).size.height * .65,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Drag handle
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),

                  const Text(
                    "Select Skills",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: SingleChildScrollView(
                      child: Wrap(
                        spacing: 10,
                        runSpacing: 10,
                        children: skills.map((skill) {
                          final selected = selectedSkills.contains(skill);

                          return GestureDetector(
                            onTap: () {
                              setModalState(() {
                                selected
                                    ? selectedSkills.remove(skill)
                                    : selectedSkills.add(skill);
                              });
                              setState(() {}); // update main UI
                            },
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: selected
                                    ? AppColors.green.withOpacity(.12)
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: selected
                                      ? AppColors.green
                                      : Colors.grey.shade300,
                                ),
                              ),
                              child: Text(
                                skill,
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: selected
                                      ? AppColors.green
                                      : Colors.black87,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade600,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (loading)
      return const Scaffold(body: Center(child: CircularProgressIndicator()));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isCreate ? "Create Job Offer" : "Edit Job Offer"),
        backgroundColor: AppColors.background,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 40, top: 16),
        child: Column(
          children: [
            _SectionCard(
              title: "Job Details",
              child: Column(
                children: [
                  _DropdownField(
                    label: "Job Title",
                    value: jobTitle,
                    items: jobTitles,
                    onChanged: (v) => setState(() => jobTitle = v),
                  ),
                  const SizedBox(height: 12),
                  _DropdownField(
                    label: "Job Type",
                    value: jobType,
                    items: jobTypes,
                    onChanged: (v) => setState(() => jobType = v),
                  ),
                  const SizedBox(height: 16),

                  _TextField(
                    label: "Salary",
                    controller: salaryCtrl,
                    hint: "e.g. 180K / year",
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: const Text(
                      "Skills",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () => _openSkillSelector(context),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.green),
                        color: Colors.white,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add, color: AppColors.green),
                          SizedBox(width: 8),
                          Text(
                            "Add Skills",
                            style: TextStyle(
                              fontWeight: FontWeight.w600,

                              color: AppColors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: selectedSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        deleteIcon: const Icon(Icons.close, size: 18),
                        onDeleted: () =>
                            setState(() => selectedSkills.remove(skill)),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        labelStyle: const TextStyle(
                          color: AppColors.green,
                          fontWeight: FontWeight.w500,
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 8,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _customButton(
                      text: "Save Draft",
                      size: size,
                      gradient: AppColors.gradientPink,
                      shadowColor: AppColors.red,
                      onPressed: () => _saveJob(post: false),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _customButton(
                      text: isCreate ? "Post Job" : "Update Job",
                      size: size,
                      gradient: AppColors.gradientgreen,
                      shadowColor: AppColors.green,
                      onPressed: () => _saveJob(post: true),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;

  const _TextField({
    required this.label,
    required this.controller,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: hint,
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== PREMIUM DROPDOWN FIELD =====================
class _DropdownField extends StatelessWidget {
  final String label;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _DropdownField({
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 6),
        Container(
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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: DropdownButtonFormField<String>(
              value: value,
              decoration: const InputDecoration(border: InputBorder.none),
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(value: e, child: Text(e)),
                  )
                  .toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

// ===================== CARD =====================
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

// ===================== BUTTON =====================
Widget _customButton({
  required String text,
  required Size size,
  required Gradient gradient,
  required Color shadowColor,
  required VoidCallback onPressed,
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
        backgroundColor: Colors.transparent,
        shadowColor: Colors.transparent,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: size.width * 0.045,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    ),
  );
}
