import 'package:flutter/material.dart';

class GoogleUser {
  final List<dynamic> docs;

  GoogleUser({@required this.docs});

  factory GoogleUser.fromJson(Map<String, dynamic> json) {
    return GoogleUser(
      docs: json['results'],
    );
  }
}