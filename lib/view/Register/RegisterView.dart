import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/AuthController.dart';
import 'package:green_heart/view/Register/components/button.dart';

import 'components/fields.dart';

class RegisterView extends StatefulWidget {
  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  TextStyle style = TextStyle(fontFamily: 'Montserrat', fontSize: 20.0);
  TextStyle get getStyle => style;

  bool initMealCat = false;
  AuthenticationController c = Get.put(AuthenticationController());
  final emailAuth = TextEditingController();
  final passwordAuth = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(36.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 120.0, child: Icon(Icons.ac_unit_outlined)),
                  SizedBox(height: 45.0),
                  emailField(emailAuth, style),
                  SizedBox(height: 25.0),
                  passwordField(passwordAuth, style),
                  SizedBox(
                    height: 35.0,
                  ),
                  registerButton(
                      style, context, emailAuth.text, passwordAuth.text),
                  SizedBox(
                    height: 15.0,
                  ),
                  TextButton(
                    child: Text("Login",
                        style: TextStyle(color: Color(0xFFF7980D))),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
