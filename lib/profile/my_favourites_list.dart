import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../services/add_to_favs.dart';

class MyFavouritesList extends StatefulWidget {
  const MyFavouritesList({super.key});

  @override
  State<MyFavouritesList> createState() => _MyFavouritesListState();
}

class _MyFavouritesListState extends State<MyFavouritesList> {
  List<Map<String, dynamic>> myFavourites = [];
  String? currentUserId;

  @override
  void initState() {
    super.initState();
    getCurrentUserId();
  }

  void getCurrentUserId() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    User? user = auth.currentUser;

    if (user != null) {
      currentUserId = user.uid; // Get the current user's ID
      print("Current User ID: $currentUserId");
      _fetchFavourites(); // Fetch favourites after getting the user ID
    } else {
      print("No user is currently signed in.");
    }
  }

  Future<void> _fetchFavourites() async {
    if (currentUserId == null) return; // Ensure user ID is available

    try {
      final favouritesSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('favorites')
          .get();

      setState(() {
        myFavourites = favouritesSnapshot.docs
            .map((doc) => {
                  "name": doc['name'],
                  "img": doc['img'],
                  "description": doc['description'],
                  "itemId": doc.id, // Store the document ID for removal
                })
            .toList();
      });
    } catch (e) {
      print('Error fetching favourites: $e');
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
          "My Favourites",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: Column(
        children: [
          myFavourites.isEmpty
              ? Center(
                  child: Container(
                    height: height * 0.4,
                    width: width * 0.4,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Icon(
                          Icons.hourglass_empty,
                          color: ClrConstant.primaryColor.withOpacity(0.5),
                        ),
                        Text(
                          "No Favourites Yet",
                          style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: ClrConstant.primaryColor.withOpacity(0.5)),
                        ),
                      ],
                    ),
                  ),
                )
              : Expanded(
                  child: ListView.builder(
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: EdgeInsets.only(
                            left: width * 0.03,
                            right: width * 0.03,
                            top: height * 0.015),
                        child: Container(
                          height: height * 0.1,
                          width: width * 0.8,
                          decoration: BoxDecoration(
                              color: ClrConstant.primaryColor.withOpacity(0.4),
                              borderRadius:
                                  BorderRadius.circular(width * 0.03)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: height * 0.1,
                                width: width * 0.2,
                                decoration: BoxDecoration(
                                    color: ClrConstant.primaryColor
                                        .withOpacity(0.4),
                                    borderRadius:
                                        BorderRadius.circular(width * 0.03),
                                    image: DecorationImage(
                                        image: NetworkImage(
                                            myFavourites[index]["img"]),
                                        fit: BoxFit.cover)),
                              ),
                              Container(
                                height: height * 0.1,
                                width: width * 0.5,
                                child: Center(
                                  child: Text(myFavourites[index]["name"] ??
                                      'Unknown User'),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  String itemId = myFavourites[index]['itemId'];
                                  await removeFromFavorites(
                                      itemId, currentUserId!);
                                  setState(() {
                                    myFavourites.removeAt(index);
                                  });
                                },
                                child: Icon(
                                  Icons.favorite,
                                  color: Colors.red,
                                ),
                              ),
                              SizedBox(width: width*0.02,)
                            ],
                          ),
                        ),
                      );
                    },
                    itemCount: myFavourites.length,
                  ),
                ),
        ],
      ),
    );
  }
}
