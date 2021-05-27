import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';

class ActivityController extends GetxController {
  RxInt _calorieGoal = 0.obs;
  RxInt get calorieGoal => this._calorieGoal;

  double _calorieEaten = 0.0;
  RxDouble _percentageCalorie = 0.0.obs;
  RxDouble get percentageCalorie => this._percentageCalorie;

  RxDouble _co2Saved = 0.0.obs;
  RxDouble get co2Saved => this._co2Saved;

  RxString _goalIndex = "0".obs;
  RxString get goalIndex => this._goalIndex;

  RxString _mealIndex = "0".obs;
  RxString get mealIndex => this._mealIndex;

  RxString _co2Index = "0".obs;
  RxString get co2Index => this._co2Index;

  int _mealEaten;

  int _goalAchieved;
  DateTime _isUpdated;

  final listCalories = [].obs;
  final listGoal = [].obs;

  int awakeTimeHour = 0;
  int awakeTimeMinute = 0;

  RxBool _graphSelect = false.obs;
  RxBool get graphSelect => this._graphSelect;

  @override
  void onInit() {
    super.onInit();
  }

  void initOnChange() {
    _percentageCalorie.value = 0.0;
    _calorieEaten = 0.0;
    _calorieGoal.value = 0;
    listCalories.value = [];
    listGoal.value = [];
    getCalorieGoal();
    updateCaloriesList();
    updateGoalList();
  }

  void getCalorieGoal() {
    //We retrieve data from the database for the user, we get his calorie goal and his awake time
    FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .get()
        .then((value) {
      Iterable<MapEntry<String, dynamic>> values = value.data().entries;

      _calorieGoal.value = values
          .firstWhere((element) => element.key == "dailyGoal")
          .value
          .round();

      awakeTimeHour =
          values.firstWhere((element) => element.key == "awakeTimeHour").value;
      awakeTimeMinute = values
          .firstWhere((element) => element.key == "awakeTimeMinute")
          .value;
      _co2Saved.value =
          values.firstWhere((element) => element.key == "co2Saved").value;
      _mealEaten =
          values.firstWhere((element) => element.key == "mealEaten").value;
      _goalAchieved =
          values.firstWhere((element) => element.key == "goalAchieved").value;
      _isUpdated = values
          .firstWhere((element) => element.key == "isUpdated")
          .value
          .toDate();

      print("${_isUpdated.day} DATEE");

      //Then we update ui
      updateProgressBar();
      updateAchievements();
    });
  }

