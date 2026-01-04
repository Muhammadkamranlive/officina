import 'package:client/AppColors/AppColors.dart';
import 'package:client/AppColors/AppUI.dart';
import 'package:flutter/material.dart';

class RecruiterAddJobScreen extends StatelessWidget {
  const RecruiterAddJobScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.background,
        title: const Text(
          "Create Job Post",
          style: TextStyle(
            color: AppUI.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        iconTheme: const IconThemeData(color: AppUI.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            _SectionCard(
              title: "Job Information",
              child: _JobInfoForm(),
            ),
            SizedBox(height: 16),
            
            _ActionButtons(),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}


class _JobInfoForm extends StatelessWidget {
  const _JobInfoForm();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _input("Job Title (Position)"),
        const SizedBox(height: 12),
        _input("Pharmacy Name"),
        const SizedBox(height: 12),
        _input("Location"),
        const SizedBox(height: 12),
        _input("Job Description", maxLines: 4),
        const SizedBox(height: 12),
        Text("Job Type" , style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
        const SizedBox(height: 8),
        _JobTypeSelector(),
        const SizedBox(height: 12),
        Text("Required Skills" , style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),),
        const SizedBox(height: 8),
        _SkillSelector(),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _input(String hint, {int maxLines = 1}) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(
          colors: [Color(0xFF00C853), Color(0xFF64DD17)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(2), // border thickness
      child: Container(
        decoration: BoxDecoration(
          color:
              Colors.white, // keep inner field white for clear input visibility
          borderRadius: BorderRadius.circular(12),
        ),
        child: TextField(

          obscureText: false,
          decoration: InputDecoration(
            labelText: hint,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
          ),
          cursorColor: AppColors.green,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }
}



class _JobTypeSelector extends StatelessWidget {
  const _JobTypeSelector();

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      children: const [
        _ChoiceChip("Full Time"),
        _ChoiceChip("Part Time"),
        _ChoiceChip("Replacement"),
      ],
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  final String label;
  const _ChoiceChip(this.label);

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(label),
      backgroundColor: AppUI.primary.withOpacity(.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
class _SkillSelector extends StatelessWidget {
  const _SkillSelector();

  static const skills = [
    "Pharmacy Management",
    "Customer Service",
    "Stock Management",
    "Data Entry",
    "Medical Knowledge",
    "Sales",
    "Intern Training",
    "Labeling",
  ];

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: skills
          .map((skill) => Chip(
                label: Text(skill),
                backgroundColor: Colors.grey.shade100,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ))
          .toList(),
    );
  }
}



class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppUI.card,
        borderRadius: BorderRadius.circular(AppUI.radius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}


class _ActionButtons extends StatelessWidget {
  const _ActionButtons();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
           _customButton(text: 'Save as Draft', onPressed: (){}, size: size, gradient: AppColors.gradientBlue, shadowColor: AppColors.blue),
           _customButton(text: 'Publish Job', onPressed: (){}, size: size, gradient: AppColors.gradientgreen, shadowColor: AppColors.green),
        ]),
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
