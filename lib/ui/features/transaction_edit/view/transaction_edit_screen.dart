import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../bloc/transaction_edit_bloc.dart';
import '../bloc/transaction_edit_state.dart';
import '../bloc/transaction_edit_event.dart';
import '../../../ui.dart';

class TransactionEditScreen extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionEditScreen({super.key, required this.transaction});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionEditBloc(
        categoryRepository: context.read(),
        transactionRepository: context.read(),
      )..add(TransactionEditInitialized(transaction)),
      child: BlocConsumer<TransactionEditBloc, TransactionEditState>(
        listener: (context, state) {
          if (state is TransactionEditSuccess) {
            Navigator.pop(context);
          } else if (state is TransactionEditDeleted) {
            Navigator.pop(context);
          } else if (state is TransactionEditError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is TransactionEditInitial ||
              state is TransactionEditLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is TransactionEditError) {
            return Scaffold(
              body: Center(child: Text('Ошибка: ${state.message}')),
            );
          } else if (state is TransactionEditLoaded ||
              state is TransactionEditSaving ||
              state is TransactionEditDeleting) {
            final loadedState = state as dynamic;
            return _buildContent(context, loadedState);
          } else if (state is TransactionEditSuccess ||
              state is TransactionEditDeleted) {
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
    final title = state.transaction.type == TransactionType.income
        ? 'Редактировать доход'
        : 'Редактировать расход';
    final isSaving = state is TransactionEditSaving;
    final isDeleting = state is TransactionEditDeleting;
    final isProcessing = isSaving || isDeleting;

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
            onPressed: isProcessing
                ? null
                : () => context.read<TransactionEditBloc>().add(
                    TransactionEditSaveTransaction(),
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
            onTap: isProcessing
                ? () {}
                : () => _selectFromList(
                    context,
                    'счёт',
                    state.accounts,
                    (account) => context.read<TransactionEditBloc>().add(
                      TransactionEditAccountChanged(account),
                    ),
                  ),
          ),
          MyListTileRow(
            title: 'Категория',
            value: state.selectedCategory?.name ?? '',
            onTap: isProcessing
                ? () {}
                : () => _selectCategory(context, state.categories),
          ),
          MyListTileRow(
            title: 'Сумма',
            value: state.amount.isEmpty ? 'Введите' : '${state.amount} ₽',
            onTap: isProcessing
                ? () {}
                : () => _selectAmount(context, state.amount),
          ),
          MyListTileRow(
            title: 'Дата',
            value: dateStr,
            onTap: isProcessing
                ? () {}
                : () => _selectDate(context, state.selectedDate),
          ),
          MyListTileRow(
            title: 'Время',
            value: timeStr,
            onTap: isProcessing
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
            enabled: !isProcessing,
            controller: TextEditingController(text: state.comment),
            onChanged: (comment) => context.read<TransactionEditBloc>().add(
              TransactionEditCommentChanged(comment),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              fixedSize: const Size.fromHeight(50),
              backgroundColor: Colors.red,
              elevation: 0,
            ),
            onPressed: isProcessing
                ? null
                : () => context.read<TransactionEditBloc>().add(
                    TransactionEditDeleteTransaction(),
                  ),
            child: isDeleting
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text('Удалить', style: TextStyle(color: Colors.white)),
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
      context.read<TransactionEditBloc>().add(
        TransactionEditDateChanged(picked),
      );
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
      context.read<TransactionEditBloc>().add(
        TransactionEditDateChanged(newDateTime),
      );
    }
  }

  void _selectAmount(BuildContext context, String currentAmount) {
    final controller = TextEditingController(text: currentAmount);
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
              context.read<TransactionEditBloc>().add(
                TransactionEditAmountChanged(controller.text),
              );
              Navigator.pop(context);
            },
            child: const Text('ОК'),
          ),
        ],
      ),
    );
  }

  Future<void> _selectCategory(
    BuildContext context,
    List<Category> categories,
  ) async {
    final result = await showModalBottomSheet<Category>(
      context: context,
      builder: (ctx) => ListView(
        children: categories
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
      context.read<TransactionEditBloc>().add(
        TransactionEditCategoryChanged(result),
      );
    }
  }

  Future<void> _selectFromList(
    BuildContext context,
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
}
