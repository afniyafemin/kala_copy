import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

Future<void> deleteAccount () async {
  try{
    User? user= FirebaseAuth.instance.currentUser;
    if(user != null){
      await FirebaseFirestore.instance.collection('users').doc(user.uid).delete();
      print("User account deleted successfully.");
    }else{
      print("No User is currently logged in.");
    }
  }catch(e){
    print(e);
  }
}