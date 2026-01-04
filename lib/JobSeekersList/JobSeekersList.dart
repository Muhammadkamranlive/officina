import 'package:client/AppColors/AppColors.dart';
import 'package:client/JobSeekersList/Component/candidateCard.dart';
import 'package:flutter/material.dart';

class JobSeekersList extends StatelessWidget {
  const JobSeekersList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.green),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const Text(
          'Job Seekers',
          style: TextStyle(color: AppColors.green),
        ),
        centerTitle: true,
      ),
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Hiring',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Find the best talent for your team',
                style: TextStyle(color: AppColors.textLight),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: const [
                    CandidateCard(
                      name: 'Aiden Parker',
                      role: 'Software Engineer',
                      experience: '6 years',
                      availability: '2 Weeks',
                      status: 'Shortlisted',
                      matchRate: 0.90,
                    ),
                    CandidateCard(
                      name: 'Priya Nair',
                      role: 'Cybersecurity Analyst',
                      experience: '8 years',
                      availability: '2 Weeks',
                      status: 'Shortlisted',
                      matchRate: 0.85,
                    ),
                    CandidateCard(
                      name: 'David Kim',
                      role: 'Mobile Developer',
                      experience: '4 years',
                      availability: '1 Month',
                      status: 'Interview Scheduled',
                      matchRate: 0.80,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}



