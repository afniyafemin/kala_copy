import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kala_copy/services/user_model.dart';


Future<UserModel?> signUp(
    String email, String password, String username, String category, String phone, String city
    ) async {
  try{
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password
    );
    String uid = userCredential.user!.uid;
    UserModel userModel= UserModel(
        uid: userCredential.user!.uid,
        username: username,
        email: email,
        category: category,
        phone: phone,
        city: city
    );

    await FirebaseFirestore.instance.collection('users').doc(userModel.uid).set(userModel.toMap());
    return userModel;

  }catch(e){
    print(e);
    return null;
  }
}