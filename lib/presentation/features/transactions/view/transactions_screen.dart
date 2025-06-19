import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/transactions_bloc.dart';
import '../bloc/transactions_event.dart';
import '../bloc/transactions_state.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/presentation/widgets/item_list_tile.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class TransactionsScreen extends StatelessWidget {
  final bool isIncome;
  const TransactionsScreen({Key? key, required this.isIncome})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => TransactionsBloc(
        transactionRepository: context.read<TransactionRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )..add(TransactionsLoad(isIncome: isIncome)),
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
              title: Text(isIncome ? 'Доходы сегодня' : 'Расходы сегодня'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.history),
                  onPressed: () {
                    // TODO: переход в историю
                  },
                ),
              ],
            ),
            body: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Всего',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(0)} ₽',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Text('Сортировка:'),
                      const SizedBox(width: 8),
                      DropdownButton<TransactionsSort>(
                        value: state.sort,
                        items: const [
                          DropdownMenuItem(
                            value: TransactionsSort.date,
                            child: Text('По дате'),
                          ),
                          DropdownMenuItem(
                            value: TransactionsSort.amount,
                            child: Text('По сумме'),
                          ),
                        ],
                        onChanged: (sort) {
                          if (sort != null) {
                            context.read<TransactionsBloc>().add(
                              TransactionsChangeSort(sort),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: transactions.isEmpty
                      ? Center(
                          child: Text(
                            isIncome
                                ? 'Нет доходов за сегодня'
                                : 'Нет расходов за сегодня',
                          ),
                        )
                      : ListView.separated(
                          itemCount: transactions.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final t = transactions[index];
                            final cat = categories.firstWhere(
                              (c) => c.id == t.categoryId,
                              orElse: () => Category(
                                id: 0,
                                name: isIncome ? 'Доход' : 'Расход',
                                emoji: isIncome ? '💰' : '💸',
                                isIncome: isIncome,
                                color: '#E0E0E0',
                              ),
                            );
                            return MyItemListTile(
                              transaction: t,
                              category: cat,
                              bgColor: colorFor(cat.name).withOpacity(0.2),
                              onTap: () {
                                // TODO: переход к редактированию
                              },
                            );
                          },
                        ),
                ),
              ],
            ),
            floatingActionButton: FloatingActionButton(
              heroTag: isIncome ? 'income_fab' : 'expense_fab',
              backgroundColor: Colors.green,
              onPressed: () {
                // TODO: переход к добавлению операции
              },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
