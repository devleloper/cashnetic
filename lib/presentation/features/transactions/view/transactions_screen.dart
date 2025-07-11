import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/widgets/transactions_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
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
import 'package:cashnetic/di/di.dart';
import 'package:cashnetic/presentation/theme/light_color_for.dart';
import 'package:cashnetic/domain/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:cashnetic/main.dart';
import 'package:cashnetic/presentation/widgets/shimmer_placeholder.dart';

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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(context);
    syncStatusNotifier.removeListener(_onSyncStatusChanged); // just in case
    syncStatusNotifier.addListener(_onSyncStatusChanged);
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
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    syncStatusNotifier.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  void _animateTransactionToHistory(
    BuildContext context,
    Transaction tx,
    GlobalKey historyIconKey,
  ) async {
    final overlay = Overlay.of(context);

    final fabBox = context.findRenderObject() as RenderBox?;
    Offset fabOffset = Offset.zero;
    try {
      fabOffset =
          fabBox?.localToGlobal(fabBox.size.center(Offset.zero)) ?? Offset.zero;
    } catch (_) {}

    final historyBox =
        historyIconKey.currentContext?.findRenderObject() as RenderBox?;
    Offset historyOffset = Offset.zero;
    try {
      if (historyBox != null) {
        final position = historyBox.localToGlobal(Offset.zero);
        final size = historyBox.size;
        final double relativeOffsetX = size.width * 2.7;
        historyOffset =
            position +
            Offset(size.width / 2 + relativeOffsetX, size.height / 2);
      }
    } catch (_) {}

    if (fabOffset == Offset.zero || historyOffset == Offset.zero) return;
    String emoji = '💸';
    String categoryName = S.of(context).expense;
    Color bgColor = Color(0xFFE6F4EA);
    try {
      emoji = _getCategoryEmoji(context, tx.categoryId ?? 0);
      categoryName = _getCategoryName(context, tx.categoryId ?? 0);
      bgColor = colorFor(categoryName).withOpacity(0.2);
    } catch (_) {}
    if (emoji.isEmpty) emoji = '💸';

    final entry = OverlayEntry(
      builder: (context) {
        return TransactionsFlyChip(
          start: fabOffset,
          end: historyOffset,
          emoji: emoji,
          bgColor: bgColor,
        );
      },
    );
    overlay.insert(entry);
    await Future.delayed(const Duration(milliseconds: 1700));
    entry.remove();
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
    return BlocProvider(
      create: (context) => TransactionsBloc(
        transactionRepository: getIt<TransactionsRepository>(),
        categoryRepository: getIt<CategoriesRepository>(),
      )..add(TransactionsLoad(isIncome: widget.isIncome, accountId: accountId)),
      child: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
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
                    icon: const Icon(Icons.history, color: Colors.white),
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
              body: const ShimmerTransactionListPlaceholder(),
            );
          }
          if (state is TransactionsError) {
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
                    icon: const Icon(Icons.history, color: Colors.white),
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
              body: Center(child: Text(state.message)),
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
                  icon: const Icon(Icons.history, color: Colors.white),
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
                  child: TransactionsListView(
                    transactions: transactions,
                    categories: categories,
                    isIncome: widget.isIncome,
                    onTap: (t, cat) async {
                      // Get account name and currency from AccountBloc
                      String accountName = S.of(context).account;
                      String currency = 'RUB';
                      final accountState = context.read<AccountBloc>().state;
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
                      await showModalBottomSheet(
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
                                TransactionEditScreen(transactionId: t.id),
                          );
                        },
                      );
                      context.read<TransactionsBloc>().add(
                        TransactionsLoad(
                          isIncome: widget.isIncome,
                          accountId: accountId,
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              key: fabKey,
              heroTag: widget.isIncome ? 'income_fab' : 'expense_fab',
              backgroundColor: Colors.green,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        TransactionAddScreen(isIncome: widget.isIncome),
                  ),
                );
                context.read<TransactionsBloc>().add(
                  TransactionsLoad(
                    isIncome: widget.isIncome,
                    accountId: accountId,
                  ),
                );
                // FlyTransactionChip animation is no longer used
              },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
