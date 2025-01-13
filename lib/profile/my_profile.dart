
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_stars/flutter_rating_stars.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../services/artist_rating_services.dart';
import '../services/delete_account_method.dart';
import '../services/fetch_user_data.dart';
import '../services/sign_out_method.dart';
import '../services/user_model.dart';
import 'edit_profile.dart';
import 'follow/followers_following.dart';
import 'my_booked_events.dart';
import 'my_events_list.dart';
import 'my_favourites_list.dart';
import 'my_works_gallery.dart';


class MyProfileNew extends StatefulWidget {
  const MyProfileNew({super.key});

  @override
  State<MyProfileNew> createState() => _MyProfileNewState();
}

double value = 0;

List favorites = [
  ImgConstant.fav1,
  ImgConstant.fav2,
  ImgConstant.fav3,
  ImgConstant.fav3,
  ImgConstant.fav4,
  ImgConstant.fav2,
  ImgConstant.fav4,
  ImgConstant.fav1,
];

class _MyProfileNewState extends State<MyProfileNew> {

  bool click = true;
  bool fav = true;
  var pop = 0;


  String? _profileImageUrl;
  String _username = '';
  String _category = '';
  String _city = '';
  String _description = '';
  int _followersCount = 0;
  int _followingCount = 0;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (userDoc.exists) {
        setState(() {
          var data = userDoc.data() as Map<String, dynamic>;
          _profileImageUrl = data['profileImageUrl'];
          _username = data['username'] ?? '';
          _category = data['category'] ?? '';
          _city = data['city'] ?? '';
          _description = data['description'] ?? '';
          _followersCount = (data['followers'] as List<dynamic>?)?.length ?? 0;
          _followingCount = (data['following'] as List<dynamic>?)?.length ?? 0;
        });
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        centerTitle: true,
        title: Text(
          "MY PROFILE",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: width * 0.025),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(width * 0.025),
            child: GestureDetector(
              onTap:(){
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      backgroundColor: ClrConstant.primaryColor,
                      title: Text("Do you want to Logout your account now ? remember your password to login again ! "
                          "\n  If you are deleting the account, then you cant be restore the account or any profile information ",
                        style: TextStyle(
                          fontSize: width*0.03,
                          color: ClrConstant.whiteColor.withOpacity(0.5),
                          fontWeight: FontWeight.w700
                        ),
                      ),
                      actions: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            GestureDetector(
                                onTap:(){
                                  setState(() {
                                    showDialog(context: context,
                                      builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: ClrConstant.primaryColor,
                                        title: Text("Are you sure? you want to delete?"),
                                        actions: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {

                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: Text("cancel"),
                                          ),

                                          GestureDetector(
                                            onTap: () {
                                              setState(() {

                                              });
                                              deleteAccount();
                                              Navigator.pop(context);
                                            },
                                            child: Text("delete",
                                              style: TextStyle(
                                                color: Colors.red
                                              ),
                                            ),
                                          ),

                                        ],
                                      );
                                    },);
                                  });
                                },
                                child: Text("Delete",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w900
                                  ),
                                )
                            ),

                            GestureDetector(
                                onTap:(){
                                  setState(() {
                                    showDialog(context: context,
                                      builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: ClrConstant.primaryColor,
                                        title: Text("Are you sure? you want to delete?"),
                                        actions: [
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {

                                              });
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: Text("cancel"),
                                          ),
                                          GestureDetector(
                                            onTap: () {
                                              setState(() {

                                              });
                                              signOut();
                                              Navigator.pop(context);
                                              Navigator.pop(context);
                                            },
                                            child: Text("logout",
                                              style: TextStyle(
                                                color: Colors.red
                                              ),
                                            ),
                                          ),

                                        ],
                                      );
                                    },);
                                  });
                                },
                                child: Text("logout",
                                  style: TextStyle(
                                      color: Colors.red,
                                      fontWeight: FontWeight.w900
                                  ),
                                )
                            ),

                            GestureDetector(
                                onTap: (){
                                  setState(() {

                                  });
                                  Navigator.pop(context);
                                },
                                child: Text("Not now",
                                  style: TextStyle(
                                      color: ClrConstant.whiteColor,
                                      fontWeight: FontWeight.w900
                                  ),
                                )
                            ),
                          ],
                        ),

                      ],
                    );
                  },
                );
              },
              child: Container(
                  height: height * 0.05,
                  width: width * 0.075,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.03),
                    color: ClrConstant.whiteColor.withOpacity(0.4),
                  ),
                  child: Icon(
                    Icons.logout_outlined,
                    color: ClrConstant.blackColor,
                  )),
            ),
          ),
        ],
      ),
      body: ListView(
        children: [
          // SizedBox(),
          Stack(children: [
            Container(
              height: height * 0.35,
              decoration: BoxDecoration(
                  color: ClrConstant.primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(width * 0.5),
                    bottomLeft: Radius.circular(width * 0.00),
                  )),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Padding(
                    padding: EdgeInsets.only(left: width * 0.1, right: width * 0.1),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: width * 0.1,
                          backgroundColor: ClrConstant.whiteColor,
                          backgroundImage: _profileImageUrl != null
                              ? NetworkImage(_profileImageUrl!)
                              : AssetImage('assets/images/placeholder_user.png')
                          as ImageProvider,
                        ),
                        FutureBuilder(
                          future: fetchUserData(),
                          builder: (context, snapshot) {
                            print(snapshot.data);
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator(),);
                            } else if(snapshot.hasError){
                              return Center(child: Text("error: ${snapshot.error}"),);
                            }
                            else if(snapshot.data == null){
                              return Center(child: Text("No user data is found"),);
                            }
                            else{
                              UserModel user = snapshot.data!;
                              return Container(
                                height: height*0.125,
                                width: width*0.5,
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(user.username!,
                                      style: TextStyle(
                                        fontWeight: FontWeight.w900,

                                      ),
                                    ),
                                    Text(user.category!,
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900,
                                        color: ClrConstant.blackColor.withOpacity(0.5)
                                      ),
                                    ),
                                    SizedBox(height: height*0.003,),
                                    Container(
                                      height: height*0.05,
                                      // width: width*0.75,
                                      child: Text('''${user.description!}''',
                                      ),
                                    ),
                                  ],
                                ),
                              );
                          }
                          },
                        ),
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FollowersFollowing(),));
                          });
                        },
                        child: Container(
                          height: height * 0.075,
                          width: width * 0.225,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.03),
                              border: Border.all()),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "$_followersCount",
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text("Followers"),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => FollowersFollowing(),));
                          });
                        },
                        child: Container(
                          height: height * 0.075,
                          width: width * 0.225,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.03),
                              border: Border.all()),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text(
                                "$_followingCount",
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              Text("Following"),
                            ],
                          ),
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context, MaterialPageRoute(builder: (context) => EditProfileNew(),));
                          setState(() {

                          });
                        },
                        child: Container(
                          height: height * 0.05,
                          width: width * 0.225,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(width * 0.03),
                              border: Border.all()),
                          child: Center(
                            child: Text(
                              "Edit profile",
                              style: TextStyle(
                                fontSize: width * 0.03,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: width*0.03,)
                    ],
                  ),
                  Row(
                    children: [
                      Padding(
                        padding:  EdgeInsets.only(left: width*0.08),
                        child: RatingStars(
                          valueLabelVisibility: false,
                          value: _avgRating,
                        ),
                      ),
                    ],
                  ),
                  SizedBox()
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: height * 0.3,left: width*0.3),
              child: Container(
                height: height * 0.5,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyWorksGallery(),));
                        setState(() {

                        });
                      },
                      child: Container(
                        height: height * 0.1,
                        width: width * 0.65,
                        decoration: BoxDecoration(
                            color: ClrConstant.whiteColor,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(width * 0.03),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 4),
                                  spreadRadius: width * 0.0001,
                                  blurRadius: width * 0.003,
                                  color: ClrConstant.primaryColor.withOpacity(0.8))
                            ]),
                        child: Center(
                          child: Text("Gallery",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: width*0.035,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyEventsList(),));
                        setState(() {

                        });
                      },
                      child: Container(
                        height: height * 0.1,
                        width: width * 0.65,
                        decoration: BoxDecoration(
                            color: ClrConstant.whiteColor,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(width * 0.03),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 4),
                                  spreadRadius: width * 0.0001,
                                  blurRadius: width * 0.003,
                                  color: ClrConstant.primaryColor.withOpacity(0.8))
                            ]),
                        child: Center(
                          child: Text("Events",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: width*0.035,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MyFavouritesList(),));
                        setState(() {

                        });
                      },
                      child: Container(
                        height: height * 0.1,
                        width: width * 0.65,
                        decoration: BoxDecoration(
                            color: ClrConstant.whiteColor,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(width * 0.03),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 4),
                                  spreadRadius: width * 0.0001,
                                  blurRadius: width * 0.003,
                                  color: ClrConstant.primaryColor.withOpacity(0.8))
                            ]),
                        child: Center(
                          child: Text("Favourites",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: width*0.035,
                            ),
                          ),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => BookedEvents(),));
                        setState(() {

                        });
                      },
                      child: Container(
                        height: height * 0.1,
                        width: width * 0.65,
                        decoration: BoxDecoration(
                            color: ClrConstant.whiteColor,
                            // border: Border.all(),
                            borderRadius: BorderRadius.circular(width * 0.03),
                            boxShadow: [
                              BoxShadow(
                                  offset: Offset(0, 4),
                                  spreadRadius: width * 0.0001,
                                  blurRadius: width * 0.003,
                                  color: ClrConstant.primaryColor.withOpacity(0.8))
                            ]),
                        child: Center(
                          child: Text("Booked Events",
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: width*0.035,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          ]),
        ]
      ),
    );
  }
}
