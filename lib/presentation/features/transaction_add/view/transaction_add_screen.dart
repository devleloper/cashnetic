import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
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
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/presentation/features/settings/bloc/settings_bloc.dart';
import 'package:cashnetic/presentation/features/settings/bloc/settings_state.dart';

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
      create: (context) =>
          TransactionAddBloc()..add(TransactionAddInitialized(widget.isIncome)),
      child: BlocConsumer<TransactionAddBloc, TransactionAddState>(
        listener: (context, state) {
          if (state is TransactionAddSuccess) {
            Navigator.pop(context, true);
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
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(state.message),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<TransactionAddBloc>().add(
                          TransactionAddInitialized(widget.isIncome),
                        );
                      },
                      child: Text(
                        state.message.contains('account')
                            ? S.of(context).createAccount
                            : state.message.contains('category')
                            ? S.of(context).createCategory
                            : S.of(context).createAccount,
                      ),
                    ),
                  ],
                ),
              ),
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
          return Scaffold(
            body: Center(child: Text(S.of(context).unknownState)),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, dynamic state) {
    if (state is! TransactionAddLoaded && state is! TransactionAddSaving) {
      return Scaffold(body: Center(child: Text(S.of(context).unknownState)));
    }
    final dateStr = DateFormat('dd.MM.yyyy').format(state.selectedDate);
    final timeStr = TimeOfDay.fromDateTime(state.selectedDate).format(context);
    final title = widget.isIncome
        ? S.of(context).addIncome
        : S.of(context).addExpense;
    final isSaving = state is TransactionAddSaving;
    return Center(
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        child: Container(
          color: Theme.of(context).colorScheme.surface,
          width: double.infinity,
          constraints: const BoxConstraints(maxWidth: 500),
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Шапка с закругленными углами
                BlocBuilder<SettingsBloc, SettingsState>(
                  builder: (context, settingsState) {
                    Color headerColor = Colors.green; // Цвет по умолчанию
                    if (settingsState is SettingsLoaded) {
                      headerColor = settingsState.primaryColor;
                    }
                    
                    return Container(
                      decoration: BoxDecoration(
                        color: headerColor,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        children: [
                          IconButton(
                            icon: Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.pop(context),
                          ),
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          IconButton(
                            icon: isSaving
                                ? SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : Icon(
                                    Icons.check,
                                    color: Colors.white,
                                  ),
                            onPressed: isSaving
                                ? null
                                : () => _validateAndSave(context, state),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                Expanded(
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
                                  (state.account!.name.trim().isEmpty))
                              ? S.of(context).account
                              : state.account!.name,
                          onTap: isSaving
                              ? () {}
                              : () => _selectAccount(
                                  context,
                                  state.accounts,
                                  state.account,
                                ),
                        ),
                        MyListTileRow(
                          title: S.of(context).category,
                          value: state.selectedCategory?.name ?? '',
                          onTap: isSaving
                              ? () {}
                              : () => _selectCategory(
                                  context,
                                  state.categories,
                                ),
                        ),
                        MyListTileRow(
                          title: S.of(context).amount,
                          value: state.amount.isEmpty
                              ? S.of(context).enter
                              : '${state.amount} ₽',
                          onTap: isSaving
                              ? () {}
                              : () => _selectAmount(context, state.amount),
                        ),
                        MyListTileRow(
                          title: S.of(context).date,
                          value: dateStr,
                          onTap: isSaving
                              ? () {}
                              : () =>
                                    _selectDate(context, state.selectedDate),
                        ),
                        MyListTileRow(
                          title: S.of(context).time,
                          value: timeStr,
                          onTap: isSaving
                              ? () {}
                              : () =>
                                    _selectTime(context, state.selectedDate),
                        ),
                        const SizedBox(height: 16),
                        TransactionCommentField(
                          controller: _commentController,
                          enabled: !isSaving,
                          onChanged: (comment) => context
                              .read<TransactionAddBloc>()
                              .add(TransactionAddCommentChanged(comment)),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _validateAndSave(BuildContext context, dynamic state) {
    if (state is! TransactionAddLoaded && state is! TransactionAddSaving) {
      return;
    }

    final errors = <String>[];

    if (state.account == null) {
      errors.add(S.of(context).selectAccount);
    }

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
      builder: (c) => AccountSelectSheet(
        accounts: accounts,
        onSelect: (acc) => Navigator.pop(c, acc),
        onCreateAccount: () async {
          Navigator.pop(c);
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
            bloc.add(TransactionAddInitialized(widget.isIncome));
          }
        },
      ),
    );
    if (res != null) {
      context.read<AccountBloc>().add(SelectAccount(res.id));
      bloc.add(TransactionAddAccountChanged(res));
    }
  }

  Future<void> _selectCategory(
    BuildContext context,
    List<Category> categories,
  ) async {
    final bloc = context.read<TransactionAddBloc>();

    final res = await showModalBottomSheet<Category>(
      context: context,
      builder: (c) => CategorySelectSheet(
        categories: categories, // Передаем все категории, фильтрация будет в CategorySelectSheet
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
      lastDate: DateTime.now(),
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
