import 'dart:io';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

Future<String?> pickImage() async {
  final ImagePicker _picker = ImagePicker();
  final XFile? image = await _picker.pickImage(source: ImageSource.gallery);

  if (image != null) {
    // Upload the image to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();
    final imageRef = storageRef.child('events/${image.name}');
    await imageRef.putFile(File(image.path));

    // Get the download URL
    String downloadUrl = await imageRef.getDownloadURL();
    return downloadUrl; // Return the image URL
  }
  return null; // Return null if no image was picked
}