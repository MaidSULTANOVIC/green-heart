import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/color.dart';
import 'package:green_heart/controllers/ProfileController.dart';

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
                    FutureBuilder<String>(
                        future: controller.futureGender,
                        initialData: "Loading gender ...",
                        builder: (context, snapshot) {
                          return new Text(
                              snapshot.data
                          );
                        }),
                    // FutureBuilder<String>(
                    //     future: controller.futureBirthday,
                    //     initialData: "Loading birthday ...",
                    //     builder: (context, snapshot) {
                    //       return new Text(
                    //           snapshot.data
                    //       );
                    //     })
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
