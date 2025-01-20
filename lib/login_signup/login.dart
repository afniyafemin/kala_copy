import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../bottom_navigation_bar/bottom_navigation.dart';
import '../constants/color_constant.dart';
import '../constants/image_constant.dart';
import '../main.dart';
import '../services/sign_in_method.dart';
import 'google_signup.dart';
import 'otp_signup.dart';


class Login extends StatefulWidget {
  final VoidCallback showRegisterPage;
  const Login({super.key, required this.showRegisterPage});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  bool pass = true;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void handleGoogleSignIn(BuildContext context) async {
    try {
      User? user = await signInWithGoogle(context);
      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => BottomNavigationPage()),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Google Sign-In failed or was canceled.")),
        );
      }
    } catch (e) {
      print("Error during Google Sign-In: $e");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      backgroundColor: ClrConstant.whiteColor,
      body: Padding(
        padding: EdgeInsets.all(width*0.05),
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Padding(
                padding: EdgeInsets.only(top:height*0.2),
                child: Container(
                  height: height*0.8,
                  width: width*1,
                  decoration: BoxDecoration(
                    image: DecorationImage(image: AssetImage(ImgConstant.bgimage))
                  ),
                ),
              ),
              Center(
                child: Container(
                  height: height*1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Column(
                        children: [
                          Text("We Say Hello!",
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              fontSize: width*0.05
                            ),
                          ),
                          Text("Login with your email and password"),
                        ],
                      ),

                      Form(
                        // key: formKey,
                        child: Column(children: [

                          TextFormField(
                              controller: emailController,
                              autovalidateMode: AutovalidateMode
                                  .onUserInteraction,
                              validator: (value) {
                                if (value == null ||
                                    value.isEmpty) {
                                  return "please enter the username";
                                }
                              },

                              cursorColor: ClrConstant.blackColor,

                            decoration: InputDecoration(
                                labelText: "Email :",
                                labelStyle: TextStyle(
                                    color:
                                    ClrConstant.blackColor),
                                suffixIcon: Icon(Icons.person),

                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ClrConstant.blackColor,
                                  ),
                                  borderRadius: BorderRadius.circular(width*0.05)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ClrConstant.blackColor,
                                ),
                                borderRadius: BorderRadius.circular(width*0.05)
                              ),
                              filled: true,
                              fillColor: ClrConstant.primaryColor.withOpacity(0.3),
                            ),
                              keyboardType: TextInputType.emailAddress
                          ),
                          SizedBox(height: height*0.03,),
                          TextFormField(
                            controller: passwordController,
                            validator: (value) {
                              if (!RegExp(
                                  r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                  .hasMatch(value!)) {
                                return "Enter a valid password";
                              }
                            },
                            cursorColor: ClrConstant.blackColor,
                            obscuringCharacter: "*",
                            obscureText: pass ? true : false,
                            maxLength: 30,

                            decoration: InputDecoration(
                                labelText: "password :",
                                labelStyle: TextStyle(
                                    color:
                                    ClrConstant.blackColor),
                                counterText: "",
                                suffixIcon: InkWell(
                                    onTap: () {
                                      pass = !pass;
                                      setState(() {});
                                    },
                                    child: Icon(pass
                                        ? Icons.visibility_off
                                        : Icons.visibility)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: ClrConstant.blackColor,
                                  ),
                                  borderRadius: BorderRadius.circular(width*0.05)
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: ClrConstant.blackColor,
                                ),
                                borderRadius: BorderRadius.circular(width*0.05)
                              ),
                              filled: true,
                              fillColor: ClrConstant.primaryColor.withOpacity(0.3),
                            ),
                          ),
                          SizedBox(height: height*0.03,),
                          GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [Text("forgot password")],
                            ),
                          ),
                          SizedBox(height: height*0.03,),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                signIn(emailController.text, passwordController.text);
                              });
                            },
                            child: Container(
                              height: height * 0.04,
                              width: width * 0.4,
                              decoration: BoxDecoration(
                                  boxShadow: [
                                    BoxShadow(
                                        color: ClrConstant.blackColor.withOpacity(0.2),
                                        spreadRadius: width*0.003,
                                        blurRadius: width*0.03,
                                        offset: Offset(0, 12)
                                    )
                                  ],
                                  color: ClrConstant.primaryColor.withOpacity(0.75),
                                  borderRadius:
                                  BorderRadiusDirectional
                                      .circular(width * 0.1)),
                              child: Center(
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: ClrConstant.blackColor,
                                      fontSize: width * 0.04),
                                ),
                              ),
                            ),
                          ),
                        ]),
                      ),
                      Text("OR",
                        style: TextStyle(
                          fontSize: width*0.05,
                          fontWeight: FontWeight.w900,
                          color: ClrConstant.blackColor
                        ),
                      ),
                      Column(
                        children: [
                          GestureDetector(
                            onTap: () => handleGoogleSignIn(context),
                            child: Container(
                              height: height*0.05,
                              width: width*0.5,
                              decoration: BoxDecoration(
                                color: ClrConstant.primaryColor.withOpacity(0.75),
                                borderRadius: BorderRadius.circular(width*0.05),
                              ),
                              child: Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Image(image: AssetImage(ImgConstant.google),fit: BoxFit.fill,height: height*0.03,color: ClrConstant.blackColor,),
                                    Text("Sign in with Google",
                                      style: TextStyle(
                                          color: ClrConstant.blackColor,
                                          fontWeight: FontWeight.w700
                                      ),
                                    ),
                                    SizedBox()
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: height*0.015,),
                          // GestureDetector(
                          //   onTap: () {
                          //     Navigator.push(context, MaterialPageRoute(builder: (context) => OtpSignin(),));
                          //     setState(() {
                          //
                          //     });
                          //   },
                          //   child: Container(
                          //     height: height*0.05,
                          //     width: width*0.5,
                          //     decoration: BoxDecoration(
                          //       color: ClrConstant.primaryColor.withOpacity(0.75),
                          //       borderRadius: BorderRadius.circular(width*0.05),
                          //     ),
                          //     child: Center(
                          //       child: Row(
                          //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          //         children: [
                          //           Icon(Icons.phone,color: ClrConstant.blackColor,),
                          //           Text("Sign in with phone",
                          //             style: TextStyle(
                          //               color: ClrConstant.blackColor,
                          //               fontWeight: FontWeight.w700
                          //             ),
                          //           ),
                          //           SizedBox()
                          //         ],
                          //       ),
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),

                      GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Don't have an account?",
                              style: TextStyle(
                                fontSize: width * 0.03,
                              ),
                            ),
                            Text(
                              "Create New",
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: width * 0.03),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
