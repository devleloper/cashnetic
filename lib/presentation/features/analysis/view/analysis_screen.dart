import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_bloc.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_event.dart';
import 'package:cashnetic/presentation/features/analysis/bloc/analysis_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/analysis_year_filter_chips.dart';
import '../widgets/analysis_period_selector.dart';
import '../widgets/analysis_total_summary.dart';
import '../widgets/analysis_category_sliver_list.dart';
import '../widgets/cashnetic_pie_chart_widget.dart';
import 'package:provider/provider.dart';
import 'package:cashnetic/main.dart';
import 'package:cashnetic/presentation/widgets/shimmer_placeholder.dart';

class AnalysisScreen extends StatefulWidget {
  final AnalysisType type;
  const AnalysisScreen({super.key, required this.type});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  SyncStatus? _lastSyncStatus;
  SyncStatusNotifier? _syncStatusNotifier;

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
    final syncStatusNotifier = _syncStatusNotifier;
    if (syncStatusNotifier == null) return;
    if (_lastSyncStatus == syncStatusNotifier.status) return;
    _lastSyncStatus = syncStatusNotifier.status;
    if (syncStatusNotifier.status == SyncStatus.online) {
      if (mounted) {
        final bloc = context.read<AnalysisBloc>();
        final state = bloc.state;
        if (state is AnalysisLoaded) {
          bloc.add(LoadAnalysis(year: state.selectedYear, type: widget.type));
        } else {
          bloc.add(LoadAnalysis(year: DateTime.now().year, type: widget.type));
        }
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
    return BlocBuilder<AnalysisBloc, AnalysisState>(
      builder: (context, state) {
        if (state is AnalysisLoading) {
          return const ShimmerAnalysisScreenPlaceholder();
        }
        if (state is AnalysisError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is! AnalysisLoaded) {
          return const SizedBox.shrink();
        }
        final result = state.result;
        final selectedYears = state.selectedYears;

        final sortedData = List<CategoryChartData>.from(result.data)
          ..sort((a, b) {
            final ad = a.lastTransactionDate ?? DateTime(1970);
            final bd = b.lastTransactionDate ?? DateTime(1970);
            return bd.compareTo(ad);
          });

        // Synced list for chart and legend
        final chartSections = result.data
            .map(
              (c) => AnalysisPieChartData(
                amount: c.amount,
                categoryTitle: c.categoryTitle,
                color: c.color,
                percent: c.percent,
              ),
            )
            .toList();
        return Scaffold(
          appBar: AppBar(
            title: Text(
              widget.type == AnalysisType.expense
                  ? S.of(context).expenseAnalysis
                  : S.of(context).incomeAnalysis,
              style: const TextStyle(fontSize: 20, color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: Colors.green,
            leading: const BackButton(color: Colors.white),
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Container(
                  color: Color(0xFFE6F4EA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: AnalysisYearFilterChips(
                    availableYears: state.availableYears,
                    selectedYears: selectedYears,
                    type: widget.type,
                    onChanged: (newYears) {
                      context.read<AnalysisBloc>().add(
                        ChangeYears(years: newYears, type: widget.type),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  color: Color(0xFFE6F4EA),
                  child: AnalysisPeriodSelector(
                    periodStart: result.periodStart,
                    periodEnd: result.periodEnd,
                    type: widget.type,
                    onChanged: (from, to) {
                      context.read<AnalysisBloc>().add(
                        ChangePeriod(from: from, to: to, type: widget.type),
                      );
                    },
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  color: Color(0xFFE6F4EA),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: AnalysisTotalSummary(total: result.total),
                ),
              ),
              SliverToBoxAdapter(child: SizedBox(height: 42)),
              if (result.total > 0 && result.data.isNotEmpty)
                SliverToBoxAdapter(
                  child: CashneticPieChartWidget(data: chartSections),
                ),
              SliverToBoxAdapter(child: SizedBox(height: 28)),
              if (result.data.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      S.of(context).noDataForAnalysis,
                      style: TextStyle(fontSize: 18, color: Colors.grey),
                    ),
                  ),
                )
              else
                AnalysisCategorySliverList(
                  sortedData: sortedData,
                  type: widget.type,
                ),
            ],
          ),
        );
      },
    );
  }
}

// Delegate for pinned legend
class _LegendHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;
  _LegendHeaderDelegate({required this.child});
  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Material(
      color: Colors.white,
      child: SizedBox(height: maxExtent, child: child),
    );
  }

  @override
  double get maxExtent => 80;
  @override
  double get minExtent => 80;
  @override
  bool shouldRebuild(covariant _LegendHeaderDelegate oldDelegate) => false;
}
