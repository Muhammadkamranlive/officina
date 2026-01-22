import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';
import 'package:client/Server/Model/JobSeekerModel/JobSeekerModel.dart';
import 'package:client/Server/Repo/JobSeekers/JobSeekerRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


class JobSeekerHeader extends StatefulWidget {
  const JobSeekerHeader({super.key});

  @override
  State<JobSeekerHeader> createState() => _JobSeekerHeaderState();
}

class _JobSeekerHeaderState extends State<JobSeekerHeader> {
  final JobSeekerRepository _jobSeekerRepo = JobSeekerRepository();

  JobSeekerModel? _jobSeeker;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadJobSeeker();
  }

  Future<void> _loadJobSeeker() async {
    final auth = context.read<AuthProvider>();
    final user = auth.user;

    if (user == null) {
      setState(() => _isLoading = false);
      return;
    }

    final result = await _jobSeekerRepo.getByUid(user.userId);

    if (mounted) {
      setState(() {
        _jobSeeker = result;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          /// Menu icon
          Builder(
            builder: (context) => GestureDetector(
              onTap: () => Scaffold.of(context).openDrawer(),
              child: const Icon(Icons.menu, color: AppColors.darkGreen),
            ),
          ),
          const SizedBox(width: 12),

          /// Profile avatar + Name + Position
          _isLoading
              ? const CircularProgressIndicator()
              : Row(
                  children: [
                    // CircleAvatar(
                    //   radius: 28,
                    //   backgroundColor: AppColors.greenCeladon,
                    //   backgroundImage: _jobSeeker?.logoUrl != null
                    //       ? NetworkImage(_jobSeeker!.logoUrl!)
                    //       : null,
                    //   child: _jobSeeker?.logoUrl == null
                    //       ? const Icon(Icons.person, size: 30)
                    //       : null,
                    // ),
                    const SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getDisplayName(),
                          style: const TextStyle(
                              fontWeight: FontWeight.w800, color: AppColors.darkGreen,fontSize: 19),
                        ),
                        Text(
                          _jobSeeker?.desiredPosition ?? "Candidate",
                          style: const TextStyle(
                              fontSize: 12, color: Colors.black),
                        ),
                      ],
                    ),
                  ],
                ),

          const Spacer(),

          /// Notification icon
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationScreen()),
              ); // Handle notification tap
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.black),
              ),
              child: const Icon(Icons.notifications),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles name visibility
  String _getDisplayName() {
    if (_jobSeeker == null) return "Candidate";
    if (!_jobSeeker!.isNameVisible) return "Anonymous Candidate";
    return "${_jobSeeker!.firstName} ${_jobSeeker!.lastName}";
  }
}



