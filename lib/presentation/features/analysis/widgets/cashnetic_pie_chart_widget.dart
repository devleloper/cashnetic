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
    return Column(
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 900),
          switchInCurve: Curves.easeInOutCubic,
          switchOutCurve: Curves.easeInOutCubic,
          transitionBuilder: (child, animation) {
            final isIncoming = child.key == ValueKey(_dataKey());
            final rotateAnim = Tween<double>(
              begin: isIncoming ? 3.14159 : 0.0,
              end: isIncoming ? 6.28319 : 3.14159,
            ).animate(animation);
            final fadeAnim = isIncoming
                ? animation
                : ReverseAnimation(animation);
            return AnimatedBuilder(
              animation: animation,
              builder: (context, _) {
                return Opacity(
                  opacity: fadeAnim.value,
                  child: Transform.rotate(
                    angle: rotateAnim.value,
                    child: child,
                  ),
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
        ),
        const SizedBox(height: 36),
        _AnimatedLegend(data: data, dataKey: _dataKey()),
      ],
    );
  }
}

class _AnimatedLegend extends StatelessWidget {
  final List<AnalysisPieChartData> data;
  final String dataKey;
  const _AnimatedLegend({required this.data, required this.dataKey});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.97, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: Wrap(
        key: ValueKey(dataKey),
        spacing: 12,
        runSpacing: 6,
        children: data.asMap().entries.map((entry) {
          final c = entry.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: c.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              Text('${c.categoryTitle} (${c.percent.toStringAsFixed(0)}%)'),
            ],
          );
        }).toList(),
      ),
    );
  }
}
