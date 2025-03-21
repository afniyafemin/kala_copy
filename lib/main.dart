

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kala_copy/constants/image_constant.dart';
import 'package:kala_copy/screens/slot_booking.dart';
import 'package:kala_copy/splash/splash.dart';

import 'firebase_options.dart';


var height;
var width;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    height=MediaQuery.of(context).size.height;
    width=MediaQuery.of(context).size.width;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Splash(),
      supportedLocales: [
        const Locale('en','us'),
      ],
    );
  }
}

