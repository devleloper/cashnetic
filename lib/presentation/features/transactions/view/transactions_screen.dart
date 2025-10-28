import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/widgets/transactions_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/presentation/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/presentation/features/history/view/history_screen.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import '../widgets/transactions_total_row.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/presentation/features/transactions/widgets/transactions_fly_chip.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';
import 'package:cashnetic/domain/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:cashnetic/main.dart';
import 'dart:async';

@RoutePage()
class TransactionsScreen extends StatefulWidget {
  final bool isIncome;
  TransactionsScreen({Key? key, required this.isIncome}) : super(key: key);

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final Key historyIconKey = UniqueKey();
  final Key fabKey = UniqueKey();
  SyncStatus? _lastSyncStatus;
  Completer<void>? _refreshCompleter;
  SyncStatusNotifier? _syncStatusNotifier;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<SyncStatusNotifier>(context);
    if (_syncStatusNotifier != notifier) {
      _syncStatusNotifier?.removeListener(_onSyncStatusChanged);
      _syncStatusNotifier = notifier;
      _syncStatusNotifier?.addListener(_onSyncStatusChanged);
    }
  }

  void _onSyncStatusChanged() {
    final syncStatusNotifier = _syncStatusNotifier;
    if (syncStatusNotifier == null) return;
    if (_lastSyncStatus == syncStatusNotifier.status) return;
    _lastSyncStatus = syncStatusNotifier.status;
    if (syncStatusNotifier.status == SyncStatus.online) {
      if (mounted) {
        context.read<TransactionsBloc>().add(
          TransactionsLoad(
            isIncome: widget.isIncome,
            accountId: ALL_ACCOUNTS_ID,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _syncStatusNotifier?.removeListener(_onSyncStatusChanged);
    super.dispose();
  }


  String _getCategoryEmoji(BuildContext context, int categoryId) {
    final state = BlocProvider.of<TransactionsBloc>(context).state;
    if (state is TransactionsLoaded) {
      if (state.categories.isEmpty) return '❓';
      final cat = state.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(
          id: 0,
          name: '',
          emoji: '❓',
          isIncome: widget.isIncome,
          color: '#FFF',
        ),
      );
      return cat.emoji;
    }
    return '❓';
  }

  String _getCategoryName(BuildContext context, int categoryId) {
    final bloc = BlocProvider.of<TransactionsBloc>(context);
    final state = bloc.state;
    if (state is TransactionsLoaded) {
      final cat = state.categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => Category(
          id: 0,
          name: S.of(context).expense,
          emoji: '💸',
          isIncome: false,
          color: '#E0E0E0',
        ),
      );
      return cat.name;
    }
    return S.of(context).expense;
  }

  @override
  Widget build(BuildContext context) {
    // Get selected account from AccountBloc
    final accountState = context.watch<AccountBloc>().state;
    int accountId = ALL_ACCOUNTS_ID;
    if (accountState is AccountLoaded && accountState.accounts.isNotEmpty) {
      accountId = accountState.selectedAccountId;
    }
    return BlocConsumer<TransactionsBloc, TransactionsState>(
      listener: (context, state) {
        // API отключен - убираем предупреждения
        if (state is TransactionsError) {
          // Просто логируем ошибку, не показываем диалог
          debugPrint('Transactions error: ${state.message}');
        }
      },
      builder: (context, state) {
          // RefreshIndicator: complete only on Loaded/Error
          if (_refreshCompleter != null &&
              (state is TransactionsLoaded || state is TransactionsError)) {
            _refreshCompleter?.complete();
            _refreshCompleter = null;
          }
          if (state is TransactionsInitial || state is TransactionsLoading) {
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.isIncome
                      ? S.of(context).income
                      : S.of(context).expenses,
                ),
                actions: [
                  IconButton(
                    key: historyIconKey,
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              HistoryScreen(isIncome: widget.isIncome),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: const Center(
                child: CircularProgressIndicator(),
              ),
            );
          }
          if (state is TransactionsError) {
            // Always return a Scaffold so AlertDialog can be shown
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.isIncome
                      ? S.of(context).income
                      : S.of(context).expenses,
                ),
                actions: [
                  IconButton(
                    key: historyIconKey,
                    icon: const Icon(Icons.history),
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) =>
                              HistoryScreen(isIncome: widget.isIncome),
                        ),
                      );
                    },
                  ),
                ],
              ),
              body: RefreshIndicator(
                onRefresh: () async {
                  _refreshCompleter = Completer<void>();
                  context.read<TransactionsBloc>().add(
                    TransactionsLoad(
                      isIncome: widget.isIncome,
                      accountId: accountId,
                    ),
                  );
                  return _refreshCompleter!.future;
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Text(
                          'No transactions.',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }
          if (state is! TransactionsLoaded) {
            return const SizedBox.shrink();
          }
          final transactions = state.transactions;
          final categories = state.categories;
          final total = state.total;
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.isIncome ? S.of(context).income : S.of(context).expenses,
              ),
              actions: [
                IconButton(
                  key: historyIconKey,
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) =>
                            HistoryScreen(isIncome: widget.isIncome),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                if (state.isLocalFallback)
                  Container(
                    width: double.infinity,
                    color: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: const Center(
                      child: Text(
                        'Offline mode',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                TransactionsTotalRow(total: total),
                const SizedBox(height: 8),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      _refreshCompleter = Completer<void>();
                      context.read<TransactionsBloc>().add(
                        TransactionsLoad(
                          isIncome: widget.isIncome,
                          accountId: accountId,
                        ),
                      );
                      return _refreshCompleter!.future;
                    },
                    child: transactions.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(
                                height: MediaQuery.of(context).size.height * 0.5,
                                child: Center(
                                  child: Text(
                                    'No transactions.',
                                    style: TextStyle(fontSize: 18, color: Colors.grey),
                                  ),
                                ),
                              ),
                            ],
                          )
                        : TransactionsListView(
                            transactions: transactions,
                            categories: categories,
                            isIncome: widget.isIncome,
                            onTap: (t, cat) async {
                              // Get account name and currency from AccountBloc
                              String accountName = S.of(context).account;
                              String currency = 'RUB';
                              final accountState = context
                                  .read<AccountBloc>()
                                  .state;
                              if (accountState is AccountLoaded &&
                                  accountState.accounts.isNotEmpty) {
                                final acc = accountState.accounts.firstWhere(
                                  (a) => a.id == t.accountId,
                                  orElse: () => accountState.accounts.first,
                                );
                                accountName = acc.name;
                                currency = acc.moneyDetails.currency;
                              }
                              // Open transaction edit screen as modal
                              final result = await showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) {
                                  final mq = MediaQuery.of(context);
                                  final maxChildSize =
                                      (mq.size.height - mq.padding.top) /
                                      mq.size.height;
                                  return DraggableScrollableSheet(
                                    initialChildSize: 0.85,
                                    minChildSize: 0.4,
                                    maxChildSize: maxChildSize,
                                    expand: false,
                                    builder: (context, scrollController) =>
                                        TransactionEditScreen(
                                          transactionId: t.id,
                                        ),
                                  );
                                },
                              );
                              if (result == true) {
                                context.read<TransactionsBloc>().add(
                                  TransactionsLoad(
                                    isIncome: widget.isIncome,
                                    accountId: accountId,
                                  ),
                                );
                              }
                            },
                          ),
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: 'transactions_fab_${widget.isIncome ? 'income' : 'expense'}',
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: const Icon(Icons.add, color: Colors.white),
              onPressed: () async {
                final result = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) {
                    final mq = MediaQuery.of(context);
                    final maxChildSize =
                        (mq.size.height - mq.padding.top) / mq.size.height;
                    return DraggableScrollableSheet(
                      initialChildSize: 0.85,
                      minChildSize: 0.4,
                      maxChildSize: maxChildSize,
                      expand: false,
                      builder: (context, scrollController) =>
                          TransactionAddScreen(isIncome: widget.isIncome),
                    );
                  },
                );
                if (result == true) {
                  context.read<TransactionsBloc>().add(
                    TransactionsLoad(
                      isIncome: widget.isIncome,
                      accountId: accountId,
                    ),
                  );
                }
              },
            ),
          );
        },
      );
    
  }
}
