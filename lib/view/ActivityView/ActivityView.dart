import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/ActivityController.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'components/CalorieGoal.dart';
import 'components/GraphCalories.dart';
import 'components/GraphGoal.dart';

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
        child: SingleChildScrollView(
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
              Obx(() => Text("${c.co2Saved.value} metric kg of CO2",
                  style: TextStyle(color: Colors.green[400]))),
            ],
          ),
          Container(
            height: 100.0,
            color: Colors.red,
            child: Center(child: Text(" ACHIEVEMENTS HERE")),
          ),
          SizedBox(
            height: 40.0,
          ),
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: c.graphSelect.value == true
                          ? MaterialStateProperty.all(Colors.green[400])
                          : MaterialStateProperty.all(Colors.grey[300]),
                    ),
                    child: Text("Calories"),
                    onPressed:
                        c.graphSelect.value == false ? null : c.switchGraph),
                ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: c.graphSelect.value == false
                          ? MaterialStateProperty.all(Colors.green[400])
                          : MaterialStateProperty.all(Colors.grey[300]),
                    ),
                    child: Text("Daily goal"),
                    onPressed: c.graphSelect.value ? null : c.switchGraph)
              ],
            ),
          ),
          SizedBox(height: 20.0),
          Obx(() => Text(
                c.graphSelect.value == false
                    ? "Calories consumed"
                    : "Daily goal calories",
                style: TextStyle(
                    color: Colors.green[400], fontWeight: FontWeight.w400),
              )),
          Obx(
            () => Container(
                height: 350.0,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
                  child: LineChart(
                    c.graphSelect.value == false
                        ? GraphCalories().sampleData1()
                        : GraphGoal().sampleData1(),
                  ),
                )),
          ),
        ],
      ),
    ));
  }
}
