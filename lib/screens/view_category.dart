import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';
import '../../constants/image_constant.dart';
import '../profile/profile_new.dart';
import '../services/user_model.dart'; // Import your UserModel class
import 'categories_new.dart';


class CategoryDetails extends StatefulWidget {
  const CategoryDetails({super.key});

  @override
  State<CategoryDetails> createState() => _CategoryDetailsState();
}

class _CategoryDetailsState extends State<CategoryDetails> {
  Future<List<UserModel>> fetchUsersByCategory(String category) async {
    List<UserModel> users = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('category', isEqualTo: category) // Assuming 'category' is the field in Firestore
          .get();

      users = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id; // Add the document ID to the data
        return UserModel.fromMap(data); // Convert to UserModel
      }).toList();
    } catch (e) {
      print('Error fetching users: $e');
    }
    return users; // Return the list of users
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        iconTheme: IconThemeData(color: ClrConstant.whiteColor),
        title: Text(
          category_ ?? "Category", // Use null-aware operator
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: ClrConstant.whiteColor,
            fontSize: 20, // Adjust font size as needed
          ),
        ),
        centerTitle: true,
        backgroundColor: ClrConstant.primaryColor,
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(Icons.search, color: ClrConstant.whiteColor),
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: FutureBuilder<List<UserModel>>(
          future: fetchUsersByCategory(category_), // Fetch users based on the selected category
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No users found in this category.'));
            }

            final users = snapshot.data!;

            return ListView.separated(
              itemBuilder: (context, index) {
                return ListTile(
                  onTap: () {
                    // Navigate to the Profile page with the UserModel
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Profile(user: users[index]),
                      ),
                    );
                  },
                  leading: CircleAvatar(
                    backgroundImage: users[index].profileImageUrl != null && users[index].profileImageUrl!.isNotEmpty
                        ? NetworkImage(users[index].profileImageUrl!) as ImageProvider
                        : AssetImage(ImgConstant.default_user),
                  ),
                  title: Text(users[index].username ?? "Unknown User"), // Access username from UserModel
                );
              },
              separatorBuilder: (BuildContext context, int index) {
                return Divider(color: ClrConstant.primaryColor);
              },
              itemCount: users.length,
            );
          },
        ),
      ),
    );
  }
}