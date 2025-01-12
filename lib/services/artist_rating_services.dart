// artist_rating_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ArtistRatingService {
  Future<double> getArtistAverageRating() async {
    try {
      final artistDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser !.uid)
          .get();

      // Calculate average rating
      List<dynamic> ratings = artistDoc.get('ratings') ?? [];
      if (ratings.isNotEmpty) {
        double totalRating = 0;
        for (var rating in ratings) {
          totalRating += ratings[rating];
        }
        return totalRating / ratings.length;
      }
    } catch (e) {
      print('Error fetching artist rating: $e');
      // Handle error (e.g., return a default value or throw an exception)
    }
    return 0.0; // Return 0 if no ratings are found or an error occurs
  }
}