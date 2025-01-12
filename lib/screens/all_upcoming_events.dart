import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kala_copy/screens/slot_booking.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';

class AllUpcomingEvents extends StatefulWidget {
  const AllUpcomingEvents({super.key});

  @override
  State<AllUpcomingEvents> createState() => _AllUpcomingEventsState();
}

class _AllUpcomingEventsState extends State<AllUpcomingEvents> {
  final userId = FirebaseAuth.instance.currentUser?.uid;

  Future<List<Map<String, dynamic>>> fetchAllEvents() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('events').get();
      return snapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Include document ID
        return data;
      }).toList();
    } catch (e) {
      debugPrint("Error fetching events: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.whiteColor,
        title: Text(
          "Upcoming Events",
          style: TextStyle(
            fontSize: width * 0.04,
            fontWeight: FontWeight.w700,
            color: ClrConstant.blackColor,
          ),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchAllEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: width * 0.04,
                ),
              ),
            );
          }

          final events = snapshot.data ?? [];

          if (events.isEmpty) {
            return Center(
              child: Text(
                'No events found.',
                style: TextStyle(
                  fontSize: width * 0.04,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          return ListView.builder(
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];

              return Container(
                padding: EdgeInsets.all(width * 0.03),
                margin: EdgeInsets.symmetric(
                  horizontal: width * 0.03,
                  vertical: width * 0.02,
                ),
                height: height * 0.25,
                decoration: BoxDecoration(
                  color: ClrConstant.primaryColor.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(width * 0.04),
                ),
                child: Row(
                  children: [
                    // Event Image
                    Container(
                      height: height * 0.25,
                      width: width * 0.35,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(width * 0.03),
                        image: DecorationImage(
                          image: AssetImage(ImgConstant.event1),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: width * 0.03),
                    // Event Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Text(
                            event["title"] ?? 'No Title',
                            style: TextStyle(
                              fontSize: width * 0.04,
                              color: ClrConstant.blackColor,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            event["description"] ?? 'No Description',
                            style: TextStyle(
                              fontSize: width * 0.03,
                              color: ClrConstant.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 2,
                          ),
                          Text(
                            event["location"] ?? 'No Location',
                            style: TextStyle(
                              fontSize: width * 0.03,
                              color: ClrConstant.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Text(
                            "Date: ${event["date"] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: width * 0.03,
                              color: ClrConstant.blackColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          // Book Now Button
                          GestureDetector(
                            onTap: () {
                              String? eventId = event['id'];
                              if (eventId != null) {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        SlotBooking(eventId: event['eventId'],
                                          title: event['title'],
                                          location: event['location'],
                                          date: event['date'],
                                          description: event['description'],),
                                  ),
                                );
                              }
                            },
                            child: Container(
                              height: height * 0.04,
                              width: width * 0.25,
                              decoration: BoxDecoration(
                                color: ClrConstant.primaryColor,
                                borderRadius: BorderRadius.circular(width * 0.5),
                              ),
                              child: Center(
                                child: Text(
                                  "Book Now",
                                  style: TextStyle(
                                    fontSize: width * 0.035,
                                    color: ClrConstant.whiteColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
