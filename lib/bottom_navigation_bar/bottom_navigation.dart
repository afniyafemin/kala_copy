import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../constants/color_constant.dart';
import '../main.dart';
import '../profile/my_profile.dart';
import '../screens/calendar_view_1.dart';
import '../screens/categories_new.dart';
import '../screens/home.dart';
import '../services/message/user_list_page.dart';


class BottomNavigationPage extends StatefulWidget {
  const BottomNavigationPage({super.key});

  @override
  State<BottomNavigationPage> createState() => _BottomNavigationPageState();
}

class _BottomNavigationPageState extends State<BottomNavigationPage> {
   int currentIndex=0;
  List pages=[
    HomePage(),
    CategoriesNew(),
    CalendarView(),
    MessagePage(),
    MyProfileNew()
  ];
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        color: ClrConstant.whiteColor,
        onTap: (value) {
          currentIndex=value;
          setState(() {

          });
        },
        backgroundColor: ClrConstant.primaryColor,
        height: height*0.075,
        items: [
          Icon(Icons.home),
          Icon(Icons.category_outlined),
          Icon(Icons.calendar_month),
          Icon(Icons.message),
          Icon(Icons.person),
        ],
      ),
    );
  }
}
