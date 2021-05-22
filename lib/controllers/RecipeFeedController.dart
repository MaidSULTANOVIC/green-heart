import 'dart:convert';
import 'dart:io';

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
    fetchHealthData();

    // Delete this line when implemented in fetchHealthData
    _futureRecipe = fetchRecipe();

    super.onInit();
  }

  void disconnect() {
    FirebaseAuth.instance.signOut();
  }

  Future<Recipe> fetchRecipe() async {
    // TODO : Change min and max calories in relation with the calculated calories available for the user -> In variable
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

  Future<void> fetchHealthData() async {
    // TODO If we have time : add waiting animtion with something like "We are calculating the best meals for you" with nice icon

    HealthFactory health = HealthFactory();

    // The type of data that we wants to retrieve from Google Fit / Apple Health
    // ! The active energy burned retrieve calories also when we are "afk" and not doing sports
    List<HealthDataType> types = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    //Take the last data from 1 day
    //TODO CHange the duration, take from the morning until now or something else /!\ To discuss with group
    DateTime startDate = DateTime.now().subtract(Duration(days: 1));
    DateTime endDate = DateTime.now();

    List<HealthDataPoint> healthDataList = List<HealthDataPoint>();

    // Check if we have authorization to retrieve data from Google Fit or Apple Health if no, we ask them
    await health.requestAuthorization(types).then((isAuthorized) async {
      if (isAuthorized) {
        try {
          /// Fetch new data
          List<HealthDataPoint> healthData =
              await health.getHealthDataFromTypes(startDate, endDate, types);

          /// Save all the new data points
          _healthDataList.addAll(healthData);
        } catch (e) {
          print("Caught exception in getHealthDataFromTypes: $e");
        }
        double activeEnergy = 0.0;

        /// Filter out duplicates
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);

        /// Print the results
        _healthDataList.forEach((x) {
          print(
              "Data type: ${x.typeString} value : ${x.value}  ||  Unit string : ${x.unitString} || From ${x.dateFrom} to ${x.dateTo}");
          if (x.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            activeEnergy += x.value;
          }
        });

        print("Calories burned: $activeEnergy");

        // TODO : Call the function to fetch recipes API but before that calculate the calories allowed to it for this recipe

      } else {
        print("NOT AUTHORIZED");
      }
    });
  }

  double calculateCalories() {
    // TODO Implements calculations with formula + data retrieved + with user choice (lose weight a lot or not or just maintain weight)
    return 0.0;
  }
}
