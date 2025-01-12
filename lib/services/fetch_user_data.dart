import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kala_copy/services/user_model.dart';


Future<UserModel?> fetchUserData() async {
  User? user = FirebaseAuth.instance.currentUser;
  
  if (user != null ) {
    // print("current user UID :${user.uid}");
    try{
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      
      if (doc.exists) {
        print("Document data: ${doc.data()}");
        return UserModel.fromMap(doc.data() as Map<String , dynamic>);
      }else{
        print("User document does not exist.");
        return null;
      }
    }catch(e){
      print(e);
      return null;
    }
  }else{
    print("No user is currently signed in.");
    return null;
  }
}