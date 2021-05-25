import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/SettingsController.dart';

class SettingsView extends StatefulWidget {
  @override
  _SettingsViewState createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  SettingsController c = Get.put(SettingsController());

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        Text("SettingsView"),
        FlatButton(onPressed: () => c.disconnect(), child: Text("logout temp")),
      ],
    ));
  }
}
