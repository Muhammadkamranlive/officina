import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Notifications/NotificationScreen.dart';

import 'package:client/Server/Model/Recruiter.dart';

import 'package:client/Server/Repo/Receuiter/RecruiterRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AdminHeader extends StatefulWidget {
  const AdminHeader({super.key});

  @override
  State<AdminHeader> createState() => _AdminHeaderState();
}

class _AdminHeaderState extends State<AdminHeader> {
  final RecruiterRepository _jobSeekerRepo = RecruiterRepository();

  Recruiter? _jobSeeker;
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
                          "Admin",
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
    return "${_jobSeeker!.pharmacistFirstName} ${_jobSeeker!.pharmacistLastName}";
  }
}
