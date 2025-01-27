import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kala_copy/profile/profile_new.dart';
import '../../constants/image_constant.dart';
import '../../services/user_model.dart';

class Followers extends StatefulWidget {
  const Followers({super.key});

  @override
  State<Followers> createState() => _FollowersState();
}

class _FollowersState extends State<Followers> {
  List<UserModel> _followers = [];

  @override
  void initState() {
    super.initState();
    _fetchFollowers();
  }

  Future<void> _fetchFollowers() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .get();

        if (userDoc.exists) {
          List<String> followerIds = List<String>.from(userDoc.data()?['followers'] ?? []);

          List<UserModel> followersList = [];
          for (String followerId in followerIds) {
            final followerDoc = await FirebaseFirestore.instance
                .collection('users')
                .doc(followerId)
                .get();

            if (followerDoc.exists) {
              followersList.add(UserModel.fromMap(followerDoc.data()!));
            }
          }

          setState(() {
            _followers = followersList;
          });
        }
      } catch (e) {
        print('Error fetching followers: $e');
      }
    }
  }

  Future<void> _deleteFollower(String followerId) async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      try {
        // Update current user's followers list
        await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .update({
          'followers': FieldValue.arrayRemove([followerId]),
        });

        // Update follower's following list
        await FirebaseFirestore.instance
            .collection('users')
            .doc(followerId)
            .update({
          'following': FieldValue.arrayRemove([currentUser.uid]),
        });

        // Remove follower from UI
        setState(() {
          _followers.removeWhere((user) => user.uid == followerId);
        });
      } catch (e) {
        print('Error deleting follower: $e');
        // Handle errors (e.g., show a snackbar to the user)
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(width*0.03),
        child: ListView.separated(
          itemBuilder: (context, index) {
            final follower = _followers[index];
            return
              GestureDetector(
                onTap: () {
                  setState(() {

                  });
                  Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(user: follower),));
                },
                child: ListTile(

                  leading: CircleAvatar(
                    radius: width*0.075,
                    backgroundImage: AssetImage(ImgConstant.dance_category1),
                  ),

                  title: Text(follower.username ?? '',style: TextStyle(
                      fontWeight: FontWeight.w700
                  ),
                  ),

                  trailing: GestureDetector(
                    onTap: () {
                      setState(() {
                        showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("do you want to delete?",
                                  style: TextStyle(
                                    fontSize: width*0.04
                                  ),
                                ),
                                actions: [
                                  GestureDetector(
                                    onTap:() {
                                      _deleteFollower(follower.uid);
                                      Navigator.pop(context);
                              } ,
                              child: Text("delete",
                                        style: TextStyle(
                                          color: Colors.red
                                        ),
                                      )
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        Navigator.pop(context);
                                      });
                                    },
                                      child: Text("cancel")
                                  ),
                                ],
                              );
                            },
                        );
                      });
                    },
                      child: Icon(Icons.delete,color: Colors.red.withOpacity(0.75),)
                  ),
                ),
              );
          },
          separatorBuilder: (context, index) {
            return Divider();
          },
          itemCount: _followers.length,
        ),
      ),
    );
  }
}