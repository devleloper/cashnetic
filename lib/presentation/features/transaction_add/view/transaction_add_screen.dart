import 'package:cashnetic/data/models/category/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/utils/category_utils.dart';

import '../bloc/transaction_add_bloc.dart';
import '../bloc/transaction_add_state.dart';
import '../bloc/transaction_add_event.dart';
import '../../../presentation.dart';

class TransactionAddScreen extends StatefulWidget {
  final bool isIncome;

  const TransactionAddScreen({super.key, required this.isIncome});

  @override
  State<TransactionAddScreen> createState() => _TransactionAddScreenState();
}

class _TransactionAddScreenState extends State<TransactionAddScreen> {
  late TextEditingController _commentController;

  @override
  void initState() {
    super.initState();
    _commentController = TextEditingController();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionAddBloc(
        categoryRepository: context.read<CategoryRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
        accountRepository: context.read<AccountRepository>(),
      )..add(TransactionAddInitialized(widget.isIncome)),
      child: BlocConsumer<TransactionAddBloc, TransactionAddState>(
        builder: (context, state) {
          if (state is TransactionAddInitial ||
              state is TransactionAddLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is TransactionAddError) {
            return Scaffold(
              body: Center(child: Text('Ошибка: ${state.message}')),
            );
          } else if (state is TransactionAddLoaded ||
              state is TransactionAddSaving) {
            final comment = state is TransactionAddLoaded
                ? state.comment
                : (state as TransactionAddSaving).comment;
            if (_commentController.text != comment) {
              _commentController.text = comment;
            }
            return _buildContent(context, state);
          } else if (state is TransactionAddSuccess) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const Scaffold(
            body: Center(child: Text('Неизвестное состояние')),
          );
        },
        listener: (context, state) {
          if (state is TransactionAddSuccess) {
            Navigator.pop(context);
          } else if (state is TransactionAddError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic state) {
    // Ensure state is either TransactionAddLoaded or TransactionAddSaving
    if (state is! TransactionAddLoaded && state is! TransactionAddSaving) {
      return const Scaffold(body: Center(child: Text('Неизвестное состояние')));
    }

    final dateStr = DateFormat('dd.MM.yyyy').format(state.selectedDate);
    final timeStr = TimeOfDay.fromDateTime(state.selectedDate).format(context);
    final title = widget.isIncome ? 'Добавить доход' : 'Добавить расход';
    final isSaving = state is TransactionAddSaving;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: isSaving
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Icon(Icons.check, color: Colors.white),
            onPressed: isSaving ? null : () => _validateAndSave(context, state),
          ),
        ],
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          MyListTileRow(
            title: 'Счёт',
            value: state.account?.name ?? '',
            onTap: isSaving
                ? () {}
                : () => _selectAccount(context, state.accounts),
          ),
          MyListTileRow(
            title: 'Категория',
            value: state.selectedCategory?.name ?? '',
            onTap: isSaving
                ? () {}
                : () => _selectCategory(context, state.categories),
          ),
          MyListTileRow(
            title: 'Сумма',
            value: state.amount.isEmpty ? 'Введите' : '${state.amount} ₽',
            onTap: isSaving
                ? () {}
                : () => _selectAmount(context, state.amount),
          ),
          MyListTileRow(
            title: 'Дата',
            value: dateStr,
            onTap: isSaving
                ? () {}
                : () => _selectDate(context, state.selectedDate),
          ),
          MyListTileRow(
            title: 'Время',
            value: timeStr,
            onTap: isSaving
                ? () {}
                : () => _selectTime(context, state.selectedDate),
          ),
          const SizedBox(height: 16),
          TextField(
            decoration: const InputDecoration(
              labelText: 'Комментарий',
              border: OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            maxLines: 3,
            enabled: !isSaving,
            controller: _commentController,
            onChanged: (comment) => context.read<TransactionAddBloc>().add(
              TransactionAddCommentChanged(comment),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndSave(BuildContext context, dynamic state) {
    // Ensure state is either TransactionAddLoaded or TransactionAddSaving
    if (state is! TransactionAddLoaded && state is! TransactionAddSaving) {
      return;
    }

    final errors = <String>[];

    if (state.selectedCategory == null) {
      errors.add('Выберите категорию');
    }

    if (state.amount.isEmpty) {
      errors.add('Введите сумму');
    } else {
      final parsed = double.tryParse(state.amount.replaceAll(',', '.'));
      if (parsed == null || parsed <= 0) {
        errors.add('Сумма должна быть положительным числом');
      }
    }

    if (errors.isNotEmpty) {
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ошибки валидации:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ...errors.map(
                (error) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(error)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Понятно'),
                ),
              ),
            ],
          ),
        ),
      );
      return;
    }

    context.read<TransactionAddBloc>().add(TransactionAddSaveTransaction());
  }

  Future<void> _selectAccount(
    BuildContext context,
    List<Account> accounts,
  ) async {
    final bloc = context.read<TransactionAddBloc>();
    final res = await showModalBottomSheet<Account>(
      context: context,
      builder: (c) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Выберите счёт',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...accounts.map(
                  (account) => ListTile(
                    title: Text(account.name),
                    subtitle: Text(account.moneyDetails?.currency ?? ''),
                    onTap: () => Navigator.pop(c, account),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (res != null) {
      bloc.add(TransactionAddAccountChanged(res));
    }
  }

  Future<void> _selectCategory(
    BuildContext context,
    List<CategoryDTO> categories,
  ) async {
    final bloc = context.read<TransactionAddBloc>();
    final filteredCategories = categories
        .where((c) => c.isIncome == widget.isIncome)
        .toList();

    final res = await showModalBottomSheet<CategoryDTO>(
      context: context,
      builder: (c) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: const Text(
              'Выберите категорию',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView(
              children: [
                ...filteredCategories.map(
                  (cat) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: colorFor(cat.name).withOpacity(0.2),
                      child: Text(
                        cat.emoji,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text(cat.name),
                    onTap: () => Navigator.pop(c, cat),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.add),
                  title: const Text('Создать категорию'),
                  onTap: () => _showCustomCategoryDialog(context, bloc),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (res != null) {
      bloc.add(TransactionAddCategoryChanged(res));
    }
  }

  void _showCustomCategoryDialog(
    BuildContext context,
    TransactionAddBloc bloc,
  ) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '💰');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Создать категорию'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Название категории',
                hintText: 'Введите название',
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: emojiController,
              decoration: const InputDecoration(
                labelText: 'Эмоджи',
                hintText: '💰',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                bloc.add(
                  TransactionAddCustomCategoryCreated(
                    name: nameController.text,
                    emoji: emojiController.text.isNotEmpty
                        ? emojiController.text
                        : '💰',
                    isIncome: widget.isIncome,
                    color: '#E0E0E0',
                  ),
                );
                Navigator.pop(context);
                Navigator.pop(context);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final bloc = context.read<TransactionAddBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      bloc.add(TransactionAddDateChanged(picked));
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime currentDate) async {
    final bloc = context.read<TransactionAddBloc>();
    final currentTime = TimeOfDay.fromDateTime(currentDate);
    final picked = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );
    if (picked != null) {
      final newDateTime = DateTime(
        currentDate.year,
        currentDate.month,
        currentDate.day,
        picked.hour,
        picked.minute,
      );
      bloc.add(TransactionAddDateChanged(newDateTime));
    }
  }

  void _selectAmount(BuildContext context, String currentAmount) {
    final bloc = context.read<TransactionAddBloc>();
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController(text: currentAmount);
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
                bloc.add(TransactionAddAmountChanged(controller.text));
                Navigator.pop(context);
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }
}
