import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:kala_copy/main.dart';

import '../constants/color_constant.dart';

class MyWorksGallery extends StatefulWidget {
  const MyWorksGallery({super.key});

  @override
  State<MyWorksGallery> createState() => _MyWorksGalleryState();
}

class _MyWorksGalleryState extends State<MyWorksGallery> {
  late double width;

  Future<List<Map<String, dynamic>>> _fetchGalleryData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists && docSnapshot.data() != null) {
      final gallery = docSnapshot.data()?['gallery'] as List<dynamic>? ?? [];
      return gallery.map((e) => Map<String, dynamic>.from(e)).toList();
    }

    return [];
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);

      final description = await _getDescription();
      if (description == null || description.trim().isEmpty) return;

      try {
        String imageUrl = await _uploadImageToFirebase(imageFile);
        await _addToFirestore(imageUrl, description);
        if (mounted) {
          setState(() {}); // Trigger a rebuild to fetch new data
        }
      } catch (e) {
        print("Error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Failed to upload image")),
        );
      }
    }
  }

  Future<String> _uploadImageToFirebase(File imageFile) async {
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final ref = FirebaseStorage.instance.ref().child('gallery/$fileName');

    final uploadTask = await ref.putFile(imageFile);
    return await uploadTask.ref.getDownloadURL();
  }

  Future<void> _addToFirestore(String imageUrl, String description) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc =
    FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.update({
      "gallery": FieldValue.arrayUnion([
        {
          "postUrl": imageUrl,
          "description": description,
          "comments": [],
          "likes": 0,
        }
      ])
    });
  }

  Future<String?> _getDescription() async {
    String? description;
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add a Description"),
          content: TextField(
            autofocus: true,
            onChanged: (value) {
              description = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
    return description;
  }

  void _showImageDetails(Map<String, dynamic> item) {
    showDialog(
      barrierColor: ClrConstant.blackColor.withOpacity(0.5),
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: ClrConstant.whiteColor,
          surfaceTintColor: ClrConstant.blackColor.withOpacity(0.2),
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Display Image
                Container(
                  height: MediaQuery.of(context).size.height * 0.3,
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage(item["postUrl"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    item["description"] ?? "No description",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),

                const Divider(),

                // Comments Section
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: (item["comments"] as List<dynamic>).length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      leading: const Icon(Icons.comment),
                      title: Text(item["comments"][index]),
                    );
                  },
                ),

                const Divider(),

                // Likes and Edit Button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Like Button

                    Text("${item["likes"]} Likes"),

                    // Edit Button
                    IconButton(
                      icon: const Icon(Icons.edit, color: ClrConstant.primaryColor),
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _showEditDialog(item); // Open Edit Dialog
                      },
                    ),
                  ],
                ),

                // Close Button
                ElevatedButton(style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(width*0.02)
                  ),
                  backgroundColor: ClrConstant.primaryColor,
                  foregroundColor: ClrConstant.blackColor
                ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text("Close"),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditDialog(Map<String, dynamic> item) {
    String updatedDescription = item["description"];
    bool imageUpdated = false;
    File? newImage;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Edit Work"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Update Image
              ElevatedButton(
                onPressed: () async {
                  final picker = ImagePicker();
                  final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);

                  if (pickedFile != null) {
                    setState(() {
                      newImage = File(pickedFile.path);
                      imageUpdated = true;
                    });
                  }
                },
                child: const Text("Change Image"),
              ),

              // Edit Description
              TextField(
                controller: TextEditingController(text: item["description"]),
                onChanged: (value) {
                  updatedDescription = value;
                },
                decoration: const InputDecoration(labelText: "Description"),
              ),

              const SizedBox(height: 10),

              // Delete Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                onPressed: () async {
                  await _deleteWork(item);
                  Navigator.pop(context); // Close the edit dialog
                  setState(() {}); // Refresh gallery
                },
                child: const Text("Delete Work"),
              ),
            ],
          ),
          actions: [
            // Save Changes
            TextButton(
              onPressed: () async {
                if (imageUpdated && newImage != null) {
                  final newImageUrl = await _uploadImageToFirebase(newImage!);
                  item["postUrl"] = newImageUrl;
                }

                item["description"] = updatedDescription;
                await _updateFirestore(item);

                Navigator.pop(context); // Close the dialog
                setState(() {}); // Refresh gallery
              },
              child: const Text("Save"),
            ),

            // Cancel
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text("Cancel"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteWork(Map<String, dynamic> item) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    await userDoc.update({
      "gallery": FieldValue.arrayRemove([item]),
    });
  }

  Future<void> _updateFirestore(Map<String, dynamic> updatedItem) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final userDoc = FirebaseFirestore.instance.collection('users').doc(user.uid);

    final docSnapshot = await userDoc.get();
    if (docSnapshot.exists) {
      List<dynamic> gallery = docSnapshot.data()?["gallery"] ?? [];
      gallery = gallery.map((e) {
        if (e["postUrl"] == updatedItem["postUrl"]) return updatedItem;
        return e;
      }).toList();

      await userDoc.update({"gallery": gallery});
    }
  }



  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      appBar: AppBar(
        backgroundColor: ClrConstant.primaryColor,
        title: const Text(
          "My Gallery",
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(

        future: _fetchGalleryData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text("Failed to load gallery"));
          } else if (snapshot.data == null || snapshot.data!.isEmpty) {
            return const Center(child: Text("No works found"));
          }

          final gallery = snapshot.data!;
          return GridView.builder(
            padding: EdgeInsets.all(width * 0.03),
            itemCount: gallery.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              mainAxisSpacing: width * 0.03,
              crossAxisSpacing: width * 0.03,
              childAspectRatio: 1,
            ),
            itemBuilder: (BuildContext context, int index) {
              return GestureDetector(
                onTap: () => _showImageDetails(gallery[index]),
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: ClrConstant.primaryColor,
                      width: width * 0.0075,
                    ),
                    borderRadius: BorderRadius.circular(width * 0.03),
                    image: DecorationImage(
                      image: NetworkImage(gallery[index]["postUrl"]),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: ClrConstant.primaryColor,
        onPressed: _pickImage,
        child: const Icon(
          Icons.add_a_photo,
          color: Colors.white,
        ),
      ),
    );
  }
}
