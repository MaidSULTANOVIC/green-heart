import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:green_heart/models/Ingredients.dart';
import 'package:green_heart/models/Instructions.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:http/http.dart' as http;

class RecipeController extends GetxController {
  Future<Ingredients> _futureIngredients;
  Future<Instructions> _futureInstructions;
  RxBool _isFavorite = false.obs;

  Future<Ingredients> get futureIngredients => this._futureIngredients;
  Future<Instructions> get futureInstructions => this._futureInstructions;
  RxBool get isFavorite => this._isFavorite;

  CollectionReference tableFavorite = FirebaseFirestore.instance
      .collection("all_users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("likedRecipes");

  CollectionReference tableEat = FirebaseFirestore.instance
      .collection("all_users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("eatHistory");

  @override
  void onInit() {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
    _isFavorite.value = false;
    super.onInit();
  }

  void initFuture(int id) {
    checkFavorite(id);
    _futureIngredients = fetchIngredients(id);
    _futureInstructions = fetchInstructions(id);
  }

  Future<Ingredients> fetchIngredients(int id) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/$id/ingredientWidget.json?apiKey=ed014e6f54164d6bbc778828ad05114c'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Ingredients.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Recipe $id ' + response.reasonPhrase);
    }
  }

  Future<Instructions> fetchInstructions(int id) async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/$id/analyzedInstructions?apiKey=ed014e6f54164d6bbc778828ad05114c'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Instructions.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Recipe : $id ' + response.reasonPhrase);
    }
  }

  void checkFavorite(int id) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // we check for the document with the same id field as the id of the meal, if it exists, it means that it's in the favorite list
    tableFavorite.where("id", isEqualTo: id).get().then((value) {
      if (!value.docs.isEmpty) {
        _isFavorite.value = true;
      } else {
        _isFavorite.value = false;
      }
    });
  }

  void addFavorite(LinkedHashMap<String, dynamic> meal) {
    // If the meal is already in favorite, he will be deleted of the favorite list
    if (_isFavorite.value == true) {
      tableFavorite
          .where("id",
              isEqualTo: meal.entries
                  .firstWhere((element) => element.key == "id")
                  .value)
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
        _isFavorite.value = false;
      });
    } else {
      // Else, if the meal is not in favorite, he will be added
      tableFavorite.doc().set({
        'id': meal.entries.firstWhere((element) => element.key == "id").value,
        'meal': meal,
      }).then((value) => _isFavorite.value = true);
    }
  }

  void eatMeal(LinkedHashMap<String, dynamic> meal) {
    //When the user click on "Eat this meal" button, it will add the current meal in its eaten meal history
    tableEat.add({
      'date': DateTime.now(),
      'meal': meal,
    }).then((value) {
      Fluttertoast.showToast(msg: "Meal added to your history");

      FirebaseFirestore.instance
          .collection("all_users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({'mealEaten': FieldValue.increment(1)}).onError(
              (error, stackTrace) => print("ERROR :::" + error.toString()));
    });
  }

  Future<void> sendEmail(LinkedHashMap<String, dynamic> meal) async {
    //Retrieve all the ingredients in a single String
    String ingredients = "";
    await futureIngredients.then((value) {
      value.ingredients.forEach((element) {
        ingredients += element["name"];
        ingredients += " : ";
        ingredients += element["amount"]["metric"]["value"].toString();
        ingredients += " ";
        ingredients += element["amount"]["metric"]["unit"].toString();
        ingredients += "<br>";
      });
    });

    //Retrieve all the instructions in a single String
    String instructions = "";
    await futureInstructions.then((value) {
      value.instructions.forEach((element) {
        instructions += "Step " + element['number'].toString();
        instructions += " : <br>";
        instructions += element['step'];
        instructions += "<br><br>";
      });
    });

    //Create the mail with informations of th recipe
    final MailOptions mailOptions = MailOptions(
      body: 'Hello! <br>I found a nice recipe using Green Heart, and I wanted to share it with you ! <br>' +
          '<h1>Meal : ${meal['title']}</h1><h2>Ingredients : </h2> $ingredients <br> <br> <h2>Instructions : </h2> $instructions Find a picture of the meal here : ${meal['image']}</a>',
      subject: 'I found a good recipe ! ',
      isHTML: true,
    );

    //Send it
    final MailerResponse response = await FlutterMailer.send(mailOptions);
  }
}
