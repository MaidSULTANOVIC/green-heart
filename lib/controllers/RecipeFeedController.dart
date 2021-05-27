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

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  int age = -1;
  String gender = "";
  int awakeTimeHour = -1;
  int awakeTimeMinute = -1;
  int mealFrequency = -1;
  int mealEaten = 0;
  bool exists = false;

  Duration differenceTime;

  @override
  void onInit() {
    FirebaseAuth.instance.authStateChanges().listen((User user) async {
      if (user == null) {
        Get.off(() => LoginView());
      } else {}
    });

    super.onInit();
  }

  void onInitChange() {
    _healthDataList.clear();
    _healthProfileList.clear();
    mealEaten = 0;
    mealFrequency = 0;
    getUserData();
  }

  void disconnect() {
    FirebaseAuth.instance.signOut();
  }

  Future<void> getUserData() {
    //Get username of the user
    _username.value = FirebaseAuth.instance.currentUser.displayName;

    firestore
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("dailyGoalHistory")
        .where('date',
            isEqualTo: DateTime(
                DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .get()
        .then((value) {
      if (value.docs.isNotEmpty) {
        exists = true;
      }
    });

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

    // The type of data that we wants to retrieve from Google Fit
    List<HealthDataType> types = [
      HealthDataType.ACTIVE_ENERGY_BURNED,
    ];

    List<HealthDataType> typesProfile = [
      HealthDataType.WEIGHT,
      HealthDataType.HEIGHT,
    ];

    //TODO : ask user if he is awake and take this date to start retrieving data (calories)

    // Take the period between the time the user wake up and the time now to retrieve all the data of the day
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

        //If it's a height or weight, we save them
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

        // Then, the calories allowed are calculated and when the function is over, we fetch data from API to receive all the meals
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
    // Formula
    double mb = 13.707 * weight +
        492.3 * height -
        6.673 * age +
        (gender == "male" ? 667.051 : 77.607);

    // Minus 500 to lose weight
    mb -= 500;

    // The normal calories burnt when the user is not in physical activity
    int interval = (differenceTime.inMinutes / 30).round();
    interval *= 31;
    double result = 0;
    double finalResult;

    // we retrieve the meals that he already ate
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
      //For every meal that he already ate today, we store the calories number and increase the variable mealEaten
      value.docs.forEach((element) {
        result += element
            .data()
            .entries
            .firstWhere((element) => element.key == "meal")
            .value['nutrition']['nutrients'][0]['amount'];

        mealEaten++;
      });

      print("already eaten calories" + result.toString());
      print("mb 1 : $mb");
      //If the user did sports or physical activity, the caloriesBurned will be higher than the usual calories when you dont do sports
      mb += (caloriesBurned - interval);
      double calorieGoal = mb;
      saveCalorieGoal(calorieGoal);
      print("mb 2 : $mb");
      //The meals already eaten
      mb -= result;
      print("Meal eaten today : $mealEaten ");
      print("mb 3 : $mb  et frequency $mealFrequency");
      finalResult = mb /
          ((mealFrequency - mealEaten) == 0 ? 1 : (mealFrequency - mealEaten));
    });

    return finalResult;
  }

  void saveCalorieGoal(double calorie) {
    firestore
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .update({'dailyGoal': calorie});

    if (!exists) {
      firestore
          .collection("all_users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("dailyGoalHistory")
          .add({
        'date': DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day),
        'dailyGoal': calorie,
      });

      firestore
          .collection("all_users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .update({'co2Saved': FieldValue.increment(2.03)});
    } else {
      firestore
          .collection("all_users")
          .doc(FirebaseAuth.instance.currentUser.uid)
          .collection("dailyGoalHistory")
          .where('date',
              isEqualTo: DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day))
          .get()
          .then((value) {
        value.docs.forEach((element) {
          element.reference.update({'dailyGoal': calorie});
        });
      });
    }
  }
}
