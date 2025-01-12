import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddToFav {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<bool> checkIfLiked(String userId) async {
    final user = _auth.currentUser ;
    if (user != null) {
      final likedItemsCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites');

      final docRef = likedItemsCollection.doc(userId);
      final snapshot = await docRef.get();
      return snapshot.exists; // Return true if liked, false otherwise
    }
    return false; // User not logged in
  }

  Future<void> toggleLike(String userId, Map<String, dynamic> userData) async {
    final user = _auth.currentUser ;
    if (user != null) {
      final likedItemsCollection = _firestore
          .collection('users')
          .doc(user.uid)
          .collection('favorites');

      final docRef = likedItemsCollection.doc(userId);
      final snapshot = await docRef.get();

      if (snapshot.exists) {
        // Unlike the user
        await docRef.delete();
      } else {
        // Like the user
        userData['isFavorited'] = true; // Add isFavorited field
        await docRef.set(userData);
      }
    }
  }
}