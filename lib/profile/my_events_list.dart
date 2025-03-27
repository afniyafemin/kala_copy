import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kala_copy/profile/invite_artist.dart';

import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../screens/slot_booking.dart';

class MyEventsList extends StatefulWidget {
  const MyEventsList({super.key});

  @override
  State<MyEventsList> createState() => _MyEventsListState();
}

class _MyEventsListState extends State<MyEventsList> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Map<String, dynamic>>> fetchMyEvents() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('events')
        .where('userId', isEqualTo: userId) // Filter by userId
        .get();

    return snapshot.docs.map((doc) {
      Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  Future<void> deleteEvent(String eventId) async {
    try {
      await FirebaseFirestore.instance.collection('events').doc(eventId).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event deleted successfully')),
      );
      setState(() {}); // Refresh the UI
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error deleting event')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ClrConstant.primaryColor,
        title: Text(
          "My Events",
          style: TextStyle(fontSize: width * 0.05, fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          Container(
            height: height * 0.9,
            child: FutureBuilder<List<Map<String, dynamic>>>(
              future: fetchMyEvents(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final events = snapshot.data ?? [];

                if (events.isEmpty) {
                  return Center(child: Text('No events found.'));
                }

                return ListView.builder(
                  itemCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];

                    return Padding(
                      padding: EdgeInsets.only(
                        top: width * 0.03,
                        right: width * 0.03,
                        left: width * 0.03,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InviteArtist(
                                  eventId: event['id'],
                                  title: event['title'],
                                  location: event['location'],
                                  date: event['date'],
                                  description: event['description'],
                                  imgUrl: event['imageUrl'],

                                ),
                              ));
                        },
                        child: Container(
                          height: height * 0.17,
                          width: width * 0.85,
                          decoration: BoxDecoration(
                            color: ClrConstant.primaryColor.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(width * 0.05),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    height: height * 0.18,
                                    width: width * 0.25,
                                    decoration: BoxDecoration(
                                      image: DecorationImage(
                                        image: NetworkImage(event["imageUrl"]),
                                        fit: BoxFit.cover,
                                      ),
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(width * 0.05),
                                        bottomLeft: Radius.circular(width * 0.05),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(width * 0.025),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          mainAxisAlignment: MainAxisAlignment.start,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              event["title"],
                                              style: TextStyle(
                                                fontSize: width * 0.04,
                                                color: ClrConstant.blackColor,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.005),
                                            Text(
                                              event["description"],
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: ClrConstant.blackColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.005),
                                            Text(
                                              event["location"],
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: ClrConstant.blackColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            SizedBox(height: height * 0.005),
                                            Text(
                                              event["date"].toString(),
                                              style: TextStyle(
                                                fontSize: width * 0.035,
                                                color: ClrConstant.blackColor,
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  // GestureDetector(
                                  //   onTap : (){
                                  //
                                  //   },
                                  //   child: Padding(
                                  //     padding: EdgeInsets.all(width * 0.03),
                                  //     child: Container(
                                  //       height: height*0.03,
                                  //         width: width*0.125,
                                  //         decoration: BoxDecoration(
                                  //           borderRadius: BorderRadius.circular(width*0.05),
                                  //           color: ClrConstant.primaryColor,
                                  //         ),
                                  //
                                  //         child: Center(child: Text("add",
                                  //           style: TextStyle(
                                  //               color: ClrConstant.whiteColor,
                                  //               fontWeight: FontWeight.w600,
                                  //             fontSize: width*0.03
                                  //           ),
                                  //         )
                                  //         )
                                  //     ),
                                  //   ),
                                  // ),
                                  // SizedBox(width: width*0.01,),
                                  GestureDetector(
                                    onTap: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            backgroundColor: ClrConstant.primaryColor,
                                            title: Text(
                                              "Are you sure you want to delete this event?",
                                              style: TextStyle(
                                                color: ClrConstant.blackColor,
                                                fontSize: width * 0.035,
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                            actions: [
                                              GestureDetector(
                                                onTap: () {
                                                  deleteEvent(event['id']);
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.all(width * 0.03),
                                                  child: Text(
                                                    "Delete",
                                                    style: TextStyle(
                                                      color: ClrConstant.blackColor,
                                                      fontSize: width * 0.035,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(context);
                                                },
                                                child: Padding(
                                                  padding: EdgeInsets.all(width * 0.03),
                                                  child: Text(
                                                    "Cancel",
                                                    style: TextStyle(
                                                      color: ClrConstant.blackColor,
                                                      fontSize: width * 0.035,
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      );
                                    },
                                    child: Padding(
                                      padding: EdgeInsets.all(width * 0.03),
                                      child: Icon(Icons.delete, color: Colors.redAccent),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
