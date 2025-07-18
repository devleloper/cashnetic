import 'package:cashnetic/domain/entities/category.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import 'package:cashnetic/presentation/features/account/repositories/account_repository.dart';
import 'package:cashnetic/domain/entities/account.dart';

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
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:cashnetic/presentation/features/account_add/view/account_add_screen.dart';
import 'package:cashnetic/presentation/features/account_add/bloc/account_add_bloc.dart';
import 'package:cashnetic/generated/l10n.dart';

class TransactionEditScreen extends StatefulWidget {
  final int transactionId;

  const TransactionEditScreen({super.key, required this.transactionId});

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
      create: (context) =>
          TransactionEditBloc()
            ..add(TransactionEditInitialized(widget.transactionId)),
      child: BlocConsumer<TransactionEditBloc, TransactionEditState>(
        listener: (context, state) {
          if (state is TransactionEditSuccess) {
            final loaded = context.read<TransactionEditBloc>().state;
            if (loaded is TransactionEditLoaded) {
              context.read<AccountBloc>().add(SelectAccount(loaded.account.id));
            }
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
            return const Center(child: CircularProgressIndicator());
          } else if (state is TransactionEditError) {
            return Center(child: Text(state.message));
          } else if (state is TransactionEditLoaded ||
              state is TransactionEditSaving ||
              state is TransactionEditDeleting) {
            final loadedState = state as dynamic;
            if (_commentController.text != loadedState.comment) {
              _commentController.text = loadedState.comment;
            }
            return ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              child: Container(
                color: Colors.white,
                width: double.infinity,
                child: SafeArea(
                  top: false,
                  child: _buildContent(context, loadedState),
                ),
              ),
            );
          } else if (state is TransactionEditSuccess ||
              state is TransactionEditDeleted) {
            return const Center(child: CircularProgressIndicator());
          }
          return Center(child: Text(S.of(context).unknownState));
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic state) {
    final dateStr = DateFormat('dd.MM.yyyy').format(state.selectedDate);
    final timeStr = TimeOfDay.fromDateTime(state.selectedDate).format(context);
    final title = (state.selectedCategory?.isIncome ?? false)
        ? S.of(context).addIncome
        : S.of(context).addExpense;
    final isSaving = state is TransactionEditSaving;
    final isDeleting = state is TransactionEditDeleting;
    final isProcessing = isSaving || isDeleting;

    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 1000),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Шапка (fixed)
          Container(
            decoration: const BoxDecoration(
              color: Colors.green,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
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
            ),
          ),
          // Скроллируемый контент формы
          Expanded(
            child: SizedBox.expand(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    MyListTileRow(
                      title: S.of(context).account,
                      value:
                          (state.account == null ||
                              (state.account.name.trim().isEmpty))
                          ? S.of(context).account
                          : state.account.name,
                      onTap: isProcessing
                          ? () {}
                          : () => _selectAccount(context, state.accounts),
                    ),
                    MyListTileRow(
                      title: S.of(context).category,
                      value: state.selectedCategory?.name ?? '',
                      onTap: isProcessing
                          ? () {}
                          : () => _selectCategory(context, state.categories),
                    ),
                    MyListTileRow(
                      title: S.of(context).amount,
                      value: state.amount.isEmpty
                          ? S.of(context).enter
                          : state.amount,
                      onTap: isProcessing
                          ? () {}
                          : () => _selectAmount(context, state.amount),
                    ),
                    MyListTileRow(
                      title: S.of(context).date,
                      value: dateStr,
                      onTap: isProcessing
                          ? () {}
                          : () => _selectDate(context, state.selectedDate),
                    ),
                    MyListTileRow(
                      title: S.of(context).time,
                      value: timeStr,
                      onTap: isProcessing
                          ? () {}
                          : () => _selectTime(context, state.selectedDate),
                    ),
                    const SizedBox(height: 16),
                    TransactionCommentField(
                      controller: _commentController,
                      enabled: !isProcessing,
                      onChanged: (comment) => context
                          .read<TransactionEditBloc>()
                          .add(TransactionEditCommentChanged(comment)),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
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
                            : Text(
                                S.of(context).deleteAccount,
                                style: TextStyle(color: Colors.white),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _validateAndSave(BuildContext context, dynamic state) {
    final errors = <String>[];

    if (state.selectedCategory == null) {
      errors.add(S.of(context).selectCategory);
    }

    if (state.amount.isEmpty) {
      errors.add(S.of(context).enterAmount);
    } else {
      final parsed = double.tryParse(state.amount.replaceAll(',', '.'));
      if (parsed == null || parsed <= 0) {
        errors.add(S.of(context).amountMustBeAPositiveNumber);
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
        onCreateAccount: () async {
          Navigator.pop(c); // Закрыть bottom sheet
          final created = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BlocProvider(
                create: (context) => AccountAddBloc(),
                child: const AccountAddScreen(),
              ),
            ),
          );
          if (created == true) {
            bloc.add(TransactionEditInitialized(widget.transactionId));
          }
        },
      ),
    );

    if (res != null) {
      context.read<AccountBloc>().add(SelectAccount(res.id));
      bloc.add(TransactionEditAccountChanged(res));
    }
  }

  Future<void> _selectCategory(
    BuildContext context,
    List<Category> categories,
  ) async {
    final bloc = context.read<TransactionEditBloc>();
    final res = await showModalBottomSheet<Category>(
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
    List<Category> categories,
  ) {
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
      lastDate: DateTime.now(),
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
