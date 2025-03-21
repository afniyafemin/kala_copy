import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kala_copy/auth/auth_page.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../bottom_navigation_bar/bottom_navigation.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../main.dart';

class AddPage extends StatefulWidget {
  const AddPage({super.key});

  @override
  State<AddPage> createState() => _AddPageState();
}
List <Map> adds_view=[
  {
   "txt":"gygiufiwab suewfilbv \n lugfewfgiweug" ,
    "img":ImgConstant.add1
  },{
   "txt":"gygiufiwab suewfilbv \n lugfewfgiweug" ,
    "img":ImgConstant.add2
  },{
   "txt":"gygiufiwab suewfilbv \n lugfewfgiweug" ,
    "img":ImgConstant.add3
  },
];
int selectIndex=0;
class _AddPageState extends State<AddPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      body: Padding(
        padding:EdgeInsets.all(width*0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(),
            CarouselSlider.builder(
                itemCount: 3,
                itemBuilder: (context, index, realIndex) => Container(
                  height: height*0.9,
                  width: width*0.9,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(adds_view[index]["img"]))
                  ),
                ),
                options: CarouselOptions(
                  autoPlay: true,
                  autoPlayAnimationDuration: Duration(seconds: 2),
                  viewportFraction: 1.0,
                  onPageChanged: (index, reason) {
                    setState(() {
                      selectIndex=index;
                    });
                  },
                )
             ),
            AnimatedSmoothIndicator(
                activeIndex: selectIndex,
                count:adds_view.length,
              effect: JumpingDotEffect(
                dotColor: ClrConstant.blackColor,
                activeDotColor: ClrConstant.primaryColor,
                dotHeight: width*0.05,
                dotWidth: width*0.05
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => AuthPage(),));
                    setState(() {

                    });
                  },
                  child: Container(
                    height: height*0.05,
                    width: width*0.35,
                    decoration: BoxDecoration(
                        color: ClrConstant.primaryColor,
                        borderRadius: BorderRadiusDirectional.circular(width*0.1)
                    ),
                    child: Center(
                      child: Text("SKIP",
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: ClrConstant.whiteColor,
                            fontSize: width*0.05
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      )
    );
  }
}
