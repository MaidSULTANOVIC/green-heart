import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/ActivityController.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class CalorieGoal extends StatelessWidget {
  CalorieGoal({
    Key key,
  }) : super(key: key);

  ActivityController c = Get.find();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(15.0)),
            color: Colors.green[200]),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Align(
                  alignment: Alignment.centerLeft,
                  child:
                      Text("Calories goal", style: TextStyle(fontSize: 16.0))),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(15.0, 0, 25.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("0 kCal"),
                  Obx(() => Text("${c.calorieGoal.value} kCal"))
                ],
              ),
            ),
            Padding(
                padding: EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 15.0),
                child: Obx(
                  () => new LinearPercentIndicator(
                    width: MediaQuery.of(context).size.width - 70,
                    animation: true,
                    lineHeight: 20.0,
                    animationDuration: 2500,
                    percent: c.percentageCalorie.value > 1
                        ? 1
                        : c.percentageCalorie.value,
                    center:
                        Text("${(c.percentageCalorie.value * 100).round()}%"),
                    linearStrokeCap: LinearStrokeCap.roundAll,
                    progressColor: Colors.green,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
