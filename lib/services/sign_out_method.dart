import 'package:firebase_auth/firebase_auth.dart';

Future<void> signOut () async {
  try{
    await FirebaseAuth.instance.signOut();
    print('User  signed out successfully.');
  }catch(e){
    print(e);
  }
}