  void updateProgressBar() {
    // we retrieve the meals that he already ate
    FirebaseFirestore.instance
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
        _calorieEaten += element
            .data()
            .entries
            .firstWhere((element) => element.key == "meal")
            .value['nutrition']['nutrients'][0]['amount'];
      });

      //Then, the percentage of the progress bar is updated
      _percentageCalorie.value = _calorieEaten / _calorieGoal.value;

      //If the user has 90% or more of the daily goal, it will be counted as achieved

      if (_percentageCalorie.value >= 0.9) {
        DateTime today = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        if (_isUpdated.year != today.year ||
            _isUpdated.month != today.month ||
            _isUpdated.day != today.day) {
          //Update database field
          FirebaseFirestore.instance
              .collection("all_users")
              .doc(FirebaseAuth.instance.currentUser.uid)
              .update({
            'isUpdated': DateTime.now(),
            'goalAchieved': FieldValue.increment(1)
          });
        }
      }
    });
  }

  Future<void> updateCaloriesList() async {
    DateTime now = DateTime.now();

    // For each Month, we take every meal eaten within this month and we sum its calories, then, we make the average of the meals's calories
    // And we add a new FlSpot in the array that will be shown on the graph/chart

    //Three month ago
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("eatHistory")
        .where('date',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month - 3, 0))
        .where('date', isLessThan: DateTime(now.year, now.month - 2, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "meal")
            .value['nutrition']['nutrients'][0]['amount'];
        nb++;
      });
      print("THREE MONTH");
      if (nb == 0.0) {
        listCalories.add(new FlSpot(0, 0));
      } else {
        listCalories
            .add(new FlSpot(0, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });

    //Two month ago
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("eatHistory")
        .where('date',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month - 2, 0))
        .where('date', isLessThan: DateTime(now.year, now.month - 1, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "meal")
            .value['nutrition']['nutrients'][0]['amount'];
        nb++;
      });

      print("TWO MONTH");
      if (nb == 0.0) {
        listCalories.add(new FlSpot(4, 0));
      } else {
        listCalories
            .add(new FlSpot(4, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });

    //One month ago
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("eatHistory")
        .where('date',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month - 1, 0))
        .where('date', isLessThan: DateTime(now.year, now.month, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "meal")
            .value['nutrition']['nutrients'][0]['amount'];
        nb++;
      });

      print("ONE MONTH");
      if (nb == 0.0) {
        listCalories.add(new FlSpot(8, 0));
      } else {
        listCalories
            .add(new FlSpot(8, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });

    //This month
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("eatHistory")
        .where('date', isGreaterThanOrEqualTo: DateTime(now.year, now.month, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "meal")
            .value['nutrition']['nutrients'][0]['amount'];
        nb = nb + 1;
      });
      print("THIS MONTH");

      if (nb == 0.0) {
        listCalories.add(new FlSpot(11, 0));
      } else {
        listCalories.add(
            new FlSpot(11, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });
  }

  Future<void> updateGoalList() async {
    DateTime now = DateTime.now();

    // For each Month, we take every meal goal within this month and we sum its calories, then, we make the average of the goals's calories
    // And we add a new FlSpot in the array that will be shown on the graph/chart

    //Three month ago
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("dailyGoalHistory")
        .where('date',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month - 3, 0))
        .where('date', isLessThan: DateTime(now.year, now.month - 2, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "dailyGoal")
            .value;
        nb++;
      });
      print("THREE MONTH");
      if (nb == 0.0) {
        listGoal.add(new FlSpot(0, 0));
      } else {
        listGoal
            .add(new FlSpot(0, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });

    //Two month ago
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("dailyGoalHistory")
        .where('date',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month - 2, 0))
        .where('date', isLessThan: DateTime(now.year, now.month - 1, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "dailyGoal")
            .value;
        nb++;
      });

      print("TWO MONTH");
      if (nb == 0.0) {
        listGoal.add(new FlSpot(4, 0));
      } else {
        listGoal
            .add(new FlSpot(4, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });

    //One month ago
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("dailyGoalHistory")
        .where('date',
            isGreaterThanOrEqualTo: DateTime(now.year, now.month - 1, 0))
        .where('date', isLessThan: DateTime(now.year, now.month, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "dailyGoal")
            .value;
        nb++;
      });

      print("ONE MONTH");
      if (nb == 0.0) {
        listGoal.add(new FlSpot(8, 0));
      } else {
        listGoal
            .add(new FlSpot(8, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });

    //This month
    await FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("dailyGoalHistory")
        .where('date', isGreaterThanOrEqualTo: DateTime(now.year, now.month, 0))
        .get()
        .then((value) {
      double tempCal = 0.0;
      double nb = 0.0;
      value.docs.forEach((element) {
        tempCal += element
            .data()
            .entries
            .firstWhere((element) => element.key == "dailyGoal")
            .value;
        nb = nb + 1;
      });
      print("THIS MONTH");

      if (nb == 0.0) {
        listGoal.add(new FlSpot(11, 0));
      } else {
        listGoal.add(
            new FlSpot(11, (tempCal.roundToDouble() / nb).roundToDouble()));
      }
    });
  }

/**
 *  When clicked, this function is triggered, it switch the graph that will be shown
 */
  void switchGraph() {
    if (_graphSelect.value == false) {
      _graphSelect.value = true;
    } else {
      _graphSelect.value = false;
    }
  }

// Used to call every function that will find the image to display in relation with the user's stats
  void updateAchievements() {
    findAssetsGoal();
    findAssetsMeal();
    findAssetsCo2();
  }

  void findAssetsGoal() {
    //If the user goal achieved number is ... then select a picture to display
    if (_goalAchieved >= 500) {
      _goalIndex.value = "5";
    } else if (_goalAchieved >= 250) {
      _goalIndex.value = "4";
    } else if (_goalAchieved >= 100) {
      _goalIndex.value = "3";
    } else if (_goalAchieved >= 50) {
      _goalIndex.value = "2";
    } else if (_goalAchieved >= 10) {
      _goalIndex.value = "1";
    } else if (_goalAchieved >= 0) {
      _goalIndex.value = "0";
    }
  }

  void findAssetsMeal() {
    //If the user meal eaten number is ... then select a picture to display
    if (_mealEaten >= 1000) {
      _mealIndex.value = "5";
    } else if (_mealEaten >= 500) {
      _mealIndex.value = "4";
    } else if (_mealEaten >= 100) {
      _mealIndex.value = "3";
    } else if (_mealEaten >= 50) {
      _mealIndex.value = "2";
    } else if (_mealEaten >= 10) {
      _mealIndex.value = "1";
    } else if (_mealEaten >= 0) {
      _mealIndex.value = "0";
    }
  }

  void findAssetsCo2() {
    //If the user co2 saved number is ... then select a picture to display
    if (_co2Saved.value >= 1460) {
      _co2Index.value = "5";
    } else if (_co2Saved.value >= 730) {
      _co2Index.value = "4";
    } else if (_co2Saved.value >= 465) {
      _co2Index.value = "3";
    } else if (_co2Saved.value >= 100) {
      _co2Index.value = "2";
    } else if (_co2Saved.value >= 20) {
      _co2Index.value = "1";
    } else if (_co2Saved.value >= 0) {
      _co2Index.value = "0";
    }
  }
}
