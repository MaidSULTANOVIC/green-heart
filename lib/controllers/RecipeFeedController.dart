import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:green_heart/models/Recipe.dart';
import 'package:green_heart/view/Login/LoginView.dart';
import 'package:http/http.dart' as http;
import "package:health/health.dart";

enum AppState {
  DATA_NOT_FETCHED,
  FETCHING_DATA,
  DATA_READY,
  NO_DATA,
  AUTH_NOT_GRANTED
}

class RecipeFeedController extends GetxController {
  Future<Recipe> _futureRecipe;

  Future<Recipe> get futureRecipe => this._futureRecipe;

  RxInt test = 0.obs;

  List<HealthDataPoint> _healthDataList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;

  @override
  void onInit() {
    FirebaseAuth.instance.authStateChanges().listen((User user) async {
      if (user == null) {
        Get.off(() => LoginView());
      } else {}
    });

    _futureRecipe = fetchRecipe();
    fetchData();
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

  Future<void> fetchData() async {
    print("CA COMMENCE");

    HealthFactory health = HealthFactory();

    List<HealthDataType> types = [
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
      HealthDataType.STEPS,
    ];

    DateTime startDate = DateTime(2021, 5, 11, 0, 0, 0);
    DateTime endDate = DateTime(2021, 5, 11, 23, 59, 59);

    List<HealthDataPoint> healthDataList = List<HealthDataPoint>();

    Future.delayed(Duration(seconds: 2), () async {
      bool isAuthorized = await health.requestAuthorization(types);
      if (isAuthorized) {
        print("AUTORISER");
      }
      print("aprezs");

      /// Do something with the health data list
      for (var healthData in healthDataList) {
        print(healthData);
      }
    });
  }
}
