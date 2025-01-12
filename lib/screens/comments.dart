import 'package:flutter/material.dart';

import '../constants/color_constant.dart';


class Comments extends StatefulWidget {
  const Comments({super.key});

  @override
  State<Comments> createState() => _CommentsState();
}

class _CommentsState extends State<Comments> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      body: ListView.builder(
        itemBuilder: (context, index) {
          return Card(
            child: ListTile(
                title: Text("User name",
                  style: TextStyle(
                      color: ClrConstant.blackColor.withOpacity(0.5)
                  ),
                ),
                subtitle: Text("Comment"),
                trailing: Text("12:41"),
            ),
          );
        },
      ),
    );
  }
}
