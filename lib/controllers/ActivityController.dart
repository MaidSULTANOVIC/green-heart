import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

class ActivityController extends GetxController {
  RxInt _calorieGoal = 0.obs;
  RxInt get calorieGoal => this._calorieGoal;

  double _calorieEaten = 0.0;
  RxDouble _percentageCalorie = 0.0.obs;
  RxDouble get percentageCalorie => this._percentageCalorie;

  int awakeTimeHour = 0;
  int awakeTimeMinute = 0;

  @override
  void onInit() {
    super.onInit();
  }

  void initOnChange() {
    _percentageCalorie.value = 0.0;
    _calorieEaten = 0.0;
    _calorieGoal.value = 0;
    getCalorieGoal();
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
}
