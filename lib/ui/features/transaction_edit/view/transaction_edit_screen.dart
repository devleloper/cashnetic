import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../view_models/view_models.dart';

class TransactionEditScreen extends StatefulWidget {
  final TransactionModel transaction;

  const TransactionEditScreen({super.key, required this.transaction});

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
  late DateTime selectedDate;
  late TimeOfDay selectedTime;
  late String account;
  late String category;
  late String amount;
  late String comment;

  final List<String> accounts = [
    'Сбербанк',
    'Т-Банк',
    'Альфа Банк',
    'ВТБ',
    'МТС Банк',
    'Почта Банк',
  ];
  final List<String> categories = [
    'Ремонт',
    'Одежда',
    'Продукты',
    'Электроника',
    'Развлечения',
    'Образование',
    'Услуги связи',
  ];

  @override
  void initState() {
    super.initState();
    account = 'Сбербанк';
    category = widget.transaction.categoryTitle;
    amount = widget.transaction.amount.toString();
    comment = widget.transaction.comment ?? '';
    selectedDate = DateTime.fromMillisecondsSinceEpoch(widget.transaction.id);
    selectedTime = TimeOfDay.fromDateTime(selectedDate);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) {
      setState(() => selectedTime = picked);
    }
  }

  void _selectAmount() {
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: amount);
        return AlertDialog(
          title: const Text('Введите сумму'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(hintText: '0.00'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() => amount = controller.text);
                Navigator.pop(context);
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectFromList(
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) async {
    final res = await showModalBottomSheet<String>(
      context: context,
      builder: (c) => ListView(
        children: [
          ...options.map(
            (o) => ListTile(title: Text(o), onTap: () => Navigator.pop(c, o)),
          ),
          ListTile(
            title: const Text('Введите вручную…'),
            onTap: () => Navigator.pop(c, null),
          ),
        ],
      ),
    );

    if (res != null) {
      onSelected(res);
    } else {
      final input = await showDialog<String>(
        context: context,
        builder: (c) {
          final ctrl = TextEditingController();
          return AlertDialog(
            title: Text('Новый $title'),
            content: TextField(controller: ctrl, autofocus: true),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(c),
                child: const Text('Отмена'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(c, ctrl.text),
                child: const Text('Добавить'),
              ),
            ],
          );
        },
      );
      if (input != null && input.isNotEmpty) {
        setState(() {
          options.add(input);
        });
        onSelected(input);
      }
    }
  }

  void _save() {
    final parsedAmount = double.tryParse(amount.replaceAll(',', '.'));
    if (parsedAmount == null) return;

    final updated = TransactionModel(
      id: widget.transaction.id,
      categoryIcon: '💸',
      categoryTitle: category,
      amount: parsedAmount,
      comment: comment.isEmpty ? null : comment,
    );

    context.read<ExpensesViewModel>().updateTransaction(updated);
    Navigator.pop(context);
  }

  void _delete() {
    context.read<ExpensesViewModel>().deleteTransaction(widget.transaction.id);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(selectedDate);
    final timeStr = selectedTime.format(context);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _save,
          ),
        ],
        title: const Text('Редактировать расход'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _ListTileRow(
            title: 'Счёт',
            value: account,
            onTap: () => _selectFromList(
              'счёт',
              accounts,
              (v) => setState(() => account = v),
            ),
          ),
          _ListTileRow(
            title: 'Категория',
            value: category,
            onTap: () => _selectFromList(
              'категория',
              categories,
              (v) => setState(() => category = v),
            ),
          ),
          _ListTileRow(
            title: 'Сумма',
            value: amount.isEmpty ? 'Введите' : '$amount ₽',
            onTap: _selectAmount,
          ),
          _ListTileRow(title: 'Дата', value: dateStr, onTap: _selectDate),
          _ListTileRow(title: 'Время', value: timeStr, onTap: _selectTime),
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: comment),
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            onChanged: (v) => comment = v,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: Size.fromHeight(50),
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: _delete,
            child: const Text('Удалить', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _ListTileRow extends StatelessWidget {
  final String title;
  final String value;
  final VoidCallback onTap;

  const _ListTileRow({
    required this.title,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(title),
          trailing: Text(value),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
