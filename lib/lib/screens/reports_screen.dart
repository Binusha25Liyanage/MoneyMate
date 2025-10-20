import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ReportsScreen extends StatelessWidget {
  final List<PieChartSectionData> spendingData = [
    PieChartSectionData(value: 35, color: Colors.redAccent, title: 'Food'),
    PieChartSectionData(value: 25, color: Colors.blueAccent, title: 'Transport'),
    PieChartSectionData(value: 20, color: Colors.greenAccent, title: 'Entertainment'),
    PieChartSectionData(value: 20, color: Colors.yellowAccent, title: 'Others'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('📊 Reports & Analytics')),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.deepPurple.shade700, Colors.deepPurple.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 6,
                )
              ],
            ),
            child: Column(
              children: [
                const Text(
                  'Spending by Category',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 250,
                  child: PieChart(
                    PieChartData(
                      sections: spendingData,
                      sectionsSpace: 4,
                      centerSpaceRadius: 40,
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView(
                    children: spendingData.map((data) {
                      return ListTile(
                        leading: CircleAvatar(backgroundColor: data.color),
                        title: Text(data.title!, style: const TextStyle(color: Colors.white)),
                        trailing: Text('${data.value.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.white70)),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
