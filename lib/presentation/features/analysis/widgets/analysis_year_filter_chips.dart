import 'package:cashnetic/presentation/widgets/category_list_tile.dart';
import 'package:flutter/material.dart';
import '../bloc/analysis_event.dart';
import 'package:cashnetic/presentation/theme/light_color_for.dart';

class AnalysisYearFilterChips extends StatelessWidget {
  final List<int> availableYears;
  final List<int> selectedYears;
  final void Function(List<int> newYears) onChanged;
  final AnalysisType type;
  const AnalysisYearFilterChips({
    super.key,
    required this.availableYears,
    required this.selectedYears,
    required this.onChanged,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      children: availableYears.map((yr) {
        final selected = selectedYears.contains(yr);
        return FilterChip(
          elevation: 0,
          checkmarkColor: Colors.white,
          label: Text('$yr'),
          selected: selected,
          selectedColor: Colors.green,
          backgroundColor: lightColorFor('$yr'),
          labelStyle: TextStyle(color: selected ? Colors.white : Colors.black),
          onSelected: (val) {
            final newYears = List<int>.from(selectedYears);
            if (val) {
              newYears.add(yr);
            } else {
              newYears.remove(yr);
            }
            if (newYears.isNotEmpty) {
              onChanged(newYears.toSet().toList()..sort());
            }
          },
        );
      }).toList(),
    );
  }
}
