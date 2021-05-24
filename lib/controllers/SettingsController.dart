import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:green_heart/view/Login/LoginView.dart';

class SettingsController extends GetxController {
  @override
  void onInit() {
    FirebaseAuth.instance.authStateChanges().listen((User user) async {
      if (user == null) {
        Get.off(() => LoginView());
      } else {}
    });
    super.onInit();
  }

  void disconnect() {
    FirebaseAuth.instance.signOut();
  }
}
