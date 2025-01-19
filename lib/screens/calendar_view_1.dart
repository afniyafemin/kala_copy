import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../main.dart';
import '../services/add_event_to_firestore.dart';
import '../services/imagepick.dart';
import 'all_upcoming_events.dart';
import 'slot_booking.dart';

class CalendarView extends StatefulWidget {
  const CalendarView({Key? key}) : super(key: key);

  @override
  State<CalendarView> createState() => _CalendarviewAState();
}

String? dateOfEvent;

class _CalendarviewAState extends State<CalendarView> {
  CalendarFormat calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<Map<String, dynamic>>> events = {};

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _loadEvents();
  }

  Future<String?> _fetchUsername(String userId) async {
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
    return userDoc.data()?['username']; // Assuming 'username' is the field name
  }

  Future<void> _loadEvents() async {
    final querySnapshot = await FirebaseFirestore.instance.collection('events').get();

    setState(() {
      events = {};
      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        final date = data['date'] as String;

        // Fetch username based on userId
        _fetchUsername(data['userId']).then((username) {
          data['username'] = username; // Add username to event data
          // Update the events map after fetching the username
          if (!events.containsKey(date)) {
            events[date] = [];
          }
          data['id'] = doc.id; // Add Firestore document ID
          events[date]?.add(data); // Add the event data
        });
      }
    });
  }

  List<Map<String, dynamic>> _listOfDayEvents(DateTime datetime) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(datetime);
    return events[formattedDate] ?? [];
  }

  Future<void> _fetchEventsForDate(String formattedDate) async {
    final userUid = FirebaseAuth.instance.currentUser?.uid;
    if (userUid != null) {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('events')
          .where('userId', isEqualTo: userUid)
          .where('date', isEqualTo: formattedDate)
          .get();

      setState(() {
        events = {
          formattedDate: querySnapshot.docs.map(
            (doc) {
              Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
              data['id'] = doc.id;
              return data;
            },
          ).toList(),
        };
      });
    }
  }

  // Future<void> _fetchEventsForDate(String formattedDate) async {
  //   final userUid = FirebaseAuth.instance.currentUser ?.uid;
  //   if (userUid != null) {
  //     final querySnapshot = await FirebaseFirestore.instance
  //         .collection('events')
  //         .where('userId', isEqualTo: userUid)
  //         .where('date', isEqualTo: formattedDate) // Ensure this matches the stored format
  //         .get();
  //
  //     print("Query results: ${querySnapshot.docs.length} documents found.");
  //     for (var doc in querySnapshot.docs) {
  //       print("Document ID: ${doc.id}, Data: ${doc.data()}");
  //     }
  //
  //     setState(() {
  //       events = {
  //         formattedDate: querySnapshot.docs.map((doc) {
  //           Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
  //           data['id'] = doc.id;
  //           return data;
  //         }).toList(),
  //       };
  //     });
  //   }
  // }

  // List<Map<String, dynamic>> _listOfDayEvents(DateTime datetime) {
  //   final formattedDate = DateFormat('yyyy-MM-dd').format(datetime);
  //   return events[formattedDate] ?? [];
  // }
  //
  // Future<void> addEventToFirestore(
  //     String title, String description, String location, String date) async {
  //   final userUid = FirebaseAuth.instance.currentUser?.uid;
  //
  //   if (userUid != null) {
  //     final eventDoc = FirebaseFirestore.instance.collection('events').doc();
  //     final eventId = eventDoc.id; // Generate a unique ID for the event.
  //
  //     await eventDoc.set({
  //       'eventId': eventId, // Store the generated event ID.
  //       'title': title,
  //       'description': description,
  //       'location': location,
  //       'date': date,
  //       'userId': userUid,
  //     });
  //
  //     _loadEvents(); // Reload events to reflect the new addition.
  //   } else {
  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('User not logged in')));
  //   }
  // }
  void addEvent(BuildContext context, String userId) async {
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final locationController = TextEditingController();
    final dateController = TextEditingController(
      text: DateFormat('yyyy-MM-dd').format(_selectedDay!),
    );
    final seatsController = TextEditingController();
    String? imageUrl; // Variable to store the image URL

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          "Add New Event",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(imageUrl != null ? "Image Selected" : "No Image Selected"),
                  IconButton(
                    icon: Icon(Icons.add_a_photo),
                    onPressed: () async {
                      String? url = await  pickImage();
                      if (url != null) {
                        setState(() {
                          imageUrl = url; // Update the image URL
                        });
                      }
                    },
                  ),
                ],
              ),
              SizedBox(height: 8),
              TextFormField(
                cursorColor: ClrConstant.blackColor,
                controller: titleController,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: "Event title",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ClrConstant.blackColor)),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                cursorColor: ClrConstant.blackColor,
                controller: descriptionController,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: "Description",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ClrConstant.blackColor)),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                cursorColor: ClrConstant.blackColor,
                controller: locationController,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: "Location",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ClrConstant.blackColor)),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                cursorColor: ClrConstant.blackColor,
                controller: dateController,
                maxLength: 30,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: "Date (yyyy-MM-dd)",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: ClrConstant.blackColor)),
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                cursorColor: ClrConstant.blackColor,
                controller: seatsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  counterText: "",
                  hintText: "Number of seats available",
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: ClrConstant.blackColor),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              "Cancel",
              style: TextStyle(
                color: ClrConstant.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          TextButton(
            onPressed: () async {
              if (titleController.text.isEmpty ||
                  descriptionController.text.isEmpty ||
                  seatsController.text.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Please fill in all required fields."),
                  ),
                );
                return;
              }

              final formattedDate = dateController.text;
              final totalSeats = int.tryParse(seatsController.text);

              if (totalSeats == null || totalSeats <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text("Number of seats must be a valid positive number."),
                  ),
                );
                return;
              }

              // Generate and add the event
              await addEventToFirestore(
                userId,
                titleController.text,
                descriptionController.text,
                locationController.text,
                formattedDate,
                totalSeats,
                imageUrl,
              );

              Navigator.pop(context);
              titleController.clear();
              descriptionController.clear();
              locationController.clear();
              dateController.clear();
              seatsController.clear();
            },
            child: const Text(
              "Add Event",
              style: TextStyle(
                color: ClrConstant.blackColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TableCalendar(
              calendarFormat: calendarFormat,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                headerPadding: EdgeInsets.only(top: height * 0.03),
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: ClrConstant.primaryColor,
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.w900,
                ),
              ),
              calendarStyle: CalendarStyle(
                todayTextStyle: const TextStyle(
                    color: ClrConstant.whiteColor, fontWeight: FontWeight.w900),
                todayDecoration: BoxDecoration(
                  color: ClrConstant.primaryColor,
                  shape: BoxShape.circle,
                ),
                isTodayHighlighted: true,
                selectedDecoration: BoxDecoration(
                  color: ClrConstant.primaryColor.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                selectedTextStyle: const TextStyle(
                  color: ClrConstant.blackColor,
                  fontWeight: FontWeight.w900,
                ),
                defaultTextStyle: const TextStyle(
                  color: ClrConstant.blackColor,
                  fontWeight: FontWeight.w900,
                ),
                holidayTextStyle: const TextStyle(
                    color: ClrConstant.whiteColor, fontWeight: FontWeight.w900),
                weekendTextStyle: TextStyle(
                    color: Colors.red.withOpacity(0.75),
                    fontWeight: FontWeight.w900),
              ),
              focusedDay: _focusedDay,
              firstDay: DateTime(2020),
              lastDay: DateTime(2050),
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                if (!isSameDay(_selectedDay, selectedDay)) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                }
              },
              onPageChanged: (focusedDay) {
                _focusedDay = focusedDay;
              },
              eventLoader: _listOfDayEvents, // Show events for all dates
              onFormatChanged: (format) {
                if (calendarFormat != format) {
                  setState(() {
                    calendarFormat = format;
                  });
                }
              },
            ),
            Container(
              height: height * 0.5,
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ..._listOfDayEvents(_selectedDay!).map((event) => Container(
                          margin: EdgeInsets.all(width * 0.03),
                          padding: EdgeInsets.all(width * 0.03),
                          height: height * 0.3,
                          decoration: BoxDecoration(
                              color: ClrConstant.primaryColor.withOpacity(0.5),
                              borderRadius:
                                  BorderRadius.circular(width * 0.04)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: height * 0.35,
                                width: width * 0.35,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(width * 0.03),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(width * 0.03), // Ensure the image is also rounded
                                  child: Image.network(
                                    event['imageUrl'] ?? '', // Use an empty string if imageUrl is null
                                    fit: BoxFit.cover,
                                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                                      if (loadingProgress == null) return child; // If the image is loaded, return the child
                                      return Center(
                                          child: CircularProgressIndicator(
                                            value: loadingProgress.expectedTotalBytes != null
                                                ? loadingProgress.cumulativeBytesLoaded / (loadingProgress.expectedTotalBytes ?? 1)
                                                : null,
                                          )
                                      );
                                    },
                                    errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) {
                                      // If the network image fails, show the asset image
                                      return Image.asset(
                                        ImgConstant.event1, // Fallback asset image
                                        fit: BoxFit.cover,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              Column(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    event['title'] ?? 'No title',
                                    style: TextStyle(
                                        fontSize: width * 0.025,
                                        color: ClrConstant.blackColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    event['description'] ?? 'No description',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: width * 0.025,
                                        color: ClrConstant.blackColor,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  Text(
                                    event['location'] ?? 'No location',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                        fontSize: width * 0.025,
                                        color: ClrConstant.blackColor,
                                        fontWeight: FontWeight.w600),
                                  ),

                                  Text(
                                    "Event holder: ${event['username'] ?? 'Unknown'}",
                                    style: TextStyle(
                                        fontSize: width * 0.025,
                                        color: ClrConstant.blackColor,
                                        fontWeight: FontWeight.w600),
                                  ),

                                  // Text(
                                  //   event['date'] ?? 'N',
                                  //   textAlign: TextAlign.start,
                                  //   style: TextStyle(
                                  //       fontSize: width * 0.025,
                                  //       color: ClrConstant.blackColor,
                                  //       fontWeight: FontWeight.w600),
                                  // ),

                                  SizedBox(
                                    height: height * 0.05,
                                  ),

                                  InkWell(
                                    onTap: () async {
                                      print("id : ${event['id']}");

                                      String eventId = event['id'] ?? 'id1';

                                      dateOfEvent = DateFormat('yyyy-MM-dd')
                                          .format(_selectedDay!);
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => SlotBooking(
                                              eventId: event['id'],
                                              title: event['title'],
                                              location: event['location'],
                                              date: event['date'],
                                              description: event['description'],
                                              imageUrl: event['imageUrl'] ?? ImgConstant.event1,
                                            ),
                                          ));
                                      setState(() {});
                                    },
                                    child: Container(
                                      height: height * 0.03,
                                      width: width * 0.2,
                                      decoration: BoxDecoration(
                                        color: ClrConstant.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(width * 0.5),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Book Now",
                                          style: TextStyle(
                                            fontSize: width * 0.03,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox()
                            ],
                          ),
                        ))
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton:
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllUpcomingEvents(),
                ));
            setState(() {});
          },
          child: Container(
            height: height * 0.03,
            width: width * 0.225,
            decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(width * 0.05)),
            margin: EdgeInsets.only(left: width * 0.075),
            child: Center(
              child: Text("upcoming events",
                  style: TextStyle(
                      fontSize: width * 0.02, color: ClrConstant.whiteColor)),
            ),
          ),
        ),
        FloatingActionButton(
          backgroundColor: ClrConstant.primaryColor,
          onPressed: () async {
            final user =
                FirebaseAuth.instance.currentUser; // Get the current user
            if (user != null) {
              final String userId = user.uid; // Extract the userId
              addEvent(context, userId); // Pass userId to addEvent function
            } else {
              // Handle the case where the user is not logged in
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User not logged in.")),
              );
            }
          },
          child: const Icon(Icons.add, color: ClrConstant.whiteColor),
        ),
      ]),
    );
  }
}
