import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/models/models.dart';
import 'transaction_add_event.dart';
import 'transaction_add_state.dart';

class TransactionAddBloc
    extends Bloc<TransactionAddEvent, TransactionAddState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final List<String> accounts = const [
    'Сбербанк',
    'Т‑Банк',
    'Альфа Банк',
    'ВТБ',
    'МТС Банк',
    'Почта Банк',
  ];

  TransactionAddBloc({
    required this.categoryRepository,
    required this.transactionRepository,
  }) : super(TransactionAddInitial()) {
    on<TransactionAddInitialized>(_onInitialized);
    on<TransactionAddCategoryChanged>(_onCategoryChanged);
    on<TransactionAddDateChanged>(_onDateChanged);
    on<TransactionAddAccountChanged>(_onAccountChanged);
    on<TransactionAddAmountChanged>(_onAmountChanged);
    on<TransactionAddCommentChanged>(_onCommentChanged);
    on<TransactionAddSaveTransaction>(_onSaveTransaction);
  }

  Future<void> _onInitialized(
    TransactionAddInitialized event,
    Emitter<TransactionAddState> emit,
  ) async {
    emit(TransactionAddLoading());
    final result = await categoryRepository.getCategoriesByIsIncome(
      event.type == TransactionType.income,
    );
    result.fold((failure) => emit(TransactionAddError(failure.toString())), (
      categories,
    ) {
      emit(
        TransactionAddLoaded(
          categories: categories,
          selectedCategory: categories.isNotEmpty ? categories.first : null,
          selectedDate: DateTime.now(),
          account: accounts.first,
          amount: '',
          comment: '',
          accounts: accounts,
        ),
      );
    });
  }

  void _onCategoryChanged(
    TransactionAddCategoryChanged event,
    Emitter<TransactionAddState> emit,
  ) {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    emit(
      TransactionAddLoaded(
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
      emit(TransactionAddError('Заполните все поля корректно'));
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
      ),
    );

    // TODO: создать Transaction через domain и сохранить через репозиторий
    // Пока что эмулируем успешное сохранение
    await Future.delayed(const Duration(milliseconds: 500));
    emit(TransactionAddSuccess());
  }
}
