import 'package:flutter/material.dart';

class GoogleBirthday {
  final int year;
  final int month;
  final int day;

  GoogleBirthday({
    @required this.year,
    @required this.month,
    @required this.day,
  });

  factory GoogleBirthday.fromJson(Map<String, dynamic> json) {
    return GoogleBirthday(
      year: json['birthdays'][1]['date']['year'],
      month: json['birthdays'][1]['date']['month'],
      day: json['birthdays'][1]['date']['day'],
    );
  }
}