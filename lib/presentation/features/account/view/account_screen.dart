import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:cashnetic/presentation/features/account_edit/account_edit.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'dart:ui';
import '../widgets/option_row.dart';
import '../widgets/balance_bar_chart.dart';
import '../widgets/unavailable_feature_dialog.dart';

@RoutePage()
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final bool _showUnavailableDialog = true;

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

        return Stack(
          children: [
            // Основной экран
            Scaffold(
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
                  Container(
                    color: Colors.green.withOpacity(0.2),
                    child: Column(
                      children: [
                        OptionRow(
                          icon: Icons.account_balance_wallet,
                          label: 'Баланс',
                          value: NumberFormat.currency(
                            symbol: account.currency,
                            decimalDigits: 0,
                          ).format(double.tryParse(account.balance) ?? 0),
                          onTap: () async {
                            final updatedModel = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    AccountEditScreen(account: account),
                              ),
                            );
                            if (updatedModel != null) {
                              context.read<AccountBloc>().add(
                                UpdateAccount(updatedModel),
                              );
                            }
                          },
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
            ),
            // Блюр + AlertDialog поверх
            if (_showUnavailableDialog) const UnavailableFeatureDialog(),
          ],
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
