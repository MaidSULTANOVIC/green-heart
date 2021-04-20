import 'package:flutter/material.dart';

class Recipe {
  final List<dynamic> docs;

  Recipe({@required this.docs});

  factory Recipe.fromJson(List<dynamic> json) {
    return Recipe(
      docs: json,
    );
  }
}
