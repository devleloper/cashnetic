import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/widgets/transactions_list_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/presentation/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/presentation/features/history/view/history_screen.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction/transaction.dart';
import '../widgets/transactions_total_row.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/presentation/features/transactions/widgets/transactions_fly_chip.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_state.dart';

@RoutePage()
class TransactionsScreen extends StatelessWidget {
  final bool isIncome;
  final GlobalKey historyIconKey = GlobalKey();
  TransactionsScreen({Key? key, required this.isIncome}) : super(key: key);

  void _animateTransactionToHistory(
    BuildContext context,
    TransactionDTO tx,
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
      emoji = _getCategoryEmoji(context, tx.categoryId);
      categoryName = _getCategoryName(context, tx.categoryId);
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
      final first = state.categories.first;
      if (first is CategoryDTO) {
        final cat = (state.categories as List<CategoryDTO>).firstWhere(
          (c) => c.id == categoryId,
          orElse: () => CategoryDTO(
            id: 0,
            name: '',
            emoji: '❓',
            isIncome: isIncome,
            color: '#FFF',
          ),
        );
        return cat.emoji;
      } else {
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
        transactionRepository: context.read<TransactionRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
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
                isIncome
                    ? S.of(context).incomeToday
                    : S.of(context).expensesToday,
              ),
              actions: [
                IconButton(
                  key: historyIconKey,
                  icon: const Icon(Icons.history, color: Colors.white),
                  onPressed: () {
                    Navigator.push(
                      context,
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
                      final model = TransactionDomainMapper.domainToModel(
                        t,
                        CategoryDTO(
                          id: cat.id,
                          name: cat.name,
                          emoji: cat.emoji,
                          isIncome: cat.isIncome,
                          color: cat.color,
                        ),
                        accountName,
                        currency: currency,
                      );
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              TransactionEditScreen(transaction: model),
                        ),
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
              heroTag: isIncome ? 'income_fab' : 'expense_fab',
              backgroundColor: Colors.green,
              onPressed: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionAddScreen(isIncome: isIncome),
                  ),
                );
                context.read<TransactionsBloc>().add(
                  TransactionsLoad(isIncome: isIncome, accountId: 0),
                );
                if (result != null &&
                    result is Map &&
                    result['animateToHistory'] == true) {
                  _animateTransactionToHistory(
                    context,
                    result['transaction'] as TransactionDTO,
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
