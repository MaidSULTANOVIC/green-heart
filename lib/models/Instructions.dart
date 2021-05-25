import 'package:flutter/material.dart';

class Instructions {
  final List<dynamic> instructions;

  Instructions({@required this.instructions});

  factory Instructions.fromJson(List<dynamic> json) {
    try {
      return Instructions(
        instructions: json.first["steps"],
      );
    } catch (E) {
      return Instructions(instructions: new List.empty());
    }
  }
}
