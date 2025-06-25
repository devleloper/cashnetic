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

class AccountEditScreen extends StatefulWidget {
  const AccountEditScreen({super.key});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<int, TextEditingController> _controllers = {};
  bool _isProcessing = false;

  Future<void> _deleteAccountAndTransactions(
    BuildContext context,
    int accountId,
  ) async {
    setState(() => _isProcessing = true);
    final transactionRepo = context.read<TransactionRepository>();
    final accountRepo = context.read<AccountRepository>();
    await transactionRepo.deleteTransactionsByAccount(accountId);
    await accountRepo.deleteAccount(accountId);
    final accountsResult = await accountRepo.getAllAccounts();
    final accounts = accountsResult.isRight()
        ? accountsResult.getOrElse(() => [])
        : [];
    if (accounts.isEmpty && mounted) {
      Navigator.pop(context);
    }
    setState(() => _isProcessing = false);
    context.read<AccountBloc>().add(LoadAccount());
  }

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
                            // Обновить баланс через BLoC
                            final updated = acc.copyWith(
                              moneyDetails: acc.moneyDetails.copyWith(
                                balance: newBalance,
                              ),
                            );
                            // Можно отправить UpdateAccount или аналогичный event
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
                        Navigator.pop(context);
                        accountBloc.add(LoadAccount());
                      }
                    },
                  ),
                ],
              ),
              body: Form(
                key: _formKey,
                child: ListView.separated(
                  itemCount: accounts.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, idx) {
                    final acc = accounts[idx];
                    _controllers.putIfAbsent(
                      acc.id,
                      () => TextEditingController(
                        text: acc.moneyDetails.balance.toStringAsFixed(0),
                      ),
                    );
                    return ListTile(
                      title: Text(acc.name),
                      subtitle: Text(acc.moneyDetails.currency),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
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
                                      onPressed: () => Navigator.pop(ctx, null),
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
