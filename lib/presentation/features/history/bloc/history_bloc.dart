import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/history/repositories/history_repository.dart';
import 'history_event.dart';
import 'history_state.dart';
import 'package:cashnetic/di/di.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepository historyRepository = getIt<HistoryRepository>();

  // Текущее состояние фильтров и сортировки
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  HistoryType _type = HistoryType.expense;
  HistorySort _sort = HistorySort.dateDesc;
  int _page = 0;
  final int _pageSize = 30;
  bool _hasMore = true;
  List<Transaction> _allLoaded = [];

  HistoryBloc() : super(HistoryLoading()) {
    on<LoadHistory>(_onLoadHistory);
    on<ChangePeriod>(_onChangePeriod);
    on<ChangeSort>(_onChangeSort);
    on<LoadMoreHistory>(_onLoadMore);
  }

  Future<void> _onLoadHistory(
    LoadHistory event,
    Emitter<HistoryState> emit,
  ) async {
    _type = event.type;
    _from = DateTime.now().subtract(const Duration(days: 30));
    _to = DateTime.now();
    _sort = HistorySort.dateDesc;
    _page = 0;
    _allLoaded.clear();
    await _loadHistoryInternal(emit, reset: true);
  }

  Future<void> _onChangePeriod(
    ChangePeriod event,
    Emitter<HistoryState> emit,
  ) async {
    DateTime from = event.from;
    DateTime to = event.to;
    if (to.isBefore(from)) {
      final tmp = from;
      from = to;
      to = tmp;
    }
    _from = from;
    _to = to;
    _type = event.type;
    _page = 0;
    _allLoaded.clear();
    await _loadHistoryInternal(emit, reset: true);
  }

  Future<void> _onChangeSort(
    ChangeSort event,
    Emitter<HistoryState> emit,
  ) async {
    _sort = event.sort;
    _page = 0;
    _allLoaded.clear();
    await _loadHistoryInternal(emit, reset: true);
  }

  Future<void> _onLoadMore(
    LoadMoreHistory event,
    Emitter<HistoryState> emit,
  ) async {
    if (!_hasMore) return;
    _page++;
    await _loadHistoryInternal(emit, reset: false);
  }

  Future<void> _loadHistoryInternal(
    Emitter<HistoryState> emit, {
    required bool reset,
  }) async {
    if (reset) emit(HistoryLoading());
    final txs = await historyRepository.getTransactionsByPeriod(
      from: _from,
      to: _to,
      type: _type,
      sort: _sort,
      page: _page,
      pageSize: _pageSize,
    );
    // Lazy loading (постранично)
    final start = _page * _pageSize;
    final end = (_page + 1) * _pageSize;
    final pageItems = txs;
    if (reset) {
      _allLoaded = pageItems;
    } else {
      _allLoaded.addAll(pageItems);
    }
    _hasMore = end < (_allLoaded.length + pageItems.length);
    final total = historyRepository.getTotal(_allLoaded);
    final periodStrings = historyRepository.getPeriodStrings(_allLoaded);
    emit(
      HistoryLoaded(
        transactions: _allLoaded,
        total: total,
        start: periodStrings['start'] ?? '—',
        end: periodStrings['end'] ?? '—',
        from: _from,
        to: _to,
        sort: _sort,
        hasMore: _hasMore,
      ),
    );
  }
}
