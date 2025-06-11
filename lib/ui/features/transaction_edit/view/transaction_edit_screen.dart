import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../view_models/shared/transactions_view_model.dart';
import '../../../ui.dart';

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

  List<String> get categories =>
      widget.transaction.type == TransactionType.expense
      ? [
          'Ремонт',
          'Одежда',
          'Продукты',
          'Электроника',
          'Развлечения',
          'Образование',
          'Услуги связи',
        ]
      : ['Зарплата', 'Подработка'];

  @override
  void initState() {
    super.initState();
    account = widget.transaction.account;
    category = widget.transaction.categoryTitle;
    amount = widget.transaction.amount.toString();
    comment = widget.transaction.comment ?? '';
    selectedDate = widget.transaction.dateTime;
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

    final updatedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final updated = TransactionModel(
      id: widget.transaction.id,
      account: account,
      categoryIcon: selectedIconFor(category),
      categoryTitle: category,
      amount: parsedAmount,
      comment: comment.isEmpty ? null : comment,
      dateTime: updatedDateTime,
      type: widget.transaction.type,
    );

    context.read<TransactionsViewModel>().updateTransaction(updated);
    Navigator.pop(context);
  }

  void _delete() {
    context.read<TransactionsViewModel>().deleteTransaction(
      widget.transaction.id,
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat('dd.MM.yyyy').format(selectedDate);
    final timeStr = selectedTime.format(context);

    final title = widget.transaction.type == TransactionType.income
        ? 'Редактировать доход'
        : 'Редактировать расход';

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
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          MyListTileRow(
            title: 'Счёт',
            value: account,
            onTap: () => _selectFromList(
              'счёт',
              accounts,
              (v) => setState(() => account = v),
            ),
          ),
          MyListTileRow(
            title: 'Категория',
            value: category,
            onTap: () => _selectFromList(
              'категория',
              categories,
              (v) => setState(() => category = v),
            ),
          ),
          MyListTileRow(
            title: 'Сумма',
            value: amount.isEmpty ? 'Введите' : '$amount ₽',
            onTap: _selectAmount,
          ),
          MyListTileRow(title: 'Дата', value: dateStr, onTap: _selectDate),
          MyListTileRow(title: 'Время', value: timeStr, onTap: _selectTime),
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
              fixedSize: const Size.fromHeight(50),
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
