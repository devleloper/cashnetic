import 'package:cashnetic/ui/features/expenses/bloc/expenses_bloc.dart';
import 'package:cashnetic/ui/features/expenses/bloc/expenses_event.dart';
import 'package:cashnetic/ui/features/expenses/bloc/expenses_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../ui.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';

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
                      builder: (_) =>
                          const HistoryScreen(type: TransactionType.expense),
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
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final e = sorted[index];
                          // TODO: реализовать маппинг Transaction -> TransactionModel для MyItemListTile
                          return ListTile(
                            title: Text('ID: \\${e.id} | Сумма: \\${e.amount}'),
                            subtitle: Text(
                              'Категория: \\${e.categoryId ?? '-'}',
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: MyFloatingActionButton(
            icon: Icons.add,
            onPressesd: () async {
              // TODO: реализовать добавление транзакции через BLoC
              // После возврата обновить список: context.read<ExpensesBloc>().add(LoadExpenses());
            },
          ),
        );
      },
    );
  }
}
