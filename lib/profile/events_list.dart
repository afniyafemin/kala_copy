import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../screens/slot_booking.dart';


class EventsGallery extends StatefulWidget {
  final String userId; // User ID to fetch events for

  const EventsGallery({super.key, required this.userId});

  @override
  State<EventsGallery> createState() => _EventsGalleryState();
}

class _EventsGalleryState extends State<EventsGallery> {
  List<Map<String, dynamic>> events = [];
  double height = 0;
  double width = 0;

  @override
  void initState() {
    super.initState();
    _fetchUserEvents();
  }

  Future<void> _fetchUserEvents() async {
    try {
      print("Fetching events for user ID: ${widget.userId}"); // Debugging statement
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: widget.userId) // Assuming events have a userId field
          .get();

      print("Number of events fetched: ${querySnapshot.docs.length}"); // Debugging statement

      setState(() {
        events = querySnapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          data['documentId'] = doc.id; // Add the document ID to the data
          return data;
        }).toList();
      });
    } catch (e) {
      print('Error fetching user events: $e'); // Print the error
    }
  }

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: Text(
          "Events",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: events.isEmpty
          ? Center(child: Text("No events found for this user."))
          : ListView.builder(
        itemCount: events.length,
        itemBuilder: (context, index) {
          final event = events[index];
          String formattedDate;
          if (event['date'] is Timestamp) {
            formattedDate = event['date'].toDate().toString() ?? 'No Date';
          } else {
            formattedDate = event['date'] ?? 'No Date'; // Use the string value if not a timestamp
          }
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SlotBooking(
                    eventId: event['eventId'],  // Passing the documentId as eventId
                    title: event['title'],
                    imageUrl: event['imageUrl'] ?? ImgConstant.event1,
                    location: event['location'],
                    date: event['date'],
                    description: event['description'],
                  ),
                ),
              );
            },
            child: Padding(
              padding: EdgeInsets.only(
                  top: width * 0.03,
                  right: width * 0.03,
                  left: width * 0.03),
              child: Container(
                height: height * 0.15,
                width: width * 0.85,
                decoration: BoxDecoration(
                  color: ClrConstant.primaryColor,
                  borderRadius: BorderRadius.circular(width * 0.05),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: height * 0.15,
                          width: width * 0.25,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(ImgConstant.event1), // Use a default image if none is provided
                              fit: BoxFit.cover,
                            ),
                            borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(width * 0.05),
                              bottomLeft: Radius.circular(width * 0.05),
                            ),
                          ),
                        ),
                        SizedBox(width: width * 0.02),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(event["title"] ?? 'No Title', style: TextStyle(fontWeight: FontWeight.bold)),
                            Text(event["description"] ?? 'No Description'),
                            Text(event["location"] ?? 'No Location'),
                            Text(formattedDate), // Format date if it's a Timestamp
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
