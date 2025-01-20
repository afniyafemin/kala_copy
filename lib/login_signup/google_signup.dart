import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:kala_copy/services/user_model.dart';

Future<User?> signInWithGoogle(BuildContext context) async {
  try {
    // Initialize Google Sign-In
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    if (googleUser == null) {
      // User canceled the sign-in
      throw Exception("Google Sign-In was cancelled by the user.");
    }

    // Authenticate with Google
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create credential
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Add user details to Firestore
    await _addUserToFirestore(userCredential.user);

    return userCredential.user;
  } catch (e) {
    // Log and show error
    print("Error during Google Sign-In: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Sign-In failed: ${e.toString()}")),
    );
    return null;
  }
}


Future<void> _addUserToFirestore(User? user) async {
  if (user == null) return;

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  // Check if the user already exists in Firestore
  final userDoc = await userRef.get();
  if (!userDoc.exists) {
    // Create a default UserModel instance
    UserModel userModel = UserModel(
      uid: user.uid,
      username: user.displayName ?? "Unknown",
      email: user.email ?? "Unknown",
      category: "default", // Replace with the desired default value
      phone: user.phoneNumber ?? "Unknown",
      city: "default", // Replace with the desired default value
    );

    // Add user details to Firestore
    await userRef.set(userModel.toMap());
    print("User added to Firestore: ${user.email}");
  } else {
    print("User already exists in Firestore: ${user.email}");
  }
}
