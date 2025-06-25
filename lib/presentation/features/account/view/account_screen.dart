import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:cashnetic/presentation/features/account_edit/account_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/option_row.dart';
import '../widgets/balance_bar_chart.dart';
import 'package:shake/shake.dart';

@RoutePage()
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isBalanceHidden = false;
  ShakeDetector? _shakeDetector;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (detector) {
        if (mounted) {
          setState(() {
            _isBalanceHidden = !_isBalanceHidden;
          });
        }
      },
    );
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is AccountError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! AccountLoaded) {
          return const SizedBox.shrink();
        }
        final account = state.account;
        final accounts = state.accounts;
        final selectedAccountId = state.selectedAccountId;
        final selectedAccountIds = state.selectedAccountIds;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Мой счёт'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final updatedModel = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AccountEditScreen(account: account),
                    ),
                  );
                  if (updatedModel != null) {
                    context.read<AccountBloc>().add(
                      UpdateAccount(updatedModel),
                    );
                  }
                },
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<AccountBloc>().add(LoadAccount()),
            tooltip: 'Обновить',
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          body: Column(
            children: [
              // Вкладка выбора счетов (мультивыбор)
              if (accounts.length > 1)
                Container(
                  width: double.infinity,
                  color: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: accounts.map((acc) {
                        final isSelected = selectedAccountIds.contains(acc.id);
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(acc.name),
                                const SizedBox(width: 6),
                                Icon(
                                  Icons.account_balance_wallet,
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.green,
                                  size: 20,
                                ),
                              ],
                            ),
                            selected: isSelected,
                            selectedColor: Colors.green,
                            backgroundColor: Colors.white,
                            checkmarkColor: Colors.white,
                            labelStyle: TextStyle(
                              color: isSelected ? Colors.white : Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                            onSelected: (val) {
                              final newSelected = List<int>.from(
                                selectedAccountIds,
                              );
                              if (val) {
                                newSelected.add(acc.id);
                              } else {
                                newSelected.remove(acc.id);
                              }
                              if (newSelected.isNotEmpty) {
                                context.read<AccountBloc>().add(
                                  SelectAccounts(newSelected),
                                );
                              }
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              Container(
                color: Colors.green.withOpacity(0.2),
                child: Column(
                  children: [
                    OptionRow(
                      icon: Icons.account_balance_wallet,
                      label: 'Баланс',
                      value: '',
                      onTap: () {
                        setState(() {
                          _isBalanceHidden = !_isBalanceHidden;
                        });
                      },
                      trailing: Icon(
                        _isBalanceHidden
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: _isBalanceHidden
                            ? Text(
                                '****',
                                key: const ValueKey('hidden'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  letterSpacing: 6,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : Text(
                                NumberFormat.currency(
                                  symbol: account.currency,
                                  decimalDigits: 0,
                                ).format(double.tryParse(account.balance) ?? 0),
                                key: const ValueKey('visible'),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                    const Divider(height: 1),
                    OptionRow(
                      icon: Icons.currency_exchange,
                      label: 'Валюта',
                      value: account.currency,
                      onTap: () => _showCurrencyPicker(context, account),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: BalanceBarChart(points: state.dailyPoints),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, AccountDTO account) async {
    final sel = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('₽ Российский рубль'),
            onTap: () => Navigator.pop(context, '₽'),
          ),
          ListTile(
            title: const Text('\$ Доллар'),
            onTap: () => Navigator.pop(context, '\$'),
          ),
          ListTile(
            title: const Text('€ Евро'),
            onTap: () => Navigator.pop(context, '€'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Отмена'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    if (sel != null && sel != account.currency) {
      context.read<AccountBloc>().add(UpdateAccountCurrency(sel));
    }
  }
}
