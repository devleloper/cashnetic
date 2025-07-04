import 'package:flutter/material.dart';
import 'package:cashnetic_pie_chart/cashnetic_pie_chart.dart';

class AnalysisPieChartData {
  final double amount;
  final String categoryTitle;
  final Color color;
  final double percent;

  AnalysisPieChartData({
    required this.amount,
    required this.categoryTitle,
    required this.color,
    required this.percent,
  });
}

class CashneticPieChartWidget extends StatelessWidget {
  final List<AnalysisPieChartData> data;
  final double height;

  const CashneticPieChartWidget({
    Key? key,
    required this.data,
    this.height = 220,
  }) : super(key: key);

  String _dataKey() => data
      .map(
        (e) => '${e.categoryTitle}:${e.amount}:${e.percent}:${e.color.value}',
      )
      .join('|');

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) return const SizedBox.shrink();
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 900),
      switchInCurve: Curves.easeInOutCubic,
      switchOutCurve: Curves.easeInOutCubic,
      transitionBuilder: (child, animation) {
        // child.key определяет, входящий это или исходящий виджет
        final isIncoming = child.key == ValueKey(_dataKey());
        final rotateAnim = Tween<double>(
          begin: isIncoming
              ? 3.14159
              : 0.0, // 180° для входящего, 0° для исходящего
          end: isIncoming
              ? 6.28319
              : 3.14159, // 360° для входящего, 180° для исходящего
        ).animate(animation);
        final fadeAnim = isIncoming ? animation : ReverseAnimation(animation);
        return AnimatedBuilder(
          animation: animation,
          builder: (context, _) {
            return Opacity(
              opacity: fadeAnim.value,
              child: Transform.rotate(angle: rotateAnim.value, child: child),
            );
          },
        );
      },
      child: CashneticPieChart(
        key: ValueKey(_dataKey()),
        sections: data
            .map(
              (e) => CashneticPieChartSection(
                value: e.amount,
                label: e.categoryTitle,
                color: e.color,
                percent: e.percent,
              ),
            )
            .toList(),
        height: height,
      ),
    );
  }
}
