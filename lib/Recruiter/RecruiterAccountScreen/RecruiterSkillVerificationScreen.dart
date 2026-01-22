// ignore: file_names
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:flutter/material.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';

class RecruiterSkillVerificationScreen extends StatefulWidget {
  final String jobSeekerId;
   const RecruiterSkillVerificationScreen({
    super.key,
    required this.jobSeekerId,
  });

  @override
  State<RecruiterSkillVerificationScreen> createState() =>
      _RecruiterSkillVerificationScreenState();
}

class _RecruiterSkillVerificationScreenState
    extends State<RecruiterSkillVerificationScreen> {
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();
  late Future<List<JobSeekerModel>> _pendingJobSeekersFuture;

  @override
  void initState() {
    super.initState();
    _pendingJobSeekersFuture = _fetchPendingJobSeekers();
  }

  Future<List<JobSeekerModel>> _fetchPendingJobSeekers() async {
    final allJobSeekers = await _jobSeekerRepo.getAllBYId(widget.jobSeekerId);
    // Only job seekers with at least 1 pending skill
    return allJobSeekers.where((js) => js.pendingSkills.isNotEmpty).toList();
  }

  Future<void> _updateSkillStatus(
    JobSeekerModel jobSeeker,
    String skill,
    String status,
  ) async {
    final updatedSkills = Map<String, String>.from(jobSeeker.skills);
    updatedSkills[skill] = status;

    final updatedJobSeeker = JobSeekerModel(
      userId: jobSeeker.userId,
      firstName: jobSeeker.firstName,
      lastName: jobSeeker.lastName,
      isNameVisible: jobSeeker.isNameVisible,
      email: jobSeeker.email,
      phoneNumber: jobSeeker.phoneNumber,
      desiredPosition: jobSeeker.desiredPosition,
      skills: updatedSkills,
      educationBackground: jobSeeker.educationBackground,
      experienceDetails: jobSeeker.experienceDetails,
      createdAt: jobSeeker.createdAt,
      isActive: jobSeeker.isActive,
      docId: jobSeeker.docId,
      logoUrl: jobSeeker.logoUrl,
      province: jobSeeker.province,
      city: jobSeeker.city,
      streetAddress: jobSeeker.streetAddress,
      latitude: jobSeeker.latitude,
      longitude: jobSeeker.longitude,
    );

    await _jobSeekerRepo.update(updatedJobSeeker.docId!, updatedJobSeeker);
    setState(() {
      _pendingJobSeekersFuture = _fetchPendingJobSeekers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Verify Job Seeker Skills")),
      body: FutureBuilder<List<JobSeekerModel>>(
        future: _pendingJobSeekersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          final jobSeekers = snapshot.data ?? [];

          if (jobSeekers.isEmpty) {
            return const Center(child: Text("No pending skill verifications"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: jobSeekers.length,
            itemBuilder: (context, index) {
              final js = jobSeekers[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        js.isNameVisible
                            ? "${js.firstName} ${js.lastName}"
                            : "Anonymous",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text("Position: ${js.desiredPosition}"),
                      const SizedBox(height: 12),
                      const Text(
                        "Pending Skills:",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 6),
                      Column(
                        children: js.pendingSkills.map((skill) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    skill,
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                ),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => _updateSkillStatus(
                                        js,
                                        skill,
                                        SkillStatus.verified,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                      onPressed: () => _updateSkillStatus(
                                        js,
                                        skill,
                                        SkillStatus.rejected,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        }).toList(),
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
