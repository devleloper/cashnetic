import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/domain/entities/transaction.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'package:cashnetic/models/models.dart';
import 'transaction_add_event.dart';
import 'transaction_add_state.dart';

class TransactionAddBloc
    extends Bloc<TransactionAddEvent, TransactionAddState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;
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
    required this.accountRepository,
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

    try {
      // Получаем список аккаунтов для определения accountId
      final accountsResult = await accountRepository.getAllAccounts();
      final accountId = accountsResult.fold(
        (failure) => 1, // По умолчанию используем ID 1
        (accounts) {
          // Ищем аккаунт по названию или используем первый
          try {
            final account = accounts.firstWhere(
              (a) => a.name == current.account,
            );
            return account.id;
          } catch (e) {
            // Если аккаунт не найден, используем первый доступный или ID 1
            return accounts.isNotEmpty ? accounts.first.id : 1;
          }
        },
      );

      // Создаем форму транзакции
      final transactionForm = TransactionForm(
        accountId: accountId,
        categoryId: current.selectedCategory!.id,
        amount: parsed,
        timestamp: current.selectedDate,
        comment: current.comment.isEmpty ? null : current.comment,
      );

      // Сохраняем транзакцию
      final result = await transactionRepository.createTransaction(
        transactionForm,
      );

      result.fold(
        (failure) => emit(TransactionAddError(failure.toString())),
        (transaction) => emit(TransactionAddSuccess()),
      );
    } catch (e) {
      emit(TransactionAddError('Ошибка при сохранении: $e'));
    }
  }
}
