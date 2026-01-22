import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Server/Model/JobOffer.dart';
import 'package:client/Server/Model/SkillVerificationRequestModel.dart';
import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:client/Server/Repo/Receuiter/SkillVerificationRequest.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:flutter/material.dart';
import 'package:client/AppColors/AppColors.dart';
import 'package:client/Server/Repo/JobSeekers/JobApplicationRepository.dart';
import 'package:client/Server/Model/JobSeekerModel/JobApplication.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:provider/provider.dart';

import 'package:client/Server/Model/JobSeekerModel/JobApplicationWithJob.dart';

class SendSkillVerificationRequestScreen extends StatefulWidget {
  const SendSkillVerificationRequestScreen({super.key});

  @override
  State<SendSkillVerificationRequestScreen> createState() =>
      _SendSkillVerificationRequestScreenState();
}

class _SendSkillVerificationRequestScreenState
    extends State<SendSkillVerificationRequestScreen> {

  final appRepo = JobApplicationRepository();
  final requestRepo = SkillVerificationRequestRepository();

  late String jobSeekerId;

  @override
  void initState() {
    super.initState();
    jobSeekerId = context.read<AuthProvider>().user!.userId;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          "Skill Verification",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: StreamBuilder<List<JobApplicationWithJob>>(
        stream: appRepo.streamApplicationsWithJobsForCandidate(jobSeekerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = (snapshot.data ?? [])
              .where((e) => e.isAccepted)
              .toList();

          if (data.isEmpty) return _EmptyState();

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: data.length,
            itemBuilder: (_, i) {
              final item = data[i];

              return FutureBuilder<bool>(
                future: requestRepo.requestExists(
                  jobSeekerId: jobSeekerId,
                  recruiterId: item.job.userId,
                  jobId: item.job.docId!,
                ),
                builder: (_, reqSnap) {
                  final alreadySent = reqSnap.data ?? false;

                  return SkillVerificationRequestCard(
                    item: item,
                    requestAlreadySent: alreadySent,

                    /// 🔹 SEND REQUEST
                    onSendRequest: () async {
                      final request = SkillVerificationRequest(
                        jobSeekerId: jobSeekerId,
                        recruiterId: item.job.userId,
                        jobId: item.job.docId!,
                        createdAt: DateTime.now(),
                      );

                      await requestRepo.submitRequest(request);

                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text("Verification request sent"),
                          ),
                        );
                        setState(() {});
                      }
                    },

                    /// 🔹 SEND REMINDER (CHAT)
                    
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class SkillVerificationRequestCard extends StatelessWidget {
  final JobApplicationWithJob item;
  final bool requestAlreadySent;
  final VoidCallback onSendRequest;


  const SkillVerificationRequestCard({
    super.key,
    required this.item,
    required this.requestAlreadySent,
    required this.onSendRequest,

  });

  JobApplicationModel get app => item.application;
  JobOffer get job => item.job;

  IconData get jobIcon {
    switch (job.jobTitle) {
      case 'Pharmacist':
        return Icons.medication_outlined;
      case 'Gerant':
        return Icons.store_outlined;
      case 'Physician':
        return Icons.health_and_safety_outlined;
      default:
        return Icons.work_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: premiumShadow,
        border: Border.all(
          color: AppColors.greenCeladon.withOpacity(0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 🔹 HEADER (Job Info)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.greenCeladon.withOpacity(0.12),
                child: Icon(jobIcon, color: AppColors.greenCeladon),
              ),
              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      job.jobTitle,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      job.jobType,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              /// STATUS CHIP
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  "Accepted",
                  style: TextStyle(
                    color: Colors.green,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          /// 🔹 PURPOSE BOX
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.greenCeladon.withOpacity(0.08),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.verified_outlined,
                    size: 18, color: AppColors.greenCeladon),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    "Request skill verification from this recruiter to strengthen your profile credibility and ranking.",
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          /// 🔹 ACTIONS
          if (!requestAlreadySent) ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: onSendRequest,
                icon: const Icon(Icons.send_rounded, size: 18),
                label: const Text(
                  "Send Skill Verification Request",
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.greenCeladon,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
              ),
            ),
          ] else ...[
            Row(
              children: [
                Expanded(
                  child: ChatWithRecruiterButton(job: job),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class RequestSkillVerificationButton extends StatefulWidget {
  final String recruiterId;
  final String jobId;

  const RequestSkillVerificationButton({
    super.key,
    required this.recruiterId,
    required this.jobId,
  });

  @override
  State<RequestSkillVerificationButton> createState() =>
      _RequestSkillVerificationButtonState();
}

class _RequestSkillVerificationButtonState
    extends State<RequestSkillVerificationButton> {
  bool _loading = false;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: _loading ? null : _submit,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.greenCeladon),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      child: _loading
          ? const SizedBox(
              height: 18,
              width: 18,
              child: CircularProgressIndicator(strokeWidth: 2),
            )
          : const Text(
              "Request Skill Verification",
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
    );
  }

  Future<void> _submit() async {
    setState(() => _loading = true);

    try {
      final auth = context.read<AuthProvider>();
      final user = auth.user!;
      final repo = SkillVerificationRequestRepository();

      final request = SkillVerificationRequest(
        jobSeekerId: user.userId,
        recruiterId: widget.recruiterId,
        jobId: widget.jobId,
        createdAt: DateTime.now(),
      );

      await repo.submitRequest(request);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Skill verification request sent"),
        ),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to send request"),
        ),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class ChatWithRecruiterButton extends StatefulWidget {
  final JobOffer job;

  const ChatWithRecruiterButton({super.key, required this.job});

  @override
  State<ChatWithRecruiterButton> createState() =>
      _ChatWithRecruiterButtonState();
}


class _ChatWithRecruiterButtonState
    extends State<ChatWithRecruiterButton> {

  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleChat,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.greenCeladon,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.chat_bubble_outline, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    "Chat with recruiter",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> _handleChat() async {
    setState(() => _isLoading = true);

    try {
      final auth = context.read<AuthProvider>();
      if (auth.user == null) return;

      final recruiterRepo = RecruiterRepository();
      final recruiter =
          await recruiterRepo.getByUid(widget.job.userId);

      final jobSeekerId = auth.user!.userId;
      final recruiterId = widget.job.userId;

      final chatService = ChatService();
      final chatId = await chatService.getOrCreateChat(
        recruiterId,
        jobSeekerId,
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            otherUserId: recruiterId,
            personName:
                '${recruiter?.pharmacistFirstName } ${recruiter?.pharmacistLastName}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Failed to open chat. Please try again."),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.work_outline, size: 64, color: Colors.grey),
          SizedBox(height: 12),
          Text(
            "No applications yet",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 6),
          Text(
            "Apply to jobs and track them here",
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
