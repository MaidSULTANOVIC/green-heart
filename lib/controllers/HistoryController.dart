import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:green_heart/view/Login/LoginView.dart';

class HistoryController extends GetxController {
  Stream<QuerySnapshot> _futureHistory;
  Stream<QuerySnapshot> get futureHistory => this._futureHistory;

  @override
  void onInit() {
    _futureHistory = getHistory();
    super.onInit();
  }

  //Retrieve all the recipes eaten by the user, ordered by the date
  Stream<QuerySnapshot> getHistory() {
    return FirebaseFirestore.instance
        .collection("all_users")
        .doc(FirebaseAuth.instance.currentUser.uid)
        .collection("eatHistory")
        .orderBy('date', descending: true)
        .snapshots();
  }
}
