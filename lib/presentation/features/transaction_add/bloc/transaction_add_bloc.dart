import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'transaction_add_event.dart';
import 'transaction_add_state.dart';
import 'package:cashnetic/data/models/transaction/transaction.dart';

class TransactionAddBloc
    extends Bloc<TransactionAddEvent, TransactionAddState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

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
    on<TransactionAddCustomCategoryCreated>(_onCustomCategoryCreated);
  }

  Future<void> _onInitialized(
    TransactionAddInitialized event,
    Emitter<TransactionAddState> emit,
  ) async {
    emit(TransactionAddLoading());
    final result = await categoryRepository.getCategoriesByIsIncome(
      event.isIncome,
    );
    final accountsResult = await accountRepository.getAllAccounts();
    if (accountsResult.isLeft()) {
      emit(TransactionAddError('Ошибка загрузки счетов'));
      return;
    }
    final accounts = accountsResult.getOrElse(() => []);
    if (accounts.isEmpty) {
      emit(TransactionAddError('Нет счетов'));
      return;
    }
    result.fold((failure) => emit(TransactionAddError(failure.toString())), (
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
      emit(
        TransactionAddLoaded(
          categories: dtos,
          selectedCategory: dtos.isNotEmpty ? dtos.first : null,
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
      final accountId = current.account.id;

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

      result.fold((failure) => emit(TransactionAddError(failure.toString())), (
        transaction,
      ) {
        final dto = TransactionDTO(
          id: transaction.id,
          accountId: transaction.accountId,
          categoryId: transaction.categoryId ?? 0,
          amount: transaction.amount.toString(),
          transactionDate: transaction.timestamp.toIso8601String(),
          comment: transaction.comment,
          createdAt: transaction.timeInterval.createdAt.toIso8601String(),
          updatedAt: transaction.timeInterval.updatedAt.toIso8601String(),
        );
        emit(TransactionAddSuccess(dto));
      });
    } catch (e) {
      emit(TransactionAddError('Ошибка при сохранении: $e'));
    }
  }

  Future<void> _onCustomCategoryCreated(
    TransactionAddCustomCategoryCreated event,
    Emitter<TransactionAddState> emit,
  ) async {
    if (state is! TransactionAddLoaded) return;
    final current = state as TransactionAddLoaded;
    emit(TransactionAddLoading());
    final addResult = await categoryRepository.addCategory(
      name: event.name,
      emoji: event.emoji,
      isIncome: event.isIncome,
      color: event.color,
    );
    await addResult.fold(
      (failure) {
        emit(TransactionAddError('Ошибка при добавлении категории: $failure'));
      },
      (newCat) async {
        // После добавления — обновляем список и выбираем новую категорию
        final result = await categoryRepository.getCategoriesByIsIncome(
          event.isIncome,
        );
        result.fold(
          (failure) => emit(TransactionAddError(failure.toString())),
          (categories) {
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
            final selected = dtos.firstWhere(
              (c) => c.id == newCat.id,
              orElse: () => dtos.last,
            );
            emit(
              TransactionAddLoaded(
                categories: dtos,
                selectedCategory: selected,
                selectedDate: current.selectedDate,
                account: current.account,
                amount: current.amount,
                comment: current.comment,
                accounts: current.accounts,
              ),
            );
          },
        );
      },
    );
  }
}
