// import 'package:flutter/material.dart';
//
// class EventDetails extends StatelessWidget {
//   final String title;
//   final String description;
//   final String date;
//
//   const EventDetails({
//     Key? key,
//     required this.title,
//     required this.description,
//     required this.date,
//   }) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     DateTime eventDate = DateTime.parse(date); // Convert string to DateTime if needed
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(title),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               title,
//               style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//             ),
//             SizedBox(height: 10),
//             Text(
//               'Date: ${eventDate.toLocal().toString().split(' ')[0]}', // Format the date as needed
//               style: TextStyle(fontSize: 16),
//             ),
//             SizedBox(height: 10),
//             Text(
//               description,
//               style: TextStyle(fontSize: 16),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }