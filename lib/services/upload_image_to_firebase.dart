import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> _uploadImageToFirebase(File? imageFile) async {
  if (imageFile == null) return null;

  String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  Reference storageReference = FirebaseStorage.instance.ref().child('profile_images/$fileName');

  UploadTask uploadTask = storageReference.putFile(imageFile);
  TaskSnapshot taskSnapshot = await uploadTask;

  return await taskSnapshot.ref.getDownloadURL();
}