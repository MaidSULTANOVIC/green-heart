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
  void initState() {
    c.initOnChange();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        child: Column(
      children: [
        CalorieGoal(),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Total CO2 saved:",
                style: TextStyle(fontWeight: FontWeight.w500)),
            SizedBox(
              width: 10.0,
            ),
            Text("1.04 metric tons of CO2",
                style: TextStyle(color: Colors.green[400]))
          ],
        ),
      ],
    ));
  }
}
