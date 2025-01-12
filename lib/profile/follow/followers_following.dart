import 'package:flutter/material.dart';
import '../../constants/color_constant.dart';
import 'followers.dart';
import 'following.dart';

class FollowersFollowing extends StatefulWidget {
  const FollowersFollowing({super.key});

  @override
  State<FollowersFollowing> createState() => _FollowersFollowingState();
}

class _FollowersFollowingState extends State<FollowersFollowing> {

  @override
  Widget build(BuildContext context) {
    var height=MediaQuery.of(context).size.height;
    var width=MediaQuery.of(context).size.width;
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: height*0.0,
          bottom: TabBar(
            unselectedLabelStyle: TextStyle(
                color: ClrConstant.primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: width*0.04
            ),
            labelStyle: TextStyle(
                color: ClrConstant.primaryColor,
                fontWeight: FontWeight.w900,
                fontSize: width*0.04
            ),
            indicatorColor: ClrConstant.primaryColor.withOpacity(0.5),
              indicatorWeight: width*0.02,
              tabs: [
            Container(
                height: height*0.05,
                child: Center(child: Text("Following"))
            ),
            Container(
                height: height*0.05,
                child: Center(child: Text("Followers"))
            )
          ]
          ),
        ),
        backgroundColor: ClrConstant.whiteColor,
        body: TabBarView(children: [
          Following(),
          Followers(),
        ]),
      ),
    );
  }
}