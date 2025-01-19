import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<User?> SigninWithGoogle(BuildContext context) async {
  try {
    // Start the Google Sign-In process
    final GoogleSignIn googleSignIn = GoogleSignIn();
    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

    // Check if the user canceled the Google Sign-In
    if (googleUser == null) {
      throw Exception("Google Sign-In was cancelled by the user.");
    }

    // Retrieve Google authentication details
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create Google credential using the authentication tokens
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in with Firebase using the Google credential
    UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(credential);

    // Add user to Firestore
    await _addUserToFirestore(userCredential.user);

    // Return the signed-in user
    return userCredential.user;
  } catch (e) {
    // Handle errors gracefully
    print("Error during Google Sign-In: $e");
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Google Sign-In failed: ${e.toString()}")),
    );
    return null; // Return null in case of failure
  }
}

Future<void> _addUserToFirestore(User? user) async {
  if (user == null) return;

  final userRef = FirebaseFirestore.instance.collection('users').doc(user.uid);

  // Check if the user already exists in Firestore
  final userDoc = await userRef.get();
  if (!userDoc.exists) {
    // Add user details to Firestore
    await userRef.set({
      'uid': user.uid,
      'username': user.displayName ?? "Unknown",
      'email': user.email ?? "Unknown",
      'photoUrl': user.photoURL ?? "",
      'phoneNumber': user.phoneNumber ?? "Unknown",
      'createdAt': FieldValue.serverTimestamp(),
      'points': 0, // Default points for a new user
    });
    print("User added to Firestore: ${user.email}");
  } else {
    print("User already exists in Firestore: ${user.email}");
  }
}
