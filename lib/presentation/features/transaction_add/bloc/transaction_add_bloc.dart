import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'transaction_add_event.dart';
import 'transaction_add_state.dart';
import 'package:cashnetic/di/di.dart';
import '../repositories/transaction_add_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:flutter/material.dart';

class TransactionAddBloc
    extends Bloc<TransactionAddEvent, TransactionAddState> {
  final TransactionAddRepository repository = getIt<TransactionAddRepository>();

  TransactionAddBloc() : super(TransactionAddInitial()) {
    on<TransactionAddInitialized>(_onInitialized);
    on<TransactionAddCategoryChanged>(_onCategoryChanged);
    on<TransactionAddDateChanged>(_onDateChanged);
    on<TransactionAddAccountChanged>(_onAccountChanged);
    on<TransactionAddAmountChanged>(_onAmountChanged);
    on<TransactionAddCommentChanged>(_onCommentChanged);
    on<TransactionAddSaveTransaction>(_onSaveTransaction);
    on<TransactionAddCustomCategoryCreated>(_onCustomCategoryCreated);
  }

  Future<void> _onInitialized(
    TransactionAddInitialized event,
    Emitter<TransactionAddState> emit,
  ) async {
    emit(TransactionAddLoading());
    try {
      final categories = await repository.getCategories();
      final accounts = await repository.getAccounts();
      final filtered = categories
          .where((cat) => cat.isIncome == event.isIncome)
          .toList();
      if (filtered.isEmpty) {
        emit(TransactionAddError('No categories'));
        return;
      }
      emit(
        TransactionAddLoaded(
          categories: filtered,
          selectedCategory: filtered.first,
          selectedDate: DateTime.now(),
          account: accounts.isNotEmpty ? accounts.last : null,
          amount: '',
          comment: '',
          accounts: accounts,
          isIncome: event.isIncome,
        ),
      );
    } catch (e) {
      emit(TransactionAddError('Failed to load data: $e'));
    }
  }

  void _onCategoryChanged(
    TransactionAddCategoryChanged event,
    Emitter<TransactionAddState> emit,
  ) {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    // Only allow selecting categories matching current isIncome
    if (event.category.isIncome != current.isIncome) {
      emit(
        TransactionAddError(
          'Selected category does not match transaction type',
        ),
      );
      return;
    }
    emit(
      TransactionAddLoaded(
        categories: current.categories,
        selectedCategory: event.category,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
        isIncome: current.isIncome,
      ),
    );
  }

  void _onDateChanged(
    TransactionAddDateChanged event,
    Emitter<TransactionAddState> emit,
  ) {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    emit(
      TransactionAddLoaded(
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: event.date,
        account: current.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
        isIncome: current.isIncome,
      ),
    );
  }

  void _onAccountChanged(
    TransactionAddAccountChanged event,
    Emitter<TransactionAddState> emit,
  ) {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    emit(
      TransactionAddLoaded(
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: event.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
        isIncome: current.isIncome,
      ),
    );
  }

  void _onAmountChanged(
    TransactionAddAmountChanged event,
    Emitter<TransactionAddState> emit,
  ) {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    emit(
      TransactionAddLoaded(
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: event.amount,
        comment: current.comment,
        accounts: current.accounts,
        isIncome: current.isIncome,
      ),
    );
  }

  void _onCommentChanged(
    TransactionAddCommentChanged event,
    Emitter<TransactionAddState> emit,
  ) {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    emit(
      TransactionAddLoaded(
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: current.amount,
        comment: event.comment,
        accounts: current.accounts,
        isIncome: current.isIncome,
      ),
    );
  }

  Future<void> _onSaveTransaction(
    TransactionAddSaveTransaction event,
    Emitter<TransactionAddState> emit,
  ) async {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    final parsed = double.tryParse(current.amount.replaceAll(',', '.'));
    if (parsed == null || current.selectedCategory == null) {
      emit(TransactionAddError('Please fill in all fields correctly'));
      return;
    }
    // Strict check: selected category must match isIncome
    if (current.selectedCategory!.isIncome != current.isIncome) {
      emit(
        TransactionAddError(
          'Selected category does not match transaction type',
        ),
      );
      return;
    }
    emit(
      TransactionAddSaving(
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
        isIncome: current.isIncome,
      ),
    );
    try {
      final accountId = current.account?.id;
      if (accountId == null) {
        emit(TransactionAddError('Create an account first'));
        return;
      }
      final form = TransactionForm(
        accountId: accountId,
        categoryId: current.selectedCategory!.id,
        amount: parsed,
        timestamp: current.selectedDate,
        comment: current.comment.isEmpty ? null : current.comment,
      );
      final validationError = repository.validateForm(form);
      if (validationError != null) {
        emit(TransactionAddError(validationError));
        return;
      }
      final category = await repository.addTransaction(form);
      final emoji = category?.emoji ?? '💸';
      final color = category != null
          ? Color(int.parse(category.color.replaceFirst('#', '0xff')))
          : const Color(0xFFE6F4EA);
      emit(
        TransactionAddSuccess(
          categoryEmoji: emoji,
          categoryColor: color,
          selectedDate: current.selectedDate,
        ),
      );
    } catch (e) {
      emit(TransactionAddError('Error while saving: $e'));
    }
  }

  Future<void> _onCustomCategoryCreated(
    TransactionAddCustomCategoryCreated event,
    Emitter<TransactionAddState> emit,
  ) async {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    emit(TransactionAddLoading());
    try {
      final categories = await repository.getCategories();
      final filtered = categories
          .where((cat) => cat.isIncome == event.isIncome)
          .toList();
      final selected = filtered.firstWhere(
        (c) => c.name == event.name && c.emoji == event.emoji,
        orElse: () => filtered.last,
      );
      emit(
        TransactionAddLoaded(
          categories: filtered,
          selectedCategory: selected,
          selectedDate: current.selectedDate,
          account: current.account,
          amount: current.amount,
          comment: current.comment,
          accounts: current.accounts,
          isIncome: event.isIncome,
        ),
      );
    } catch (e) {
      emit(TransactionAddError('Error while adding category: $e'));
    }
  }
}
