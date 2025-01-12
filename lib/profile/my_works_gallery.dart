import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../constants/color_constant.dart';
import '../constants/image_constant.dart';


class MyWorksGallery extends StatefulWidget {
  const MyWorksGallery({super.key});

  @override
  State<MyWorksGallery> createState() => _MyWorksGalleryState();
}

var height;
var width;

class _MyWorksGalleryState extends State<MyWorksGallery> {

  int like = 0;

  List<Map> myWorks = [
    {"img": ImgConstant.event1, "description": "hello everyone1"},
    {"img": ImgConstant.dance_category1, "description": "hello everyone2"},
    {"img": ImgConstant.dance_category2, "description": "hello everyone3"},
    {"img": ImgConstant.event2, "description": "hello everyone4"},
    {"img": ImgConstant.dance_category3, "description": "hello everyone5"},
    {"img": ImgConstant.add3, "description": "hello everyone6"},
    {"img": ImgConstant.add1, "description": "hello everyone7"},
  ];

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: Text(
          "My Gallery",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(width * 0.03),
          child: Container(
            height: height * 0.9,
            child: GridView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              itemCount: myWorks.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: width * 0.03,
                crossAxisSpacing: width * 0.03,
                childAspectRatio: 1,
              ),
              itemBuilder: (BuildContext context, int index) {
                return GestureDetector(
                  onTap: () {
                    showCupertinoModalPopup(
                      context: context,
                      builder: (context) {
                        return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: height * 0.5,
                              width: width * 0.75,
                              decoration: BoxDecoration(
                                color: ClrConstant.primaryColor,
                                borderRadius:
                                    BorderRadius.circular(width * 0.05),
                                boxShadow: [
                                  BoxShadow(
                                      color: ClrConstant.blackColor
                                          .withOpacity(0.5),
                                      blurRadius: width * 0.3,
                                      spreadRadius: width * 1)
                                ],
                              ),
                              child: Padding(
                                padding: EdgeInsets.all(width * 0.03),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Container(
                                      height: height * 0.3,
                                      width: width * 0.6,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              width * 0.03),
                                          image: DecorationImage(
                                              image: AssetImage(
                                                  myWorks[index]["img"]),
                                              fit: BoxFit.fill)),
                                    ),
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              myWorks[index]["description"],
                                              style: TextStyle(
                                                  fontSize: width * 0.03,
                                                  color:
                                                      ClrConstant.whiteColor),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: height * 0.015,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        // like ++;
                                                      });
                                                    },
                                                    child: Icon(Icons
                                                        .favorite_outline_rounded)),
                                                // Text("$like",
                                                //   style: TextStyle(
                                                //     fontSize: width*0.03,
                                                //     color: ClrConstant.blackColor.withOpacity(0.35)
                                                //   ),
                                                // ),
                                                SizedBox(
                                                  width: width * 0.03,
                                                ),
                                                Icon(Icons.share),
                                                SizedBox(
                                                  width: width * 0.03,
                                                ),
                                                GestureDetector(
                                                    onTap: () {
                                                      setState(() {

                                                      });
                                                      showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            backgroundColor: ClrConstant.primaryColor,
                                                            title: Text("Are you sure? you want to delete this post permanently?",
                                                              style: TextStyle(
                                                                  color: ClrConstant.blackColor,
                                                                  fontSize: width*0.03,
                                                                  fontWeight: FontWeight.w700
                                                              ),
                                                            ),
                                                            actions: [
                                                              GestureDetector(
                                                                onTap:(){
                                                                  setState(() {
                                                                    myWorks.removeAt(index);
                                                                  });
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Padding(
                                                                  padding:  EdgeInsets.all(width*0.03),
                                                                  child: Text("delete",
                                                                    style: TextStyle(
                                                                        color: ClrConstant.blackColor,
                                                                        fontSize: width*0.03,
                                                                        fontWeight: FontWeight.w700
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                              GestureDetector(
                                                                onTap:(){
                                                                  setState(() {

                                                                  });
                                                                  Navigator.pop(context);
                                                                },
                                                                child: Padding(
                                                                  padding:  EdgeInsets.all(width*0.03),
                                                                  child: Text("cancel",
                                                                    style: TextStyle(
                                                                        color: ClrConstant.blackColor,
                                                                        fontSize: width*0.03,
                                                                        fontWeight: FontWeight.w700
                                                                    ),
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                    },
                                                    child: Icon(Icons.delete)
                                                ),
                                              ],
                                            ),
                                            GestureDetector(
                                                onTap: () {
                                                  // Navigator.push(
                                                  //     context,
                                                  //     MaterialPageRoute(
                                                  //       builder: (context) =>
                                                  //           MyCommentsPage(),
                                                  //     ));
                                                  setState(() {});
                                                },
                                                child: Text(
                                                  "view all comments",
                                                  style: TextStyle(
                                                      color: ClrConstant
                                                          .whiteColor,
                                                      fontSize: width * 0.02),
                                                ))
                                          ],
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                    setState(() {});
                  },
                  child: Container(
                    width: width * 0.3,
                    decoration: BoxDecoration(
                        border: Border.all(
                            color: ClrConstant.primaryColor,
                            width: width * 0.0075),
                        borderRadius: BorderRadius.circular(width * 0.03),
                        image: DecorationImage(
                            image: AssetImage(myWorks[index]["img"]),
                            fit: BoxFit.cover)),
                  ),
                );
              },
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ClrConstant.primaryColor,
        onPressed: () {
          showCupertinoDialog(
            context: context,
            builder: (context) => Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CupertinoActionSheet(
                  actions: [
                    CupertinoActionSheetAction(
                        onPressed: ()  {

                        },
                        child: Text(
                          "Choose From Gallery",
                          style: TextStyle(color: ClrConstant.primaryColor),
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {

                        },
                        child: Text(
                          "Camera",
                          style: TextStyle(color: ClrConstant.primaryColor),
                        )),
                    CupertinoActionSheetAction(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: Text(
                          "Cancel",
                          style: TextStyle(color: ClrConstant.primaryColor),
                        ))
                  ],
                ),
              ],
            ),
          );
          setState(() {});
        },
        child: Icon(
          Icons.add_a_photo,
          color: ClrConstant.whiteColor,
        ),
      ),
    );
  }
}
