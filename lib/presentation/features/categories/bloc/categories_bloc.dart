import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import 'categories_event.dart';
import 'categories_state.dart';
import 'package:cashnetic/di/di.dart';

class CategoriesBloc extends Bloc<CategoriesEvent, CategoriesState> {
  final CategoriesRepository categoriesRepository =
      getIt<CategoriesRepository>();

  CategoriesBloc() : super(CategoriesLoading()) {
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
    final categoriesResult = await categoriesRepository.getAllCategories();
    final txByCategoryResult = await categoriesRepository
        .getTransactionsByCategory();
    categoriesResult.fold(
      (failure) => emit(CategoriesError(failure.toString())),
      (categories) {
        txByCategoryResult.fold(
          (failure) => emit(CategoriesError(failure.toString())),
          (txByCategory) {
            emit(
              CategoriesLoaded(
                categories: categories,
                allCategories: categories,
                txByCategory: txByCategory,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onLoadCategories(
    LoadCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    emit(CategoriesLoading());
    final categoriesResult = await categoriesRepository.getAllCategories();
    final txByCategoryResult = await categoriesRepository
        .getTransactionsByCategory();
    categoriesResult.fold(
      (failure) => emit(CategoriesError(failure.toString())),
      (categories) {
        txByCategoryResult.fold(
          (failure) => emit(CategoriesError(failure.toString())),
          (txByCategory) {
            emit(
              CategoriesLoaded(
                categories: categories,
                allCategories: categories,
                txByCategory: txByCategory,
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _onSearchCategories(
    SearchCategories event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state is! CategoriesLoaded) return;
    final loaded = state as CategoriesLoaded;
    final result = await categoriesRepository.searchCategories(event.query);
    result.fold(
      (failure) {
        // Don't emit CategoriesError, just ignore search error
        // You can add log or handle via SnackBar in UI
      },
      (filtered) {
        emit(
          CategoriesLoaded(
            categories: filtered,
            allCategories: loaded.allCategories,
            searchQuery: event.query,
            txByCategory: loaded.txByCategory,
          ),
        );
      },
    );
  }

  Future<void> _onAddCategory(
    AddCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    final result = await categoriesRepository.addCategory(event.category);
    result.fold(
      (failure) => emit(CategoriesError(failure.toString())),
      (_) => add(LoadCategories()),
    );
  }

  Future<void> _onDeleteCategory(
    DeleteCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    final result = await categoriesRepository.deleteCategory(event.categoryId);
    result.fold(
      (failure) => emit(CategoriesError(failure.toString())),
      (_) => add(LoadCategories()),
    );
  }

  Future<void> _onLoadTransactionsForCategory(
    LoadTransactionsForCategory event,
    Emitter<CategoriesState> emit,
  ) async {
    if (state is! CategoriesLoaded) return;
    final loaded = state as CategoriesLoaded;
    final txByCategoryResult = await categoriesRepository
        .getTransactionsByCategory();
    txByCategoryResult.fold(
      (failure) => emit(CategoriesError(failure.toString())),
      (txByCategory) {
        emit(
          CategoriesLoaded(
            categories: loaded.categories,
            allCategories: loaded.allCategories,
            searchQuery: loaded.searchQuery,
            txByCategory: txByCategory,
          ),
        );
      },
    );
  }
}
