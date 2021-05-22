import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:green_heart/color.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  @override
  User firebaseUser = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: paleSpringBud,
      body: Container(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Padding(
                  padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: <Widget>[
                    Text(
                        firebaseUser.displayName,
                      style: TextStyle(
                        fontFamily: 'Avenir',
                        fontSize: 44,
                        color: kombuGreen
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
