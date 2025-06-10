import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../view_models/view_models.dart';

class TransactionEditScreen extends StatefulWidget {
  final TransactionModel initial;
  const TransactionEditScreen({Key? key, required this.initial})
    : super(key: key);

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late String account, category, amount, comment;
  // same lists...

  @override
  void initState() {
    super.initState();
    final t = widget.initial;
    selectedDate = DateTime.fromMillisecondsSinceEpoch(
      t.id,
    ); // при необходимости поправь
    selectedTime = TimeOfDay.now();
    account = ''; // если есть поле
    category = t.categoryTitle;
    amount = t.amount.toString();
    comment = t.comment ?? '';
  }

  void _save() {
    final parsed = double.tryParse(amount.replaceAll(',', '.'));
    if (parsed == null) return;

    final newModel = widget.initial.copyWith(
      categoryTitle: category,
      amount: parsed,
      comment: comment.isEmpty ? null : comment,
    );

    final vm = context.read<ExpensesViewModel>();
    vm.updateTransaction(newModel);
    Navigator.pop(context);
  }

  void _delete() {
    context.read<ExpensesViewModel>().deleteTransaction(widget.initial.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext ctx) {
    final dateStr = DateFormat('dd.MM.yyyy').format(selectedDate);
    final timeStr = selectedTime.format(ctx);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактирование'),
        actions: [IconButton(onPressed: _save, icon: const Icon(Icons.check))],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Категория, Сумма, Дата, Время, Комментарий – аналогично ADD
          const SizedBox(height: 20),
          TextButton(
            style: TextButton.styleFrom(backgroundColor: Colors.red),
            onPressed: _delete,
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
