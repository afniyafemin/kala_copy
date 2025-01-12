import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kala_copy/services/user_model.dart';


Future<List<UserModel>> fetchAllUsers() async {
  try {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('users').get();
    List<UserModel> users = querySnapshot.docs.map((doc) {
      return UserModel.fromMap(doc.data() as Map<String, dynamic> ?? {}); // Handle null data
    }).toList();
    return users;
  } catch (e) {
    print('Error fetching users: ${e.toString()}'); // Convert error to string
    return [];
  }
}