import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../main.dart';


class BookedEvents extends StatefulWidget {
  const BookedEvents({super.key});

  @override
  State<BookedEvents> createState() => _BookedEventsState();
}

class _BookedEventsState extends State<BookedEvents> {
  Future<List<String>> fetchEventIds() async {
    try {
      User? currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        throw Exception("No logged-in user.");
      }

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('user', isEqualTo: currentUser.uid)
          .get();

      List<String> eventIds =
          querySnapshot.docs.map((doc) => doc['eventId'] as String).toList();

      return eventIds;
    } catch (e) {
      print("Error fetching eventIds: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchEventsByIds(
      List<String> eventIds) async {
    try {
      List<Map<String, dynamic>> events = [];

      for (String eventId in eventIds) {
        DocumentSnapshot<Map<String, dynamic>> doc = await FirebaseFirestore
            .instance
            .collection('events')
            .doc(eventId)
            .get();

        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          data['documentId'] = doc.id;
          events.add(data);
        }
      }

      // Sort events: future events first in descending order, past events last
      events.sort((a, b) {
        DateTime dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime.now();
        DateTime dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime.now();

        bool isPastA = dateA.isBefore(DateTime.now());
        bool isPastB = dateB.isBefore(DateTime.now());

        if (isPastA != isPastB) {
          return isPastA ? 1 : -1; // Past events to the bottom
        } else {
          return dateB.compareTo(dateA); // Descending order within groups
        }
      });

      return events;
    } catch (e) {
      print("Error fetching events by IDs: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        iconTheme: IconThemeData(color: ClrConstant.whiteColor),
        title: Text(
          "Booked Events",
          style: TextStyle(
            color: ClrConstant.whiteColor,
            fontSize: width * 0.04,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width*0.03),
        child: Column(
            children: [
              Container(
                height: height*0.15,
                width: width*1,
                padding : EdgeInsets.only(left: width*0.125,top: height*0.0225),
                decoration: BoxDecoration(
                  color: ClrConstant.primaryColor.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(width*0.05)
                ),
                child: GridView(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      childAspectRatio: 4,
                    ),
                  children: [
                    Container(
                      width: width*0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height*0.035,
                            width: width*0.06,
                            decoration: BoxDecoration(
                              color : ClrConstant.blackColor,
                              borderRadius: BorderRadius.circular(width*0.015),
                            ),
                          ),
                          SizedBox(width: width*0.03,),
                          Text("Upcoming",
                            style: TextStyle(
                              fontWeight: FontWeight.w900
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: width*0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height*0.035,
                            width: width*0.06,
                            decoration: BoxDecoration(
                              color : ClrConstant.primaryColor,
                              borderRadius: BorderRadius.circular(width*0.015),
                            ),
                          ),
                          SizedBox(width: width*0.03,),
                          Text("Tomorrow",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                              color: ClrConstant.primaryColor
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: width*0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height*0.035,
                            width: width*0.06,
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(width*0.015),
                            ),
                          ),
                          SizedBox(width: width*0.03,),
                          Text("Today",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                              color: Colors.red
                            ),
                          )
                        ],
                      ),
                    ),
                    Container(
                      width: width*0.4,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: height*0.035,
                            width: width*0.06,
                            decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(width*0.015),
                            ),
                          ),
                          SizedBox(width: width*0.03,),
                          Text("previous",
                            style: TextStyle(
                                fontWeight: FontWeight.w900,
                              color: Colors.grey
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
          Expanded(
            child: FutureBuilder<List<String>>(
              future: fetchEventIds(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Text("You haven't booked any events."),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Text("Error: ${snapshot.error}"),
                  );
                }

                final eventIds = snapshot.data!;

                return FutureBuilder<List<Map<String, dynamic>>>(
                  future: fetchEventsByIds(eventIds),
                  builder: (context, eventSnapshot) {
                    if (eventSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    if (!eventSnapshot.hasData || eventSnapshot.data!.isEmpty) {
                      return const Center(
                        child: Text("No event details available."),
                      );
                    }

                    if (eventSnapshot.hasError) {
                      return Center(
                        child: Text("Error: ${eventSnapshot.error}"),
                      );
                    }

                    final events = eventSnapshot.data!;

                    return ListView.builder(
                      itemCount: events.length,
                      itemBuilder: (context, index) {
                        final event = events[index];
                        final eventDateStr = event['date'] ?? '';
                        final eventDate =
                            DateTime.tryParse(eventDateStr) ?? DateTime.now();

                        final today = DateTime.now();
                        final tomorrow = today.add(Duration(days: 1));
                        final isToday = eventDate.year == today.year &&
                            eventDate.month == today.month &&
                            eventDate.day == today.day;
                        final isTomorrow = eventDate.year == tomorrow.year &&
                            eventDate.month == tomorrow.month &&
                            eventDate.day == tomorrow.day;
                        final isPastEvent = eventDate.isBefore(today);

                        TextStyle textStyle;

                        if (isToday) {
                          textStyle = TextStyle(
                              fontWeight: FontWeight.w900, color: Colors.red);
                        } else if (isTomorrow) {
                          textStyle = TextStyle(
                              fontWeight: FontWeight.w900,
                              color: ClrConstant.primaryColor);
                        } else if (isPastEvent) {
                          textStyle =
                              TextStyle(color: Colors.grey.withOpacity(0.35));
                        } else {
                          textStyle = TextStyle(
                              color: ClrConstant.blackColor,
                              fontWeight: FontWeight.w600);
                        }

                        return Card(
                          color: ClrConstant.whiteColor,
                          child: ListTile(
                            leading: Container(
                              width: width * 0.15,
                              height: height * 0.15,
                              decoration: BoxDecoration(
                                color: ClrConstant.primaryColor,
                                borderRadius:
                                    BorderRadius.circular(width * 0.03),
                              ),
                              child: Image(
                                image:
                                    AssetImage(ImgConstant.instrumental_music),
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              event['title'] ?? "Untitled Event",
                              style: textStyle,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Description: ${event['description'] ?? "No description"}",
                                  style: textStyle,
                                ),
                                Text(
                                  "Location: ${event['location'] ?? "No location"}",
                                  style: textStyle,
                                ),
                                Text(
                                  "Date: $eventDateStr",
                                  style: textStyle,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),

        ]),
      ),
    );
  }
}
