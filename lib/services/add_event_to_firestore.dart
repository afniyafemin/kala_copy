import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addEventToFirestore(String userId, String title, String description,
    String location, String date) async {
  // Generate a unique eventId
  final eventDoc = FirebaseFirestore.instance.collection('events').doc();
  final eventId = eventDoc.id;

  // Create a new event object
  Map<String, dynamic> newEvent = {
    "eventId": eventId, // Unique event ID
    "userId": userId,   // ID of the user who created the event
    "title": title,
    "description": description,
    "location": location,
    "date": date,
    "dateCreated": FieldValue.serverTimestamp(), // Server-side timestamp
  };

  try {
    // Add the event to Firestore
    await eventDoc.set(newEvent);
    print("Event Added Successfully");
  } catch (error) {
    print("Failed to add event: $error");
  }
}
