import 'package:cashnetic/data/models/category/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/entities/account.dart';
import '../bloc/transaction_add_bloc.dart';
import '../bloc/transaction_add_state.dart';
import '../bloc/transaction_add_event.dart';
import '../../../presentation.dart';
import '../../../widgets/transaction_comment_field.dart';
import '../../../widgets/custom_category_dialog.dart';
import '../../../widgets/validation_error_sheet.dart';
import '../../../widgets/amount_input_dialog.dart';
import '../../../widgets/account_select_sheet.dart';
import '../../../widgets/category_select_sheet.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_bloc.dart';
import 'package:cashnetic/presentation/features/account_add/view/account_add_screen.dart';

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
          } else if (state is TransactionAddError &&
              state.message == 'Нет счетов') {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Нет счетов'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        final created = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BlocProvider(
                              create: (context) => AccountAddBloc(
                                accountRepository: context
                                    .read<AccountRepository>(),
                              ),
                              child: const AccountAddScreen(),
                            ),
                          ),
                        );
                        if (created == true) {
                          context.read<TransactionAddBloc>().add(
                            TransactionAddInitialized(widget.isIncome),
                          );
                        }
                      },
                      child: const Text('Создать счет'),
                    ),
                  ],
                ),
              ),
            );
          } else if (state is TransactionAddError &&
              state.message == 'Нет категорий') {
            return Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Нет категорий'),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () async {
                        await showDialog(
                          context: context,
                          builder: (context) => CustomCategoryDialog(
                            isIncome: widget.isIncome,
                            onCancel: () => Navigator.pop(context),
                            onCreate: (name, emoji) {
                              if (name.isNotEmpty) {
                                context.read<TransactionAddBloc>().add(
                                  TransactionAddCustomCategoryCreated(
                                    name: name,
                                    emoji: emoji.isNotEmpty ? emoji : '💰',
                                    isIncome: widget.isIncome,
                                    color: '#E0E0E0',
                                  ),
                                );
                                Navigator.pop(context);
                              }
                            },
                          ),
                        );
                        context.read<TransactionAddBloc>().add(
                          TransactionAddInitialized(widget.isIncome),
                        );
                      },
                      child: const Text('Создать категорию'),
                    ),
                  ],
                ),
              ),
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
            final today = DateTime.now();
            final txDate = DateTime.tryParse(state.transaction.transactionDate);
            final isToday =
                txDate != null &&
                txDate.year == today.year &&
                txDate.month == today.month &&
                txDate.day == today.day;
            Navigator.pop(context, {
              'transaction': state.transaction,
              'animateToHistory': !isToday,
            });
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
            value: state.account?.name ?? '—',
            onTap: isSaving
                ? () {}
                : () => _selectAccount(context, state.accounts, state.account),
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
          TransactionCommentField(
            controller: _commentController,
            enabled: !isSaving,
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

    if (state.account == null) {
      errors.add('Выберите счет');
    }

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

    context.read<TransactionAddBloc>().add(TransactionAddSaveTransaction());
  }

  Future<void> _selectAccount(
    BuildContext context,
    List<Account> accounts,
    Account? selectedAccount,
  ) async {
    final bloc = context.read<TransactionAddBloc>();
    final res = await showModalBottomSheet<Account>(
      context: context,
      isScrollControlled: true,
      builder: (c) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (accounts.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Нет счетов'),
              ),
            ...accounts.map(
              (acc) => ListTile(
                title: Text(acc.name),
                trailing: selectedAccount?.id == acc.id
                    ? const Icon(Icons.check, color: Colors.green)
                    : null,
                onTap: () => Navigator.pop(c, acc),
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Создать счет'),
              onTap: () async {
                Navigator.pop(c); // Закрыть bottom sheet
                final created = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => BlocProvider(
                      create: (context) => AccountAddBloc(
                        accountRepository: context.read<AccountRepository>(),
                      ),
                      child: const AccountAddScreen(),
                    ),
                  ),
                );
                if (created == true) {
                  // Обновить список счетов в BLoC
                  bloc.add(TransactionAddInitialized(widget.isIncome));
                }
              },
            ),
          ],
        ),
      ),
    );
    if (res != null) {
      context.read<AccountBloc>().add(SelectAccount(res.id));
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
      builder: (c) => CategorySelectSheet(
        categories: filteredCategories,
        isIncome: widget.isIncome,
        onSelect: (category) => Navigator.pop(c, category),
        onCreateCategory: () => _showCustomCategoryDialog(context, bloc),
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
    showDialog(
      context: context,
      builder: (context) => CustomCategoryDialog(
        isIncome: widget.isIncome,
        onCancel: () => Navigator.pop(context),
        onCreate: (name, emoji) {
          if (name.isNotEmpty) {
            bloc.add(
              TransactionAddCustomCategoryCreated(
                name: name,
                emoji: emoji.isNotEmpty ? emoji : '💰',
                isIncome: widget.isIncome,
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
      builder: (context) => AmountInputDialog(
        currentAmount: currentAmount,
        onSubmit: (value) {
          bloc.add(TransactionAddAmountChanged(value));
        },
      ),
    );
  }
}
