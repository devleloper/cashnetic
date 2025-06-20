import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_bloc.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_event.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/view/analysis_screen.dart';
import 'package:cashnetic/utils/category_utils.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/domain/entities/category.dart';
import '../widgets/history_period_selector.dart';
import '../widgets/history_total_row.dart';
import '../widgets/history_list_item.dart';
import '../widgets/history_list_view.dart';
import '../widgets/history_sort_dropdown.dart';

class HistoryScreen extends StatefulWidget {
  final bool isIncome;
  const HistoryScreen({super.key, required this.isIncome});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  DateTime? _from;
  DateTime? _to;

  Future<void> _pickDate(
    BuildContext context,
    bool isFrom,
    DateTime initial,
  ) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
      final from = isFrom ? picked : (_from ?? initial);
      final to = !isFrom ? picked : (_to ?? initial);
      if (from.isAfter(to)) {
        // Корректировка дат
        if (isFrom) {
          _to = from;
        } else {
          _from = to;
        }
      }
      context.read<HistoryBloc>().add(
        ChangePeriod(
          _from ?? initial,
          _to ?? initial,
          widget.isIncome ? HistoryType.income : HistoryType.expense,
        ),
      );
    }
  }

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
        _from = state.from;
        _to = state.to;
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
                    padding: const EdgeInsets.only(
                      top: 16,
                      bottom: 8,
                      left: 16,
                      right: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Период: начало',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                backgroundColor: Colors.green.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () => _pickDate(
                                context,
                                true,
                                _from ?? DateTime.now(),
                              ),
                              child: Text(
                                _from != null
                                    ? '${_from!.day.toString().padLeft(2, '0')}.${_from!.month.toString().padLeft(2, '0')}.${_from!.year}'
                                    : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Период: конец',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                backgroundColor: Colors.green.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () => _pickDate(
                                context,
                                false,
                                _to ?? DateTime.now(),
                              ),
                              child: Text(
                                _to != null
                                    ? '${_to!.day.toString().padLeft(2, '0')}.${_to!.month.toString().padLeft(2, '0')}.${_to!.year}'
                                    : '',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            HistorySortDropdown(
                              value: state.sort,
                              onChanged: (sort) {
                                if (sort != null) {
                                  context.read<HistoryBloc>().add(
                                    ChangeSort(sort),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Сумма',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              '${state.total.toStringAsFixed(0)} ₽',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ],
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
                        : HistoryListView(
                            transactions: list,
                            categories: categories,
                            isIncome: widget.isIncome,
                            onEdited: () {
                              // Обновляем историю после редактирования/удаления
                              context.read<HistoryBloc>().add(
                                LoadHistory(
                                  widget.isIncome
                                      ? HistoryType.income
                                      : HistoryType.expense,
                                ),
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
