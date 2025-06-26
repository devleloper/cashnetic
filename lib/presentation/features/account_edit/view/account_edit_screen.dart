import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/account/account.dart';
import '../widgets/balance_edit_row.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/presentation/features/account_add/widgets/account_currency_picker.dart';
import 'dart:async';

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
    final transactionRepo = context.read<TransactionRepository>();
    final accountRepo = context.read<AccountRepository>();
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
        title: const Text('Выберите счет для переноса'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: accounts
                .where((a) => a.id != excludeId)
                .map(
                  (a) => ListTile(
                    title: Text(a.name),
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
                title: const Text('Редактировать счета'),
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
                                AccountDTO(
                                  id: acc.id,
                                  userId: acc.userId,
                                  name: acc.name,
                                  balance: newBalance.toString(),
                                  currency: acc.moneyDetails.currency,
                                  createdAt: acc.timeInterval.createdAt
                                      .toIso8601String(),
                                  updatedAt: DateTime.now().toIso8601String(),
                                ),
                              ),
                            );
                          }
                        }
                        // После всех обновлений обязательно обновить список счетов
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
                            if (val.trim().isEmpty || val == acc.name) return;
                            _debounceTimers[acc.id]?.cancel();
                            _debounceTimers[acc.id] = Timer(
                              const Duration(milliseconds: 600),
                              () {
                                context.read<AccountBloc>().add(
                                  UpdateAccount(
                                    AccountDTO(
                                      id: acc.id,
                                      userId: acc.userId,
                                      name: val.trim(),
                                      balance: acc.moneyDetails.balance
                                          .toString(),
                                      currency: acc.moneyDetails.currency,
                                      createdAt: acc.timeInterval.createdAt
                                          .toIso8601String(),
                                      updatedAt: DateTime.now()
                                          .toIso8601String(),
                                    ),
                                  ),
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
                                final sel = await showModalBottomSheet<String>(
                                  context: context,
                                  builder: (_) => Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ListTile(
                                        title: const Text('₽ Российский рубль'),
                                        onTap: () =>
                                            Navigator.pop(context, '₽'),
                                      ),
                                      ListTile(
                                        title: Text('\$ Доллар'),
                                        onTap: () =>
                                            Navigator.pop(context, '\$'),
                                      ),
                                      ListTile(
                                        title: const Text('€ Евро'),
                                        onTap: () =>
                                            Navigator.pop(context, '€'),
                                      ),
                                      const Divider(),
                                      ListTile(
                                        title: const Text('Отмена'),
                                        onTap: () => Navigator.pop(context),
                                      ),
                                    ],
                                  ),
                                );
                                if (sel != null &&
                                    sel != acc.moneyDetails.currency) {
                                  context.read<AccountBloc>().add(
                                    UpdateAccount(
                                      AccountDTO(
                                        id: acc.id,
                                        userId: acc.userId,
                                        name:
                                            _nameControllers[acc.id]?.text
                                                .trim() ??
                                            acc.name,
                                        balance: acc.moneyDetails.balance
                                            .toString(),
                                        currency: sel,
                                        createdAt: acc.timeInterval.createdAt
                                            .toIso8601String(),
                                        updatedAt: DateTime.now()
                                            .toIso8601String(),
                                      ),
                                    ),
                                  );
                                }
                              },
                            ),
                            SizedBox(
                              width: 100,
                              child: TextFormField(
                                controller: _controllers[acc.id],
                                keyboardType: TextInputType.numberWithOptions(
                                  decimal: true,
                                ),
                                decoration: const InputDecoration(
                                  labelText: 'Баланс',
                                  border: OutlineInputBorder(),
                                  isDense: true,
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty)
                                    return 'Введите число';
                                  final n = double.tryParse(
                                    val.replaceAll(',', '.'),
                                  );
                                  if (n == null) return 'Только число';
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final action = await showDialog<_DeleteAction>(
                                  context: context,
                                  builder: (ctx) => AlertDialog(
                                    title: const Text('Удалить счет?'),
                                    content: const Text(
                                      'Перенести все транзакции на другой счет?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(
                                          ctx,
                                          _DeleteAction.move,
                                        ),
                                        child: const Text(
                                          'Перенести на другой счет',
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Navigator.pop(ctx, null),
                                        child: const Text('Отмена'),
                                      ),
                                    ],
                                  ),
                                );
                                if (action == _DeleteAction.move) {
                                  final toId = await _showAccountSelectDialog(
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
