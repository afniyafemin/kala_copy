import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../profile/profile_new.dart';
import '../search/search_functionality.dart';
import '../services/add_to_favs.dart';
import '../services/favorites_method.dart';
import '../services/fetch_all_users.dart';
import '../services/user_model.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? currentUserId;
  List<UserModel> topArtists = [];
  final AddToFav _addToFav = AddToFav();

  @override
  void initState() {
    super.initState();
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      currentUserId = user.uid;
    }
    fetchTopArtists(); // Fetch top artists on initialization
  }

  // Future<List<Map<String, dynamic>>> fetchGalleryPosts() async {
  //   List<Map<String, dynamic>> galleryPosts = [];
  //   try {
  //     final querySnapshot =
  //     await FirebaseFirestore.instance.collection('users').get();
  //
  //     for (var doc in querySnapshot.docs) {
  //       final data = doc.data();
  //       if (data.containsKey('gallery')) {
  //         List<dynamic> gallery = data['gallery'];
  //         for (var post in gallery) {
  //           galleryPosts.add({
  //             'username': data['username'],
  //             'profileImageUrl': data['profileImageUrl'] ?? '',
  //             'postUrl': post['postUrl'],
  //             'description': post['description'],
  //             'likes': post['likes'],
  //             'comments': post['comments'] ?? [],
  //             'likedBy': post['likedBy'] ?? [], // Track who liked the post
  //           });
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     print('Error fetching gallery posts: $e');
  //   }
  //   return galleryPosts;
  // }

  Future<UserModel> fetchUserById(String userId) async {
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data() as Map<String, dynamic>);
      } else {
        throw Exception("User  not found");
      }
    } catch (e) {
      print('Error fetching user by ID: $e');
      throw e; // Rethrow the error
    }
  }

  Future<List<Map<String, dynamic>>> fetchGalleryPosts() async {
    List<Map<String, dynamic>> galleryPosts = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance.collection('users').get();

      for (var doc in querySnapshot.docs) {
        final data = doc.data();
        if (data.containsKey('gallery')) {
          List<dynamic> gallery = data['gallery'];
          for (var post in gallery) {
            galleryPosts.add({
              'userId': doc.id, // Add user ID here
              'username': data['username'],
              'profileImageUrl': data['profileImageUrl'] ?? '',
              'postUrl': post['postUrl'],
              'description': post['description'],
              'likes': post['likes'],
              'comments': post['comments'] ?? [],
              'likedBy': post['likedBy'] ?? [],
            });
          }
        }
      }
    } catch (e) {
      print('Error fetching gallery posts: $e');
    }
    return galleryPosts;
  }

  Future<List<UserModel>> fetchTopArtists() async {
    List<UserModel> topArtists = [];
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('avgRating',
              isGreaterThan: 2) // Filter users with avgRating > 2
          .orderBy('avgRating', descending: true) // Sort in descending order
          .get();

      topArtists = querySnapshot.docs.map((doc) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromMap(data); // Convert to UserModel
      }).toList();
    } catch (e) {
      print('Error fetching top artists: $e');
    }
    return topArtists; // Return the list of top artists
  }

  Future<bool> _isUserFavorited(String userId) async {
    return await _addToFav.checkIfLiked(userId);
  }

  void _toggleFavorite(UserModel user) async {
    String itemId = user.uid!; // Use the user ID as the unique item ID
    Map<String, dynamic> userData = {
      'favoritedUser Id': user.uid,
      'name': user.username,
      'img': user.profileImageUrl ?? ImgConstant.event1,
      'description': 'Description of the user or item',
      'isFavorited': true, // Add isFavorited field
    };

    await _addToFav.toggleLike(itemId, userData);
    setState(() {
      user.isFavorite = !user.isFavorite; // Toggle the favorite state
    });
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor.withOpacity(0.4),
        title: Text(
          "Kalakaar",
          style: TextStyle(
              color: ClrConstant.blackColor,
              fontWeight: FontWeight.w900,
              fontSize: width * 0.04),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.03),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: TextFormField(
                        onTap: () {
                          showSearch(
                              context: context,
                              delegate: CustomSearchDelegate());
                        },
                        cursorHeight: width * 0.05,
                        cursorColor: ClrConstant.primaryColor,
                        decoration: InputDecoration(
                          label: Text(
                            "Search here",
                            style: TextStyle(
                                color: ClrConstant.blackColor.withOpacity(0.5),
                                fontSize: width * 0.03),
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                            size: width * 0.05,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 10),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(width * 0.03),
                          ),
                          focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(width * 0.03),
                              borderSide:
                                  BorderSide(color: ClrConstant.primaryColor)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: EdgeInsets.all(width * 0.015),
                child: Text(
                  "Top Artists",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: ClrConstant.blackColor.withOpacity(0.25),
                      fontSize: width * 0.03),
                ),
              ),
              Container(
                height: height * 0.275,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(width * 0.05)),
                child: FutureBuilder<List<UserModel>>(
                  future: fetchTopArtists(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(child: Text("Error: ${snapshot.error}"));
                    }

                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Center(child: Text("No top artists found."));
                    }

                    final topArtists = snapshot.data!;

                    return CarouselSlider.builder(
                      itemCount: topArtists.length,
                      itemBuilder: (context, index, realIndex) {
                        final artist = topArtists[index];
                        return GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => Profile(user: artist),
                              ),
                            );
                          },
                          child: Stack(
                            children: [
                              Padding(
                                padding: EdgeInsets.only(
                                    left: width * 0.025, right: width * 0.025),
                                child: Container(
                                  height: height * 0.25,
                                  width: width * 1,
                                  decoration: BoxDecoration(
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05),
                                      image: DecorationImage(
                                        image: artist.profileImageUrl != null &&
                                                artist
                                                    .profileImageUrl!.isNotEmpty
                                            ? NetworkImage(
                                                artist.profileImageUrl!)
                                            : AssetImage(
                                                    ImgConstant.dance_category3)
                                                as ImageProvider,
                                        fit: BoxFit.cover,
                                      )),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    left: width * 0.05, top: height * 0.2),
                                child: Text(
                                  artist.username ?? "Unknown Artist",
                                  style: TextStyle(
                                    fontSize: width * 0.05,
                                    color: ClrConstant.whiteColor,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Positioned(
                                right: 10,
                                top: 10,
                                child: FutureBuilder<bool>(
                                  future: _isUserFavorited(artist.uid!),
                                  builder: (context, snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
                                      return CircularProgressIndicator();
                                    }
                                    if (snapshot.hasError) {
                                      return Icon(Icons.error);
                                    }
                                    bool isFavorited = snapshot.data ?? false;
                                    return IconButton(
                                      icon: Icon(
                                        isFavorited
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color: isFavorited
                                            ? Colors.red
                                            : ClrConstant.primaryColor,
                                      ),
                                      onPressed: () {
                                        _toggleFavorite(artist);
                                      },
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      options: CarouselOptions(
                        enableInfiniteScroll: false,
                        autoPlay: true,
                        viewportFraction: 0.5,
                        enlargeCenterPage: true,
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(width * 0.015),
                child: Row(
                  children: [
                    Text(
                      "Explore",
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: ClrConstant.blackColor.withOpacity(0.25),
                        fontSize: width * 0.03,
                      ),
                    ),
                  ],
                ),
              ),
              // FutureBuilder<List<UserModel>>(
              //   future: fetchAllUsers(),
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return const Center(child: CircularProgressIndicator());
              //     } else if (snapshot.hasError) {
              //       return Center(child: Text("Error: ${snapshot.error}"));
              //     } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              //       return const Center(child: Text("No users found."));
              //     }
              //
              //     List<UserModel> users = snapshot.data!;
              //     return ListView.separated(
              //       physics: NeverScrollableScrollPhysics(),
              //       shrinkWrap: true,
              //       itemBuilder: (context, index) {
              //         UserModel user = users[index];
              //         return Container(
              //           padding: EdgeInsets.all(width * 0.025),
              //           height: height * 0.35,
              //           width: width * 0.85,
              //           decoration: BoxDecoration(
              //             borderRadius: BorderRadius.circular(width * 0.03),
              //             color: ClrConstant.primaryColor.withOpacity(0.20),
              //           ),
              //           child: Column(
              //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //             children: [
              //               GestureDetector(
              //                 onTap : (){
              //                   Navigator.push(context, MaterialPageRoute(builder: (context) => Profile(user: user),));
              //                 },
              //                 child: Row(
              //                   mainAxisAlignment: MainAxisAlignment.start,
              //                   children: [
              //                     CircleAvatar(
              //                       radius: width * 0.04,
              //                       //backgroundColor: ClrConstant.whiteColor,
              //                       backgroundImage: user.profileImageUrl != null && user.profileImageUrl!.isNotEmpty
              //                           ? NetworkImage(user.profileImageUrl!) // Use profile image URL
              //                           : AssetImage(ImgConstant.fav2) as ImageProvider, // Fallback image
              //                     ),
              //                     SizedBox(width: width * 0.03),
              //                     Text(
              //                       user.username ?? 'Unknown user',
              //                       style:
              //                           TextStyle(fontWeight: FontWeight.w600),
              //                     ),
              //                   ],
              //                 ),
              //               ),
              //               Container(
              //                 height: height * 0.2,
              //                 width: width * 0.8,
              //                 decoration: BoxDecoration(
              //                   borderRadius:
              //                       BorderRadius.circular(width * 0.03),
              //                   image: DecorationImage(
              //                     image: AssetImage(ImgConstant.event1),
              //                     fit: BoxFit.cover,
              //                   ),
              //                 ),
              //               ),
              //               Row(
              //                 mainAxisAlignment:
              //                     MainAxisAlignment.spaceBetween,
              //                 children: [
              //                   Expanded(
              //                     child: Text(
              //                       '''${user.username} : The Name that belongs to one of \n The Youngest And Successful DJ's producers..''',
              //                       style: TextStyle(
              //                         fontSize: width * 0.03,
              //                         fontWeight: FontWeight.w600,
              //                         color: ClrConstant.blackColor
              //                             .withOpacity(0.25),
              //                       ),
              //                     ),
              //                   ),
              //                   FutureBuilder<bool>(
              //                     future: _isUserFavorited(user.uid!),
              //                     builder: (context, snapshot) {
              //                       if (snapshot.connectionState ==
              //                           ConnectionState.waiting) {
              //                         return CircularProgressIndicator();
              //                       }
              //                       bool isFavorited = snapshot.data ?? false;
              //                       return IconButton(
              //                         icon: Icon(
              //                           isFavorited
              //                               ? Icons.favorite
              //                               : Icons.favorite_border,
              //                           color: isFavorited
              //                               ? Colors.red
              //                               : ClrConstant.primaryColor,
              //                         ),
              //                         onPressed: () {
              //                           _toggleFavorite(user);
              //                         },
              //                       );
              //                     },
              //                   ),
              //                 ],
              //               ),
              //             ],
              //           ),
              //         );
              //       },
              //       separatorBuilder: (context, index) {
              //         return SizedBox(height: height * 0.01);
              //       },
              //       itemCount: users.length,
              //     );
              //   },
              // ),

              // Padding(
              //   padding: EdgeInsets.symmetric(vertical: width * 0.03),
              //   child: Text(
              //     "Gallery Posts",
              //     style: TextStyle(
              //       fontWeight: FontWeight.w600,
              //       color: Colors.black.withOpacity(0.5),
              //       fontSize: width * 0.05,
              //     ),
              //   ),
              // ),
              FutureBuilder<List<Map<String, dynamic>>>(
                future: fetchGalleryPosts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text("Error: ${snapshot.error}"));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text("No gallery posts found."));
                  }

                  List<Map<String, dynamic>> galleryPosts = snapshot.data!;
                  return ListView.builder(
                    physics: NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: galleryPosts.length,
                    itemBuilder: (context, index) {
                      final post = galleryPosts[index];
                      return Container(
                        margin: EdgeInsets.only(bottom: width * 0.03),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(width * 0.03),
                            color: ClrConstant.primaryColor.withOpacity(0.4)),
                        padding: EdgeInsets.all(width * 0.03),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // GestureDetector(
                            //   onTap: () {
                            //     Navigator.push(
                            //         context,
                            //         MaterialPageRoute(
                            //           builder: (context) => Profile(user: post['username']),
                            //         ));
                            //   },
                            //   child: Row(
                            //     children: [
                            //       CircleAvatar(
                            //         radius: width * 0.05,
                            //         backgroundImage: post['profileImageUrl']
                            //                 .isNotEmpty
                            //             ? NetworkImage(post['profileImageUrl'])
                            //             : AssetImage(
                            //                     'assets/default_profile.png')
                            //                 as ImageProvider,
                            //       ),
                            //       SizedBox(width: width * 0.03),
                            //       Text(
                            //         post['username'] ?? 'Unknown User',
                            //         style: TextStyle(
                            //           fontWeight: FontWeight.w600,
                            //           fontSize: width * 0.04,
                            //         ),
                            //       ),
                            //     ],
                            //   ),
                            // ),

                            GestureDetector(
                              onTap: () async {
                                // Fetch the user data based on userId
                                final userId = post['userId'];
                                UserModel user = await fetchUserById(userId); // Create this method to fetch user data
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => Profile(user: user),
                                  ),
                                );
                              },
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    radius: width * 0.05,
                                    backgroundImage: post['profileImageUrl'].isNotEmpty
                                        ? NetworkImage(post['profileImageUrl'])
                                        : AssetImage('assets/default_profile.png') as ImageProvider,
                                  ),
                                  SizedBox(width: width * 0.03),
                                  Text(
                                    post['username'] ?? 'Unknown User',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: width * 0.04,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            SizedBox(height: width * 0.03),
                            Container(
                              height: height * 0.3,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(width * 0.02),
                                image: DecorationImage(
                                  image: NetworkImage(post['postUrl']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: width * 0.02),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                post['description'] ?? '',
                                style: TextStyle(
                                  fontSize: width * 0.035,
                                  color: Colors.black.withOpacity(0.6),
                                ),
                              ),
                            ),
                          ],
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
}
