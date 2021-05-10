import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/AuthController.dart';
import 'package:green_heart/view/Register/RegisterView.dart';

Material registerButton(TextStyle style, BuildContext context, String emailAuth,
    String passwordAuth) {
  AuthenticationController c = Get.find();
  return Material(
    elevation: 5.0,
    borderRadius: BorderRadius.circular(30.0),
    color: Color(0xFFF7980D),
    child: MaterialButton(
      minWidth: MediaQuery.of(context).size.width,
      padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
      onPressed: () async {
        c.register(emailAuth, passwordAuth);
      },
      child: Text("Register",
          textAlign: TextAlign.center,
          style:
              style.copyWith(color: Colors.white, fontWeight: FontWeight.bold)),
    ),
  );
}
