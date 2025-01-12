import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kala_copy/screens/view_category.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import 'home.dart';


class CategoriesNew extends StatefulWidget {
  const CategoriesNew({super.key});

  @override
  State<CategoriesNew> createState() => _CategoriesNewState();
}

List<Map> category = [
  {"img": ImgConstant.dancing, "txt": "Dancing"},
  {"img": ImgConstant.instrumental_music, "txt": "Instrumental Music"},
  {"img": ImgConstant.malabar, "txt": "Malabar Arts"},
  {"img": ImgConstant.martial, "txt": "Martial and Ritual Arts"},
  {"img": ImgConstant.western, "txt": "Western"},
];

String category_='';
class _CategoriesNewState extends State<CategoriesNew> {
  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      body: Row(
        children: [
          Stack(children: [
            Container(
              height: height * 1,
              width: width * 0.35,
              color: ClrConstant.primaryColor,
            ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    height: height*0.85,
                    width: width*1,
                    // color: Colors.yellowAccent,
                    child: Column(
                      children: [
                        Expanded(
                          child: ListView.separated(
                              itemBuilder: (context, index) {
                                return Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    InkWell(
                                      onTap: (){
                                        category_=category[index]["txt"];
                                        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryDetails(),));
                                        setState(() {

                                        });
                                      },
                                      child: Stack(
                                        children: [
                                          Padding(
                                            padding:  EdgeInsets.only(left: width*0.125),
                                            child: Container(
                                              height: height*0.15,
                                              width: width*0.7,
                                              decoration: BoxDecoration(
                                                color: ClrConstant.whiteColor,
                                                borderRadius: BorderRadius.circular(width*0.05),
                                                boxShadow: [

                                                  BoxShadow(
                                                    offset: Offset(0, 4),
                                                    color: ClrConstant.blackColor.withOpacity(0.1),
                                                    spreadRadius: width*0.003,
                                                    blurRadius: width*0.03
                                                  )
                                                ]
                                              ),
                                              child: Center(
                                                child:Container(
                                                  height: height*0.1,
                                                  width: width*0.5,
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                    children: [
                                                      Text(category[index]["txt"],
                                                        style: TextStyle(
                                                            color: ClrConstant.blackColor,
                                                            fontWeight: FontWeight.w700,
                                                            fontSize: width*0.04
                                                        ),
                                                      ),
                                                      Text('''this is the dscription about the category''',
                                                        style: TextStyle(
                                                          color: ClrConstant.blackColor.withOpacity(0.4),

                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),

                                              ),
                                            ),
                                          ),

                                          Padding(
                                            padding:  EdgeInsets.only(top: height*0.025),
                                            child: CircleAvatar(
                                              radius: width*0.1,
                                              backgroundImage: AssetImage(category[index]["img"]),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                );
                              },
                              separatorBuilder: (context, index) {
                                return SizedBox(height: height*0.05,);
                              },
                              itemCount: category.length
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          ]),
        ],
      ),
    );
  }
}
