import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: PieChart(
        PieChartData(
          sections: [
            PieChartSectionData(
              value: 40,
              color: Colors.blue,
              title: 'Food\n40%',
              radius: 60,
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: 30,
              color: Colors.green,
              title: 'Transport\n30%',
              radius: 60,
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: 20,
              color: Colors.orange,
              title: 'Bills\n20%',
              radius: 60,
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            PieChartSectionData(
              value: 10,
              color: Colors.purple,
              title: 'Other\n10%',
              radius: 60,
              titleStyle: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
