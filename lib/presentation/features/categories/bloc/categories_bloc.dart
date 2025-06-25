import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'categories_event.dart';
import 'categories_state.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;

  CategoriesBloc({
    required this.categoryRepository,
    required this.transactionRepository,
  }) : super(CategoriesLoading()) {
    on<InitCategoriesWithTransactions>(_onInitCategoriesWithTransactions);
    on<LoadCategories>(_onLoadCategories);
    on<SearchCategories>(_onSearchCategories);
    on<AddCategory>(_onAddCategory);
    on<DeleteCategory>(_onDeleteCategory);
    on<LoadTransactionsForCategory>(_onLoadTransactionsForCategory);
  }

  Future<void> _onInitCategoriesWithTransactions(
    InitCategoriesWithTransactions event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    final result = await categoryRepository.getAllCategories();
    final txResult = await transactionRepository.getTransactionsByPeriod(
      0, // accountId=0 — все счета
      DateTime(2000),
      DateTime.now(),
    );
    final allTx = txResult.fold((_) => <Transaction>[], (txs) => txs);
    result.fold((failure) => emit(CategoriesError(failure.toString())), (
      categories,
    ) {
      final dtos = categories
          .map(
            (cat) => CategoryDTO(
              id: cat.id,
              name: cat.name,
              emoji: cat.emoji,
              isIncome: cat.isIncome,
              color: cat.color,
            ),
          )
          .toList();
      final Map<int, List<Transaction>> txByCategory = {};
      for (final cat in dtos) {
        txByCategory[cat.id] = allTx
            .where((t) => t.categoryId == cat.id)
            .toList();
      }
      emit(CategoriesLoaded(categories: dtos, txByCategory: txByCategory));
    });
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    final result = await categoryRepository.getAllCategories();
    final txResult = await transactionRepository.getTransactionsByPeriod(
      0, // accountId=0 — все счета
      DateTime(2000),
      DateTime.now(),
    );
    final allTx = txResult.fold((_) => <Transaction>[], (txs) => txs);
    result.fold((failure) => emit(CategoriesError(failure.toString())), (
      categories,
    ) {
      // Преобразуем domain Category в CategoryDTO, если нужно
      final dtos = categories
          .map(
            (cat) => CategoryDTO(
              id: cat.id,
              name: cat.name,
              emoji: cat.emoji,
              isIncome: cat.isIncome,
              color: cat.color,
            ),
          )
          .toList();
      // Формируем txByCategory для всех категорий
      final Map<int, List<Transaction>> txByCategory = {};
      for (final cat in dtos) {
        txByCategory[cat.id] = allTx
            .where((t) => t.categoryId == cat.id)
            .toList();
      }
      emit(CategoriesLoaded(categories: dtos, txByCategory: txByCategory));
    });
  }

  Future<void> _onSearchCategories(
    SearchCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state is! CategoriesLoaded) return;
    final loaded = state as CategoriesLoaded;
    final filtered = event.query.isEmpty
        ? loaded.categories
        : loaded.categories
              .where(
                (c) => c.name.toLowerCase().contains(event.query.toLowerCase()),
              )
              .toList();
    emit(
      CategoriesLoaded(
        categories: filtered,
        searchQuery: event.query,
        txByCategory: loaded.txByCategory,
      ),
    );
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    // event.category должен быть типа CategoryDTO
    final result = await categoryRepository.getAllCategories();
    final categories = result.fold(
      (_) => <CategoryDTO>[],
      (cats) => cats
          .map(
            (cat) => CategoryDTO(
              id: cat.id,
              name: cat.name,
              emoji: cat.emoji,
              isIncome: cat.isIncome,
              color: cat.color,
            ),
          )
          .toList(),
    );
    // Здесь должна быть логика добавления категории через репозиторий (реализовать в domain/data)
    // После добавления перезагружаем список
    add(LoadCategories());
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    // Здесь должна быть логика удаления категории через репозиторий (реализовать в domain/data)
    // После удаления перезагружаем список
    add(LoadCategories());
  }

  Future<void> _onLoadTransactionsForCategory(
    LoadTransactionsForCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state is! CategoriesLoaded) return;
    final loaded = state as CategoriesLoaded;
    final txResult = await transactionRepository.getTransactionsByPeriod(
      0, // accountId=0 — все счета
      DateTime(2000),
      DateTime.now(),
    );
    final txs = txResult
        .fold((_) => <Transaction>[], (txs) => txs)
        .where((t) => t.categoryId == event.categoryId)
        .toList();
    final newTxByCat = Map<int, List<Transaction>>.from(loaded.txByCategory);
    newTxByCat[event.categoryId] = txs;
    emit(
      CategoriesLoaded(
        categories: loaded.categories,
        searchQuery: loaded.searchQuery,
        txByCategory: newTxByCat,
      ),
    );
  }
}
