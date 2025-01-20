import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

Future<void> signOut() async {
  try {
    // Sign out from Firebase Authentication
    await FirebaseAuth.instance.signOut();

    // Check if the user is signed in with Google
    final GoogleSignIn googleSignIn = GoogleSignIn();
    if (await googleSignIn.isSignedIn()) {
      await googleSignIn.signOut(); // Sign out from Google
      print('Signed out from Google.');
    }

    print('User signed out successfully.');
  } catch (e) {
    print('Error during sign-out: $e');
  }
}
