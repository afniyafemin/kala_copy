import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../bottom_navigation_bar/bottom_navigation.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../main.dart';
import '../services/sign_up_method.dart';

class Signup extends StatefulWidget {
  final VoidCallback showLoginPage;
  const Signup({super.key, required this.showLoginPage});

  @override
  State<Signup> createState() => _SignupState();
}

class _SignupState extends State<Signup> {
  bool pass = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController cityController = TextEditingController();

  String? selectedCategory; // Variable to hold the selected category

  // List of categories
  final List<String> categories = [
    "Dance Forms",
    "Instrumental Music",
    "Ritual & Temple Arts",
    "Theatre & Story Telling",
    "Martial Arts",
    "Puppetry & Shadow Theatre",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
                height: height * 0.925,
                width: width * 1,
                decoration: BoxDecoration(
                    color: ClrConstant.whiteColor,
                    image: DecorationImage(
                        image: AssetImage(ImgConstant.bgimage),
                        fit: BoxFit.fill)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    SizedBox(),
                    Padding(
                      padding: EdgeInsets.all(width * 0.1),
                      child: Form(
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: nameController,
                              autovalidateMode: AutovalidateMode.onUserInteraction,
                              validator: (value) {

                                Future<bool> isUsernameUnique(String username) async {
                                  final QuerySnapshot result = await FirebaseFirestore.instance
                                      .collection('users')
                                      .where('username', isEqualTo: username.toLowerCase()) // Use lower case for case-insensitive check
                                      .get();
                                  return result.docs.isEmpty; // Returns true if username is unique
                                }

                                Future<String> validateUsername(String username) async {
                                  // Length Check
                                  if (username.length < 3 || username.length > 20) {
                                    return "Username must be between 3 and 20 characters.";
                                  }

                                  // Character Restrictions
                                  if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(username)) {
                                    return "Username can only contain letters, numbers, and underscores.";
                                  }

                                  // Prohibited Usernames
                                  List<String> prohibitedUsernames = ['admin', 'user', 'test'];
                                  if (prohibitedUsernames.contains(username.toLowerCase())) {
                                  return "This username is not allowed.";
                                  }

                                  // Check for uniqueness
                                  bool isUnique = await isUsernameUnique(username);
                                  if (!isUnique) {
                                  return "Username is already taken.";
                                  }

                                  return "Username is available.";
                                }
                                return null;
                              },
                              cursorColor: ClrConstant.blackColor,
                              decoration: InputDecoration(
                                  fillColor:
                                      ClrConstant.primaryColor.withOpacity(0.3),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  labelText: "Username :",
                                  labelStyle:
                                      TextStyle(color: ClrConstant.blackColor),
                                  suffixIcon: Icon(Icons.person)),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Email is required";
                                }
                                // Regular expression for validating email
                                String pattern = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';
                                RegExp regex = RegExp(pattern);
                                if (!regex.hasMatch(value)) {
                                  return "Enter a valid email address";
                                }
                                return null; // Return null if the input is valid
                              },
                              controller: emailController,
                              cursorColor: ClrConstant.blackColor,
                              decoration: InputDecoration(
                                  fillColor:
                                      ClrConstant.primaryColor.withOpacity(0.3),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  labelText: "valid email :",
                                  labelStyle:
                                      TextStyle(color: ClrConstant.blackColor),
                                  suffixIcon: Icon(Icons.mail)),
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Password is required";
                                } else if (value.length < 6) {
                                  return "Password must be at least 6 characters long";
                                }
                                return null; // Return null if the input is valid
                              },
                              controller: passwordController,
                              cursorColor: ClrConstant.blackColor,
                              decoration: InputDecoration(
                                  fillColor:
                                      ClrConstant.primaryColor.withOpacity(0.3),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  labelText: "password :",
                                  labelStyle:
                                      TextStyle(color: ClrConstant.blackColor),
                                  suffixIcon: InkWell(
                                      onTap: () {
                                        pass = !pass;
                                        setState(() {});
                                      },
                                      child: Icon(pass
                                          ? Icons.visibility
                                          : Icons.visibility_off)),
                                  counterText: ''),
                              maxLength: 30,
                              obscureText: pass ? true : false,
                              obscuringCharacter: "*",
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            TextFormField(
                              controller: confirmPasswordController,
                              cursorColor: ClrConstant.blackColor,
                              decoration: InputDecoration(
                                  fillColor:
                                      ClrConstant.primaryColor.withOpacity(0.3),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  labelText: "confirm password :",
                                  labelStyle:
                                      TextStyle(color: ClrConstant.blackColor),
                                  suffixIcon: InkWell(
                                      onTap: () {
                                        pass = !pass;
                                        setState(() {});
                                      },
                                      child: Icon(pass
                                          ? Icons.visibility
                                          : Icons.visibility_off)),
                                  counterText: ''),
                              maxLength: 30,
                              obscureText: pass ? true : false,
                              obscuringCharacter: "*",
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            DropdownButtonFormField<String>(
                              value: selectedCategory,
                              hint: Text("Select Category"),
                              items: categories.map((String category) {
                                return DropdownMenuItem<String>(
                                  value: category,
                                  child: Text(category),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedCategory = newValue;
                                });
                              },
                              decoration: InputDecoration(
                                fillColor:
                                    ClrConstant.primaryColor.withOpacity(0.3),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ClrConstant.primaryColor),
                                  borderRadius:
                                      BorderRadius.circular(width * 0.05),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: ClrConstant.primaryColor),
                                  borderRadius:
                                      BorderRadius.circular(width * 0.05),
                                ),

                              ),
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return "Phone number is required";
                                } else if (value.length != 10) {
                                  return "Phone number must be exactly 10 digits";
                                }
                                return null; // Return null if the input is valid
                              },
                              controller: phoneController,
                              cursorColor: ClrConstant.blackColor,
                              minLines: 1,

                              decoration: InputDecoration(
                                  fillColor:
                                      ClrConstant.primaryColor.withOpacity(0.3),
                                  filled: true,
                                  focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: ClrConstant.primaryColor),
                                      borderRadius:
                                          BorderRadius.circular(width * 0.05)),
                                  labelText: "Phone no :",
                                  labelStyle:
                                      TextStyle(color: ClrConstant.blackColor),
                                  suffixIcon: Icon(Icons.phone),
                                  counterText: ""),
                              keyboardType: TextInputType.phone,
                              maxLength: 10,
                            ),
                            SizedBox(
                              height: height * 0.015,
                            ),
                            TextFormField(
                              validator: (value) {
                                if (value!.isEmpty) {
                                  return "phone number required";
                                }
                              },
                              controller: cityController,
                              cursorColor: ClrConstant.blackColor,
                              decoration: InputDecoration(
                                fillColor:
                                    ClrConstant.primaryColor.withOpacity(0.3),
                                filled: true,
                                focusedBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ClrConstant.primaryColor),
                                    borderRadius:
                                        BorderRadius.circular(width * 0.05)),
                                enabledBorder: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        color: ClrConstant.primaryColor),
                                    borderRadius:
                                        BorderRadius.circular(width * 0.05)),
                                labelText: "City :",
                                labelStyle:
                                    TextStyle(color: ClrConstant.blackColor),
                                suffixIcon: Icon(Icons.location_on),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        setState(() {});
                        final userModel = await signUp(
                            emailController.text,
                            passwordController.text,
                            nameController.text,
                            selectedCategory ?? "",
                            phoneController.text,
                            cityController.text);

                        if (userModel != null) {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BottomNavigationPage(),
                              ));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text("Signup Failed")));
                        }
                      },
                      child: Container(
                        height: height * 0.04,
                        width: width * 0.4,
                        decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color:
                                      ClrConstant.blackColor.withOpacity(0.2),
                                  spreadRadius: width * 0.003,
                                  blurRadius: width * 0.03,
                                  offset: Offset(0, 12))
                            ],
                            color: ClrConstant.primaryColor.withOpacity(0.75),
                            borderRadius:
                                BorderRadiusDirectional.circular(width * 0.1)),
                        child: Center(
                          child: Text(
                            "Sign Up",
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: ClrConstant.blackColor,
                                fontSize: width * 0.04),
                          ),
                        ),
                      ),
                    ),
                  ],
                )),
            Padding(
              padding: EdgeInsets.only(bottom: height * 0.02),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Already have an account? ",
                    style: TextStyle(fontSize: width * 0.03),
                  ),
                  GestureDetector(
                    onTap: widget.showLoginPage,
                    child: Text(
                      "LOGIN",
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: width * 0.03),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
