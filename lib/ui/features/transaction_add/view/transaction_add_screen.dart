import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/transaction_add_bloc.dart';
import '../bloc/transaction_add_state.dart';
import '../bloc/transaction_add_event.dart';
import '../../../ui.dart';

class TransactionAddScreen extends StatelessWidget {
  final TransactionType type;

  const TransactionAddScreen({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionAddBloc(
        categoryRepository: context.read(),
        transactionRepository: context.read(),
      )..add(TransactionAddInitialized(type)),
      child: BlocConsumer<TransactionAddBloc, TransactionAddState>(
        listener: (context, state) {
          if (state is TransactionAddSuccess) {
            Navigator.pop(context);
          } else if (state is TransactionAddError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
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
            final loadedState = state as dynamic;
            return _buildContent(context, loadedState);
          } else if (state is TransactionAddSuccess) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          return const Scaffold(
            body: Center(child: Text('Неизвестное состояние')),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic state) {
    final dateStr = DateFormat('dd.MM.yyyy').format(state.selectedDate);
    final timeStr = TimeOfDay.fromDateTime(state.selectedDate).format(context);
    final title = type == TransactionType.income
        ? 'Добавить доход'
        : 'Добавить расход';
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
            onPressed: isSaving
                ? null
                : () => context.read<TransactionAddBloc>().add(
                    TransactionAddSaveTransaction(),
                  ),
          ),
        ],
        title: Text(title),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          MyListTileRow(
            title: 'Счёт',
            value: state.account,
            onTap: isSaving
                ? () {}
                : () => _selectFromList(
                    context,
                    'счёт',
                    state.accounts,
                    (account) => context.read<TransactionAddBloc>().add(
                      TransactionAddAccountChanged(account),
                    ),
                  ),
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
            controller: TextEditingController(text: state.comment),
            onChanged: (comment) => context.read<TransactionAddBloc>().add(
              TransactionAddCommentChanged(comment),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      context.read<TransactionAddBloc>().add(TransactionAddDateChanged(picked));
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime currentDate) async {
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
      context.read<TransactionAddBloc>().add(
        TransactionAddDateChanged(newDateTime),
      );
    }
  }

  void _selectAmount(BuildContext context, String currentAmount) {
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
                context.read<TransactionAddBloc>().add(
                  TransactionAddAmountChanged(controller.text),
                );
                Navigator.pop(context);
              },
              child: const Text('ОК'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectCategory(
    BuildContext context,
    List<Category> categories,
  ) async {
    final filteredCategories = categories
        .where((c) => c.isIncome == (type == TransactionType.income))
        .toList();

    final res = await showModalBottomSheet<Category>(
      context: context,
      builder: (c) => ListView(
        children: [
          ...filteredCategories.map(
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
      context.read<TransactionAddBloc>().add(
        TransactionAddCategoryChanged(res),
      );
    }
  }

  Future<void> _selectFromList(
    BuildContext context,
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
