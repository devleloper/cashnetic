import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/account/repositories/account_repository.dart';
import 'dart:async';
import 'package:cashnetic/di/di.dart';
import 'package:cashnetic/presentation/features/account_edit/repositories/account_edit_repository.dart';
import 'package:cashnetic/presentation/features/account_edit/bloc/account_edit_bloc.dart';
import 'package:cashnetic/presentation/features/account_edit/bloc/account_edit_event.dart';
import 'package:cashnetic/presentation/features/account_edit/bloc/account_edit_state.dart';

class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _controllers = {};
  final Map<int, TextEditingController> _nameControllers = {};
  final Map<int, Timer?> _debounceTimers = {};
  bool _isProcessing = false;

  Future<void> _moveTransactionsAndDeleteAccount(
    BuildContext context,
    int fromAccountId,
    int toAccountId,
  ) async {
    setState(() => _isProcessing = true);
    final transactionRepo = getIt<TransactionsRepository>();
    final accountRepo = getIt<AccountRepository>();
    await transactionRepo.moveTransactionsToAccount(fromAccountId, toAccountId);
    await accountRepo.deleteAccount(fromAccountId);
    setState(() => _isProcessing = false);
    context.read<AccountBloc>().add(LoadAccount());
  }

  Future<int?> _showAccountSelectDialog(
    BuildContext context,
    List<Account> accounts,
    int excludeId,
  ) async {
    return showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).selectAccountToTransfer),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: accounts
                .where((a) => a.id != excludeId)
                .map(
                  (a) => ListTile(
                    title: Text(
                      a.name.trim().isEmpty ? S.of(context).account : a.name,
                    ),
                    onTap: () => Navigator.pop(ctx, a.id),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    for (final c in _controllers.values) {
      c.dispose();
    }
    for (final c in _nameControllers.values) {
      c.dispose();
    }
    for (final t in _debounceTimers.values) {
      t?.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is! AccountLoaded) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        final accounts = state.accounts;
        return Stack(
          children: [
            Scaffold(
              appBar: AppBar(
                title: Text(S.of(context).editAccounts),
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: () async {
                      if (_formKey.currentState?.validate() ?? false) {
                        final accountBloc = context.read<AccountBloc>();
                        for (final acc in accounts) {
                          final ctrl = _controllers[acc.id];
                          if (ctrl == null) continue;
                          final newBalance = double.tryParse(
                            ctrl.text.replaceAll(',', '.'),
                          );
                          if (newBalance != null &&
                              newBalance != acc.moneyDetails.balance) {
                            accountBloc.add(
                              UpdateAccount(
                                acc.copyWith(
                                  moneyDetails: acc.moneyDetails.copyWith(
                                    balance: newBalance,
                                  ),
                                ),
                              ),
                            );
                          }
                        }
                        accountBloc.add(LoadAccount());
                        Navigator.pop(context);
                      }
                    },
                  ),
                ],
              ),
              body: Padding(
                padding: EdgeInsets.only(top: 10),
                child: Form(
                  key: _formKey,
                  child: ListView.separated(
                    itemCount: accounts.length,
                    separatorBuilder: (_, __) => Column(
                      children: const [
                        SizedBox(height: 10),
                        Divider(
                          height: 1,
                          thickness: 1,
                          color: Color(0x22000000),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                    itemBuilder: (context, idx) {
                      final acc = accounts[idx];
                      _controllers.putIfAbsent(
                        acc.id,
                        () => TextEditingController(
                          text: acc.moneyDetails.balance.toStringAsFixed(0),
                        ),
                      );
                      _nameControllers.putIfAbsent(
                        acc.id,
                        () => TextEditingController(text: acc.name),
                      );
                      return BlocProvider<AccountEditBloc>(
                        create: (_) =>
                            AccountEditBloc()..add(AccountEditInitialized(acc)),
                        child: BlocBuilder<AccountEditBloc, AccountEditState>(
                          builder: (context, state) {
                            if (state is! AccountEditLoaded) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            return ListTile(
                              title: TextField(
                                controller: _nameControllers[acc.id],
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                                onChanged: (val) {
                                  if (val.trim().isEmpty || val == acc.name)
                                    return;
                                  _debounceTimers[acc.id]?.cancel();
                                  _debounceTimers[acc.id] = Timer(
                                    const Duration(milliseconds: 600),
                                    () {
                                      context.read<AccountEditBloc>().add(
                                        AccountEditNameChanged(val.trim()),
                                      );
                                    },
                                  );
                                },
                              ),
                              subtitle: null,
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Text(
                                      acc.moneyDetails.currency,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                    onPressed: () async {
                                      final sel =
                                          await showModalBottomSheet<String>(
                                            context: context,
                                            builder: (_) =>
                                                SingleChildScrollView(
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      ListTile(
                                                        title: Text(
                                                          S
                                                              .of(context)
                                                              .russianRuble,
                                                        ),
                                                        onTap: () =>
                                                            Navigator.pop(
                                                              context,
                                                              '₽',
                                                            ),
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          S.of(context).dollar,
                                                        ),
                                                        onTap: () =>
                                                            Navigator.pop(
                                                              context,
                                                              ' 4',
                                                            ),
                                                      ),
                                                      ListTile(
                                                        title: Text(
                                                          S.of(context).euro,
                                                        ),
                                                        onTap: () =>
                                                            Navigator.pop(
                                                              context,
                                                              '€',
                                                            ),
                                                      ),
                                                      const Divider(),
                                                      ListTile(
                                                        title: Text(
                                                          S.of(context).cancel,
                                                        ),
                                                        onTap: () =>
                                                            Navigator.pop(
                                                              context,
                                                            ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                          );
                                      if (sel != null &&
                                          sel != acc.moneyDetails.currency) {
                                        context.read<AccountEditBloc>().add(
                                          AccountEditCurrencyChanged(sel),
                                        );
                                      }
                                    },
                                  ),
                                  SizedBox(
                                    width: 100,
                                    child: TextFormField(
                                      controller: _controllers[acc.id],
                                      keyboardType:
                                          TextInputType.numberWithOptions(
                                            decimal: true,
                                          ),
                                      decoration: InputDecoration(
                                        labelText: S.of(context).balance,
                                        border: OutlineInputBorder(),
                                        isDense: true,
                                      ),
                                      validator: (val) {
                                        if (val == null || val.isEmpty) {
                                          return 'Enter a number';
                                        }
                                        final n = double.tryParse(
                                          val.replaceAll(',', '.'),
                                        );
                                        if (n == null)
                                          return S.of(context).onlyANumber;
                                        return null;
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      final action =
                                          await showDialog<_DeleteAction>(
                                            context: context,
                                            builder: (ctx) => AlertDialog(
                                              title: Text(
                                                S.of(context).deleteAccount,
                                              ),
                                              content: Text(
                                                S
                                                    .of(context)
                                                    .moveAllTransactionsToAnotherAccount,
                                              ),
                                              actions: [
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(
                                                        ctx,
                                                        _DeleteAction.move,
                                                      ),
                                                  child: Text(
                                                    S
                                                        .of(context)
                                                        .moveToAnotherAccount,
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () =>
                                                      Navigator.pop(ctx, null),
                                                  child: Text(
                                                    S.of(context).cancel,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          );
                                      if (action == _DeleteAction.move) {
                                        final toId =
                                            await _showAccountSelectDialog(
                                              context,
                                              accounts,
                                              acc.id,
                                            );
                                        if (toId != null) {
                                          await _moveTransactionsAndDeleteAccount(
                                            context,
                                            acc.id,
                                            toId,
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
            if (_isProcessing)
              Container(
                color: Colors.black.withOpacity(0.2),
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        );
      },
    );
  }
}

enum _DeleteAction { move }
