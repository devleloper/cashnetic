import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/utils/category_utils.dart';
import '../../../widgets/floating_action_button.dart';
import '../../history/view/history_screen.dart';
import '../../transaction_add/view/transaction_add_screen.dart';
import '../bloc/expenses_bloc.dart';
import '../bloc/expenses_event.dart';
import '../bloc/expenses_state.dart';

@RoutePage()
class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExpensesBloc()..add(LoadExpensesEvent()),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Расходы сегодня'),
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const HistoryScreen(type: TransactionType.expense),
                  ),
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<ExpensesBloc, ExpensesState>(
          builder: (context, state) {
            if (state is ExpensesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExpensesLoaded) {
              final transactions = state.transactions;
              final total = state.total;

              if (transactions.isEmpty) {
                return const Center(child: Text('Нет расходов за сегодня'));
              }

              final sorted = [...transactions]
                ..sort((a, b) => b.timestamp.compareTo(a.timestamp));

              return Column(
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
                          '${total.toStringAsFixed(0)} ₽',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      itemCount: sorted.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final e = sorted[index];
                        final bgColor = colorFor(
                          e.categoryId.toString(),
                        ).withOpacity(0.2);
                        return MyTransactionListTile(
                          transaction: e,
                          bgColor: bgColor,
                        );
                      },
                    ),
                  ),
                ],
              );
            } else if (state is ExpensesError) {
              return Center(child: Text(state.message));
            }

            return const SizedBox.shrink();
          },
        ),
        floatingActionButton: MyFloatingActionButton(
          icon: Icons.add,
          onPressesd: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const TransactionAddScreen(type: TransactionType.expense),
              ),
            );

            context.read<ExpensesBloc>().add(LoadExpensesEvent());
          },
        ),
      ),
    );
  }
}

class MyTransactionListTile extends StatelessWidget {
  final Transaction transaction;
  final Color bgColor;
  final VoidCallback? onTap;

  const MyTransactionListTile({
    super.key,
    required this.transaction,
    required this.bgColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: bgColor,
        child: Text(
          '💸',
          style: const TextStyle(fontSize: 18),
        ), // TODO: Emoji по categoryId
      ),
      title: Text('Категория ${transaction.categoryId}'),
      subtitle: transaction.comment != null ? Text(transaction.comment!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${transaction.amount.toStringAsFixed(0)} ₽',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
