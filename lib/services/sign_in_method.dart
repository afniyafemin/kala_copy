import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../bottom_navigation_bar/bottom_navigation.dart';

Future<User?> signIn(String email, String password, BuildContext context) async {
  try {
    UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    if (userCredential.user != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => BottomNavigationPage()),
      );
    }
    return userCredential.user;
  } catch (e) {
    print("Login Error: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Login failed. Check credentials.")),
    );
    return null;
  }
}
