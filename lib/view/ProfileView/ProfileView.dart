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
import 'package:numberpicker/numberpicker.dart';

class ProfileView extends StatefulWidget {
  @override
  _ProfileViewState createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  ProfileController controller = Get.put(ProfileController());

  @override
  void initState() {
    controller.retrieveData();
    super.initState();
  }

  User user = FirebaseAuth.instance.currentUser;

  void _changeTime() {
    showDialog(
      context: context,
      builder: (BuildContext context) => changeTime(context),
    );
  }

  Widget changeTime(BuildContext context) {
    int _value = 1;

    return AlertDialog(
      title: const Text('Select your awake time'),
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Obx(() => Row(
                  children: [
                    Column(children: [
                      Text("Hour"),
                      NumberPicker(
                        selectedTextStyle:
                            TextStyle(color: Colors.green[400], fontSize: 25.0),
                        value: controller.awakeHour.value,
                        minValue: 0,
                        maxValue: 23,
                        onChanged: (value) =>
                            controller.awakeHour.value = value,
                      ),
                    ]),
                    Column(children: [
                      Text("Minute"),
                      NumberPicker(
                        selectedTextStyle:
                            TextStyle(color: Colors.green[400], fontSize: 25.0),
                        value: controller.awakeMinute.value,
                        minValue: 0,
                        maxValue: 59,
                        onChanged: (value) =>
                            controller.awakeMinute.value = value,
                      ),
                    ])
                  ],
                ))
          ],
        );
      }),
      actions: <Widget>[
        new TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel', style: TextStyle(color: Colors.black)),
        ),
        new TextButton(
          child: Text("Update", style: TextStyle(color: Colors.black)),
          onPressed: controller.updateAwakeTime,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            //container for the profile picture and name
            Container(
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
                        style: TextStyle(fontSize: 20.0, color: Colors.black),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 50.0, 15.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.grey,
                              spreadRadius: 1)
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                height: 40.0,
                                child: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                )),
                            FutureBuilder<String>(
                                future: controller.futureGender,
                                initialData: "Loading gender ...",
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    return new Text(
                                      snapshot.data,
                                      style: TextStyle(
                                          fontSize: 15.0, color: Colors.black),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        boxShadow: [
                          BoxShadow(
                              blurRadius: 5,
                              color: Colors.grey,
                              spreadRadius: 1)
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Row(
                          children: [
                            SizedBox(
                                height: 40.0,
                                child: Icon(
                                  Icons.cake,
                                  color: Colors.black,
                                )),
                            FutureBuilder<GoogleBirthday>(
                                future: controller.futureBirthday,
                                builder: (context, snapshot) {
                                  if (snapshot.hasData) {
                                    final year = snapshot.data.year.toString();
                                    final month =
                                        snapshot.data.month.toString();
                                    final day = snapshot.data.day.toString();
                                    final date = day + "/" + month + "/" + year;
                                    return new Text(date,
                                        style: TextStyle(
                                            fontSize: 15.0,
                                            color: Colors.black));
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
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 25.0, 15.0, 0.0),
                    child: Row(
                      children: [
                        Text("Diet : ",
                            style: TextStyle(
                                fontSize: 15.0, fontWeight: FontWeight.w500)),
                        Obx(() => DropdownButton<String>(
                              value: controller.dropDownValue.value,
                              icon: const Icon(Icons.arrow_downward),
                              iconSize: 24,
                              elevation: 16,
                              style: const TextStyle(color: Colors.black87),
                              underline: Container(
                                height: 2,
                                color: Colors.black54,
                              ),
                              onChanged: (String newValue) {
                                setState(() {
                                  controller.updateDropDownSelected(newValue);
                                  controller.updateDiet(newValue);
                                });
                              },
                              items: <String>[
                                'Vegetarian',
                                'Vegan'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                            )),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(15.0, 15.0, 15.0, 0.0),
                    child: ElevatedButton(
                      onPressed: _changeTime,
                      child: Text("Change awake time",
                          style: TextStyle(color: Colors.black)),
                      style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white70)),
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
