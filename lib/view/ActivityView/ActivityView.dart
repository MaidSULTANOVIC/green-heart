import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/ActivityController.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'components/CalorieGoal.dart';

class ActivityView extends StatefulWidget {
  @override
  _ActivityViewState createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  ActivityController c = Get.put(ActivityController());

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        CalorieGoal(),
      ],
    ));
  }
}
