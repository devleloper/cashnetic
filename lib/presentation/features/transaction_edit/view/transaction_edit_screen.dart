import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction_response/transaction_response.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/utils/category_utils.dart';

import '../bloc/transaction_edit_bloc.dart';
import '../bloc/transaction_edit_state.dart';
import '../bloc/transaction_edit_event.dart';
import '../../../presentation.dart';
import '../../../widgets/transaction_comment_field.dart';
import '../../../widgets/custom_category_dialog.dart';
import '../../../widgets/validation_error_sheet.dart';
import '../../../widgets/amount_input_dialog.dart';
import '../../../widgets/account_select_sheet.dart';
import '../../../widgets/category_select_sheet.dart';

class TransactionEditScreen extends StatefulWidget {
  final TransactionResponseDTO transaction;

  const TransactionEditScreen({super.key, required this.transaction});

  @override
  State<TransactionEditScreen> createState() => _TransactionEditScreenState();
}

class _TransactionEditScreenState extends State<TransactionEditScreen> {
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
      create: (context) => TransactionEditBloc(
        categoryRepository: context.read<CategoryRepository>(),
        transactionRepository: context.read<TransactionRepository>(),
        accountRepository: context.read<AccountRepository>(),
      )..add(TransactionEditInitialized(widget.transaction)),
      child: BlocConsumer<TransactionEditBloc, TransactionEditState>(
        listener: (context, state) {
          if (state is TransactionEditSuccess) {
            Navigator.pop(context, true);
          } else if (state is TransactionEditDeleted) {
            Navigator.pop(context, true);
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
            // Обновляем контроллер комментария
            if (_commentController.text != loadedState.comment) {
              _commentController.text = loadedState.comment;
            }
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
    final title = state.transaction.category.isIncome
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
                : () => _validateAndSave(context, state),
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
            onTap: isProcessing
                ? () {}
                : () => _selectAccount(context, state.accounts),
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
          TransactionCommentField(
            controller: _commentController,
            enabled: !isProcessing,
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
              shadowColor: Colors.transparent,
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

  void _validateAndSave(BuildContext context, dynamic state) {
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
        builder: (context) => ValidationErrorSheet(
          errors: errors,
          onClose: () => Navigator.pop(context),
        ),
      );
      return;
    }

    context.read<TransactionEditBloc>().add(TransactionEditSaveTransaction());
  }

  Future<void> _selectAccount(
    BuildContext context,
    List<Account> accounts,
  ) async {
    final bloc = context.read<TransactionEditBloc>();
    final res = await showModalBottomSheet<Account>(
      context: context,
      builder: (c) => AccountSelectSheet(
        accounts: accounts,
        onSelect: (account) => Navigator.pop(c, account),
      ),
    );

    if (res != null) {
      bloc.add(TransactionEditAccountChanged(res));
    }
  }

  Future<void> _selectCategory(
    BuildContext context,
    List<CategoryDTO> categories,
  ) async {
    final bloc = context.read<TransactionEditBloc>();
    final res = await showModalBottomSheet<CategoryDTO>(
      context: context,
      builder: (c) => CategorySelectSheet(
        categories: categories,
        isIncome: categories.isNotEmpty ? categories.first.isIncome : false,
        onSelect: (cat) => Navigator.pop(c, cat),
        onCreateCategory: () =>
            _showCustomCategoryDialog(context, bloc, categories),
      ),
    );

    if (res != null) {
      bloc.add(TransactionEditCategoryChanged(res));
    }
  }

  void _showCustomCategoryDialog(
    BuildContext context,
    TransactionEditBloc bloc,
    List<CategoryDTO> categories,
  ) {
    final nameController = TextEditingController();
    final emojiController = TextEditingController(text: '💰');
    final isIncome = categories.isNotEmpty ? categories.first.isIncome : false;

    showDialog(
      context: context,
      builder: (context) => CustomCategoryDialog(
        isIncome: isIncome,
        onCancel: () => Navigator.pop(context),
        onCreate: (name, emoji) {
          if (name.isNotEmpty) {
            bloc.add(
              TransactionEditCustomCategoryCreated(
                name: name,
                emoji: emoji.isNotEmpty ? emoji : '💰',
                isIncome: isIncome,
                color: '#E0E0E0',
              ),
            );
            Navigator.pop(context);
            Navigator.pop(context);
          }
        },
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final bloc = context.read<TransactionEditBloc>();
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      bloc.add(TransactionEditDateChanged(picked));
    }
  }

  Future<void> _selectTime(BuildContext context, DateTime currentDate) async {
    final bloc = context.read<TransactionEditBloc>();
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
      bloc.add(TransactionEditDateChanged(newDateTime));
    }
  }

  void _selectAmount(BuildContext context, String currentAmount) {
    final bloc = context.read<TransactionEditBloc>();
    showDialog(
      context: context,
      builder: (_) => AmountInputDialog(
        currentAmount: currentAmount,
        onSubmit: (value) {
          bloc.add(TransactionEditAmountChanged(value));
        },
      ),
    );
  }
}
