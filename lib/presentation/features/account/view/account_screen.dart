import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/data/models/account/account.dart';
import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:cashnetic/presentation/features/account_edit/account_edit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../widgets/option_row.dart';
import '../widgets/account_balance_chart.dart';
import 'package:shake/shake.dart';
import 'package:spoiler_widget/spoiler_widget.dart';
import 'dart:ui';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:cashnetic/main.dart';
import 'package:cashnetic/presentation/widgets/shimmer_placeholder.dart';

@RoutePage()
class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  bool _isBalanceHidden = false;
  ShakeDetector? _shakeDetector;
  Orientation? _lastOrientation;
  StreamSubscription<AccelerometerEvent>? _accelSub;
  bool? _lastFaceDown;
  SyncStatus? _lastSyncStatus;

  @override
  void initState() {
    super.initState();
    _shakeDetector = ShakeDetector.autoStart(
      onPhoneShake: (event) {
        if (mounted) {
          setState(() {
            _isBalanceHidden = !_isBalanceHidden;
          });
        }
      },
      minimumShakeCount: 2,
      shakeSlopTimeMS: 800,
      shakeThresholdGravity: 2.2,
    );
    _accelSub = accelerometerEvents.listen((event) {
      // z < 0 — screen down, z > 0 — screen up
      final isFaceDown = event.z < 0;
      if (_lastFaceDown != null && _lastFaceDown != isFaceDown) {
        setState(() {
          _isBalanceHidden = !_isBalanceHidden;
        });
      }
      _lastFaceDown = isFaceDown;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(context);
    syncStatusNotifier.removeListener(_onSyncStatusChanged); // just in case
    syncStatusNotifier.addListener(_onSyncStatusChanged);
    final orientation = MediaQuery.of(context).orientation;
    if (_lastOrientation != null && _lastOrientation != orientation) {
      setState(() {
        _isBalanceHidden = !_isBalanceHidden;
      });
    }
    _lastOrientation = orientation;
  }

  void _onSyncStatusChanged() {
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    if (_lastSyncStatus == syncStatusNotifier.status) return;
    _lastSyncStatus = syncStatusNotifier.status;
    if (syncStatusNotifier.status == SyncStatus.online) {
      if (mounted) {
        context.read<AccountBloc>().add(LoadAccount());
      }
    }
  }

  @override
  void dispose() {
    _shakeDetector?.stopListening();
    _accelSub?.cancel();
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    syncStatusNotifier.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AccountBloc, AccountState>(
      builder: (context, state) {
        if (state is AccountLoading) {
          return const ShimmerAccountScreenPlaceholder();
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
          floatingActionButton: FloatingActionButton(
            onPressed: () => context.read<AccountBloc>().add(LoadAccount()),
            tooltip: 'Refresh',
            child: const Icon(Icons.refresh, color: Colors.white),
          ),
          body: Column(
            children: [
              Container(
                width: double.infinity,
                color: Color(0xFFE6F4EA),
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
                              Text(
                                acc.name.trim().isEmpty
                                    ? S.of(context).account
                                    : acc.name,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                acc.moneyDetails?.currency ?? '',
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
                color: Color(0xFFE6F4EA),
                child: Column(
                  children: [
                    OptionRow(
                      icon: Icons.account_balance_wallet,
                      label: S.of(context).balance,
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
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeIn,
                        switchOutCurve: Curves.easeOut,
                        transitionBuilder: (child, animation) =>
                            FadeTransition(opacity: animation, child: child),
                        child: _BalanceSpoiler(
                          key: ValueKey(
                            _isBalanceHidden.toString() +
                                selectedCurrencies.join(','),
                          ),
                          isHidden: _isBalanceHidden,
                          state: state,
                          accounts: accounts,
                          selectedAccountIds: selectedAccountIds,
                          aggregatedBalances: aggregatedBalances,
                          selectedCurrencies: selectedCurrencies,
                          onTap: () {
                            setState(() {
                              _isBalanceHidden = !_isBalanceHidden;
                            });
                          },
                        ),
                      ),
                    ),
                    const Divider(height: 1),
                    OptionRow(
                      icon: Icons.currency_exchange,
                      label: S.of(context).currency,
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
                  child: AccountBalanceChart(points: state.dailyPoints),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showCurrencyPicker(BuildContext context, Account account) async {
    final sel = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(S.of(context).russianRuble),
            onTap: () => Navigator.pop(context, '₽'),
          ),
          ListTile(
            title: Text(S.of(context).dollar),
            onTap: () => Navigator.pop(context, '\$'),
          ),
          ListTile(
            title: const Text('€ Euro'),
            onTap: () => Navigator.pop(context, '€'),
          ),
          const Divider(),
          ListTile(
            title: Text(S.of(context).cancel),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    if (sel != null && sel != account.moneyDetails.currency) {
      context.read<AccountBloc>().add(UpdateAccountCurrency(sel));
    }
  }
}

class _BalanceSpoiler extends StatelessWidget {
  final bool isHidden;
  final AccountState state;
  final List<Account> accounts;
  final List<int> selectedAccountIds;
  final Map<String, double> aggregatedBalances;
  final List<String> selectedCurrencies;
  final VoidCallback onTap;

  const _BalanceSpoiler({
    Key? key,
    required this.isHidden,
    required this.state,
    required this.accounts,
    required this.selectedAccountIds,
    required this.aggregatedBalances,
    required this.selectedCurrencies,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (state is! AccountLoaded) return const SizedBox.shrink();
    final loaded = state as AccountLoaded;
    if (selectedCurrencies.length == 1) {
      return GestureDetector(
        onTap: onTap,
        child: SpoilerText(
          text: NumberFormat.currency(
            symbol: selectedCurrencies.first,
            decimalDigits: 0,
          ).format(loaded.computedBalance),
          config: TextSpoilerConfig(
            particleDensity: 2,
            particleColor: Colors.green,
            isEnabled: isHidden,
            enableFadeAnimation: true,
            enableGestureReveal: false,
            textStyle: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
      );
    } else {
      return GestureDetector(
        onTap: onTap,
        child: SpoilerOverlay(
          config: WidgetSpoilerConfig(
            particleDensity: 2,
            particleColor: Colors.green,
            isEnabled: isHidden,
            enableFadeAnimation: true,
            enableGestureReveal: false,
            fadeRadius: 3,
            imageFilter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: selectedCurrencies
                .map(
                  (cur) => Text(
                    NumberFormat.currency(symbol: cur, decimalDigits: 0).format(
                      accounts
                          .where((acc) => acc.moneyDetails?.currency == cur)
                          .map((acc) {
                            if (selectedAccountIds.length == 1) {
                              return loaded.computedBalance;
                            } else {
                              return aggregatedBalances[cur] ?? 0;
                            }
                          })
                          .fold<double>(0, (a, b) => a + (b is num ? b : 0)),
                    ),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      );
    }
  }
}
