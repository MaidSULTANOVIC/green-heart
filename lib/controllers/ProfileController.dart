import 'package:get/get_state_manager/src/simple/get_controllers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileController extends GetxController {


  @override
  void onInit() {
    _futureGender = getGender();
    _futureBirthday = getBirthday();
    super.onInit();
  }

  GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: [
      "https://www.googleapis.com/auth/user.birthday.read",
      "https://www.googleapis.com/auth/user.gender.read"
    ],
  );

  Future<String> _futureGender;
  Future<String> get futureGender => this._futureGender;

  Future<String> _futureBirthday;
  Future<String> get futureBirthday => this._futureBirthday;

  Future<String> getGender() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final headers = await googleUser.authHeaders;
    final r = await http.get(Uri.parse(
        "https://people.googleapis.com/v1/people/me?personFields=genders&key="),
        headers: {
          "Authorization": headers["Authorization"]
        }
    );
    final response = jsonDecode(r.body);
    return response["genders"][0]["formattedValue"];
  }
  Future<String> getBirthday() async {
    GoogleSignInAccount googleUser = await _googleSignIn.signIn();
    final headers = await googleUser.authHeaders;
    final r = await http.get(Uri.parse(
        "https://people.googleapis.com/v1/people/me?personFields=birthdays&key="),
        headers: {
          "Authorization": headers["Authorization"]
        }
    );
    final response = jsonDecode(r.body);
    return response["birthdays"][0]["formattedValue"];
  }
}