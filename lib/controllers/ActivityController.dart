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

      //Then we update ui
      updateProgressBar();
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
    });
  }

  Future<void> updateCaloriesList() async {
    DateTime now = DateTime.now();

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
        listCalories.add(new FlSpot(0, tempCal.roundToDouble() / nb));
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
        listCalories.add(new FlSpot(4, tempCal.roundToDouble() / nb));
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
        listCalories.add(new FlSpot(8, tempCal.roundToDouble() / nb));
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
        listCalories.add(new FlSpot(11, tempCal.roundToDouble() / nb));
      }
    });
  }

  Future<void> updateGoalList() async {
    DateTime now = DateTime.now();

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
        listGoal.add(new FlSpot(0, tempCal.roundToDouble() / nb));
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
        listGoal.add(new FlSpot(4, tempCal.roundToDouble() / nb));
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
        listGoal.add(new FlSpot(8, tempCal.roundToDouble() / nb));
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
        listGoal.add(new FlSpot(11, tempCal.roundToDouble() / nb));
      }
    });
  }

  void switchGraph() {
    if (_graphSelect.value == false) {
      _graphSelect.value = true;
    } else {
      _graphSelect.value = false;
    }
  }
}
