import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:green_heart/models/Recipe.dart';
import 'package:green_heart/view/Login/LoginView.dart';
import 'package:http/http.dart' as http;

class RecipeFeedController extends GetxController {
  Future<Recipe> _futureRecipe;

  Future<Recipe> get futureRecipe => this._futureRecipe;

  RxInt test = 0.obs;

  @override
  void onInit() {
    FirebaseAuth.instance.authStateChanges().listen((User user) async {
      if (user == null) {
        Get.off(() => LoginView());
      } else {}
    });

    _futureRecipe = fetchRecipe();
    super.onInit();
  }

  void disconnect() {
    FirebaseAuth.instance.signOut();
  }

  Future<Recipe> fetchRecipe() async {
    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/complexSearch?apiKey=ed014e6f54164d6bbc778828ad05114c&diet=vegetarian&minCalories=350&maxCalories=500&number=4'),
    );

    if (response.statusCode == 200) {
      // If the server did return a 200 OK response,
      // then parse the JSON.
      return Recipe.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      throw Exception('Failed to load Recipe' + response.reasonPhrase);
    }
  }
}
