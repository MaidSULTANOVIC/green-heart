import 'package:flutter/material.dart';

class Recipe {
  final List<dynamic> docs;

  Recipe({@required this.docs});

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      docs: json['results'],
    );
  }
}
