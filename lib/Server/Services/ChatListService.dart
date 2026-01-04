import 'package:cloud_firestore/cloud_firestore.dart';

class ChatListService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Chats where current user is involved
  Stream<QuerySnapshot> chatListStream(String myUserId) {
     
    return _firestore
        .collection('chats')
        .where('users', arrayContains: myUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots();
  }

  /// Fetch user info
  Future<Map<String, dynamic>?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    return doc.data();
  }
}
