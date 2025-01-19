import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kala_copy/services/message/chat_page.dart';
import '../constants/color_constant.dart';
import '../profile/profile_new.dart';
import '../services/user_model.dart';


class SearchArtistDelegate extends SearchDelegate {
  List<String> searchTerms = []; // This will hold the usernames

  SearchArtistDelegate() {
    _fetchUsernames();
  }

  Future<void> _fetchUsernames() async {
    // Fetch usernames from Firestore
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    searchTerms = snapshot.docs.map((doc) => doc['username'] as String).toList();
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear, color: ClrConstant.primaryColor),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      onPressed: () {
        close(context, null);
      },
      icon: Icon(Icons.arrow_back, color: ClrConstant.primaryColor),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSuggestionsOrResults();
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSuggestionsOrResults();
  }

  Widget _buildSuggestionsOrResults() {
    List<String> matchQuery = searchTerms
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return Container(
      color: ClrConstant.whiteColor,
      child: ListView.builder(
        itemCount: matchQuery.length,
        itemBuilder: (context, index) {
          var result = matchQuery[index];
          return ListTile(
            trailing: GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatPage(otherUserId: result, otherUsername: result),));
              },
              child: Text("invite",
                style: TextStyle(
                  color: ClrConstant.primaryColor,
                  fontWeight: FontWeight.w800
                ),
              ),
            ),
            title: Text(result),
            onTap: () async {
              // Fetch user data based on the selected username
              var userDoc = await FirebaseFirestore.instance
                  .collection('users')
                  .where('username', isEqualTo: result)
                  .limit(1)
                  .get();

              if (userDoc.docs.isNotEmpty) {
                // Assuming the first document is the correct user
                var userData = userDoc.docs.first.data();
                UserModel user = UserModel.fromMap(userData); // Convert to UserModel
              }

            },
          );
        },
      ),
    );
  }
}