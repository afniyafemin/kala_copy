import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Creates or fetches a chat between participants.
  Future<String> createOrFetchChat(String currentUserId, String otherUserId) async {
    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .get();

    // Check if a chat already exists between the users

    final existingChat = chatQuery.docs.firstWhereOrNull((doc) {
      final participants = List<String>.from(doc['participants']);
      return participants.contains(otherUserId);
    });


    if (existingChat != null) {
      return existingChat.id; // Return the existing chat ID
    }

    // If no chat exists, create a new one
    final newChat = await _firestore.collection('chats').add({
      'participants': [currentUserId, otherUserId],
      'lastMessage': {
        'senderId': '',
        'content': '',
        'timestamp': FieldValue.serverTimestamp(),
      },
    });

    return newChat.id;
  }

  /// Sends a message in the specified chat.
  Future<void> sendMessage(String chatId, String senderId, String content) async {
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Update the last message and add the message to the messages collection
    await _firestore.collection('chats').doc(chatId).update({
      'lastMessage': {
        'senderId': senderId,
        'content': content,
        'timestamp': timestamp,
      },
    });

    await _firestore.collection('chats').doc(chatId).collection('messages').add({
      'senderId': senderId,
      'content': content,
      'timestamp': timestamp,
      'read': false,
    });
  }

  /// Marks all messages in a chat as read for the current user.
  Future<void> markMessagesAsRead(String chatId, String currentUserId) async {
    final unreadMessages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .where('senderId', isNotEqualTo: currentUserId)
        .where('read', isEqualTo: false)
        .get();

    for (final message in unreadMessages.docs) {
      await message.reference.update({'read': true});
    }
  }

  /// Returns a stream of chat document snapshots for a specific chat.
  Stream<DocumentSnapshot> getChatStream(String chatId) {
    return _firestore.collection('chats').doc(chatId).snapshots();
  }

  /// Returns a stream of messages in a chat, ordered by timestamp.
  Stream<QuerySnapshot> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots();
  }

  /// Fetches a list of recent chats for the current user.
  Stream<List<Map<String, dynamic>>> fetchRecentChats(String currentUserId) {
    return _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessage.timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final otherUserId = (data['participants'] as List).firstWhere(
              (id) => id != currentUserId,
        );

        return {
          'chatId': doc.id,
          'otherUserId': otherUserId,
          'lastMessage': data['lastMessage'] ?? {},
        };
      }).toList();
    });
  }
}
