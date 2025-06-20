import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/account_repository.dart';
import 'package:cashnetic/data/models/category/category.dart';
import 'package:cashnetic/data/models/transaction_response/transaction_response.dart';
import 'package:cashnetic/domain/entities/forms/transaction_form.dart';
import 'transaction_edit_event.dart';
import 'transaction_edit_state.dart';

class TransactionEditBloc
    extends Bloc<TransactionEditEvent, TransactionEditState> {
  final CategoryRepository categoryRepository;
  final TransactionRepository transactionRepository;
  final AccountRepository accountRepository;

  TransactionEditBloc({
    required this.categoryRepository,
    required this.transactionRepository,
    required this.accountRepository,
  }) : super(TransactionEditInitial()) {
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
    final result = await categoryRepository.getCategoriesByIsIncome(
      event.transaction.category.isIncome,
    );
    final accountsResult = await accountRepository.getAllAccounts();
    if (accountsResult.isLeft()) {
      emit(TransactionEditError('Ошибка загрузки счетов'));
      return;
    }
    final accounts = accountsResult.getOrElse(() => []);
    result.fold((failure) => emit(TransactionEditError(failure.toString())), (
      categories,
    ) {
      // Преобразуем domain Category в CategoryDTO
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

      // Находим соответствующую категорию
      CategoryDTO? selectedCategory;
      try {
        selectedCategory = dtos.firstWhere(
          (c) =>
              c.name == event.transaction.category.name &&
              c.emoji == event.transaction.category.emoji,
        );
      } catch (e) {
        selectedCategory = dtos.isNotEmpty ? dtos.first : null;
      }

      // Парсим дату из строки
      DateTime transactionDate;
      try {
        transactionDate = DateTime.parse(event.transaction.transactionDate);
      } catch (e) {
        transactionDate = DateTime.now();
      }

      // Находим Account по имени (или id, если есть)
      final selectedAccount = accounts.firstWhere(
        (a) => a.name == event.transaction.account.name,
        orElse: () => accounts.isNotEmpty
            ? accounts.first
            : throw Exception('Нет счетов'),
      );

      emit(
        TransactionEditLoaded(
          transaction: event.transaction,
          categories: dtos,
          selectedCategory: selectedCategory,
          selectedDate: transactionDate,
          account: selectedAccount,
          amount: event.transaction.amount,
          comment: event.transaction.comment ?? '',
          accounts: accounts,
        ),
      );
    });
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
      emit(TransactionEditError('Заполните все поля корректно'));
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
      final accountId = current.account.id;

      // Создаем форму транзакции для обновления
      final transactionForm = TransactionForm(
        accountId: accountId,
        categoryId: current.selectedCategory!.id,
        amount: parsed,
        timestamp: current.selectedDate,
        comment: current.comment.isEmpty ? null : current.comment,
      );

      // Обновляем транзакцию
      final result = await transactionRepository.updateTransaction(
        current.transaction.id,
        transactionForm,
      );

      result.fold(
        (failure) => emit(TransactionEditError(failure.toString())),
        (transaction) => emit(TransactionEditSuccess()),
      );
    } catch (e) {
      emit(TransactionEditError('Ошибка при сохранении: $e'));
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
      // Удаляем транзакцию
      final result = await transactionRepository.deleteTransaction(
        current.transaction.id,
      );

      result.fold(
        (failure) => emit(TransactionEditError(failure.toString())),
        (_) => emit(TransactionEditDeleted()),
      );
    } catch (e) {
      emit(TransactionEditError('Ошибка при удалении: $e'));
    }
  }

  Future<void> _onCustomCategoryCreated(
    TransactionEditCustomCategoryCreated event,
    Emitter<TransactionEditState> emit,
  ) async {
    if (state is! TransactionEditLoaded) return;
    final current = state as TransactionEditLoaded;
    emit(TransactionEditLoading());
    final addResult = await categoryRepository.addCategory(
      name: event.name,
      emoji: event.emoji,
      isIncome: event.isIncome,
      color: event.color,
    );
    await addResult.fold(
      (failure) {
        emit(TransactionEditError('Ошибка при добавлении категории: $failure'));
      },
      (newCat) async {
        // После добавления — обновляем список и выбираем новую категорию
        final result = await categoryRepository.getCategoriesByIsIncome(
          event.isIncome,
        );
        result.fold(
          (failure) => emit(TransactionEditError(failure.toString())),
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
              TransactionEditLoaded(
                transaction: current.transaction,
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
