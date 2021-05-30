import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/AuthController.dart';
import 'package:green_heart/view/HomePage.dart';
import 'package:green_heart/view/Register/RegisterView.dart';

import 'components/button.dart';
import 'components/fields.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);

  // Controller to being able to retrive the value inside TextField
  final emailAuth = TextEditingController();
  final passwordAuth = TextEditingController();

  // Auth controller to be able to login or register a user
  AuthenticationController c = Get.put(AuthenticationController());

  @override
  Widget build(BuildContext context) {
    User firebaseUser = FirebaseAuth.instance.currentUser;

    // We check if a user is connected, if it is connected, we redirect him to the HomePage
    if (firebaseUser != null) {
      return HomePageView();
    } else {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Container(
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(36.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Image.asset(
                    "assets/logo.png",
                    scale: 1.5,
                  ),
                  TextButton(
                      onPressed: () {
                        c.signInWithGoogle2();
                      },
                      child: Image.asset(
                        "assets/google_signin_light.png",
                        scale: 1.7,
                      )),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
