import 'package:cashnetic/presentation/features/history/bloc/history_bloc.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_event.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/view/analysis_screen.dart';
import 'package:cashnetic/presentation/widgets/item_list_tile.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/domain/entities/category.dart';

class HistoryScreen extends StatefulWidget {
  final bool isIncome;
  const HistoryScreen({super.key, required this.isIncome});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HistoryBloc>().add(
      LoadHistory(widget.isIncome ? HistoryType.income : HistoryType.expense),
    );
    context.read<CategoriesBloc>().add(LoadCategories());
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
        return BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, catState) {
            List<Category> categories = [];
            if (catState is CategoriesLoaded) {
              categories = catState.categories
                  .map(
                    (cat) => Category(
                      id: cat.id,
                      name: cat.name,
                      emoji: cat.emoji,
                      isIncome: cat.isIncome,
                      color: cat.color,
                    ),
                  )
                  .toList();
            }
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.isIncome ? 'Доходы за месяц' : 'Расходы за месяц',
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
                                    type: widget.isIncome
                                        ? AnalysisType.income
                                        : AnalysisType.expense,
                                  ),
                                ),
                            child: AnalysisScreen(
                              type: widget.isIncome
                                  ? AnalysisType.income
                                  : AnalysisType.expense,
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
                              widget.isIncome
                                  ? 'Нет доходов за последний месяц'
                                  : 'Нет расходов за последний месяц',
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            itemCount: list.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (_, index) {
                              final e = list[index];
                              final cat = categories.firstWhere(
                                (c) => c.id == e.categoryId,
                                orElse: () => Category(
                                  id: 0,
                                  name: '—',
                                  emoji: '❓',
                                  isIncome: false,
                                  color: '#E0E0E0',
                                ),
                              );
                              final bgColor = colorFor(
                                cat.name,
                              ).withOpacity(0.2);
                              return MyItemListTile(
                                transaction: e,
                                category: cat,
                                bgColor: bgColor,
                              );
                            },
                          ),
                  ),
                ],
              ),
            );
          },
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
