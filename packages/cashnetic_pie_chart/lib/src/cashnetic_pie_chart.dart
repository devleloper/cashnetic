import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'cashnetic_pie_chart_section.dart';

/// Публичный виджет для отображения круговой диаграммы
class CashneticPieChart extends StatefulWidget {
  final List<CashneticPieChartSection> sections;
  final double height;
  final double? centerSpaceRadius;

  /// [sections] — список секторов (значение, цвет, подпись)
  /// [height] — высота графика
  /// [centerSpaceRadius] — радиус центрального пространства (по умолчанию 50)
  const CashneticPieChart({
    Key? key,
    required this.sections,
    this.height = 220,
    this.centerSpaceRadius,
  }) : super(key: key);

  @override
  State<CashneticPieChart> createState() => _CashneticPieChartState();
}

class _CashneticPieChartState extends State<CashneticPieChart> {
  int? _touchedIndex;

  @override
  Widget build(BuildContext context) {
    final data = widget.sections;
    if (data.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          PieChart(
            swapAnimationCurve: Curves.easeInOutCubic,
            swapAnimationDuration: const Duration(milliseconds: 1500),
            PieChartData(
              sections: data.asMap().entries.map((entry) {
                final i = entry.key;
                final c = entry.value;
                final isTouched = i == _touchedIndex;
                final total = data.fold<double>(0, (sum, s) => sum + s.value);
                final percent = total > 0 ? (c.value / total) * 100 : 0.0;
                return PieChartSectionData(
                  value: c.value,
                  title: '${(c.percent ?? percent).toStringAsFixed(0)}%',
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
              centerSpaceRadius: widget.centerSpaceRadius ?? 50,
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
                      _touchedIndex = null;
                    } else {
                      _touchedIndex = idx;
                    }
                  });
                },
              ),
            ),
          ),
          if (_touchedIndex != null &&
              _touchedIndex! >= 0 &&
              _touchedIndex! < data.length)
            Positioned.fill(
              child: Center(
                child: _PieTooltip(
                  color: data[_touchedIndex!].color,
                  label: data[_touchedIndex!].label,
                  value: data[_touchedIndex!].value,
                  percent:
                      data[_touchedIndex!].percent ??
                      _calcPercent(data, _touchedIndex!),
                ),
              ),
            ),
        ],
      ),
    );
  }

  double _calcPercent(List<CashneticPieChartSection> data, int index) {
    final total = data.fold<double>(0, (sum, s) => sum + s.value);
    if (total == 0) return 0.0;
    return (data[index].value / total) * 100;
  }
}

class _PieTooltip extends StatelessWidget {
  final Color color;
  final String label;
  final double value;
  final double percent;
  const _PieTooltip({
    required this.color,
    required this.label,
    required this.value,
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
              label,
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
              value.toStringAsFixed(0),
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
