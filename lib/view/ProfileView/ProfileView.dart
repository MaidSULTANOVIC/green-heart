import 'dart:collection';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/color.dart';
import 'package:green_heart/controllers/ProfileController.dart';
import 'package:green_heart/models/GoogleBirthday.dart';
import 'components/recipeCardQuery.dart';

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
                  colors: [celadon, blizzardBlue],
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
                SizedBox(height: 40.0),
                Text("Gender"),
                Row(
                  children: [
                    SizedBox(height: 40.0, child: Icon(Icons.person)),
                    FutureBuilder<String>(
                        future: controller.futureGender,
                        initialData: "Loading gender ...",
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            return new Text(
                                snapshot.data
                            );
                          } else if (snapshot.hasError) {
                            return SafeArea(child: Text("${snapshot.error}"));
                          }
                          return CircularProgressIndicator();
                        }),
                  ],
                ),
                Text("Birthday"),
                Row(
                  children: [
                    SizedBox(height: 40.0, child: Icon(Icons.cake)),
                    FutureBuilder<GoogleBirthday>(
                        future: controller.futureBirthday,
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            final year = snapshot.data.year.toString();
                            final month = snapshot.data.month.toString();
                            final day = snapshot.data.day.toString();
                            final date = year + "/" + month + "/" + day;
                            return new Text(
                                date
                            );
                          } else if (snapshot.hasError) {
                            return SafeArea(child: Text("${snapshot.error}"));
                          }
                          return CircularProgressIndicator();
                        })
                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Column(
              children: [
                FutureBuilder<QuerySnapshot>(
                  future: controller.futureFavourite,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      final List<DocumentSnapshot> documents = snapshot.data.docs;


                      return ListView.builder(
                          physics: NeverScrollableScrollPhysics(),
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: documents.length,
                          itemBuilder: (context, index) {
                            LinkedHashMap<String, dynamic> map =
                            new LinkedHashMap<String, dynamic>();
                            map['id'] = documents[index]['meal']['id'];
                            map['title'] = documents[index]['meal']['title'];
                            map['image'] = documents[index]['meal']['image'];

                            return recipeCardQuery(
                                documents[index]['meal']['image'],
                                documents[index]['meal']['title'],
                                documents[index]['meal']['nutrition']
                                ['nutrients'][0]['amount'],
                                map);
                          });

                    } else if (snapshot.hasError) {
                      return SafeArea(child: Text("${snapshot.error}"));
                    }
                    // By default, show a loading spinner.
                    return CircularProgressIndicator();
                  },
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
