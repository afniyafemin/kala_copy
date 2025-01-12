import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';
import '../../constants/image_constant.dart';
import '../../main.dart';
import '../../services/user_model.dart';
import '../profile_new.dart';

class Following extends StatefulWidget {
  const Following({super.key});

  @override
  State<Following> createState() => _FollowingState();
}

class _FollowingState extends State<Following> {
  List<UserModel> _following = [];

  @override
  void initState() {
    super.initState();
    _fetchFollowing();
  }

  Future<void> _fetchFollowing() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          List<String> followingIds =
          List<String>.from(userDoc.data()?['following'] ?? []);

          List<UserModel> followingList = [];
          for (String followingId in followingIds) {
            try {
              final followingDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .doc(followingId)
                  .get();

              if (followingDoc.exists) {
                final userData = followingDoc.data();
                if (userData != null) {
                  followingList.add(UserModel.fromMap(userData));
                } else {
                  print('Following document for $followingId is null');
                }
              } else {
                print('Following document for $followingId does not exist');
              }
            } catch (e) {
              print('Error fetching following document for $followingId: $e');
            }
          }

          setState(() {
            _following = followingList;
          });
        } else {
          print('Current user document does not exist');
        }
      } catch (e) {
        print('Error fetching user document: $e');
      }
    }
  }

  Future<void> _unfollowUser(String followingId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Update current user's following list
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'following': FieldValue.arrayRemove([followingId]),
        });

        // Update following user's followers list
        await FirebaseFirestore.instance
            .collection('users')
            .doc(followingId)
            .update({
          'followers': FieldValue.arrayRemove([currentUser.uid]),
        });

        // Remove unfollowed user from UI
        setState(() {
          _following.removeWhere((user) => user.uid == followingId);
        });
      } catch (e) {
        print('Error unfollowing user: $e');
        // Handle errors (e.g., show a snackbar to the user)
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.separated(
        itemBuilder: (context, index) {
          final followingUser = _following[index];
          return Padding(
            padding: EdgeInsets.all(8.0),
            child: ListTile(
              onTap: (){
                Navigator.push(context, MaterialPageRoute(builder: (context)=> Profile(user: followingUser)));
              },
              leading: CircleAvatar(
                radius: MediaQuery.of(context).size.width * 0.075,
                backgroundImage: AssetImage(ImgConstant.dance_category3),
              ),
              title: Text(
                followingUser.username ?? '',
                style: TextStyle(fontWeight: FontWeight.w700),
              ),
              trailing: GestureDetector(
                onTap: () {
                  setState(() {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text(
                            "Do you want to unfollow them?",
                            style: TextStyle(fontSize: MediaQuery.of(context).size.width * 0.04),
                          ),
                          actions: [
                            GestureDetector(
                              onTap: () { _unfollowUser(followingUser.uid);
                                Navigator.pop(context);
                                },
                              child: Text(
                                "Unfollow",
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  Navigator.pop(context);
                                });
                              },
                              child: Text("cancel"),
                            ),
                          ],
                        );
                      },
                    );
                  });
                },
                child: Text(
                  "Unfollow",
                  style: TextStyle(color: ClrConstant.primaryColor),
                ),
              ),
            ),
          );
        },
        separatorBuilder: (context, index) => Divider(),
        itemCount: _following.length,
      ),
    );
  }
}