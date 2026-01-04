import 'package:client/AppColors/AppColors.dart';
import 'package:flutter/material.dart';

class NotificationDetailScreen extends StatelessWidget {
  final Map<String, dynamic> notification;
  const NotificationDetailScreen({super.key, required this.notification});

  IconData _getIcon(String type) {
    switch (type) {
      case "login":
        return Icons.login;
      case "logout":
        return Icons.logout;
      case "payment":
        return Icons.payment;
      case "job_post":
        return Icons.campaign;
      case "job_apply":
        return Icons.person_add_alt;
      default:
        return Icons.notifications;
    }
  }

  Color _getColor(String type) {
    switch (type) {
      case "login":
        return Colors.green;
      case "logout":
        return Colors.red;
      case "payment":
        return AppColors.green;
      case "job_post":
        return Colors.orange;
      case "job_apply":
        return Colors.blue;
      default:
        return AppColors.darkGreen;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          "Notification Detail",
          style: TextStyle(color: AppColors.darkGreen),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon and Title
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _getColor(notification['type']).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getIcon(notification['type']),
                    color: _getColor(notification['type']),
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    notification['title'],
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.darkGreen,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Timestamp
            Text(
              notification['time'],
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),

            const SizedBox(height: 24),

            // Full Description
            Text(
              notification['description'],
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
          ],
        ),
      ),
    );
  }
}
