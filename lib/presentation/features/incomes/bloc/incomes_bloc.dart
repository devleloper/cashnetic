import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'incomes_event.dart';
import 'incomes_state.dart';

class IncomesBloc extends Bloc<IncomesEvent, IncomesState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  IncomesBloc({
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(IncomesInitial()) {
    on<LoadIncomes>(_onLoadIncomes);
    on<RefreshIncomes>(_onRefreshIncomes);
    on<AddIncome>(_onAddIncome);
    on<DeleteIncome>(_onDeleteIncome);
    on<UpdateIncome>(_onUpdateIncome);
  }

  Future<void> _onLoadIncomes(
    LoadIncomes event,
    Emitter<IncomesState> emit,
  ) async {
    emit(IncomesLoading());
    await _loadTodayIncomes(emit);
  }

  Future<void> _onRefreshIncomes(
    RefreshIncomes event,
    Emitter<IncomesState> emit,
  ) async {
    if (state is IncomesLoaded) {
      final currentState = state as IncomesLoaded;
      emit(
        IncomesRefreshing(
          incomes: currentState.incomes,
          total: currentState.total,
          date: currentState.date,
        ),
      );
    }
    await _loadTodayIncomes(emit);
  }

  Future<void> _loadTodayIncomes(Emitter<IncomesState> emit) async {
    try {
      final today = DateTime.now();
      final start = DateTime(today.year, today.month, today.day);
      final end = DateTime(today.year, today.month, today.day, 23, 59, 59);

      // Получаем все транзакции за сегодня
      final txResult = await transactionRepository.getTransactionsByPeriod(
        1, // accountId=1 (TODO: поддержка мультиаккаунтов)
        start,
        end,
      );

      final allTransactions = txResult.fold(
        (failure) => <Transaction>[],
        (transactions) => transactions,
      );

      // Получаем категории для фильтрации доходов
      final catResult = await categoryRepository.getAllCategories();
      final categories = catResult.fold(
        (failure) => <Category>[],
        (cats) => cats,
      );

      // Фильтруем только доходы
      final incomeTransactions = allTransactions.where((transaction) {
        final category = categories.firstWhere(
          (cat) => cat.id == transaction.categoryId,
          orElse: () => Category(
            id: 0,
            name: '',
            emoji: '',
            isIncome: false,
            color: '#E0E0E0',
          ),
        );
        return category.isIncome;
      }).toList();

      // Удаляем дубликаты по ID
      final unique = <int>{};
      final uniqueIncomes = incomeTransactions
          .where((t) => unique.add(t.id))
          .toList();

      // Сортируем по дате — новые сверху
      uniqueIncomes.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final total = uniqueIncomes.fold<double>(0, (sum, t) => sum + t.amount);

      emit(IncomesLoaded(incomes: uniqueIncomes, total: total, date: today));
    } catch (e) {
      emit(IncomesError('Ошибка при загрузке доходов: $e'));
    }
  }

  Future<void> _onAddIncome(AddIncome event, Emitter<IncomesState> emit) async {
    // TODO: добавить транзакцию через репозиторий
    add(RefreshIncomes());
  }

  Future<void> _onDeleteIncome(
    DeleteIncome event,
    Emitter<IncomesState> emit,
  ) async {
    // Получаем транзакцию по id (можно из состояния, если есть)
    int? categoryId;
    if (state is IncomesLoaded) {
      final txList = (state as IncomesLoaded).incomes;
      final tx = txList.where((t) => t.id == event.transactionId).toList();
      if (tx.isNotEmpty) {
        categoryId = tx.first.categoryId;
      }
    }
    // Удаляем транзакцию
    await transactionRepository.deleteTransaction(event.transactionId);
    // После удаления — обновляем список
    add(RefreshIncomes());
    // Проверяем, остались ли транзакции с этой категорией
    if (categoryId != null) {
      final allTxResult = await transactionRepository.getTransactionsByPeriod(
        1, // accountId=1 (TODO: поддержка мультиаккаунтов)
        DateTime(2000),
        DateTime.now(),
      );
      final allTx = allTxResult.fold((_) => <Transaction>[], (txs) => txs);
      await categoryRepository.deleteCategoryIfUnused(categoryId, allTx);
    }
  }

  Future<void> _onUpdateIncome(
    UpdateIncome event,
    Emitter<IncomesState> emit,
  ) async {
    // TODO: обновить транзакцию через репозиторий
    add(RefreshIncomes());
  }
}
