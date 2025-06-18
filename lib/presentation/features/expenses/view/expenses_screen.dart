import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/data/mappers/transaction_mapper.dart';
import 'package:cashnetic/presentation/features/expenses/bloc/expenses_bloc.dart';
import 'package:cashnetic/presentation/features/expenses/bloc/expenses_event.dart';
import 'package:cashnetic/presentation/features/expenses/bloc/expenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../presentation.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';

@RoutePage()
class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ExpensesBloc>().add(LoadExpenses());
    context.read<CategoriesBloc>().add(LoadCategories());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpensesBloc, ExpensesState>(
      builder: (context, state) {
        if (state is ExpensesLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is ExpensesError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! ExpensesLoaded) {
          return const SizedBox.shrink();
        }
        final sorted = [...state.transactions]
          ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
        return BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, catState) {
            List<CategoryDTO> categories = [];
            if (catState is CategoriesLoaded) {
              categories = catState.categories;
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text('Расходы сегодня'),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.history, color: Colors.white),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const HistoryScreen(isIncome: false),
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
                        const Text(
                          'Всего',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Text(
                          '${state.total.toStringAsFixed(0)} ₽',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: state.transactions.isEmpty
                        ? const Center(child: Text('Нет расходов за сегодня'))
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: sorted.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final t = sorted[index];
                              final cat = categories.firstWhere(
                                (c) => c.id == t.categoryId,
                                orElse: () => CategoryDTO(
                                  id: 0,
                                  name: 'Расход',
                                  emoji: '💸',
                                  isIncome: false,
                                  color: '#E0E0E0',
                                ),
                              );
                              return MyItemListTile(
                                transaction: t,
                                category: cat,
                                bgColor: Colors.green.shade50,
                                onTap: () => _editTransaction(context, t, cat),
                              );
                            },
                          ),
                  ),
                ],
              ),
              floatingActionButton: MyFloatingActionButton(
                icon: Icons.add,
                onPressesd: () async {
                  await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const TransactionAddScreen(isIncome: false),
                    ),
                  );
                  context.read<ExpensesBloc>().add(LoadExpenses());
                },
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _editTransaction(
    BuildContext context,
    Transaction transaction,
    CategoryDTO category,
  ) async {
    final transactionModel = TransactionDomainMapper.domainToModel(
      transaction,
      category,
      'Сбербанк', // TODO: получить реальное название аккаунта
    );

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TransactionEditScreen(transaction: transactionModel),
      ),
    );

    // Обновляем список после возврата с экрана редактирования
    context.read<ExpensesBloc>().add(LoadExpenses());
  }
}
