import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addToFavorites(String favoritedUserId, String currentUserId,
    String name, String img, String description, String itemId) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('favorites')
        .doc(itemId)
        .set({
      'favoritedUser Id':
          favoritedUserId, // Store the user ID of the favorited user
      'itemId': itemId,
      'name': name,
      'img': img,
      'description': description, // Add description
    });
  } catch (e) {
    print('Error adding to favorites: $e');
  }
}

Future<void> removeFromFavorites(String itemId, String currentUserId) async {
  try {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserId)
        .collection('favorites')
        .doc(itemId) // Use itemId as the document ID
        .delete();
  } catch (e) {
    print('Error removing from favorites: $e');
  }
}
