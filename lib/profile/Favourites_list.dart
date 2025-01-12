import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../services/user_model.dart';

class FavouritesList extends StatefulWidget {
  final String userId; // User ID of the selected user

  const FavouritesList({super.key, required this.userId});

  @override
  State<FavouritesList> createState() => _FavouritesListState();
}

class _FavouritesListState extends State<FavouritesList> {
  List<UserModel> favoriteUsers = [];

  @override
  void initState() {
    super.initState();
    fetchFavorites(); // Fetch favorites on initialization
  }

  Future<void> fetchFavorites() async {
    try {
      // Fetch the favorites subcollection for the selected user
      final favoritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId) // Use the passed userId
          .collection('favorites')
          .get();

      // Create a list to hold the favorite user IDs
      List favoriteUserIds = favoritesSnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return data['favoritedUser  Id']; // Get the favorited user ID
      }).toList();

      // Fetch the details of the favorite users
      for (String userId in favoriteUserIds) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();

        if (userDoc.exists) {
          Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
          favoriteUsers.add(UserModel.fromMap(userData)); // Convert to UserModel
        }
      }

      setState(() {}); // Update the state with favorite users
    } catch (e) {
      print('Error fetching favorites: $e'); // Print error if fetching fails
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: Text(
          "Favourites",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.03),
        child: favoriteUsers.isNotEmpty
            ? ListView.builder(
          itemCount: favoriteUsers.length,
          itemBuilder: (context, index) {
            UserModel user = favoriteUsers[index];
            return Padding(
              padding: EdgeInsets.only(top: height * 0.015),
              child: Container(
                height: height * 0.1,
                width: width * 0.8,
                decoration: BoxDecoration(
                  color: ClrConstant.primaryColor.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(width * 0.03),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      height: height * 0.1,
                      width: width * 0.2,
                      decoration: BoxDecoration(
                        color: ClrConstant.primaryColor.withOpacity(0.4),
                        borderRadius: BorderRadius.circular(width * 0.03),
                        image: DecorationImage(
                          image: AssetImage(ImgConstant.event1), // Use user image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      height: height * 0.1,
                      width: width * 0.5,
                      child: Center(child: Text(user.username ?? 'Unknown User')),
                    ),
                    Icon(Icons.favorite, color: Colors.red),
                    SizedBox(),
                  ],
                ),
              ),
            );
          },
        )
            : Center(child: Text("No favorites found.")),
      ),
    );
  }
}