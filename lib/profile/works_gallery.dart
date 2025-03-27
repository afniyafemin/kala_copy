import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../constants/color_constant.dart';

class WorksGallery extends StatefulWidget {
  final String userId;
  const WorksGallery({super.key, required this.userId});

  @override
  State<WorksGallery> createState() => _WorksGalleryState();
}

class _WorksGalleryState extends State<WorksGallery> {
  Future<List<Post>> fetchWorks() async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists && userDoc.data() != null) {
        var gallery = List<Map<String, dynamic>>.from(userDoc.data()?['gallery'] ?? []);

        return gallery
            .map((postData) => Post(
          img: postData['postUrl'] ?? '',
          description: postData['description'] ?? '',
          likes: postData['likes'] ?? 0,
          comments: List<dynamic>.from(postData['comments'] ?? []),
          likedBy: List<String>.from(postData['likedBy'] ?? []),
        ))
            .toList();
      }
    } catch (e) {
      print("Error fetching works: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: Text("Gallery"),
      ),
      body: FutureBuilder<List<Post>>(
        future: fetchWorks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No works available"));
          }

          final posts = snapshot.data!;

          return GridView.builder(
            padding: EdgeInsets.all(screenWidth * 0.03),
            itemCount: posts.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: screenWidth > 600 ? 4 : 3,
              mainAxisSpacing: screenWidth * 0.03,
              crossAxisSpacing: screenWidth * 0.03,
              childAspectRatio: 1,
            ),
            itemBuilder: (context, index) {
              final post = posts[index];
              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PostDetailsPage(
                        post: post,
                        userId: widget.userId,
                      ),
                    ),
                  );
                },
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(screenWidth * 0.03),
                    image: DecorationImage(
                      image: NetworkImage(post.img),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PostDetailsPage extends StatefulWidget {
  final Post post;
  final String userId;

  const PostDetailsPage({
    required this.post,
    required this.userId,
    super.key,
  });

  @override
  State<PostDetailsPage> createState() => _PostDetailsPageState();
}

class _PostDetailsPageState extends State<PostDetailsPage> {
  final TextEditingController _commentController = TextEditingController();
  late List<dynamic> comments;

  @override
  void initState() {
    super.initState();
    comments = widget.post.comments;
  }

  Future<void> toggleLike() async {
    String currentUserId = widget.userId; // Current logged-in user
    bool currentlyLiked = widget.post.isLiked(currentUserId);

    setState(() {
      if (currentlyLiked) {
        widget.post.likedBy.remove(currentUserId);
        widget.post.likes -= 1;
      } else {
        widget.post.likedBy.add(currentUserId);
        widget.post.likes += 1;
      }
    });

    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var gallery = List<Map<String, dynamic>>.from(userDoc['gallery']);
        int index = gallery.indexWhere((p) => p['postUrl'] == widget.post.img);

        if (index != -1) {
          gallery[index]['likes'] = widget.post.likes;
          gallery[index]['likedBy'] = widget.post.likedBy; // Update likedBy list
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .update({'gallery': gallery});
        }
      }
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  Future<void> addComment(String comment) async {
    if (comment.trim().isEmpty) return;

    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var gallery = List<Map<String, dynamic>>.from(userDoc['gallery']);
        int index = gallery.indexWhere((p) => p['postUrl'] == widget.post.img);

        if (index != -1) {
          gallery[index]['comments'] = List<dynamic>.from(gallery[index]['comments'] ?? [])
            ..add(comment);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .update({'gallery': gallery});
          setState(() {
            comments.add(comment);
          });
        }
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: ClrConstant.whiteColor),
        backgroundColor: ClrConstant.primaryColor,
        title: Text("Post Details",
          style: TextStyle(
            color: ClrConstant.whiteColor,
            fontWeight: FontWeight.w700
          ),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(width * 0.03),
        child: ListView(
          children: [
            Container(
              height: height * 0.4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: DecorationImage(
                  image: NetworkImage(widget.post.img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              "Description: ${widget.post.description}",
              style: TextStyle(fontSize: width * 0.04),
            ),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    widget.post.isLiked(widget.userId) ? Icons.favorite : Icons.favorite_border,
                    color: widget.post.isLiked(widget.userId) ? Colors.red : Colors.grey,
                  ),
                  onPressed: toggleLike,
                ),
                Text('${widget.post.likes}'),
              ],
            ),
            const Divider(),
            Text(
              "Comments",
              style: TextStyle(
                color: ClrConstant.blackColor.withOpacity(0.75),
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            comments.isEmpty
                ? Text(
              "No comments yet.",
              style: TextStyle(
                color: ClrConstant.blackColor.withOpacity(0.4),
                fontWeight: FontWeight.w700,
              ),
            )
                : Container(
              height: height * 0.2,
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      comments[index],
                      style: TextStyle(
                          color: ClrConstant.primaryColor,
                        fontSize: width*0.04
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              cursorColor: ClrConstant.primaryColor,
              controller: _commentController,
              decoration: InputDecoration(
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(width * 0.05),
                    borderSide: BorderSide(
                        color: ClrConstant.primaryColor,
                      width: width*0.0075
                    )
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(width * 0.05),
                  borderSide: BorderSide(
                    color: ClrConstant.primaryColor,
                      width: width*0.0075
                  )
                ),
                hintText: 'Add a comment...',
                hintStyle: TextStyle(
                  color: ClrConstant.blackColor.withOpacity(0.3),
                  fontSize: width * 0.04,
                ),
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: ClrConstant.primaryColor),
                  onPressed: () {
                    addComment(_commentController.text.trim());
                    _commentController.clear();
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Post {
  final String img;
  final String description;
  int likes;
  final List<dynamic> comments;
  List<String> likedBy; // Store user IDs who liked the post

  Post({
    required this.img,
    required this.description,
    required this.likes,
    this.comments = const [],
    this.likedBy = const [],
  });

  bool isLiked(String userId) {
    return likedBy.contains(userId);
  }
}

