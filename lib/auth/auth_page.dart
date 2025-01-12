import 'package:flutter/cupertino.dart';

import '../login_signup/login.dart';
import '../login_signup/signup.dart';


class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool showLoginPage = true;

  void toggling(){
    setState(() {
      showLoginPage =!showLoginPage;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return Login(showRegisterPage: toggling);
    }else{
      return Signup(showLoginPage: toggling);
    }
  }
}
