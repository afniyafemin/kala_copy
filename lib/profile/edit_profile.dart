import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';

class EditProfileNew extends StatefulWidget {
  const EditProfileNew({super.key});

  @override
  State<EditProfileNew> createState() => _EditProfileNewState();
}

class _EditProfileNewState extends State<EditProfileNew> {
  final nameController = TextEditingController();
  final categoryController = TextEditingController();
  final cityController = TextEditingController();
  final descriptionController = TextEditingController();
  File? _imgFile;
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        var data = userDoc.data() as Map<String, dynamic>;
        nameController.text = data['username'] ?? '';
        categoryController.text = data['category'] ?? '';
        cityController.text = data['city'] ?? '';
        descriptionController.text = data['description'] ?? '';
        setState(() {
          _uploadedImageUrl = data['profileImageUrl'];
        });
      }
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedFile = await _picker.pickImage(source: source);

    if (pickedFile != null) {
      setState(() {
        _imgFile = File(pickedFile.path);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Image selected. Tap the upload button to save.")),
      );
    }
  }

  Future<String?> _uploadImageToFirebase(File? imageFile) async {
    if (imageFile == null) return null;

    try {
      // Delete old image if exists
      if (_uploadedImageUrl != null) {
        await FirebaseStorage.instance.refFromURL(_uploadedImageUrl!).delete();
      }

      // Upload new image
      String fileName = DateTime.now().millisecondsSinceEpoch.toString();
      Reference storageReference =
      FirebaseStorage.instance.ref().child('profile_images/$fileName');

      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask;

      // Get download URL
      return await taskSnapshot.ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image. Please try again.")),
      );
      return null;
    }
  }

  Future<void> _updateUserData(String? imageUrl) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'profileImageUrl': imageUrl,
        'username': nameController.text,
        'category': categoryController.text,
        'city': cityController.text,
        'description': descriptionController.text,
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Profile updated successfully!")),
      );
    }
  }

  void _handleUpload() async {
    if (_imgFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image first.")),
      );
      return;
    }

    try {
      String? imageUrl = await _uploadImageToFirebase(_imgFile);
      if (imageUrl != null) {
        setState(() {
          _uploadedImageUrl = imageUrl;
        });
        await _updateUserData(imageUrl);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to upload image. Please try again.")),
      );
    }
  }

  void _showImageSourceDialog() {
    showCupertinoDialog(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: Text("Select Image Source"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(ImageSource.gallery);
              Navigator.pop(context);
            },
            child: Text("Choose From Gallery"),
          ),
          CupertinoActionSheetAction(
            onPressed: () {
              _pickImage(ImageSource.camera);
              Navigator.pop(context);
            },
            child: Text("Use Camera"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.pop(context),
          child: Text("Cancel"),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height;
    var width = MediaQuery.of(context).size.width;
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Edit Profile",
          style: TextStyle(
              fontSize: width * 0.035,
              fontWeight: FontWeight.w700,
            color: ClrConstant.whiteColor
          ),
        ),
        backgroundColor: ClrConstant.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            SizedBox(height: height*0.05,),
            Stack(children: [
              CircleAvatar(
                radius: width * 0.2,
                backgroundColor: ClrConstant.primaryColor.withOpacity(0.4),
                child: CircleAvatar(
                  radius: width * 0.185,
                  backgroundImage: _imgFile != null
                      ? FileImage(_imgFile!)
                      : (_uploadedImageUrl != null
                      ? NetworkImage(_uploadedImageUrl!)
                      : AssetImage(ImgConstant.dance_category1)) as ImageProvider,
                ),
              ),
              Positioned(
                top: height * 0.15,
                left: width * 0.28,
                child: GestureDetector(
                  onTap: _showImageSourceDialog,
                  child: CircleAvatar(
                    radius: width * 0.045,
                    backgroundColor: ClrConstant.primaryColor,
                    child: Icon(
                      Icons.add,
                      color: ClrConstant.whiteColor,
                    ),
                  ),
                ),
              )
            ]),
            SizedBox(height: height*0.05,),
            Padding(
              padding: EdgeInsets.all(width * 0.03),
              child: Column(
                children: [
                  TextFormField(
                    controller: nameController,
                    decoration: InputDecoration(
                      labelText: "Username",
                      filled: true,
                      fillColor: ClrConstant.primaryColor.withOpacity(0.4),
                      suffixIcon: Icon(Icons.person),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  TextFormField(
                    controller: categoryController,
                    decoration: InputDecoration(
                      labelText: "Category",
                      filled: true,
                      fillColor: ClrConstant.primaryColor.withOpacity(0.4),
                      suffixIcon: Icon(Icons.category),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  TextFormField(
                    controller: cityController,
                    decoration: InputDecoration(
                      labelText: "City",
                      filled: true,
                      fillColor: ClrConstant.primaryColor.withOpacity(0.4),
                      suffixIcon: Icon(Icons.location_on),
                    ),
                  ),
                  SizedBox(height: height * 0.015),
                  TextFormField(
                    controller: descriptionController,
                    decoration: InputDecoration(
                      labelText: "Description",
                      filled: true,
                      fillColor: ClrConstant.primaryColor.withOpacity(0.4),
                      suffixIcon: Icon(Icons.edit),
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              // onTap: () async {
              //   // Check if required fields are empty
              //   if (nameController.text.trim().isEmpty ||
              //       categoryController.text.trim().isEmpty ||
              //       cityController.text.trim().isEmpty ||
              //       descriptionController.text.trim().isEmpty) {
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('Please fill in all fields.')),
              //     );
              //     return;
              //   }
              //
              //   try {
              //     // Upload image if selected, else keep the previous URL
              //     String? imageUrl =
              //     _imgFile != null ? await _uploadImageToFirebase(_imgFile) : _uploadedImageUrl;
              //
              //     // Update user data with the image URL
              //     await _updateUserData(imageUrl);
              //
              //     // Notify the user of successful update
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('Profile updated successfully!')),
              //     );
              //
              //     // Optionally navigate back or refresh the screen
              //     Navigator.pop(context);
              //   } catch (e) {
              //     // Handle errors gracefully
              //     ScaffoldMessenger.of(context).showSnackBar(
              //       SnackBar(content: Text('Failed to save changes. Please try again.')),
              //     );
              //   }
              // },
              onTap: () async {
                if (nameController.text.trim().isEmpty ||
                    categoryController.text.trim().isEmpty ||
                    cityController.text.trim().isEmpty ||
                    descriptionController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill in all fields.')),
                  );
                  return;
                }

                try {
                  // Upload new image or keep old URL
                  String? imageUrl =
                  _imgFile != null ? await _uploadImageToFirebase(_imgFile) : _uploadedImageUrl;

                  if (imageUrl != null) {
                    // Update Firestore with new data
                    await _updateUserData(imageUrl);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Profile updated successfully!')),
                    );

                    Navigator.pop(context); // Navigate back or refresh screen
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save changes. Please try again.')),
                  );
                }
              },

              child: Container(
                height: height * 0.04,
                width: width * 0.3,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(width * 0.05),
                  color: ClrConstant.primaryColor,
                ),
                child: Center(
                  child: Text(
                    "Save Changes",
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: width * 0.03,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _handleUpload,
      //   backgroundColor: ClrConstant.primaryColor,
      //   child: Icon(Icons.cloud_upload),
      // ),
    );
  }
}
