import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'transaction_edit_event.dart';
import 'transaction_edit_state.dart';
import 'package:cashnetic/di/di.dart';
import '../repositories/transaction_edit_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/account.dart';
import 'package:cashnetic/domain/entities/transaction.dart';

class TransactionEditBloc
    extends Bloc<TransactionEditEvent, TransactionEditState> {
  final TransactionEditRepository repository =
      getIt<TransactionEditRepository>();

  TransactionEditBloc() : super(TransactionEditInitial()) {
    on<TransactionEditInitialized>(_onInitialized);
    on<TransactionEditCategoryChanged>(_onCategoryChanged);
    on<TransactionEditDateChanged>(_onDateChanged);
    on<TransactionEditAccountChanged>(_onAccountChanged);
    on<TransactionEditAmountChanged>(_onAmountChanged);
    on<TransactionEditCommentChanged>(_onCommentChanged);
    on<TransactionEditSaveTransaction>(_onSaveTransaction);
    on<TransactionEditDeleteTransaction>(_onDeleteTransaction);
    on<TransactionEditCustomCategoryCreated>(_onCustomCategoryCreated);
  }

  Future<void> _onInitialized(
    TransactionEditInitialized event,
    Emitter<TransactionEditState> emit,
  ) async {
    emit(TransactionEditLoading());
    try {
      final transaction = await repository.getTransactionById(
        event.transactionId,
      );
      final categories = await repository.getCategories();
      final accounts = await repository.getAccounts();
      final selectedCategory = categories.isNotEmpty
          ? categories.firstWhere(
              (c) => c.id == transaction.categoryId,
              orElse: () => categories.first,
            )
          : throw Exception('No categories');
      final selectedAccount = accounts.isNotEmpty
          ? accounts.firstWhere(
              (a) => a.id == transaction.accountId,
              orElse: () => accounts.first,
            )
          : throw Exception('No accounts');
      emit(
        TransactionEditLoaded(
          transaction: transaction,
          categories: categories,
          selectedCategory: selectedCategory,
          selectedDate: transaction.timestamp,
          account: selectedAccount,
          amount: transaction.amount.toString(),
          comment: transaction.comment ?? '',
          accounts: accounts,
        ),
      );
    } catch (e) {
      emit(TransactionEditError('Failed to load data: $e'));
    }
  }

  void _onCategoryChanged(
    TransactionEditCategoryChanged event,
    Emitter<TransactionEditState> emit,
  ) {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(
      TransactionEditLoaded(
        transaction: current.transaction,
        categories: current.categories,
        selectedCategory: event.category,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
      ),
    );
  }

  void _onDateChanged(
    TransactionEditDateChanged event,
    Emitter<TransactionEditState> emit,
  ) {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(
      TransactionEditLoaded(
        transaction: current.transaction,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: event.date,
        account: current.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
      ),
    );
  }

  void _onAccountChanged(
    TransactionEditAccountChanged event,
    Emitter<TransactionEditState> emit,
  ) {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(
      TransactionEditLoaded(
        transaction: current.transaction,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: event.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
      ),
    );
  }

  void _onAmountChanged(
    TransactionEditAmountChanged event,
    Emitter<TransactionEditState> emit,
  ) {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(
      TransactionEditLoaded(
        transaction: current.transaction,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: event.amount,
        comment: current.comment,
        accounts: current.accounts,
      ),
    );
  }

  void _onCommentChanged(
    TransactionEditCommentChanged event,
    Emitter<TransactionEditState> emit,
  ) {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(
      TransactionEditLoaded(
        transaction: current.transaction,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: current.amount,
        comment: event.comment,
        accounts: current.accounts,
      ),
    );
  }

  Future<void> _onSaveTransaction(
    TransactionEditSaveTransaction event,
    Emitter<TransactionEditState> emit,
  ) async {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    final parsed = double.tryParse(current.amount.replaceAll(',', '.'));
    if (parsed == null || current.selectedCategory == null) {
      emit(TransactionEditError('Please fill in all fields correctly'));
      return;
    }
    emit(
      TransactionEditSaving(
        transaction: current.transaction,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
      ),
    );
    try {
      final form = TransactionForm(
        accountId: current.account.id,
        categoryId: current.selectedCategory!.id,
        amount: parsed,
        timestamp: current.selectedDate,
        comment: current.comment.isEmpty ? null : current.comment,
      );
      final validationError = repository.validateForm(form);
      if (validationError != null) {
        emit(TransactionEditError(validationError));
        return;
      }
      await repository.updateTransaction(current.transaction.id, form);
      emit(TransactionEditSuccess());
    } catch (e) {
      emit(TransactionEditError('Error while saving: $e'));
    }
  }

  Future<void> _onDeleteTransaction(
    TransactionEditDeleteTransaction event,
    Emitter<TransactionEditState> emit,
  ) async {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(
      TransactionEditDeleting(
        transaction: current.transaction,
        categories: current.categories,
        selectedCategory: current.selectedCategory,
        selectedDate: current.selectedDate,
        account: current.account,
        amount: current.amount,
        comment: current.comment,
        accounts: current.accounts,
      ),
    );
    try {
      await repository.deleteTransaction(current.transaction.id);
      emit(TransactionEditDeleted());
    } catch (e) {
      emit(TransactionEditError('Error while deleting: $e'));
    }
  }

  Future<void> _onCustomCategoryCreated(
    TransactionEditCustomCategoryCreated event,
    Emitter<TransactionEditState> emit,
  ) async {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(TransactionEditLoading());
    try {
      final categories = await repository.getCategories();
      final filtered = categories
          .where((cat) => cat.isIncome == event.isIncome)
          .toList();
      final selected = filtered.isNotEmpty
          ? filtered.firstWhere(
              (c) => c.name == event.name && c.emoji == event.emoji,
              orElse: () => filtered.last,
            )
          : throw Exception('No category found');
      emit(
        TransactionEditLoaded(
          transaction: current.transaction,
          categories: filtered,
          selectedCategory: selected,
          selectedDate: current.selectedDate,
          account: current.account,
          amount: current.amount,
          comment: current.comment,
          accounts: current.accounts,
        ),
      );
    } catch (e) {
      emit(TransactionEditError('Error while adding category: $e'));
    }
  }
}
