import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/color.dart';
import 'package:green_heart/controllers/ProfileController.dart';
import 'package:green_heart/models/GoogleBirthday.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    super.initState();
  }

  @override
  User user = FirebaseAuth.instance.currentUser;
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                boxShadow: [BoxShadow(blurRadius: 10, color: Colors.grey, spreadRadius: 1)],
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [lightGreen, lightCoral],
                )
            ),
            child: Container(
              width: double.infinity,
              height: 350.0,
              child: Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black87, spreadRadius: 1)],
                      ),
                      child: CircleAvatar(
                        backgroundImage: NetworkImage(
                            user.photoURL
                        ),
                        radius: 80.0,
                      ),
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    Text(
                      user.displayName,
                      style: TextStyle(
                          fontSize: 30.0,
                          color: Colors.white
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
              child: Column(
                children: [
                  Text("Gender"),
                  Row(
                    children: [
                      SizedBox(height: 120.0, child: Icon(Icons.person)),
                      FutureBuilder<String>(
                          future: controller.futureGender,
                          initialData: "Loading gender ...",
                          builder: (context, snapshot) {
                            return new Text(
                                snapshot.data
                            );
                          }),
                    ],
                  ),
                  Text("Birthday"),
                  Row(
                    children: [
                      SizedBox(height: 120.0, child: Icon(Icons.cake)),
                      FutureBuilder<GoogleBirthday>(
                          future: controller.futureBirthday,
                          builder: (context, snapshot) {
                            final year = snapshot.data.year.toString();
                            final month = snapshot.data.month.toString();
                            final day = snapshot.data.day.toString();
                            final date = year + "/" + month + "/" + day;
                            return new Text(
                                date
                            );
                          })
                    ],
                  )
                ],
              )

          )
        ],
      ),
    );
  }
}
