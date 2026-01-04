import 'package:cloud_firestore/cloud_firestore.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Create or get chat
  Future<String> getOrCreateChat(String myId, String otherUserId) async {
    final chatsRef = _firestore.collection('chats');

    final query =
        await chatsRef.where('users', arrayContains: myId).get();

    for (var doc in query.docs) {
      final users = List<String>.from(doc['users']);
      if (users.contains(otherUserId)) {
        return doc.id;
      }
    }

    final newChat = await chatsRef.add({
      'users': [myId, otherUserId],
      'lastMessage': '',
      'lastMessageTime': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    return newChat.id;
  }

  /// Stream messages (🔥 FIXED FIELD NAME)
  Stream<QuerySnapshot> messageStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Send message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
  }) async {
    final chatRef = _firestore.collection('chats').doc(chatId);
    final chatSnap = await chatRef.get();

    final users = List<String>.from(chatSnap['users']);
    final batch = _firestore.batch();

    // Save message
    batch.set(
      chatRef.collection('messages').doc(),
      {
        'senderId': senderId,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'seenBy': [senderId], // 🔥 important
      },
    );

    // Update chat meta
    final updates = <String, dynamic>{
      'lastMessage': text,
      'lastMessageSenderId': senderId,
      'lastMessageTime': FieldValue.serverTimestamp(),
    };

    for (final uid in users) {
      if (uid != senderId) {
        updates['unreadCount_$uid'] =
            FieldValue.increment(1);
      }
    }

    batch.update(chatRef, updates);
    await batch.commit();

    
  }
}
