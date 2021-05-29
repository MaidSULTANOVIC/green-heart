import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:green_heart/models/GoogleBirthday.dart';
import 'package:green_heart/services/age.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileController extends GetxController {
  Future<String> _futureGender;
  Future<String> get futureGender => this._futureGender;

  Future<GoogleBirthday> _futureBirthday;
  Future<GoogleBirthday> get futureBirthday => this._futureBirthday;

  Future<QuerySnapshot> _futureFavourite;
  Future<QuerySnapshot> get futureFavourite => this._futureFavourite;

  int _age = 0;
  String _gender = "";

  CollectionReference tableFavorite = FirebaseFirestore.instance
      .collection("all_users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("likedRecipes");

  DocumentReference documentReference = FirebaseFirestore.instance
      .collection("all_users")
      .doc(FirebaseAuth.instance.currentUser.uid);

  @override
  void onInit() {
    _futureGender = getGender();
    _futureBirthday = getBirthday();
    updateInfo();
    _futureFavourite = getFavourite();
    super.onInit();
  }

  Future<void> updateInfo() async {
    //Wait for future to completes then set value into variables
    await _futureGender.then((value) => _gender = value);
    await _futureBirthday
        .then((value) => _age = getAge(value.year, value.month, value.day));

    //Update database
    if (_age != 0 && _gender != "") {
      documentReference.update({"age": _age, "gender": _gender});
    }
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      "https://www.googleapis.com/auth/user.birthday.read",
      "https://www.googleapis.com/auth/user.gender.read"
    ],
  );

  Future<String> getGender() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final headers = await googleUser.authHeaders;
    final response = await http.get(
        Uri.parse(
            "https://people.googleapis.com/v1/people/me?personFields=genders"),
        headers: {"Authorization": headers["Authorization"]});
    final finalResponse = jsonDecode(response.body);
    return finalResponse["genders"][0]["formattedValue"];
  }

  Future<GoogleBirthday> getBirthday() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final headers = await googleUser.authHeaders;
    final response = await http.get(
        Uri.parse(
            "https://people.googleapis.com/v1/people/me?personFields=birthdays"),
        headers: {"Authorization": headers["Authorization"]});
    GoogleBirthday googleBirthday =
        GoogleBirthday.fromJson(jsonDecode(response.body));
    return googleBirthday;
  }

  Future<QuerySnapshot> getFavourite() async {
    return await FirebaseFirestore.instance
        .collection('all_users')
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection('likedRecipes')
        .get();
  }
}
