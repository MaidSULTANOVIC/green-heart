import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/models/Ingredients.dart';
import 'package:green_heart/models/Instructions.dart';
import 'package:http/http.dart' as http;

class RecipeController extends GetxController {
  Future<Ingredients> _futureIngredients;
  Future<Instructions> _futureInstructions;

  Future<Ingredients> get futureIngredients => this._futureIngredients;
  Future<Instructions> get futureInstructions => this._futureInstructions;

  @override
  void onInit() {
    super.onInit();
  }

  void initFuture(int id) {
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
      throw Exception('Failed to load Recipe' + response.reasonPhrase);
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
      throw Exception('Failed to load Recipe' + response.reasonPhrase);
    }
  }
}
