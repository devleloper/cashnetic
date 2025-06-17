import 'package:cashnetic/ui/features/history/bloc/history_bloc.dart';
import 'package:cashnetic/ui/features/history/bloc/history_event.dart';
import 'package:cashnetic/ui/features/history/bloc/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/models/transactions/transaction_model.dart';
import 'package:cashnetic/ui/features/analysis/view/analysis_screen.dart';
import 'package:cashnetic/ui/widgets/item_list_tile.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:intl/intl.dart';
import 'package:cashnetic/ui/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/ui/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

class HistoryScreen extends StatefulWidget {
  final TransactionType type;
  const HistoryScreen({super.key, required this.type});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(
      LoadHistory(
        widget.type == TransactionType.expense
            ? HistoryType.expense
            : HistoryType.income,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        if (state is HistoryLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is HistoryError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! HistoryLoaded) {
          return const SizedBox.shrink();
        }
        final list = state.transactions;
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.type == TransactionType.expense
                  ? 'Расходы за месяц'
                  : 'Доходы за месяц',
            ),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.calendar_month, color: Colors.white),
                onPressed: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BlocProvider(
                        create: (context) =>
                            AnalysisBloc(
                              transactionRepository: context
                                  .read<TransactionRepository>(),
                              categoryRepository: context
                                  .read<CategoryRepository>(),
                            )..add(
                              LoadAnalysis(
                                year: DateTime.now().year,
                                type: widget.type == TransactionType.expense
                                    ? AnalysisType.expense
                                    : AnalysisType.income,
                              ),
                            ),
                        child: AnalysisScreen(
                          type: widget.type == TransactionType.expense
                              ? AnalysisType.expense
                              : AnalysisType.income,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Container(
                color: const Color(0xFFD9F3DB),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Column(
                  children: [
                    _HistoryPeriodRow(label: 'Начало', value: state.start),
                    _HistoryPeriodRow(label: 'Конец', value: state.end),
                    _HistoryPeriodRow(
                      label: 'Сумма',
                      value: '${state.total.toStringAsFixed(0)} ₽',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: list.isEmpty
                    ? Center(
                        child: Text(
                          widget.type == TransactionType.expense
                              ? 'Нет расходов за последний месяц'
                              : 'Нет доходов за последний месяц',
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        itemCount: list.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, index) {
                          final e = list[index];
                          final txModel = transactionDomainToModel(
                            e,
                            account: '',
                            categoryIcon: '',
                            categoryTitle: '',
                            type: TransactionType.expense,
                          );
                          final bgColor = colorFor(
                            txModel.categoryTitle,
                          ).withOpacity(0.2);
                          return MyItemListTile(e: txModel, bgColor: bgColor);
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _HistoryPeriodRow extends StatelessWidget {
  final String label, value;
  const _HistoryPeriodRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(
            value,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

TransactionModel transactionDomainToModel(
  Transaction t, {
  required String account,
  required String categoryIcon,
  required String categoryTitle,
  required TransactionType type,
}) {
  return TransactionModel(
    id: t.id,
    categoryId: t.categoryId ?? 0,
    account: account,
    categoryIcon: categoryIcon,
    categoryTitle: categoryTitle,
    type: type,
    comment: t.comment,
    amount: t.amount,
    transactionDate: t.timestamp,
  );
}
