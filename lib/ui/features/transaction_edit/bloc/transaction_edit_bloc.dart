import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/entities/category.dart';
import 'package:cashnetic/models/models.dart';
import 'transaction_edit_event.dart';
import 'transaction_edit_state.dart';

class TransactionEditBloc
    extends Bloc<TransactionEditEvent, TransactionEditState> {
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

  TransactionEditBloc({
    required this.categoryRepository,
    required this.transactionRepository,
  }) : super(TransactionEditInitial()) {
    on<TransactionEditInitialized>(_onInitialized);
    on<TransactionEditCategoryChanged>(_onCategoryChanged);
    on<TransactionEditDateChanged>(_onDateChanged);
    on<TransactionEditAccountChanged>(_onAccountChanged);
    on<TransactionEditAmountChanged>(_onAmountChanged);
    on<TransactionEditCommentChanged>(_onCommentChanged);
    on<TransactionEditSaveTransaction>(_onSaveTransaction);
    on<TransactionEditDeleteTransaction>(_onDeleteTransaction);
  }

  Future<void> _onInitialized(
    TransactionEditInitialized event,
    Emitter<TransactionEditState> emit,
  ) async {
    emit(TransactionEditLoading());
    final result = await categoryRepository.getCategoriesByIsIncome(
      event.transaction.type == TransactionType.income,
    );
    result.fold((failure) => emit(TransactionEditError(failure.toString())), (
      categories,
    ) {
      // Находим соответствующую категорию
      Category? selectedCategory;
      try {
        selectedCategory = categories.firstWhere(
          (c) =>
              c.name == event.transaction.categoryTitle &&
              c.emoji == event.transaction.categoryIcon,
        );
      } catch (e) {
        selectedCategory = categories.isNotEmpty ? categories.first : null;
      }

      emit(
        TransactionEditLoaded(
          transaction: event.transaction,
          categories: categories,
          selectedCategory: selectedCategory,
          selectedDate: event.transaction.transactionDate,
          account: event.transaction.account,
          amount: event.transaction.amount.toString(),
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

    // TODO: сохранить через domain репозиторий
    // Создаем обновленную транзакцию для сохранения
    // final updatedTransaction = TransactionModel(
    //   id: current.transaction.id,
    //   categoryId: current.selectedCategory!.id,
    //   account: current.account,
    //   categoryIcon: current.selectedCategory!.emoji,
    //   categoryTitle: current.selectedCategory!.name,
    //   amount: parsed,
    //   comment: current.comment.isEmpty ? null : current.comment,
    //   transactionDate: current.selectedDate,
    //   type: current.transaction.type,
    // );

    // Пока что эмулируем успешное сохранение
    await Future.delayed(const Duration(milliseconds: 500));
    emit(TransactionEditSuccess());
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

    // TODO: удалить через domain репозиторий
    // Пока что эмулируем успешное удаление
    await Future.delayed(const Duration(milliseconds: 500));
    emit(TransactionEditDeleted());
  }
}
