import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/models/category/category_model.dart';
import 'package:cashnetic/models/models.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../view_models/categories/categories_view_model.dart';
import '../../../../view_models/shared/transactions_view_model.dart';
import '../../../ui.dart';

class TransactionAddScreen extends StatefulWidget {
  final TransactionType type;

  const TransactionAddScreen({super.key, required this.type});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String account = 'Сбербанк';
  String amount = '';
  String comment = '';
  CategoryModel? selectedCategory;
  bool ready = false;

  final List<String> accounts = [
    'Сбербанк',
    'Т‑Банк',
    'Альфа Банк',
    'ВТБ',
    'МТС Банк',
    'Почта Банк',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final vm = context.read<CategoriesViewModel>();
      await vm.loadCategories();
      final options = vm.categories
          .where((c) => c.isIncome == (widget.type == TransactionType.income))
          .toList();
      setState(() {
        selectedCategory = options.isNotEmpty ? options.first : null;
        ready = true;
      });
    });
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

  Future<void> _selectCategory() async {
    final vm = context.read<CategoriesViewModel>();
    final options = vm.categories
        .where((c) => c.isIncome == (widget.type == TransactionType.income))
        .toList();

    final res = await showModalBottomSheet<CategoryModel>(
      context: context,
      builder: (c) => ListView(
        children: [
          ...options.map(
            (cat) => ListTile(
              leading: Text(cat.emoji),
              title: Text(cat.name),
              onTap: () => Navigator.pop(c, cat),
            ),
          ),
        ],
      ),
    );

    if (res != null) {
      setState(() => selectedCategory = res);
    }
  }

  void _save() {
    final parsed = double.tryParse(amount.replaceAll(',', '.'));
    if (parsed == null || selectedCategory == null) return;

    final dt = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
      selectedTime.hour,
      selectedTime.minute,
    );

    final model = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch,
      categoryId: selectedCategory!.id,
      account: account,
      categoryIcon: selectedCategory!.emoji,
      categoryTitle: selectedCategory!.name,
      amount: parsed,
      comment: comment.isEmpty ? null : comment,
      transactionDate: dt,
      type: widget.type,
    );

    context.read<TransactionsViewModel>().addTransaction(model);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    if (!ready) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (selectedCategory == null) {
      return const Scaffold(
        body: Center(child: Text('Нет доступных категорий')),
      );
    }

    final dateStr = DateFormat('dd.MM.yyyy').format(selectedDate);
    final timeStr = selectedTime.format(context);
    final title = widget.type == TransactionType.income
        ? 'Добавить доход'
        : 'Добавить расход';

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
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            onChanged: (v) => comment = v,
          ),
        ],
      ),
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
        ],
      ),
    );

    if (res != null) {
      onSelected(res);
    }
  }
}
