import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'expenses_event.dart';
import 'expenses_state.dart';
import 'package:cashnetic/domain/entities/category.dart';

class ExpensesBloc extends Bloc<ExpensesEvent, ExpensesState> {
  final TransactionRepository transactionRepository;
  final CategoryRepository categoryRepository;

  ExpensesBloc({
    required this.transactionRepository,
    required this.categoryRepository,
  }) : super(ExpensesLoading()) {
    on<LoadExpenses>(_onLoadExpenses);
    on<AddExpense>(_onAddExpense);
    on<DeleteExpense>(_onDeleteExpense);
    on<UpdateExpense>(_onUpdateExpense);
  }

  Future<void> _onLoadExpenses(
    LoadExpenses event,
    Emitter<ExpensesState> emit,
  ) async {
    emit(ExpensesLoading());
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todayEnd = DateTime(now.year, now.month, now.day, 23, 59, 59);
    final txResult = await transactionRepository.getTransactionsByPeriod(
      1,
      todayStart,
      todayEnd,
    ); // accountId=1 (TODO: поддержка мультиаккаунтов)
    final txs = txResult
        .fold((_) => <Transaction>[], (txs) => txs)
        .where(
          (t) =>
              t.timestamp.isAfter(todayStart) && t.timestamp.isBefore(todayEnd),
        )
        .toList();
    // Получаем категории для фильтрации расходов
    final catResult = await categoryRepository.getAllCategories();
    final categories = catResult.fold((_) => <dynamic>[], (cats) => cats);
    // Фильтруем только расходы
    final expenses = txs.where((t) {
      final cat = categories.firstWhere(
        (c) => c.id == t.categoryId,
        orElse: () => Category(
          id: 0,
          name: 'Неизвестно',
          emoji: '❓',
          isIncome: false,
          color: '#E0E0E0',
        ),
      );
      return cat.isIncome == false;
    }).toList();
    final total = expenses.fold<double>(0, (sum, t) => sum + t.amount);
    emit(ExpensesLoaded(transactions: expenses, total: total));
  }

  Future<void> _onAddExpense(
    AddExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    // event.transaction должен быть типа Transaction
    // Здесь должна быть логика добавления транзакции через репозиторий
    add(LoadExpenses());
  }

  Future<void> _onDeleteExpense(
    DeleteExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    // Получаем транзакцию по id (можно из состояния, если есть)
    int? categoryId;
    if (state is ExpensesLoaded) {
      final txList = (state as ExpensesLoaded).transactions;
      final tx = txList.where((t) => t.id == event.transactionId).toList();
      if (tx.isNotEmpty) {
        categoryId = tx.first.categoryId;
      }
    }
    // Удаляем транзакцию
    await transactionRepository.deleteTransaction(event.transactionId);
    // После удаления — обновляем список
    add(LoadExpenses());
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

  Future<void> _onUpdateExpense(
    UpdateExpense event,
    Emitter<ExpensesState> emit,
  ) async {
    // Здесь должна быть логика обновления транзакции через репозиторий
    add(LoadExpenses());
  }
}
