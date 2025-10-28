import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_bloc.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_event.dart';
import 'package:cashnetic/presentation/features/history/bloc/history_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/view/analysis_screen.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart'
    hide ChangePeriod;
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_bloc.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_state.dart';
import 'package:cashnetic/presentation/features/categories/bloc/categories_event.dart';
import 'package:cashnetic/domain/entities/category.dart';
import '../widgets/history_list_view.dart';
import '../widgets/history_sort_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:cashnetic/main.dart';
import 'package:cashnetic/presentation/widgets/shimmer_placeholder.dart';
import 'package:cashnetic/presentation/theme/theme.dart';
import 'dart:async';

class HistoryScreen extends StatefulWidget {
  final bool isIncome;
  const HistoryScreen({super.key, required this.isIncome});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  SyncStatus? _lastSyncStatus;
  SyncStatusNotifier? _syncStatusNotifier;
  Completer<void>? _refreshCompleter;

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
      final bloc = context.read<HistoryBloc>();
      final state = bloc.state;
      if (state is HistoryLoaded) {
        DateTime from = isFrom ? picked : state.from;
        DateTime to = !isFrom ? picked : state.to;
        bloc.add(
          ChangePeriod(
            from,
            to,
            widget.isIncome ? HistoryType.income : HistoryType.expense,
          ),
        );
      }
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final notifier = Provider.of<SyncStatusNotifier>(context);
    if (_syncStatusNotifier != notifier) {
      _syncStatusNotifier?.removeListener(_onSyncStatusChanged);
      _syncStatusNotifier = notifier;
      _syncStatusNotifier?.addListener(_onSyncStatusChanged);
    }
  }

  void _onSyncStatusChanged() {
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    if (_lastSyncStatus == syncStatusNotifier.status) return;
    _lastSyncStatus = syncStatusNotifier.status;
    if (syncStatusNotifier.status == SyncStatus.online) {
      if (mounted) {
        context.read<HistoryBloc>().add(
          LoadHistory(
            widget.isIncome ? HistoryType.income : HistoryType.expense,
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _syncStatusNotifier?.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistoryBloc, HistoryState>(
      builder: (context, state) {
        // RefreshIndicator: complete only on Loaded/Error
        if (_refreshCompleter != null &&
            (state is HistoryLoaded || state is HistoryError)) {
          _refreshCompleter?.complete();
          _refreshCompleter = null;
        }
        if (state is HistoryLoading) {
          return Scaffold(
            appBar: AppBar(
              title: Text(
                widget.isIncome
                    ? S.of(context).incomeForTheMonth
                    : S.of(context).expensesForTheMonth,
              ),
              leading: IconButton(
                icon: Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.calendar_month),
                  onPressed: () async {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BlocProvider(
                          create: (context) => AnalysisBloc()
                            ..add(
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
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (state is HistoryError) {
          return Scaffold(
            body: Center(
              child: Text(
                'Failed to fetch data',
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ),
          );
        }
        if (state is! HistoryLoaded) {
          return const SizedBox.shrink();
        }
        final list = state.transactions;
        return BlocBuilder<CategoriesBloc, CategoriesState>(
          builder: (context, catState) {
            if (catState is! CategoriesLoaded) {
              return const Center(child: CircularProgressIndicator());
            }
            List<Category> categories = catState.allCategories
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
            debugPrint(
              '[HistoryScreen] Categories for HistoryListView: ' +
                  categories
                      .map((c) => 'id=' + c.id.toString() + ',name=' + c.name)
                      .join('; '),
            );
            return Scaffold(
              appBar: AppBar(
                title: Text(
                  widget.isIncome
                      ? S.of(context).incomeForTheMonth
                      : S.of(context).expensesForTheMonth,
                ),
                leading: IconButton(
                  icon: Icon(Icons.arrow_back),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Icon(Icons.calendar_month),
                    onPressed: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => BlocProvider(
                            create: (context) => AnalysisBloc()
                              ..add(
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
                    color: sectionBackgroundColor(context),
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
                            Text(
                              S.of(context).periodStart,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () =>
                                  _pickDate(context, true, state.from),
                              child: Text(
                                '${state.from.day.toString().padLeft(2, '0')}.${state.from.month.toString().padLeft(2, '0')}.${state.from.year}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
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
                            Text(
                              S.of(context).periodEnd,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
                              ),
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(32),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 18,
                                  vertical: 8,
                                ),
                              ),
                              onPressed: () =>
                                  _pickDate(context, false, state.to),
                              child: Text(
                                '${state.to.day.toString().padLeft(2, '0')}.${state.to.month.toString().padLeft(2, '0')}.${state.to.year}',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
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
                            Text(
                              S.of(context).total,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(
                                  context,
                                ).textTheme.bodyLarge?.color,
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
                    child: RefreshIndicator(
                      onRefresh: () async {
                        _refreshCompleter = Completer<void>();
                        context.read<HistoryBloc>().add(
                          LoadHistory(
                            widget.isIncome
                                ? HistoryType.income
                                : HistoryType.expense,
                          ),
                        );
                        return _refreshCompleter!.future;
                      },
                      child: list.isEmpty
                          ? Center(
                              child: Text(
                                widget.isIncome
                                    ? S.of(context).noIncomeForTheLastMonth
                                    : S.of(context).noExpensesForTheLastMonth,
                              ),
                            )
                          : HistoryListView(
                              transactions: list,
                              categories: categories,
                              isIncome: widget.isIncome,
                              onEdited: () {
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
