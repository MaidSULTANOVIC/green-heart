import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/AuthController.dart';
import 'package:green_heart/view/HomePage.dart';
import 'package:green_heart/view/Register/RegisterView.dart';

import '../../color.dart';
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
                  Column(
                    children: [
                      Image.asset(
                        "assets/logo.png",
                        scale: 1.3,
                      ),
                      SizedBox(height: 15.0),
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                            text: "Eating healthy and green is ",
                            style: TextStyle(
                                fontWeight: FontWeight.w500,
                                fontSize: 28.0,
                                color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                  text: "easier",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 28.0,
                                      color: Colors.green[400])),
                              TextSpan(
                                  text: " than you think!",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 28.0,
                                  )),
                            ]),
                      ),
                      SizedBox(height: 15.0),
                      Text("Sign in will take only few seconds",
                          style: TextStyle(
                              color: Colors.black38,
                              fontWeight: FontWeight.w500))
                    ],
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
