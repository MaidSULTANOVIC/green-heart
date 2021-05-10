import 'package:flutter/material.dart';

TextField emailField(TextEditingController emailAuth, TextStyle style) {
  return TextField(
    cursorColor: Color(0xFF36DC55),
    controller: emailAuth,
    obscureText: false,
    style: style,
    decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(15.0)),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Email",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0))),
  );
}

TextField passwordField(TextEditingController passwordAuth, TextStyle style) {
  return TextField(
    cursorColor: Color(0xFF36DC55),
    controller: passwordAuth,
    obscureText: true,
    style: style,
    decoration: InputDecoration(
        fillColor: Colors.white,
        filled: true,
        focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.red),
            borderRadius: BorderRadius.circular(15.0)),
        contentPadding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 15.0),
        hintText: "Password",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15.0))),
  );
}
