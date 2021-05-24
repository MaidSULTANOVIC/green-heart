import 'dart:collection';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/models/Ingredients.dart';
import 'package:green_heart/models/Instructions.dart';
import 'package:http/http.dart' as http;

class RecipeController extends GetxController {
  Future<Ingredients> _futureIngredients;
  Future<Instructions> _futureInstructions;
  RxBool _isFavorite = false.obs;

  Future<Ingredients> get futureIngredients => this._futureIngredients;
  Future<Instructions> get futureInstructions => this._futureInstructions;
  RxBool get isFavorite => this._isFavorite;

  CollectionReference table = FirebaseFirestore.instance
      .collection("all_users")
      .doc(FirebaseAuth.instance.currentUser.uid)
      .collection("likedRecipes");

  @override
  void onInit() {
    final Future<FirebaseApp> _initialization = Firebase.initializeApp();
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
    table.where("id", isEqualTo: id).get().then((value) {
      if (value != null) {
        _isFavorite.value = true;
      } else {
        _isFavorite.value = false;
      }
    });
  }

  void addFavorite(LinkedHashMap<String, dynamic> meal) {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    // If the meal is already in favorite, he will be deleted of the favorite list
    if (_isFavorite.value == true) {
      table
          .where("id", isEqualTo: meal.values.elementAt(0))
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.delete();
        });
        _isFavorite.value = false;
      });
    } else {
      // Else, if the meal is not in favorite, he will be added
      firestore
          .collection("all_users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("likedRecipes")
          .doc()
          .set({
        'id': meal.values.elementAt(0),
        'meal': meal,
      }).then((value) => _isFavorite.value = true);
    }
  }
}
