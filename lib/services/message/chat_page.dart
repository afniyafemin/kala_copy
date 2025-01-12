import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';


class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUsername;

  const ChatPage({
    Key? key,
    required this.otherUserId,
    required this.otherUsername,
  }) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String currentUserId;
  String? chatId;

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
      _initializeChat();
    } else {
      // Handle user not logged in
      Navigator.of(context).pop();
    }
  }

  Future<void> _initializeChat() async {
    final chatQuery = await _firestore
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessage.timestamp', descending: true)
        .get();

    final existingChat = chatQuery.docs.firstWhereOrNull((doc) {
      final participants = List<String>.from(doc['participants']);
      return participants.contains(widget.otherUserId);
    });

    if (existingChat != null) {
      setState(() {
        chatId = existingChat.id;
      });
    } else {
      final newChat = await _firestore.collection('chats').add({
        'participants': [currentUserId, widget.otherUserId],
        'lastMessage': {
          'senderId': '',
          'content': '',
          'timestamp': FieldValue.serverTimestamp(),
        },
      });
      setState(() {
        chatId = newChat.id;
      });
    }
    _listenForNewMessages();
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isNotEmpty && chatId != null) {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final content = _messageController.text.trim();

      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': {
          'senderId': currentUserId,
          'content': content,
          'timestamp': timestamp,
        },
      });

      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'senderId': currentUserId,
        'content': content,
        'timestamp': timestamp,
        'read': false,
      });

      _messageController.clear();
    }
  }

  void _listenForNewMessages() {
    if (chatId != null) {
      _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('senderId', isEqualTo: widget.otherUserId)
          .where('read', isEqualTo: false)
          .snapshots()
          .listen((snapshot) {
        for (final doc in snapshot.docs) {
          doc.reference.update({'read': true});
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: Text(
          widget.otherUsername,
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatId == null
                ? Center(child: Text('Initializing chat...'))
                : StreamBuilder<QuerySnapshot>(
                    stream: _firestore
                        .collection('chats')
                        .doc(chatId)
                        .collection('messages')
                        .orderBy('timestamp')
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      final messages = snapshot.data!.docs;

                      return messages.isEmpty
                          ? Center(child: Text('Start the conversation!'))
                          : ListView.builder(
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final message = messages[index].data()
                                    as Map<String, dynamic>;
                                final isMe =
                                    message['senderId'] == currentUserId;

                                return Align(
                                  alignment: isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                                  child: Container(
                                    margin: EdgeInsets.symmetric(
                                        vertical: 5, horizontal: 10),
                                    padding: EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: isMe
                                          ? ClrConstant.primaryColor
                                          : ClrConstant.primaryColor
                                              .withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      message['content'],
                                      style: TextStyle(
                                        color:
                                            isMe ? Colors.white : Colors.black,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: ClrConstant.primaryColor.withOpacity(0.2),
                    ),
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: ClrConstant.primaryColor,
                  ),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
