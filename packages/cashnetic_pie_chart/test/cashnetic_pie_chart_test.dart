import 'package:flutter_test/flutter_test.dart';
import 'package:cashnetic_pie_chart/cashnetic_pie_chart.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('CashneticPieChart builds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: CashneticPieChart(
          sections: [
            CashneticPieChartSection(value: 1, label: 'A', color: Colors.blue),
            CashneticPieChartSection(value: 2, label: 'B', color: Colors.red),
          ],
        ),
      ),
    );
    expect(find.byType(CashneticPieChart), findsOneWidget);
  });
}
