import 'package:flutter/material.dart';

enum AccountChartMode { days, months }

class SegmentedControl extends StatelessWidget {
  final AccountChartMode selectedMode;
  final ValueChanged<AccountChartMode> onChanged;
  const SegmentedControl({
    Key? key,
    required this.selectedMode,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SegmentedButton<AccountChartMode>(
        segments: const [
          ButtonSegment(value: AccountChartMode.days, label: Text('Дни')),
          ButtonSegment(value: AccountChartMode.months, label: Text('Месяцы')),
        ],
        selected: <AccountChartMode>{selectedMode},
        onSelectionChanged: (modes) {
          onChanged(modes.first);
        },
      ),
    );
  }
}
