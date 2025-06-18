import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/models/models.dart';
import 'package:cashnetic/presentation/features/transaction_add/view/transaction_add_screen.dart';
import 'package:cashnetic/presentation/features/transaction_edit/view/transaction_edit_screen.dart';
import 'package:cashnetic/utils/format_currency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import '../../history/history.dart';
import '../bloc/incomes_bloc.dart';
import '../bloc/incomes_state.dart';
import '../bloc/incomes_event.dart';

@RoutePage()
class IncomesScreen extends StatelessWidget {
  const IncomesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => IncomesBloc(
        transactionRepository: context.read<TransactionRepository>(),
        categoryRepository: context.read<CategoryRepository>(),
      )..add(LoadIncomes()),
      child: BlocConsumer<IncomesBloc, IncomesState>(
        listener: (context, state) {
          if (state is IncomesError) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is IncomesInitial || state is IncomesLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else if (state is IncomesError) {
            return Scaffold(
              appBar: _buildAppBar(context),
              body: Center(child: Text('Ошибка: ${state.message}')),
            );
          } else if (state is IncomesLoaded || state is IncomesRefreshing) {
            return _buildContent(context, state);
          }
          return const Scaffold(
            body: Center(child: Text('Неизвестное состояние')),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.green,
      elevation: 0,
      title: const Text(
        'Доходы сегодня',
        style: TextStyle(color: Colors.white),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history, color: Colors.white),
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const HistoryScreen(type: TransactionType.income),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildContent(BuildContext context, IncomesState state) {
    final incomes = state is IncomesLoaded
        ? state.incomes
        : (state as IncomesRefreshing).incomes;
    final total = state is IncomesLoaded
        ? state.total
        : (state as IncomesRefreshing).total;
    final isRefreshing = state is IncomesRefreshing;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: Column(
        children: [
          Container(
            color: const Color(0xFFD9F3DB),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Всего',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  '${formatCurrency(total)} ₽',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: incomes.isEmpty
                ? const Center(child: Text('Нет доходов за сегодня'))
                : RefreshIndicator(
                    onRefresh: () async {
                      context.read<IncomesBloc>().add(RefreshIncomes());
                    },
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: incomes.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (context, index) {
                        final transaction = incomes[index];
                        return ListTile(
                          title: Text(_getCategoryName(transaction.categoryId)),
                          subtitle: transaction.comment?.isNotEmpty == true
                              ? Text(
                                  transaction.comment!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                          trailing: Text(
                            '${formatCurrency(transaction.amount)} ₽',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => TransactionEditScreen(
                                  transaction: _convertToTransactionModel(
                                    transaction,
                                  ),
                                ),
                              ),
                            );
                            context.read<IncomesBloc>().add(RefreshIncomes());
                          },
                        );
                      },
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'income_fab',
        backgroundColor: Colors.green,
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  const TransactionAddScreen(type: TransactionType.income),
            ),
          );
          context.read<IncomesBloc>().add(RefreshIncomes());
        },
        child: const Icon(Icons.add, size: 32, color: Colors.white),
      ),
    );
  }

  String _getCategoryName(int? categoryId) {
    // TODO: получить название категории из репозитория
    // Пока возвращаем заглушку
    return 'Доход';
  }

  TransactionModel _convertToTransactionModel(Transaction transaction) {
    // TODO: создать маппер для конвертации domain Transaction в UI TransactionModel
    // Пока возвращаем заглушку
    return TransactionModel(
      id: transaction.id,
      categoryId: transaction.categoryId ?? 0,
      account: 'Сбербанк', // TODO: получить из репозитория аккаунтов
      categoryIcon: '💰', // TODO: получить из категории
      categoryTitle: _getCategoryName(transaction.categoryId),
      amount: transaction.amount,
      comment: transaction.comment,
      transactionDate: transaction.timestamp,
      type: TransactionType.income,
    );
  }
}
