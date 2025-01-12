import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';

class SlotBooking extends StatefulWidget {
  final String eventId;
  final String title;
  final String location;
  final String date;
  final String description;

  const SlotBooking({
    Key? key,
    required this.eventId,
    required this.title,
    required this.location,
    required this.date,
    required this.description,
  }) : super(key: key);

  @override
  State<SlotBooking> createState() => _SlotBookingState();
}

class _SlotBookingState extends State<SlotBooking> {
  String title = '';
  String description = '';
  String location = '';
  String date = '';

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController numberOfPeopleController = TextEditingController();

  Future<void> fetchEvent() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('events')
          .doc(widget.eventId)
          .get();

      if (snapshot.exists) {
        var eventData = snapshot.data() as Map<String, dynamic>;
        setState(() {
          title = eventData['title'] ?? 'No Title';
          description = eventData['description'] ?? 'No Description';
          location = eventData['location'] ?? 'No Location';
          date = eventData['date'] ?? DateTime.now().toIso8601String();
        });
      } else {
        setState(() {
          title = 'Event Not Found';
          description = '';
          location = '';
          date = '';
        });
      }
    } catch (e) {
      debugPrint('Error fetching event: $e');
    }
  }

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

  @override
  void initState() {
    super.initState();
    title = widget.title;
    description = widget.description;
    location = widget.location;
    date = widget.date;

    fetchEvent();
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
          "Booking Registration",
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
              SizedBox(height: height * 0.03),
              Column(
                children: [
                  buildTextField(
                      controller: nameController,
                      label: "Full Name",
                      icon: Icons.person),
                  SizedBox(height: height * 0.02),
                  buildTextField(
                      controller: emailController,
                      label: "Valid email",
                      icon: Icons.email_outlined),
                  SizedBox(height: height * 0.02),
                  buildTextField(
                      controller: cityController,
                      label: "City",
                      icon: Icons.place),
                  SizedBox(height: height * 0.02),
                  buildTextField(
                      controller: numberOfPeopleController,
                      label: "Number of People",
                      icon: Icons.group,
                      keyboardType: TextInputType.number),
                ],
              ),
              SizedBox(height: height * 0.05),
              InkWell(
                onTap: confirmBooking,
                child: Container(
                  height: height * 0.04,
                  width: width * 0.3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.05),
                    color: ClrConstant.primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      "Confirm",
                      style: TextStyle(
                        fontSize: width * 0.03,
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
