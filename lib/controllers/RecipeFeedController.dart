import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:green_heart/models/Recipe.dart';
import 'package:green_heart/view/Login/LoginView.dart';
import 'package:green_heart/view/RecipeFeed/RecipeFeedView.dart';
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

  RxString _username = "".obs;
  String get username => this._username.value;

  double height = -1;
  double weight = -1;

  List<HealthDataPoint> _healthDataList = [];
  List<HealthDataPoint> _healthProfileList = [];
  AppState _state = AppState.DATA_NOT_FETCHED;

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int age = -1;
  String gender = "";
  int awakeTimeHour = -1;
  int awakeTimeMinute = -1;
  int mealFrequency = -1;

  Duration differenceTime;

  @override
  void onInit() {
    FirebaseAuth.instance.authStateChanges().listen((User user) async {
      if (user == null) {
        Get.off(() => LoginView());
      } else {}
    });

    getUserData();
    super.onInit();
  }

  void disconnect() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> getUserData() {
    //Get username of the user
    _username.value = FirebaseAuth.instance.currentUser.displayName;

    //We retrieve and store all user data
    firestore
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      Iterable<MapEntry<String, dynamic>> values = value.data().entries;

      age = values.firstWhere((element) => element.key == "age").value;
      gender = values.firstWhere((element) => element.key == "gender").value;
      awakeTimeHour =
          values.firstWhere((element) => element.key == "awakeTimeHour").value;
      awakeTimeMinute = values
          .firstWhere((element) => element.key == "awakeTimeMinute")
          .value;
      mealFrequency =
          values.firstWhere((element) => element.key == "mealFrequency").value;
    }).then((value) {
      fetchHealthData();
    });
  }

  Future<Recipe> fetchRecipe(int minCalories, int maxCalories) async {
    // TODO : Change min and max calories in relation with the calculated calories available for the user -> In variable

    // int minCalories = 350;
    // int maxCalories = 500;

    final response = await http.get(
      Uri.parse(
          'https://api.spoonacular.com/recipes/complexSearch?apiKey=ed014e6f54164d6bbc778828ad05114c&diet=vegetarian&minCalories=$minCalories&maxCalories=$maxCalories&number=4'),
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

    List<HealthDataType> typesProfile = [
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
    ];

    //TODO CHange the duration, take from the morning until now or something else /!\ To discuss with group

    //TODO : ask user if he is awake and take this date to start retrieving data (calories)
    DateTime startDate = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, awakeTimeHour, awakeTimeMinute, 0);
    DateTime endDate = DateTime.now();
    differenceTime = endDate.difference(startDate);

    List<HealthDataPoint> healthDataList = List<HealthDataPoint>();
    List<HealthDataPoint> healthProfileList = List<HealthDataPoint>();

    // Check if we have authorization to retrieve data from Google Fit or Apple Health if no, we ask them
    await health.requestAuthorization(types).then((isAuthorized) async {
      if (isAuthorized) {
        try {
          /// Fetch new data
          List<HealthDataPoint> healthData =
              await health.getHealthDataFromTypes(startDate, endDate, types);

          /// Save all the new data points
          _healthDataList.addAll(healthData);

          //-----------------------------------------------------------------------------------------

          List<HealthDataPoint> healthProfile =
              await health.getHealthDataFromTypes(
                  DateTime(2018, 5, 22, 7, 0, 0), endDate, typesProfile);

          _healthProfileList.addAll(healthProfile);
        } catch (e) {
          print("Caught exception in getHealthDataFromTypes: $e");
        }
        double activeEnergy = 0.0;

        /// Filter out duplicates
        _healthDataList = HealthFactory.removeDuplicates(_healthDataList);
        _healthProfileList = HealthFactory.removeDuplicates(_healthProfileList);

        /// Print the results
        _healthDataList.forEach((x) {
          print(
              "Data type: ${x.typeString} value : ${x.value}  ||  Unit string : ${x.unitString} || From ${x.dateFrom} to ${x.dateTo}");

          if (x.type == HealthDataType.ACTIVE_ENERGY_BURNED) {
            activeEnergy += x.value;
          }
        });

        _healthProfileList.forEach((x) {
          if (x.type == HealthDataType.HEIGHT) {
            height = x.value;
          } else if (x.type == HealthDataType.WEIGHT) {
            weight = x.value;
          }
        });

        print("Calories burned: $activeEnergy");
        print("Height : $height");
        print("Weight : $weight");

        // TODO : Call the function to fetch recipes API but before that calculate the calories allowed to it for this recipe

        calculateCalories(activeEnergy).then((value) {
          print("allowed " + value.round().toString());
          _futureRecipe = fetchRecipe((value - 100.0).round(), value.round())
              .whenComplete(() => Get.forceAppUpdate());
        });
      } else {
        print("NOT AUTHORIZED");
      }
    });
  }

  Future<double> calculateCalories(double caloriesBurned) async {
    // TODO Implements calculations with formula + data retrieved + with user choice (lose weight a lot or not or just maintain weight)
    double mb = 13.707 * weight +
        492.3 * height -
        6.673 * age +
        (gender == "male" ? 667.051 : 77.607);
    mb -= 500;

    int interval = (differenceTime.inMinutes / 30).round();
    interval *= 31;
    double result = 0;
    double finalResult;

    await firestore
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("eatHistory")
        .where("date",
            isGreaterThanOrEqualTo: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                awakeTimeHour,
                awakeTimeMinute,
                0))
        .get()
        .then((value) {
      value.docs.forEach((element) {
        result += element
            .data()
            .entries
            .firstWhere((element) => element.key == "meal")
            .value['nutrition']['nutrients'][0]['amount'];
      });
      print("already eaten calories" + result.toString());
      //If the user did sports or physical activity, the caloriesBurned will be higher than the usual calories when you dont do sports
      mb += (caloriesBurned - interval);
      print(caloriesBurned - interval);

      finalResult = mb / mealFrequency;
    });

    return finalResult;
  }
}
