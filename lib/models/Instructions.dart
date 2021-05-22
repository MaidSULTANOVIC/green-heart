import 'package:flutter/material.dart';

class Instructions {
  final List<dynamic> instructions;

  Instructions({@required this.instructions});

  factory Instructions.fromJson(List<dynamic> json) {
    return Instructions(
      instructions: json.first["steps"],
    );
  }
}
