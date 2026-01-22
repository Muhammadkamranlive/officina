import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/RecruiterAccountScreen/RecruiterSkillVerificationScreen.dart';
import 'package:client/Server/Model/SkillVerificationRequestWithJobSeeker.dart';

import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

class PendingSkillVerificationScreen extends StatefulWidget {
  const PendingSkillVerificationScreen({super.key});

  @override
  State<PendingSkillVerificationScreen> createState() =>
      _PendingSkillVerificationScreenState();
}

class _PendingSkillVerificationScreenState
    extends State<PendingSkillVerificationScreen> {

  @override
  void initState() {
    super.initState();

  }

  @override
  Widget build(BuildContext context) {
    final repo = SkillVerificationRequestRepository();
    final recruiterId = context.read<AuthProvider>().user!.userId;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: const Text(
          "Verify Jobseeker Skills",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: FutureBuilder<List<SkillVerificationRequestWithJobSeeker>>(
        future: repo.getRequestsWithJobSeekersForRecruiter(recruiterId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(child: Text("Failed to load requests"));
          }

          final data = snapshot.data ?? [];

          if (data.isEmpty) {
            return const Center(child: Text("No pending skill requests"));
          }

         return ListView.builder(
  padding: const EdgeInsets.all(16),
  itemCount: data.length,
  itemBuilder: (_, i) {
    final item = data[i];
    final js = item.jobSeeker;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            /// 👤 Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.greenCeladon.withOpacity(0.15),
              child: const Icon(
                Icons.person,
                color: AppColors.greenCeladon,
              ),
            ),

            const SizedBox(width: 14),

            /// 📄 Jobseeker Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    js.isNameVisible
                        ? "${js.firstName} ${js.lastName}"
                        : "Anonymous",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    js.desiredPosition,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            /// 🔘 Action Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RecruiterSkillVerificationScreen(
                      jobSeekerId: js.userId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.greenCeladon,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Text(
                "Verify Skills",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
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
    );
  }
}
