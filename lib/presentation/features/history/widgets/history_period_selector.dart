import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HistoryPeriodSelector extends StatelessWidget {
  final DateTime from;
  final DateTime to;
  final VoidCallback onFromTap;
  final VoidCallback onToTap;
  const HistoryPeriodSelector({
    Key? key,
    required this.from,
    required this.to,
    required this.onFromTap,
    required this.onToTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Period: start',
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
              onPressed: onFromTap,
              child: Text(
                DateFormat('LLLL yyyy', 'ru').format(from),
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
            Text(
              S.of(context).periodEnd,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                elevation: 0,
                shadowColor: Colors.transparent,
                backgroundColor: Colors.green.withOpacity(0.8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 6,
                ),
              ),
              onPressed: onToTap,
              child: Text(
                DateFormat('LLLL yyyy', 'ru').format(to),
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
