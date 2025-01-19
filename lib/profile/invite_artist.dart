import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:kala_copy/profile/search_artists.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';

class InviteArtist extends StatefulWidget {
  final String eventId;
  final String title;
  final String location;
  final String date;
  final String description;

  const InviteArtist({
    Key? key,
    required this.eventId,
    required this.title,
    required this.location,
    required this.date,
    required this.description,
  }) : super(key: key);

  @override
  State<InviteArtist> createState() => _InviteArtistState();
}

class _InviteArtistState extends State<InviteArtist> {
  String title = '';
  String description = '';
  String location = '';
  String date = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController numberOfPeopleController = TextEditingController();

  // Future<void> fetchEvent() async {
  //   try {
  //     DocumentSnapshot snapshot = await FirebaseFirestore.instance
  //         .collection('events')
  //         .doc(widget.eventId)
  //         .get();
  //
  //     if (snapshot.exists) {
  //       var eventData = snapshot.data() as Map<String, dynamic>;
  //       setState(() {
  //         title = eventData['title'] ?? 'No Title';
  //         description = eventData['description'] ?? 'No Description';
  //         location = eventData['location'] ?? 'No Location';
  //         date = eventData['date'] ?? DateTime.now().toIso8601String();
  //       });
  //     } else {
  //       setState(() {
  //         title = 'Event Not Found';
  //         description = '';
  //         location = '';
  //         date = '';
  //       });
  //     }
  //   } catch (e) {
  //     debugPrint('Error fetching event: $e');
  //   }
  // }

  Future<void> confirmBooking() async {
    try {
      await FirebaseFirestore.instance.collection('bookings').add({
        'eventId': widget.eventId,
        'name': nameController.text,
        'email': emailController.text,
        'city': cityController.text,
        'numberOfPeople': int.parse(numberOfPeopleController.text),
        'date': DateTime.now().toIso8601String(),
        'user' : FirebaseAuth.instance.currentUser?.uid,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Booking Confirmed!')),
      );
      Navigator.pop(context);
    } catch (e) {
      debugPrint('Error saving booking: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to confirm booking. Please try again.')),
      );
    }
  }

  Stream<List<Map<String, dynamic>>> fetchBookedUsers() {
    return FirebaseFirestore.instance
        .collection('bookings')
        .where('eventId', isEqualTo: widget.eventId)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'name': data['name'] ?? 'Unknown',
        'numberOfPeople': data['numberOfPeople'] ?? 0,
        'email': data['email'] ?? 'Unknown',
      };
    }).toList());
  }

  int totalSeats = 0;
  int bookedSeats = 0;

  Future<void> fetchEventDetails() async {
    try {
      // Fetch event details
      DocumentSnapshot eventSnapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (eventSnapshot.exists) {
        var eventData = eventSnapshot.data() as Map<String, dynamic>;
        setState(() {
          title = eventData['title'] ?? 'No Title';
          description = eventData['description'] ?? 'No Description';
          location = eventData['location'] ?? 'No Location';
          date = eventData['date'] ?? DateTime.now().toIso8601String();
          totalSeats = eventData['numberOfSeats'] ?? 0;
        });
      }

      // Calculate total booked seats
      QuerySnapshot bookingsSnapshot = await FirebaseFirestore.instance
          .collection('bookings')
          .where('eventId', isEqualTo: widget.eventId)
          .get();

      int bookedCount = bookingsSnapshot.docs.fold<int>(
        0,
            (previousValue, element) {
          var data = element.data() as Map<String, dynamic>;
          return previousValue + (data['numberOfPeople'] ?? 0) as int;
        },
      );

      setState(() {
        bookedSeats = bookedCount;
      });
    } catch (e) {
      debugPrint('Error fetching event or bookings: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    title = widget.title;
    description = widget.description;
    location = widget.location;
    date = widget.date;
    fetchEventDetails();
    // fetchEvent();
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
          title,
          style: TextStyle(fontSize: width * 0.04),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.03),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Stack(
                    children: [
                      Container(
                        height: height * 0.3,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(width * 0.03),
                          image: DecorationImage(
                            image: AssetImage(ImgConstant.event1),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.03, top: width * 0.03),
                        child: Text(
                          title.isNotEmpty ? title : 'Loading...',
                          style: TextStyle(
                              color: ClrConstant.whiteColor,
                              fontSize: width * 0.05,
                              fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: height * 0.02),
                  Row(children: [Text("Date: $date")]),
                  SizedBox(height: height * 0.01),
                  Row(children: [Text("Description: $description")]),
                  SizedBox(height: height * 0.01),
                  Row(children: [Text("Location: $location")]),

                ],
              ),
              SizedBox(height: height * 0.1),
              InkWell(
                onTap: () {
                  showSearch(
                      context: context,
                      delegate: SearchArtistDelegate());
                },
                child: Container(
                  height: height * 0.04,
                  width: width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.05),
                    color: ClrConstant.primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      "Invite Artist",
                      style: TextStyle(
                        fontSize: width * 0.03,
                        color: ClrConstant.whiteColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: height*0.02,
              ),
              Divider(color: ClrConstant.primaryColor,
              height: height*0.02,),
              Text(
                "Booked People",
                style: TextStyle(
                  fontSize: width * 0.05,
                  fontWeight: FontWeight.bold,
                  color: ClrConstant.primaryColor,
                ),
              ),
              SizedBox(height: height * 0.02),
              Row(mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "Seats Booked: $bookedSeats / $totalSeats",
                    style: TextStyle(
                      fontSize: width * 0.03,
                      fontWeight: FontWeight.bold,
                      color: ClrConstant.blackColor,
                    ),
                  ),
                ],
              ),
              SizedBox(height: height * 0.02),
              StreamBuilder<List<Map<String, dynamic>>>(
                stream: fetchBookedUsers(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Text("Error loading bookings: ${snapshot.error}");
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text("No bookings yet.");
                  }

                  final bookings = snapshot.data!;
                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: bookings.length,
                    itemBuilder: (context, index) {
                      final booking = bookings[index];
                      return Card(
                        child: ListTile(
                          tileColor: ClrConstant.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(width*0.02)
                          ),
                          title: Text(booking['name']),
                          subtitle: Column(
                            // mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  "Number of People: ${booking['numberOfPeople']}"),
                              Text(
                                  "Email: ${booking['email']}"),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    var width = MediaQuery.of(context).size.width;
    return TextFormField(
      controller: controller,
      cursorColor: ClrConstant.primaryColor,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(width * 0.05),
          borderSide: BorderSide.none,
        ),
        fillColor: ClrConstant.primaryColor.withOpacity(0.4),
        suffixIcon: Icon(
          icon,
          color: ClrConstant.blackColor.withOpacity(0.25),
        ),
        label: Text(
          label,
          style: TextStyle(
            fontSize: width * 0.03,
            color: ClrConstant.blackColor.withOpacity(0.25),
          ),
        ),
      ),
    );
  }
}
