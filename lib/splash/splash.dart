import 'package:flutter/material.dart';
import '../auth/stream.dart';
import '../constants/color_constant.dart';


class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}
var height;
var width;

class _SplashState extends State<Splash> {

  @override
  void initState(){
    Future.delayed(Duration(seconds: 5)).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => StreamPage(),)),);
  }

  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ClrConstant.primaryColor,
      body: Center(
        child: Text("Kalakaar",
          style: TextStyle(
              fontSize: width*0.05,
              fontWeight: FontWeight.w900
          ),
        ),
      ),
    );
  }
}
