import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class AnalysisPieChart extends StatefulWidget {
  final List<dynamic> data;
  const AnalysisPieChart({super.key, required this.data});

  @override
  State<AnalysisPieChart> createState() => _AnalysisPieChartState();
}

class _AnalysisPieChartState extends State<AnalysisPieChart> {
  int? touchedIndex;

  @override
  Widget build(BuildContext context) {
    final data = widget.data;
    if (data.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 220,
      child: Stack(
        children: [
          PieChart(
            swapAnimationCurve: Curves.easeInOutCubic,
            swapAnimationDuration: const Duration(milliseconds: 1500),
            PieChartData(
              sections: data.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                final isTouched = i == touchedIndex;
                return PieChartSectionData(
                  value: c.amount,
                  title: '${c.percent.toStringAsFixed(0)}%',
                  radius: isTouched ? 70 : 60,
                  color: c.color,
                  titleStyle: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    overflow: TextOverflow.ellipsis,
                  ),
                  titlePositionPercentageOffset: 0.6,
                  badgeWidget: null,
                );
              }).toList(),
              centerSpaceRadius: 50,
              sectionsSpace: 2,
              borderData: FlBorderData(show: false),
              pieTouchData: PieTouchData(
                enabled: true,
                touchCallback: (event, response) {
                  setState(() {
                    final idx = response?.touchedSection?.touchedSectionIndex;
                    if (!event.isInterestedForInteractions ||
                        idx == null ||
                        idx < 0 ||
                        idx >= data.length) {
                      touchedIndex = null;
                    } else {
                      touchedIndex = idx;
                    }
                  });
                },
              ),
            ),
          ),
          if (touchedIndex != null &&
              touchedIndex! >= 0 &&
              touchedIndex! < data.length)
            Positioned.fill(
              child: Center(
                child: _PieTooltip(
                  color: data[touchedIndex!].color,
                  category: data[touchedIndex!].categoryTitle,
                  amount: data[touchedIndex!].amount,
                  percent: data[touchedIndex!].percent,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PieTooltip extends StatelessWidget {
  final Color color;
  final String category;
  final double amount;
  final double percent;
  const _PieTooltip({
    required this.color,
    required this.category,
    required this.amount,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: color.withOpacity(0.95),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 180),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              category,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            const SizedBox(height: 4),
            Text(
              '${amount.toStringAsFixed(0)} ₽',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
            Text(
              '${percent.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                overflow: TextOverflow.ellipsis,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }
}
