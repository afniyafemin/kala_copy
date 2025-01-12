import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';


class WorksGallery extends StatefulWidget {
  const WorksGallery({super.key});

  @override
  State<WorksGallery> createState() => _WorksGalleryState();
}

class _WorksGalleryState extends State<WorksGallery> {
  List<Post> allWorks = [
    Post(img: ImgConstant.event1, likeCount: 0, description: "description1"),
    Post(img: ImgConstant.event2, likeCount: 0, description: "description2"),
    Post(img: ImgConstant.add1, likeCount: 0, description: "description3"),
    Post(img: ImgConstant.add3, likeCount: 0, description: "description4"),
    Post(img: ImgConstant.add2, likeCount: 0, description: "description5"),
    Post(img: ImgConstant.trending1, likeCount: 0, description: "description6"),
    Post(img: ImgConstant.trending2, likeCount: 0, description: "description7"),
  ];

  int? _selectedPostIndex;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: Text(
          "Works Gallery",
          style: TextStyle(
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.03),
          child: Column(
            children: [
              GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                scrollDirection: Axis.vertical,
                itemCount: allWorks.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: width * 0.03,
                  crossAxisSpacing: width * 0.03,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedPostIndex = index;
                        showDialog(
                          context: context,
                          builder: (context) {
                            return PostDetails(
                              post: allWorks[_selectedPostIndex!],
                              onClose: () {
                                setState(() {
                                  _selectedPostIndex = null;
                                });
                                Navigator.of(context).pop();
                              },
                              onSubmitComment: (comment) {
                                // Add logic to submit comment to your backend (e.g., Firestore)
                                print("Comment submitted: $comment");
                              },
                            );
                          },
                        );
                      });
                    },
                    child: Container(
                      width: width * 0.3,
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: ClrConstant.primaryColor,
                          width: width * 0.0075,
                        ),
                        borderRadius: BorderRadius.circular(width * 0.03),
                        image: DecorationImage(
                          image: AssetImage(allWorks[index].img),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
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

class PostDetails extends StatefulWidget {
  final Post post;
  final VoidCallback onClose;
  final Function(String) onSubmitComment; // Callback to submit comment
  const PostDetails({required this.post, required this.onClose, super.key, required this.onSubmitComment});

  @override
  State<PostDetails> createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  final TextEditingController _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Dialog(
      backgroundColor: ClrConstant.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(width * 0.05),
      ),
      child: Padding(
        padding: EdgeInsets.all(width * 0.03),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: height * 0.3,
              width: width * 0.6,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(width * 0.03),
                image: DecorationImage(
                  image: AssetImage(widget.post.img),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            Column(
              children: [
                Row(
                  children: [
                    Text(
                      widget.post.description,
                      style: TextStyle(
                          fontSize: width * 0.03, color: ClrConstant.whiteColor),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.015),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                            onTap: () {
                              setState(() {
                                widget.post.like = !widget.post.like;
                                widget.post.like? widget.post.likeCount++: widget.post.likeCount--;
                              });
                            },
                            child: Icon(widget.post.like
                                ? Icons.favorite
                                : Icons.favorite_outline_rounded)),

                        Container(
                          height: height*0.03,
                          width: width*0.05,
                          child: Center(child: Text(widget.post.likeCount.toString()),),
                        ),
                        SizedBox(
                          width: width * 0.05,
                        ),
                        Icon(Icons.share),
                        SizedBox(
                          width: width * 0.05,
                        ),
                        IconButton(
                          onPressed: (){
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Add Comment',style: TextStyle(
                                    fontSize: 20,
                                    color: ClrConstant.blackColor,
                                    fontWeight: FontWeight.w700
                                  ),),
                                  content: TextField(
                                    controller: _commentController,
                                    decoration: InputDecoration(
                                      hintText: 'Enter your comment',
                                      hintStyle: TextStyle(color: ClrConstant.blackColor.withOpacity(0.5)),
                                      filled: true,
                                      fillColor: ClrConstant.primaryColor,
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: ClrConstant.primaryColor),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8.0),
                                        borderSide: BorderSide(color: ClrConstant.primaryColor),
                                      ),
                                    ),
                                    cursorColor: ClrConstant.primaryColor, // Change cursor color
                                  ),
                                  actions: <Widget>[
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(color: ClrConstant.primaryColor),
                                      ),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Submit the comment
                                        widget.onSubmitComment(_commentController.text);
                                        _commentController.clear();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text(
                                        'Submit',
                                        style: TextStyle(color: ClrConstant.primaryColor),
                                      ),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(Icons.comment_bank_outlined),
                        ),
                      ],
                    ),
                    GestureDetector(
                        onTap: () {
                          // Navigator.push(
                          //     context,
                          //     MaterialPageRoute(
                          //       builder: (context) => MyCommentsPage(),
                          //     ));
                        },
                        child: Text(
                          "view all comments",
                          style: TextStyle(
                              color: ClrConstant.whiteColor,
                              fontSize: width * 0.02),
                        ))
                  ],
                )
              ],
            ),
          ],
        ),
      ),
    );
  }
}


class Post {
  String img;
  String description;
  int likeCount;
  bool like = false;

  Post({required this.img, required this.likeCount, required this.description});

  void incrementLikeCount() {
    likeCount++;
  }
}

