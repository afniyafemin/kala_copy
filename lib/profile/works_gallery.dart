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

      if (userDoc.exists) {
        var gallery = List<Map<String, dynamic>>.from(userDoc['gallery']);
        return gallery
            .map((postData) => Post(
          img: postData['postUrl'],
          description: postData['description'],
          likes: postData['likes'],
          comments: List<dynamic>.from(postData['comments'] ?? []),
        ))
            .toList();
      }
    } catch (e) {
      print("Error fetching works: $e");
    }
    return [];
  }

  Future<void> updateLikes(int index, bool isLiked, List<Post> posts) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var gallery = List<Map<String, dynamic>>.from(userDoc['gallery']);

        if (index >= 0 && index < gallery.length) {
          gallery[index]['likes'] += isLiked ? -1 : 1;
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .update({'gallery': gallery});
          setState(() {
            posts[index].likes = gallery[index]['likes'];
            posts[index].isLiked = !isLiked;
          });
        }
      }
    } catch (e) {
      print("Error updating likes: $e");
    }
  }

  Future<List<dynamic>> fetchComments(String postUrl) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var gallery = List<Map<String, dynamic>>.from(userDoc['gallery']);
        var post = gallery.firstWhere((p) => p['postUrl'] == postUrl);
        return post['comments'] ?? [];
      }
    } catch (e) {
      print("Error fetching comments: $e");
    }
    return [];
  }

  Future<void> addComment(String postUrl, String comment) async {
    try {
      var userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        var gallery = List<Map<String, dynamic>>.from(userDoc['gallery']);
        int index = gallery.indexWhere((p) => p['postUrl'] == postUrl);

        if (index != -1) {
          gallery[index]['comments'].add(comment);
          await FirebaseFirestore.instance
              .collection('users')
              .doc(widget.userId)
              .update({'gallery': gallery});
        }
      }
    } catch (e) {
      print("Error adding comment: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: const Text("Works Gallery"),
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

          return SingleChildScrollView(
            padding: EdgeInsets.all(width * 0.03),
            child: GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: posts.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: width * 0.03,
                crossAxisSpacing: width * 0.03,
                childAspectRatio: 1,
              ),
              itemBuilder: (context, index) {
                final post = posts[index];
                return GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => PostDetails(
                        post: post,
                        onLikeToggle: () => updateLikes(index, post.isLiked, posts),
                        onAddComment: (comment) => addComment(post.img, comment),
                        fetchComments: () => fetchComments(post.img),
                      ),
                    );
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(width * 0.03),
                      image: DecorationImage(
                        image: NetworkImage(post.img),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class PostDetails extends StatefulWidget {
  final Post post;
  final VoidCallback onLikeToggle;
  final Future<void> Function(String) onAddComment;
  final Future<List<dynamic>> Function() fetchComments;

  const PostDetails({
    required this.post,
    required this.onLikeToggle,
    required this.onAddComment,
    required this.fetchComments,
    super.key,
  });

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final TextEditingController _commentController = TextEditingController();
  List<dynamic> comments = [];

  @override
  void initState() {
    super.initState();
    _loadComments();
  }

  Future<void> _loadComments() async {
    comments = await widget.fetchComments();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.03),
                image: DecorationImage(
                  image: NetworkImage(widget.post.img),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 16),
            Text(widget.post.description),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        widget.post.isLiked
                            ? Icons.favorite
                            : Icons.favorite_border,
                        color: Colors.red,
                      ),
                      onPressed: widget.onLikeToggle,
                    ),
                    Text(widget.post.likes.toString()),
                  ],
                ),
              ],
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: comments.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(comments[index]),
                  );
                },
              ),
            ),
            TextField(
              controller: _commentController,
              decoration: InputDecoration(
                hintText: 'Add a comment...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Colors.grey),
                ),
                filled: true,
                fillColor: Colors.grey[200],
                suffixIcon: IconButton(
                  icon: Icon(Icons.send, color: ClrConstant.primaryColor),
                  onPressed: () {
                    widget.onAddComment(_commentController.text);
                    _commentController.clear();
                    _loadComments();
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
  bool isLiked;
  final List<dynamic> comments;

  Post({
    required this.img,
    required this.description,
    required this.likes,
    this.isLiked = false,
    this.comments = const [],
  });
}
