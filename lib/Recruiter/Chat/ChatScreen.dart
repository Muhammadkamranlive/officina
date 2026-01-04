import 'package:client/AppColors/AppColors.dart';
import 'package:client/Guard/AuthProvider/AuthProvider.dart';
import 'package:client/Server/Services/ChatService.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String personName;
  final String otherUserId;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.personName,
    required this.otherUserId,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _controller = TextEditingController();

  String? chatId;

  @override
  void initState() {
    super.initState();
    _initChat();
  }

  Future<void> _initChat() async {
    final user = context.read<AuthProvider>().user;
    if (user == null) return;

    final id = widget.chatId.isNotEmpty
        ? widget.chatId
        : await _chatService.getOrCreateChat(user.userId, widget.otherUserId);

    setState(() {
      chatId = id; // 🔥 IMPORTANT
    });

    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: user.userId)
        .get()
        .then((snapshot) {
          for (var doc in snapshot.docs) {
            doc.reference.update({
              'seenBy': FieldValue.arrayUnion([user.userId]),
            });
          }
        });

    await FirebaseFirestore.instance.collection('chats').doc(id).update({
      'unreadCount_${user.userId}': 0,
    });
  }

  void _sendMessage() {
    final user = context.read<AuthProvider>().user;
    if (user == null || chatId == null) return;

    final text = _controller.text.trim();
    if (text.isEmpty) return;

    _chatService.sendMessage(
      chatId: chatId!,
      senderId: user.userId,
      text: text,
    );

    FirebaseFirestore.instance.collection('chats').doc(chatId).update({
      'typing_${user.userId}': false,
    });

    _controller.clear();
  }

  String _formatTime(Timestamp? time) {
    if (time == null) return '';
    final date = time.toDate();
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: Row(
          children: [
            const CircleAvatar(
              radius: 20,
              backgroundImage: AssetImage('assets/avatar.png'),
            ),
            const SizedBox(width: 12),
            Text(
              widget.personName,
              style: const TextStyle(color: AppColors.darkGreen),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            /// 💬 Messages
            Expanded(
              child: chatId!.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : StreamBuilder<QuerySnapshot>(
                      stream: _chatService.messageStream(chatId!),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final messages = snapshot.data!.docs;

                        if (messages.isEmpty) {
                          return const Center(child: Text("No messages yet"));
                        }
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (!snapshot.hasData) return const SizedBox();

                            final data =
                                snapshot.data!.data() as Map<String, dynamic>;
                            final user = context.read<AuthProvider>().user;

                            final isTyping =
                                data['typing_${widget.otherUserId}'] == true;

                            if (!isTyping) return const SizedBox();

                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 6),
                              child: Text(
                                'Typing...',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontStyle: FontStyle.italic,
                                  color: Colors.grey,
                                ),
                              ),
                            );
                          },
                        );

                        return ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount: messages.length,
                          itemBuilder: (context, index) {
                            final data =
                                messages[index].data() as Map<String, dynamic>;
                            final isMe = data['senderId'] == user?.userId;

                            return Align(
                              alignment: isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(vertical: 6),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                constraints: BoxConstraints(
                                  maxWidth:
                                      MediaQuery.of(context).size.width * 0.7,
                                ),
                                decoration: BoxDecoration(
                                  gradient: isMe
                                      ? AppColors.gradientdarkgreen
                                      : LinearGradient(
                                          colors: [
                                            Colors.grey.shade200,
                                            Colors.grey.shade300,
                                          ],
                                        ),
                                  borderRadius: BorderRadius.only(
                                    topLeft: const Radius.circular(20),
                                    topRight: const Radius.circular(20),
                                    bottomLeft: isMe
                                        ? const Radius.circular(20)
                                        : Radius.zero,
                                    bottomRight: isMe
                                        ? Radius.zero
                                        : const Radius.circular(20),
                                  ),
                                ),
                                child: Stack(
                                  children: [
                                    /// Message Text
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 18, // space for time + ticks
                                      ),
                                      child: Text(
                                        data['text'] ?? '',
                                        style: TextStyle(
                                          color: isMe
                                              ? Colors.white
                                              : Colors.black87,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),

                                    /// Time + Ticks (Bottom Right)
                                    Positioned(
                                      bottom: 0,
                                      right: 0,
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            _formatTime(data['createdAt']),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: isMe
                                                  ? Colors.white70
                                                  : Colors.black54,
                                            ),
                                          ),
                                          if (isMe) ...[
                                            const SizedBox(width: 4),
                                            Icon(
                                              Icons.check,
                                              size: 14,
                                              color:
                                                  (data['seenBy']?.length ??
                                                          1) >
                                                      1
                                                  ? Colors.blue
                                                  : Colors.white70,
                                            ),
                                            if ((data['seenBy']?.length ?? 1) >
                                                1)
                                              Icon(
                                                Icons.check,
                                                size: 14,
                                                color: Colors.blue,
                                              ),
                                          ],
                                        ],
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
            ),

            /// ✍️ Input
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: "Type a message...",
                          border: InputBorder.none,
                        ),
                        onChanged: (value) {
                          final user = context.read<AuthProvider>().user;
                          if (user == null || chatId == null) return;

                          FirebaseFirestore.instance
                              .collection('chats')
                              .doc(chatId)
                              .update({
                                'typing_${user.userId}': value.isNotEmpty,
                              });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  GestureDetector(
                    onTap: _sendMessage,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: const BoxDecoration(
                        color: AppColors.green,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.send, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
