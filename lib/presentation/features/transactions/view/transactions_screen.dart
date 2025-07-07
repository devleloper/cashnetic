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

@RoutePage()
class TransactionsScreen extends StatelessWidget {
  final bool isIncome;
  final GlobalKey historyIconKey = GlobalKey();
  final GlobalKey fabKey = GlobalKey();
  TransactionsScreen({Key? key, required this.isIncome}) : super(key: key);

  void _animateTransactionToHistory(
    BuildContext context,
    Transaction tx,
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
          isIncome: isIncome,
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
    // accountId всегда 0 — показываем все транзакции

    return BlocProvider(
      create: (context) => TransactionsBloc(
        transactionRepository: getIt<TransactionsRepository>(),
        categoryRepository: getIt<CategoriesRepository>(),
      )..add(TransactionsLoad(isIncome: isIncome, accountId: 0)),
      child: BlocBuilder<TransactionsBloc, TransactionsState>(
        builder: (context, state) {
          if (state is TransactionsLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          if (state is TransactionsError) {
            return Scaffold(body: Center(child: Text(state.message)));
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
                isIncome ? S.of(context).income : S.of(context).expenses,
              ),
              actions: [
                IconButton(
                  key: historyIconKey,
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => HistoryScreen(isIncome: isIncome),
                      ),
                    );
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                TransactionsTotalRow(total: total),

                const SizedBox(height: 8),
                Expanded(
                  child: TransactionsListView(
                    transactions: transactions,
                    categories: categories,
                    isIncome: isIncome,
                    onTap: (t, cat) async {
                      // Получаем имя и валюту аккаунта из AccountBloc
                      String accountName = S.of(context).account;
                      String currency = 'RUB';
                      final accountState = context.read<AccountBloc>().state;
                      if (accountState is AccountLoaded) {
                        final acc = accountState.accounts.firstWhere(
                          (a) => a.id == t.accountId,
                          orElse: () => accountState.accounts.first,
                        );
                        accountName = acc.name;
                        currency = acc.moneyDetails.currency;
                      }
                      // Открыть экран редактирования операции модально
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
                        TransactionsLoad(isIncome: isIncome, accountId: 0),
                      );
                    },
                  ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              key: fabKey,
              heroTag: isIncome ? 'income_fab' : 'expense_fab',
              backgroundColor: Colors.green,
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
                      initialChildSize: 0.7,
                      minChildSize: 0.4,
                      maxChildSize: maxChildSize,
                      expand: false,
                      builder: (context, scrollController) =>
                          TransactionAddScreen(isIncome: isIncome),
                    );
                  },
                );
                context.read<TransactionsBloc>().add(
                  TransactionsLoad(isIncome: isIncome, accountId: 0),
                );
                if (result != null &&
                    result is Map &&
                    result['animateToHistory'] == true) {
                  _animateTransactionToHistoryCustom(
                    context,
                    result['emoji'] as String? ?? '💸',
                    result['color'] as Color? ?? const Color(0xFFE6F4EA),
                    fabKey,
                    historyIconKey,
                  );
                }
              },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

// Добавить функцию для анимации с emoji и цветом
void _animateTransactionToHistoryCustom(
  BuildContext context,
  String emoji,
  Color bgColor,
  GlobalKey fabKey,
  GlobalKey historyIconKey,
) async {
  final overlay = Overlay.of(context);
  if (overlay == null) return;
  final fabBox = fabKey.currentContext?.findRenderObject() as RenderBox?;
  final historyBox =
      historyIconKey.currentContext?.findRenderObject() as RenderBox?;
  Offset fabOffset = Offset.zero;
  Offset historyOffset = Offset.zero;
  try {
    if (fabBox != null) {
      fabOffset =
          fabBox.localToGlobal(Offset.zero) +
          Offset(fabBox.size.width / 2, fabBox.size.height / 2);
    }
    if (historyBox != null) {
      final position = historyBox.localToGlobal(Offset.zero);
      final size = historyBox.size;
      historyOffset = position + Offset(size.width / 2, size.height / 2);
    }
  } catch (_) {}
  if (fabOffset == Offset.zero || historyOffset == Offset.zero) return;
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
