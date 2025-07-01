import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_event.dart';

class HistorySortDropdown extends StatelessWidget {
  final HistorySort value;
  final ValueChanged<HistorySort?> onChanged;
  const HistorySortDropdown({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<HistorySort>(
            value: value,
            icon: const Icon(
              Icons.arrow_drop_down,
              color: Colors.green,
              size: 20,
            ),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
            borderRadius: BorderRadius.circular(8),
            isDense: true,
            items: [
              DropdownMenuItem(
                value: HistorySort.dateDesc,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(S.of(context).byDateNewestFirst),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: HistorySort.dateAsc,
                child: Row(
                  children: [
                    Icon(Icons.calendar_today, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(S.of(context).byDateOldestFirst),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: HistorySort.amountDesc,
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(S.of(context).byAmountDesc),
                  ],
                ),
              ),
              DropdownMenuItem(
                value: HistorySort.amountAsc,
                child: Row(
                  children: [
                    Icon(Icons.attach_money, size: 16, color: Colors.green),
                    SizedBox(width: 4),
                    Text(S.of(context).byAmountAsc),
                  ],
                ),
              ),
            ],
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }
}
