import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';
import '../../constants/image_constant.dart';
import '../../main.dart';
import 'chat_page.dart';


class MessagePage extends StatefulWidget {
  const MessagePage({Key? key}) : super(key: key);

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> {
  List<Map<String, dynamic>> _users = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    _fetchCurrentUserId();
    _fetchUsers();
  }

  Future<void> _fetchCurrentUserId() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        currentUserId = user.uid; // Get the current user's ID
      });
    }
  }

  Future<void> _fetchUsers() async {
    try {
      final usersCollection = FirebaseFirestore.instance.collection('users');
      final querySnapshot = await usersCollection.get();

      setState(() {
        _users = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .where((user) => user['uid'] != currentUserId) // Filter out the current user
            .toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  Stream<List<Map<String, dynamic>>> _fetchRecentChats() async* {
    final chatQuery = FirebaseFirestore.instance
        .collection('chats')
        .where('participants', arrayContains: currentUserId)
        .orderBy('lastMessage.timestamp', descending: true)
        .snapshots();

    await for (final snapshot in chatQuery) {
      final chats = await Future.wait(snapshot.docs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final otherUserId = (data['participants'] as List).firstWhere(
              (id) => id != currentUserId,
        );

        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(otherUserId)
            .get();

        return {
          'chatId': doc.id,
          'otherUserId': otherUserId,
          'otherUsername': userDoc.data()?['username'] ?? 'Unknown User',
          'lastMessage': data['lastMessage'] ?? {},
        };
      }).toList());

      yield chats;
    }
  }

  void _startNewChat() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select a User'),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: _users.length,
              itemBuilder: (context, index) {
                final user = _users[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: AssetImage(ImgConstant.event1), // Default avatar
                  ),
                  title: Text(user['username'] ?? 'Unknown User'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          otherUserId: user['uid'],
                          otherUsername: user['username'] ?? 'Unknown User',
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: const Text('Chats'),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _fetchRecentChats(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final recentChats = snapshot.data ?? [];

          return ListView.separated(
            itemCount: recentChats.length,
            itemBuilder: (context, index) {
              final chat = recentChats[index];
              final otherUserId = chat['otherUserId'];
              final otherUsername = chat['otherUsername'] ?? 'Unknown User';

              final lastMessage = chat['lastMessage'] as Map<String, dynamic>;
              final content = lastMessage['content'] ?? '';
              final timestamp = lastMessage['timestamp'] != null
                  ? DateTime.fromMillisecondsSinceEpoch(
                lastMessage['timestamp'],
              )
                  : null;
              final isRead = lastMessage['read'] ?? false;

              final formattedTime = timestamp != null
                  ? TimeOfDay.fromDateTime(timestamp).format(context)
                  : '';

              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(ImgConstant.event1), // Default avatar
                ),
                title: Text('$otherUsername',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),),
                subtitle: Row(
                  children: [
                    Icon(
                      isRead ? Icons.done_all : Icons.done,
                      size: 16,
                      color: isRead ? Colors.blue : Colors.grey,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        content,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                trailing: Text(formattedTime),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ChatPage(
                        otherUserId: otherUserId,
                        otherUsername: otherUsername,
                      ),
                    ),
                  );
                },
              );
            },
            separatorBuilder: (context, index) {
              return Divider(
                color: ClrConstant.primaryColor,
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ClrConstant.primaryColor,
        onPressed: _startNewChat,
        child: const Icon(Icons.chat,
          color: ClrConstant.whiteColor,
        ),
      ),
    );
  }
}
