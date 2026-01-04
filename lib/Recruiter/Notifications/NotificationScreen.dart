import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Model/NotificationModel.dart';
import 'package:client/Server/Repo/Notifications/NotificationsRepository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'NotificationDetailScreen.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationRepository _repo = NotificationRepository();
  List<NotificationModel> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNotifications();
  }

  Future<void> _fetchNotifications() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final data = await _repo.getByUserId(user.userId);
    setState(() {
      _notifications = data;
      _isLoading = false;
    });
  }

  /// 🔥 Mark notification as read (Firestore + UI)
  Future<void> _markAsRead(int index) async {
    final notification = _notifications[index];

    if (notification.isRead || notification.docId == null) return;

    // Update local UI instantly
    setState(() {
      _notifications[index] = notification.copyWith(isRead: true);
    });

    // Update Firestore
    await _repo.update(
      notification.docId!,
      notification.copyWith(isRead: true),
    );
  }

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
          "Notifications",
          style: TextStyle(
            color: AppColors.darkGreen,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No notifications",
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _notifications.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final notification = _notifications[index];
                    final timeText = _formatTime(notification.createdAt);

                    return GestureDetector(
                      onTap: () async {
                        await _markAsRead(index);

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NotificationDetailScreen(
                              notification: {
                                "type": notification.type,
                                "title": notification.title,
                                "description": notification.description,
                                "time": timeText,
                              },
                            ),
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: notification.isRead
                              ? Colors.white
                              : AppColors.green.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.03),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Icon
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: _getColor(notification.type)
                                    .withOpacity(0.15),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                _getIcon(notification.type),
                                color: _getColor(notification.type),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 14),

                            // Content
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    notification.title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: AppColors.darkGreen,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    notification.description,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Time + unread dot
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  timeText,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[500],
                                  ),
                                ),
                                const SizedBox(height: 6),
                                if (!notification.isRead)
                                  Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      color: AppColors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 60) return "${diff.inMinutes} min ago";
    if (diff.inHours < 24) return "${diff.inHours} hrs ago";
    if (diff.inDays < 7) return "${diff.inDays} days ago";

    return "${dateTime.day}/${dateTime.month}/${dateTime.year}";
  }
}
