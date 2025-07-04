import 'package:flutter/material.dart';
import 'package:cashnetic_pie_chart/cashnetic_pie_chart.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Pie Chart Example')),
        body: Center(
          child: CashneticPieChart(
            sections: [
              CashneticPieChartSection(
                value: 40,
                label: 'A',
                color: Colors.blue,
              ),
              CashneticPieChartSection(
                value: 30,
                label: 'B',
                color: Colors.red,
              ),
              CashneticPieChartSection(
                value: 30,
                label: 'C',
                color: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
