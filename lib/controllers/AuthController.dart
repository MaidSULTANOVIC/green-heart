import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:green_heart/models/GoogleBirthday.dart';
import 'package:green_heart/services/age.dart';
import 'package:green_heart/view/HomePage.dart';
import 'package:http/http.dart' as http;

class AuthenticationController extends GetxController {
  GoogleSignInAccount googleUser;

  void login(String emailAuth, String passwordAuth) async {
    try {
      print(emailAuth + "//" + passwordAuth);
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: emailAuth, password: passwordAuth)
          .then((value) => Get.off(() => HomePageView()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }

  Future<void> register(String emailAuth, String passwordAuth) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
              email: emailAuth, password: passwordAuth)
          .then((value) => Get.off(() => HomePageView()));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        print('The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        print('The account already exists for that email.');
      }
    } catch (e) {
      print(e);
    }
  }

  Future<void> signInWithGoogle2() async {
    // Trigger the authentication flow
    googleUser = await GoogleSignIn().signIn();
    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    print("ouiici");
    // Once signed in, return the UserCredential
    FirebaseAuth.instance.signInWithCredential(credential).then((value) {
      checkUserFirebase();
      googleUser.authHeaders
          .then((value) => print("AUTH HEADER : " + value.values.first));
    });
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      "https://www.googleapis.com/auth/user.birthday.read",
      "https://www.googleapis.com/auth/user.gender.read"
    ],
  );

  Future<String> getGender() async {
    final headers = await googleUser.authHeaders;
    final response = await http.get(
        Uri.parse(
            "https://people.googleapis.com/v1/people/me?personFields=genders"),
        headers: {"Authorization": headers["Authorization"]});
    final finalResponse = jsonDecode(response.body);
    return finalResponse["genders"][0]["formattedValue"];
  }

  Future<int> getBirthday() async {
    final headers = await googleUser.authHeaders;
    final response = await http.get(
        Uri.parse(
            "https://people.googleapis.com/v1/people/me?personFields=birthdays"),
        headers: {"Authorization": headers["Authorization"]});
    GoogleBirthday googleBirthday =
        GoogleBirthday.fromJson(jsonDecode(response.body));
    return getAge(
        googleBirthday.year, googleBirthday.month, googleBirthday.day);
  }

/**
 * If the user is a first time user, it will add a new document for him with his data, if he's already in the collection, nothing is done
 */
  Future<void> checkUserFirebase() async {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    int age = 18;
    String gender = "Male";

    await getBirthday().then((value) => age = value);
    await getGender().then((value) => gender = value);

    //If the user doesn't exist in database, we create a new document for him with his user id and add default values
    firestore
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      if (!value.exists) {
        firestore
            .collection("all_users")
            .doc(FirebaseAuth.instance.currentUser.uid)
            .set({
          'age': age,
          'awakeTimeHour': 7,
          'awakeTimeMinute': 30,
          'mealFrequency': 3,
          'gender': gender,
          'calorieGoal': 1800.0,
          'mealEaten': 0,
          'goalAchieved': 0,
          'co2Saved': 0.0,
          'isUpdated': DateTime.now().subtract(Duration(hours: 24)),
        }, SetOptions(merge: true));
      } //Then, redirect the user to Home Page
    }).then((value) => Get.off(() => HomePageView()));
  }
}
