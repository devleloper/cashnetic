import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:intl/intl.dart';
import 'history_event.dart';
import 'history_state.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  // Текущее состояние фильтров и сортировки
  DateTime _from = DateTime.now().subtract(const Duration(days: 30));
  DateTime _to = DateTime.now();
  HistoryType _type = HistoryType.expense;
  HistorySort _sort = HistorySort.dateDesc;
  int _page = 0;
  final int _pageSize = 30;
  bool _hasMore = true;
  List<Transaction> _allLoaded = [];

  HistoryBloc({
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(HistoryLoading()) {
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
    // Если конец меньше начала — меняем их местами
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
    final txResult = await transactionRepository.getTransactionsByPeriod(
      0,
      _from,
      _to,
    ); // accountId=0 — все счета
    final txs = txResult.fold((_) => <Transaction>[], (txs) => txs);
    final catResult = await categoryRepository.getAllCategories();
    final categories = catResult.fold((_) => <dynamic>[], (cats) => cats);
    // Фильтруем по типу
    var filtered = txs.where((t) {
      final cat = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(
          id: 0,
          name: 'Unknown',
          emoji: '❓',
          isIncome: false,
          color: '#E0E0E0',
        ),
      );
      return _type == HistoryType.expense
          ? cat.isIncome == false
          : cat.isIncome == true;
    }).toList();
    // Сортировка
    switch (_sort) {
      case HistorySort.dateDesc:
        filtered.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case HistorySort.dateAsc:
        filtered.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case HistorySort.amountDesc:
        filtered.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case HistorySort.amountAsc:
        filtered.sort((a, b) => a.amount.compareTo(b.amount));
        break;
      case HistorySort.category:
        filtered.sort(
          (a, b) => (a.categoryId ?? 0).compareTo(b.categoryId ?? 0),
        );
        break;
    }
    // Lazy loading (постранично)
    final start = _page * _pageSize;
    final end = (_page + 1) * _pageSize;
    final pageItems = filtered.skip(start).take(_pageSize).toList();
    if (reset) {
      _allLoaded = pageItems;
    } else {
      _allLoaded.addAll(pageItems);
    }
    _hasMore = end < filtered.length;
    final total = filtered.fold<double>(0, (sum, t) => sum + t.amount);
    final startStr = filtered.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(filtered.last.timestamp)
        : '—';
    final endStr = filtered.isNotEmpty
        ? DateFormat('dd.MM.yyyy').format(filtered.first.timestamp)
        : '—';
    emit(
      HistoryLoaded(
        transactions: _allLoaded,
        total: total,
        start: startStr,
        end: endStr,
        from: _from,
        to: _to,
        sort: _sort,
        hasMore: _hasMore,
      ),
    );
  }
}
