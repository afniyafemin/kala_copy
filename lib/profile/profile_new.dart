import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../services/message/chat_page.dart';
import '../services/user_model.dart';
import 'Favourites_list.dart';
import 'events_list.dart';
import 'works_gallery.dart';


class Profile extends StatefulWidget {
  final UserModel user;


  const Profile({super.key, required this.user});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollow = false;
  double _userRating = 0.0;
  double _avgRating = 0.0;

  @override
  void initState() {
    super.initState();
    checkIfFollowing();
    _getArtistRating();
    _getUserRating();
  }

  Future<void> checkIfFollowing() async {
    final currentUser  = FirebaseAuth.instance.currentUser ;
    if (currentUser  != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      if (userDoc.exists) {
        final followers = List<String>.from(userDoc.data()?['followers'] ?? []);
        setState(() {
          isFollow = followers.contains(currentUser .uid);
        });
      }
    }
  }

  Future<void> toggleFollow() async {
    final currentUser  = FirebaseAuth.instance.currentUser ;
    if (currentUser  != null) {
      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.user.uid);
      final currentUserRef = FirebaseFirestore.instance.collection('users').doc(currentUser .uid);

      try {
        if (isFollow) {
          await userRef.update({
            'followers': FieldValue.arrayRemove([currentUser .uid]),
          });
          await currentUserRef.update({
            'following': FieldValue.arrayRemove([widget.user.uid]),
          });
        } else {
          await userRef.update({
            'followers': FieldValue.arrayUnion([currentUser.uid]),
          });
          await currentUserRef.update({
            'following': FieldValue.arrayUnion([widget.user.uid]),
          });
        }

        setState(() {
          isFollow = !isFollow;
        });
      } catch (e) {
        print("Error updating follow status: $e");
      }
    }
  }

  Future<void> _getArtistRating() async {
    try {
      final artistDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      List<dynamic> ratings = artistDoc.get('ratings') ?? [];
      if (ratings.isNotEmpty) {
        double totalRating = 0;
        for (var rating in ratings) {
          totalRating += rating['rating'];
        }
        setState(() {
          _avgRating = totalRating / ratings.length;
        });
      }
    } catch (e) {
      print('Error fetching artist rating: $e');
    }
  }

  Future<void> _getUserRating() async {
    final currentUser  = FirebaseAuth.instance.currentUser ;
    if (currentUser  != null) {
      final artistDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      List<dynamic> ratings = artistDoc.get('ratings') ?? [];
      for (var rating in ratings) {
        if (rating['userId'] == currentUser .uid) {
          setState(() {
            _userRating = rating['rating'];
          });
          break;
        }
      }
    }
  }

  Future<void> _submitRating() async {
    final currentUser  = FirebaseAuth.instance.currentUser ;
    if (currentUser  == null || _userRating <= 0) {
      return;
    }

    try {
      final userRef = FirebaseFirestore.instance.collection('users').doc(widget.user.uid);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final documentSnapshot = await transaction.get(userRef);
        final existingRatings = List<dynamic>.from(documentSnapshot.data()?['ratings'] ?? []);

        int index = existingRatings.indexWhere((rating) => rating['userId'] == currentUser .uid);

        if (index != -1) {
          existingRatings[index]['rating'] = _userRating;
        } else {
          existingRatings.add({
            'userId': currentUser .uid,
            'rating': _userRating,
          });
        }

        transaction.update(userRef, {'ratings': existingRatings});
      });

      await _updateAvgRating(); // Update the average rating after submitting a new rating
      _getArtistRating();
      setState(() {});
    } catch (e) {
      print('Error submitting rating: $e');
    }
  }

  Future<void> _updateAvgRating() async {
    try {
      final artistDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.user.uid)
          .get();

      List<dynamic> ratings = artistDoc.get('ratings') ?? [];
      if (ratings.isNotEmpty) {
        double totalRating = 0;
        for (var rating in ratings) {
          totalRating += rating['rating'];
        }
        double avgRating = totalRating / ratings.length;

        // Convert the average rating to an integer
        int avgRatingInt = avgRating.toInt();

        await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
          'avgRating': avgRatingInt, // Store the integer value
        });
      } else {
        await FirebaseFirestore.instance.collection('users').doc(widget.user.uid).update({
          'avgRating': 0, // Set to 0 if no ratings exist
        });
      }
    } catch (e) {
      print('Error updating average rating: $e');
    }
  }
  Future<List<Map<String, dynamic>>> fetchUpcomingEvents() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: widget.user.uid)
          .get();

      List<Map<String, dynamic>> events = [];
      for (var doc in querySnapshot.docs) {
        var event = doc.data() as Map<String, dynamic>;
        String dateString = event['date'];

        // Convert date string to DateTime
        DateTime eventDate = DateTime.parse(dateString);

        // Only add the event if the event date is in the future
        if (eventDate.isAfter(DateTime.now())) {
          events.add(event);
        }
      }

      // Sort events by date (ascending order)
      events.sort((a, b) {
        DateTime dateA = DateTime.parse(a['date']);
        DateTime dateB = DateTime.parse(b['date']);
        return dateA.compareTo(dateB);
      });

      return events;
    } catch (e) {
      print('Error fetching upcoming events: $e');
      return [];
    }
  }


  void _showReportDialog() {
    final TextEditingController reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: ClrConstant.whiteColor,
          title: Text(
            "Report User",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
          ),
          content: Padding(
            padding: EdgeInsets.symmetric(vertical: 12.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: reasonController,
                  decoration: InputDecoration(
                    labelText: "Reason for reporting",
                    hintText: "Please specify the reason",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                  ),
                  maxLines: 4,
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () async {
                String reason = reasonController.text.trim();
                if (reason.isNotEmpty) {
                  await _submitReport(reason);
                  Navigator.of(context).pop(); // Close the dialog
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Please provide a reason.")),
                  );
                }
              },
              child: Text("Report",style: TextStyle(
                color: ClrConstant.blackColor
              ),),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitReport(String reason) async {
    final currentUser   = FirebaseAuth.instance.currentUser  ;
    if (currentUser   != null) {
      try {
        await FirebaseFirestore.instance.collection('reports').add({
          'reportedUser  Id': widget.user.uid,
          'reporterUser  Id': currentUser .uid,
          'reason': reason,
          'timestamp': FieldValue.serverTimestamp(),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Report submitted successfully.")),
        );
      } catch (e) {
        print('Error submitting report: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error submitting report.")),
        );
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
          "PROFILE",
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: width * 0.025),
        ),
        actions: [
          Padding(
            padding: EdgeInsets.all(width * 0.025),
            child: GestureDetector(
              onTap: () {
                showMenu(
                  color: ClrConstant.primaryColor,
                  context: context,
                  position: RelativeRect.fromLTRB(width * 0.9, 0, 0, height * 0.95),
                  items: [
                    PopupMenuItem(
                      child: GestureDetector(
                        onTap: () {
                          _showReportDialog();
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            children: [
                              Icon(Icons.report),
                              SizedBox(width: width*0.02,),
                              Text(
                                "Report",
                                style: TextStyle(fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              },
              child: Container(
                height: height * 0.05,
                width: width * 0.1,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.03),
                  color: ClrConstant.whiteColor.withOpacity(0.4),
                ),
                child: Icon(
                  Icons.more_vert,
                  color: ClrConstant.blackColor,
                ),
              ),
            ),
          )

        ],
      ),
      body: ListView(
        children: [
          Column(
            children: [
              Stack(children: [
                Container(
                  height: height * 0.3,
                  decoration: BoxDecoration(
                    color: ClrConstant.primaryColor,
                    borderRadius: BorderRadius.only(
                      bottomRight: Radius.circular(width * 0.475),
                      bottomLeft: Radius.circular(width * 0.00),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        height: height * 0.225,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(left: 15.0),
                              child: CircleAvatar(
                                radius: width * 0.1,
                                backgroundImage: NetworkImage(widget.user.profileImageUrl ?? ImgConstant.fav1),
                              ),
                            ),
                            SizedBox(height: height * 0.02),
                            RatingBar.builder(
                              initialRating: _avgRating,
                              minRating: 0,
                              direction: Axis.horizontal,
                              allowHalfRating: true,
                              itemCount: 5,
                              itemSize: width * 0.06,
                              itemBuilder: (context, _) => Icon(
                                Icons.star,
                                color: Colors.amber,
                              ),
                              onRatingUpdate: (rating) {
                                setState(() {
                                  _userRating = rating;
                                });
                              },
                            ),
                            GestureDetector(
                              onTap: _submitRating,
                              child: Container(
                                height: height * 0.02,
                                width: width * 0.1,
                                decoration: BoxDecoration(
                                  color: ClrConstant.whiteColor,
                                  borderRadius: BorderRadius.circular(width * 0.015),
                                ),
                                child: Center(
                                  child: Text(
                                    "Submit",
                                    style: TextStyle(
                                      color: ClrConstant.primaryColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: width * 0.015,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: height * 0.2,
                        width: width * 0.5,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.user.username ?? 'Unknown User',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              height: height*0.05,
                              // width: width*0.75,
                              child: Text('''${widget.user.description!}''',
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: width*0.0275
                                ),
                              ),
                            ),
                            Padding(
                              padding:  EdgeInsets.all(height*0.02),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  GestureDetector(
                                    onTap: toggleFollow,
                                    child: Container(
                                      height: height * 0.05,
                                      width: width * 0.3,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(width * 0.03),
                                        border: Border.all(),
                                      ),
                                      child: Center(
                                        child: Text(
                                          isFollow ? "Following" : "Follow",
                                          style: TextStyle(
                                            fontSize: width * 0.03,
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatPage(otherUserId: widget.user.uid, otherUsername:  widget.user.username ?? 'Unknown User')));
                                    },
                                      child: Icon(Icons.message))
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox()
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.only(top: height * 0.2, left: width * 0.3),
                  child: Container(
                    height: height * 0.35,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => WorksGallery(userId: widget.user.uid)));
                          },
                          child: Container(
                            height: height * 0.1,
                            width: width * 0.65,
                            decoration: BoxDecoration(
                              color: ClrConstant.whiteColor,
                              borderRadius: BorderRadius.circular(width * 0.03),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 4),
                                  spreadRadius: width * 0.0001,
                                  blurRadius: width * 0.003,
                                  color: ClrConstant.primaryColor.withOpacity(0.5),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Gallery",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: width * 0.035,
                                ),
                              ),
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => EventsGallery(userId: widget.user.uid)));
                          },
                          child: Container(
                            height: height * 0.1,
                            width: width * 0.65,
                            decoration: BoxDecoration(
                              color: ClrConstant.whiteColor,
                              borderRadius: BorderRadius.circular(width * 0.03),
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 4),
                                  spreadRadius: width * 0.0001,
                                  blurRadius: width * 0.003,
                                  color: ClrConstant.primaryColor.withOpacity(0.5),
                                )
                              ],
                            ),
                            child: Center(
                              child: Text(
                                "Events",
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: width * 0.035,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]),
              Text(
                "Upcoming Events",
                style: TextStyle(
                  color: ClrConstant.blackColor.withOpacity(0.4),
                  fontWeight: FontWeight.w700,
                ),
              ),
              SizedBox(
                height: height*0.025,
              ),
              Center(
                child: FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchUpcomingEvents(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return CircularProgressIndicator();
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No upcoming events now", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)));
                    }

                    final events = snapshot.data!;

                    return Container(
                      height: height * 0.2,
                      width: width * 1,
                      child: CarouselSlider.builder(
                        itemBuilder: (BuildContext context, int index, int realIndex) {
                          final event = events[index];
                          return Container(
                            height: height * 0.2,
                            width: width * 0.9,
                            decoration: BoxDecoration(
                              color: ClrConstant.primaryColor,
                              borderRadius: BorderRadius.circular(width * 0.1),
                              image: DecorationImage(
                                image: NetworkImage(event['imageUrl'] ?? ImgConstant.event1), // Use the imageUrl from the event
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                event['title'], // Displaying the event title
                                style: TextStyle(
                                  color: ClrConstant.whiteColor,
                                  shadows: [
                                    Shadow(
                                      color: ClrConstant.blackColor,
                                      offset: Offset(0, 3),
                                      blurRadius: 2
                                    )
                                  ],
                                  fontWeight: FontWeight.bold,
                                  fontSize: width * 0.05,
                                ),
                              ),
                            ),
                          );
                        },
                        options: CarouselOptions(
                          autoPlay: true,
                          viewportFraction: 1,
                        ),
                        itemCount: events.length,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}