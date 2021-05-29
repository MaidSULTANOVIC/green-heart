import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/color.dart';
import 'package:green_heart/controllers/ProfileController.dart';
import 'package:green_heart/models/GoogleBirthday.dart';
import 'package:green_heart/view/RecipeFeed/components/RecipeCard.dart';

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

  User user = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 10, color: Colors.grey, spreadRadius: 1)
                  ],
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [celadon, blizzardBlue],
                  )),
              child: Container(
                width: double.infinity,
                height: 200.0,
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.black87,
                                spreadRadius: 1)
                          ],
                        ),
                        child: CircleAvatar(
                          backgroundImage: NetworkImage(user.photoURL),
                          radius: 60.0,
                        ),
                      ),
                      SizedBox(
                        height: 10.0,
                      ),
                      Text(
                        user.displayName,
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.grey,
                                spreadRadius: 1)
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [celadon, blizzardBlue],
                          )),
                      child: Row(
                        children: [
                          SizedBox(
                              height: 40.0,
                              child: Icon(
                                Icons.person,
                                color: Colors.white,
                              )),
                          FutureBuilder<String>(
                              future: controller.futureGender,
                              initialData: "Loading gender ...",
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  return new Text(
                                    snapshot.data,
                                    style: TextStyle(
                                        fontSize: 20.0, color: Colors.white),
                                  );
                                } else if (snapshot.hasError) {
                                  return SafeArea(
                                      child: Text("${snapshot.error}"));
                                }
                                return CircularProgressIndicator();
                              }),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                                blurRadius: 10,
                                color: Colors.grey,
                                spreadRadius: 1)
                          ],
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [celadon, blizzardBlue],
                          )),
                      child: Row(
                        children: [
                          SizedBox(
                              height: 40.0,
                              child: Icon(
                                Icons.cake,
                                color: Colors.white,
                              )),
                          FutureBuilder<GoogleBirthday>(
                              future: controller.futureBirthday,
                              builder: (context, snapshot) {
                                if (snapshot.hasData) {
                                  final year = snapshot.data.year.toString();
                                  final month = snapshot.data.month.toString();
                                  final day = snapshot.data.day.toString();
                                  final date = year + "/" + month + "/" + day;
                                  return new Text(date,
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.white));
                                } else if (snapshot.hasError) {
                                  return SafeArea(
                                      child: Text("${snapshot.error}"));
                                }
                                return CircularProgressIndicator();
                              })
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            FutureBuilder<QuerySnapshot>(
              future: controller.futureFavourite,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  List<DocumentSnapshot> documents = snapshot.data.docs;
                  List<dynamic> documentsMeal = List<dynamic>();
                  documents.forEach((element) {
                    documentsMeal.add(element['meal']);
                  });
                  return ListView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemCount: documents.length,
                      itemBuilder: (context, index) {
                        return recipeCard(documentsMeal, index);
                      });
                } else if (snapshot.hasError) {
                  return Text("Error " + snapshot.error.toString());
                }
                return CircularProgressIndicator();
              },
            )
          ],
        ),
      ),
    );
  }
}
