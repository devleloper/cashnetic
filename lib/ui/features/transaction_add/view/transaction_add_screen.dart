import 'package:cashnetic/utils/category_utils.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../models/models.dart';
import '../../../../view_models/view_models.dart';

class TransactionAddScreen extends StatefulWidget {
  const TransactionAddScreen({super.key});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String account = 'Сбербанк';
  String category = 'Ремонт';
  String amount = '';
  String comment = '';

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

    final now = DateTime.now();
    final model = TransactionModel(
      id: DateTime.now().millisecondsSinceEpoch,
      account: account,
      categoryIcon: selectedIconFor(category), // эмоджи + цвет в UI ниже
      categoryTitle: category,
      amount: parsedAmount,
      comment: comment.isEmpty ? null : comment,
      dateTime: DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      ),
    );

    final vm = context.read<ExpensesViewModel>();
    vm.addTransaction(model);
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
        title: const Text('Мои расходы'),
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
