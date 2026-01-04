import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Recruiter/Chat/ChatScreen.dart';
import 'package:client/Server/Services/ChatListService.dart';
import 'package:client/Server/Model/AppUser.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  final ChatListService _chatListService = ChatListService();

  // Cache user info to avoid multiple network calls
  final Map<String, Map<String, dynamic>> _userCache = {};

  Future<Map<String, dynamic>> _getUser(String userId) async {
    if (_userCache.containsKey(userId)) return _userCache[userId]!;

    final data = await _chatListService.getUser(userId);
    if (data != null) _userCache[userId] = data;
    return data ?? {'email': 'User'};
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        final user = auth.user;
        if (user == null) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: AppColors.background,
            elevation: 0,
            title: const Text(
              "Chats",
              style: TextStyle(
                color: AppColors.darkGreen,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          body: Column(
            children: [
              // 🔍 Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const TextField(
                    decoration: InputDecoration(
                      hintText: "Search chats",
                      border: InputBorder.none,
                      icon: Icon(Icons.search),
                    ),
                  ),
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: _chatListService.chatListStream(user.userId),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(
                        child: Text(
                          "No chats yet",
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      );
                    }

                    final chats = snapshot.data!.docs;

                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 19,
                        vertical: 10,
                      ),
                      itemCount: chats.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final chat =
                            chats[index].data() as Map<String, dynamic>;
                        final otherUserId = (chat['users'] as List).firstWhere(
                          (id) => id != user.userId,
                        );

                        return FutureBuilder<Map<String, dynamic>>(
                          future: _getUser(otherUserId),
                          builder: (context, userSnapshot) {
                            if (!userSnapshot.hasData) return const SizedBox();

                            final otherUser = userSnapshot.data!;
                            final lastMessage = chat['lastMessage'] ?? '';
                            final time = chat['lastMessageTime'] as Timestamp?;

                            final unreadCount =
                                chat['unreadCount_${user.userId}'] ?? 0;

                            final lastSenderId = chat['lastMessageSenderId'];
                            final isMe = lastSenderId == user.userId;

                            final displayMessage = isMe
                                ? 'You: $lastMessage'
                                : lastMessage;

                            String formattedTime = '';
                            if (time != null) {
                              final dateTime = time.toDate();
                              final now = DateTime.now();
                              final difference = now.difference(dateTime);
                              if (difference.inMinutes < 60) {
                                formattedTime =
                                    '${difference.inMinutes} min ago';
                              } else if (difference.inHours < 24) {
                                formattedTime = '${difference.inHours} hr ago';
                              } else {
                                formattedTime =
                                    '${dateTime.day}/${dateTime.month}/${dateTime.year}';
                              }
                            }

                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ChatScreen(
                                      personName: otherUser['email'] ?? 'User',
                                      otherUserId: otherUserId,
                                      chatId: chats[index].id,
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(16),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.05),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    const CircleAvatar(
                                      radius: 26,
                                      backgroundImage: AssetImage(
                                        'assets/avatar.png',
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    /// 🧾 Name + Message
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            otherUser['email'] ?? 'User',
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: AppColors.darkGreen,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            displayMessage,
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: unreadCount > 0
                                                  ? Colors.black
                                                  : Colors.grey,
                                              fontWeight: unreadCount > 0
                                                  ? FontWeight.w500
                                                  : FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),

                                    /// ⏱ Time + Badge
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          formattedTime,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        if (unreadCount > 0)
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: AppColors.green,
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Text(
                                              unreadCount.toString(),
                                              style: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
