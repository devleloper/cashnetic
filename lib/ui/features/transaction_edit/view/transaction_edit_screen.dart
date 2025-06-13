import 'package:cashnetic/models/category/category_model.dart';
import 'package:cashnetic/models/models.dart';
import 'package:cashnetic/view_models/categories/categories_view_model.dart';
import 'package:cashnetic/view_models/shared/transactions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
  late String amount;
  late String comment;
  CategoryModel? selectedCategory;

  final List<String> accounts = [
    'Сбербанк',
    'Т-Банк',
    'Альфа Банк',
    'ВТБ',
    'МТС Банк',
    'Почта Банк',
  ];

  @override
  void initState() {
    super.initState();
    account = widget.transaction.account;
    amount = widget.transaction.amount.toString();
    comment = widget.transaction.comment ?? '';
    selectedDate = widget.transaction.transactionDate;
    selectedTime = TimeOfDay.fromDateTime(selectedDate);

    final cats = context.read<CategoriesViewModel>().categories;

    final match = cats
        .where(
          (c) =>
              c.name == widget.transaction.categoryTitle &&
              c.emoji == widget.transaction.categoryIcon &&
              c.isIncome == (widget.transaction.type == TransactionType.income),
        )
        .toList();

    selectedCategory = match.isNotEmpty
        ? match.first
        : cats
              .where(
                (c) =>
                    c.isIncome ==
                    (widget.transaction.type == TransactionType.income),
              )
              .firstOrNull;
  }

  void _save() {
    final parsed = double.tryParse(amount.replaceAll(',', '.'));
    if (parsed == null || selectedCategory == null) return;

    final updated = TransactionModel(
      id: widget.transaction.id,
      categoryId: selectedCategory!.id,
      account: account,
      categoryIcon: selectedCategory!.emoji,
      categoryTitle: selectedCategory!.name,
      amount: parsed,
      comment: comment.isEmpty ? null : comment,
      transactionDate: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
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

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null) setState(() => selectedTime = picked);
  }

  void _selectAmount() {
    final controller = TextEditingController(text: amount);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Введите сумму'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
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
      ),
    );
  }

  Future<void> _selectCategory() async {
    final vm = context.read<CategoriesViewModel>();
    final options = vm.categories
        .where(
          (c) =>
              c.isIncome == (widget.transaction.type == TransactionType.income),
        )
        .toList();

    final result = await showModalBottomSheet<CategoryModel>(
      context: context,
      builder: (ctx) => ListView(
        children: options
            .map(
              (cat) => ListTile(
                leading: Text(cat.emoji),
                title: Text(cat.name),
                onTap: () => Navigator.pop(ctx, cat),
              ),
            )
            .toList(),
      ),
    );

    if (result != null) {
      setState(() => selectedCategory = result);
    }
  }

  Future<void> _selectFromList(
    String title,
    List<String> options,
    ValueChanged<String> onSelected,
  ) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      builder: (ctx) => ListView(
        children: options
            .map(
              (o) =>
                  ListTile(title: Text(o), onTap: () => Navigator.pop(ctx, o)),
            )
            .toList(),
      ),
    );

    if (result != null) {
      onSelected(result);
    }
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
            value: selectedCategory?.name ?? '',
            onTap: _selectCategory,
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
