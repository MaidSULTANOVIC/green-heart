import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:green_heart/controllers/ActivityController.dart';

class GraphCalories extends StatelessWidget {
  GraphCalories({
    Key key,
  }) : super(key: key);

  ActivityController c = Get.find();

  List<Color> gradientColors = [
    const Color(0xff23b6e6),
    const Color(0xff02d39a),
  ];

  @override
  Widget build(BuildContext context) {
    return LineChart(sampleData1());
  }

  LineChartData sampleData1() {
    return LineChartData(
      gridData: FlGridData(
        show: true,
        drawVerticalLine: true,
        horizontalInterval: 500.0,
        getDrawingHorizontalLine: (value) {
          return FlLine(
            color: Colors.grey[400],
            strokeWidth: 1,
          );
        },
        getDrawingVerticalLine: (value) {
          return FlLine(
            color: Colors.grey[300],
            strokeWidth: 1,
          );
        },
      ),
      titlesData: FlTitlesData(
        show: true,
        bottomTitles: SideTitles(
          showTitles: true,
          reservedSize: 22,
          getTextStyles: (value) => const TextStyle(
              color: Color(0xff68737d),
              fontWeight: FontWeight.bold,
              fontSize: 12),
          getTitles: (value) {
            switch (value.toInt()) {
              case 0:
                return '3 Month Ago';
              case 4:
                return '2 Month Ago';
              case 8:
                return '1 Month Ago';
              case 11:
                return 'Now';
            }
            return '';
          },
          margin: 8,
        ),
        leftTitles: SideTitles(
          showTitles: true,
          getTextStyles: (value) => const TextStyle(
            color: Color(0xff67727d),
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
          getTitles: (value) {
            switch (value.toInt()) {
              case 500:
                return '500 kCal';
              case 1500:
                return '1500kCal';
              case 2500:
                return '2500kCal';
            }
            return '';
          },
          reservedSize: 28,
          margin: 12,
        ),
      ),
      borderData: FlBorderData(
          show: true,
          border: Border.all(color: const Color(0xff37434d), width: 2)),
      minX: 0,
      maxX: 11,
      minY: 0,
      maxY: 3000,
      lineBarsData: [
        LineChartBarData(
          spots: c.listCalories.value.cast<FlSpot>(),
          isCurved: false,
          colors: gradientColors,
          barWidth: 5,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
          ),
          belowBarData: BarAreaData(
            show: true,
            colors:
                gradientColors.map((color) => color.withOpacity(0.3)).toList(),
          ),
        ),
      ],
    );
  }
}
