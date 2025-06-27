import 'package:flutter/material.dart';
import '../bloc/analysis_event.dart';

class AnalysisPeriodSelector extends StatelessWidget {
  final DateTime periodStart;
  final DateTime periodEnd;
  final void Function(DateTime from, DateTime to) onChanged;
  final AnalysisType type;
  const AnalysisPeriodSelector({
    super.key,
    required this.periodStart,
    required this.periodEnd,
    required this.onChanged,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Период: начало',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                elevation: 0,
                backgroundColor: Colors.green.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
              ),
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: periodStart.isAfter(periodEnd)
                      ? periodEnd
                      : periodStart,
                  firstDate: DateTime(2000),
                  lastDate: periodEnd.isBefore(periodStart)
                      ? periodStart
                      : periodEnd,
                );
                if (picked != null) {
                  onChanged(picked, periodEnd);
                }
              },
              child: Text(
                '${periodStart.day.toString().padLeft(2, '0')}.${periodStart.month.toString().padLeft(2, '0')}.${periodStart.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Период: конец',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                shadowColor: Colors.transparent,
                elevation: 0,
                backgroundColor: Colors.green.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 8,
                ),
              ),
              onPressed: () async {
                final now = DateTime.now();
                final lastAllowed = periodEnd.isAfter(now) ? now : periodEnd;
                final safeInitialDate = periodEnd.isAfter(lastAllowed)
                    ? lastAllowed
                    : periodEnd;
                final picked = await showDatePicker(
                  context: context,
                  initialDate: safeInitialDate,
                  firstDate: periodStart,
                  lastDate: lastAllowed,
                );
                if (picked != null) {
                  onChanged(periodStart, picked);
                }
              },
              child: Text(
                '${periodEnd.day.toString().padLeft(2, '0')}.${periodEnd.month.toString().padLeft(2, '0')}.${periodEnd.year}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
