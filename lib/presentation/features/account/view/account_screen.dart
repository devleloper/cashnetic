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
        final aggregatedBalances = state.aggregatedBalances;
        final selectedCurrencies = state.selectedCurrencies;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Мой счета'),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () async {
                  final updatedModel = await Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => AccountEditScreen()),
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
              Container(
                width: double.infinity,
                color: Colors.green.withOpacity(0.2),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
                              Text(
                                acc.moneyDetails.currency,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                ),
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
                            : (selectedCurrencies.length == 1
                                  ? Text(
                                      NumberFormat.currency(
                                        symbol: selectedCurrencies.first,
                                        decimalDigits: 0,
                                      ).format(state.computedBalance),
                                      key: const ValueKey('visible'),
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    )
                                  : Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: selectedCurrencies
                                          .map(
                                            (cur) => Text(
                                              NumberFormat.currency(
                                                symbol: cur,
                                                decimalDigits: 0,
                                              ).format(
                                                accounts
                                                    .where(
                                                      (acc) =>
                                                          acc
                                                              .moneyDetails
                                                              .currency ==
                                                          cur,
                                                    )
                                                    .map((acc) {
                                                      final accDTO = AccountDTO(
                                                        id: acc.id,
                                                        userId: acc.userId,
                                                        name: acc.name,
                                                        balance: acc
                                                            .moneyDetails
                                                            .balance
                                                            .toString(),
                                                        currency: acc
                                                            .moneyDetails
                                                            .currency,
                                                        createdAt: acc
                                                            .timeInterval
                                                            .createdAt
                                                            .toIso8601String(),
                                                        updatedAt: acc
                                                            .timeInterval
                                                            .updatedAt
                                                            .toIso8601String(),
                                                      );
                                                      final points =
                                                          state.dailyPoints;
                                                      if (selectedAccountIds
                                                              .length ==
                                                          1) {
                                                        return state
                                                            .computedBalance;
                                                      } else {
                                                        return aggregatedBalances[cur] ??
                                                            0;
                                                      }
                                                    })
                                                    .fold<double>(
                                                      0,
                                                      (a, b) => a + b,
                                                    ),
                                              ),
                                              style: const TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          )
                                          .toList(),
                                    )),
                      ),
                    ),
                    const Divider(height: 1),
                    OptionRow(
                      icon: Icons.currency_exchange,
                      label: 'Валюта',
                      value: selectedCurrencies.length == 1
                          ? selectedCurrencies.first
                          : selectedCurrencies.join(', '),
                      onTap: (selectedCurrencies.length == 1)
                          ? () => _showCurrencyPicker(context, account)
                          : null,
                      trailing: selectedCurrencies.length == 1
                          ? const Icon(Icons.chevron_right, color: Colors.grey)
                          : const Icon(Icons.block, color: Colors.grey),
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
