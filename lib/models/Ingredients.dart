import 'package:flutter/material.dart';

class Ingredients {
  final List<dynamic> ingredients;

  Ingredients({@required this.ingredients});

  factory Ingredients.fromJson(Map<String, dynamic> json) {
    return Ingredients(
      ingredients: json['ingredients'],
    );
  }
}
