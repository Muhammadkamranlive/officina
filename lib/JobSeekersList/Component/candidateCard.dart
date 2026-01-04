import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';

class CandidateCard extends StatelessWidget {
  final String name, role, experience, availability, status;
  final double matchRate;

  const CandidateCard({
    super.key,
    required this.name,
    required this.role,
    required this.experience,
    required this.availability,
    required this.status,
    required this.matchRate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 28,
                backgroundImage: AssetImage('assets/avatar.png'),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  Text(role, style: TextStyle(color: AppColors.textLight)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Experience: $experience'),
              Text('Availability: $availability'),
            ],
          ),
          const SizedBox(height: 10),
          Text('Status: $status', style: TextStyle(color: AppColors.textLight)),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: matchRate,
              backgroundColor: Colors.grey.shade200,
              color: AppColors.green,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
