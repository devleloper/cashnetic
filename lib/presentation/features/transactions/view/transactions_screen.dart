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
import 'package:cashnetic/presentation/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/presentation/features/history/view/history_screen.dart';
import 'package:cashnetic/router/router.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:cashnetic/data/models/category/category.dart';

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
                Container(
                  color: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Всего',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        '${total.toStringAsFixed(0)} ₽',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  color: Colors.green.withOpacity(0.2),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Text(
                        'Сортировка:',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 6),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green, width: 1),
                        ),
                        child: Padding(
                          padding: EdgeInsetsGeometry.symmetric(horizontal: 4),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TransactionsSort>(
                              value: state.sort,
                              icon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.green,
                                size: 20,
                              ),
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              isDense: true,
                              items: const [
                                DropdownMenuItem(
                                  value: TransactionsSort.date,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.calendar_today,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4),
                                      Text('По дате'),
                                    ],
                                  ),
                                ),
                                DropdownMenuItem(
                                  value: TransactionsSort.amount,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.attach_money,
                                        size: 16,
                                        color: Colors.green,
                                      ),
                                      SizedBox(width: 4),
                                      Text('По сумме'),
                                    ],
                                  ),
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
                          ),
                        ),
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
                              onTap: () async {
                                final model =
                                    TransactionDomainMapper.domainToModel(
                                      t,
                                      CategoryDTO(
                                        id: cat.id,
                                        name: cat.name,
                                        emoji: cat.emoji,
                                        isIncome: cat.isIncome,
                                        color: cat.color,
                                      ),
                                      'Сбербанк',
                                    );
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => TransactionEditScreen(
                                      transaction: model,
                                    ),
                                  ),
                                );
                                context.read<TransactionsBloc>().add(
                                  TransactionsLoad(isIncome: isIncome),
                                );
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
              onPressed: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TransactionAddScreen(isIncome: isIncome),
                  ),
                );
                context.read<TransactionsBloc>().add(
                  TransactionsLoad(isIncome: isIncome),
                );
              },
              child: const Icon(Icons.add, size: 32, color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}
