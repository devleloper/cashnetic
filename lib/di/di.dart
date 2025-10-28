import 'package:cashnetic/data/database.dart';
import 'package:cashnetic/presentation/features/account/repositories/account_repository.dart';
import 'package:cashnetic/data/repositories/drift_transaction_repository.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';
import 'package:cashnetic/presentation/features/categories/repositories/categories_repository.dart';
import 'package:cashnetic/presentation/features/settings/repositories/settings_repository.dart';
import 'package:cashnetic/presentation/features/settings/repositories/settings_repository_impl.dart';
import 'package:cashnetic/presentation/features/transaction_add/repositories/transaction_add_repository.dart';
import 'package:cashnetic/presentation/features/transaction_add/repositories/transaction_add_repository_impl.dart';
import 'package:cashnetic/presentation/features/transaction_edit/repositories/transaction_edit_repository.dart';
import 'package:cashnetic/presentation/features/transaction_edit/repositories/transaction_edit_repository_impl.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository.dart';
import 'package:cashnetic/presentation/features/transactions/repositories/transactions_repository_impl.dart';
import 'package:cashnetic/data/repositories/drift_account_repository.dart';
import 'package:cashnetic/presentation/features/account_add/repositories/account_add_repository.dart';
import 'package:cashnetic/presentation/features/account_edit/repositories/account_edit_repository.dart';
import 'package:cashnetic/presentation/features/history/repositories/history_repository.dart';
import 'package:cashnetic/presentation/features/analysis/repositories/analysis_repository.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  // API отключен - не регистрируем ApiClient и SyncManager
  // getIt.registerLazySingleton<ApiClient>(() => ApiClient());
  // getIt.registerLazySingleton<SyncManager>(
  //   () => SyncManager(getIt<AppDatabase>(), getIt<ApiClient>()),
  // );

  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      getIt<AppDatabase>(),
      getIt<TransactionsRepository>(),
    ),
  );

  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      driftCategoryRepository: getIt<DriftCategoryRepository>(),
      transactionsRepository: getIt<TransactionsRepository>(),
    ),
  );

  getIt.registerLazySingleton<SettingsRepository>(
    () => SettingsRepositoryImpl(),
  );

  getIt.registerLazySingleton<TransactionAddRepository>(
    () => TransactionAddRepositoryImpl(),
  );

  getIt.registerLazySingleton<TransactionEditRepository>(
    () => TransactionEditRepositoryImpl(),
  );

  getIt.registerLazySingleton<TransactionsRepository>(
    () => TransactionsRepositoryImpl(),
  );

  getIt.registerLazySingleton<DriftAccountRepository>(
    () => DriftAccountRepository(getIt<AppDatabase>(), null),
  );

  getIt.registerLazySingleton<DriftTransactionRepository>(
    () => DriftTransactionRepository(getIt<AppDatabase>(), null),
  );
  getIt.registerLazySingleton<DriftCategoryRepository>(
    () => DriftCategoryRepository(getIt<AppDatabase>(), null),
  );

  getIt.registerLazySingleton<AccountAddRepository>(
    () => AccountAddRepositoryImpl(getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<AccountEditRepository>(
    () => AccountEditRepositoryImpl(getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      transactionRepository: getIt<TransactionsRepository>(),
      categoryRepository: getIt<CategoriesRepository>(),
    ),
  );

  getIt.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(
      transactionRepository: getIt<TransactionsRepository>(),
      categoryRepository: getIt<CategoriesRepository>(),
      sectionColors: const [
        Color(0xFF4CAF50), // Зеленый
        Color(0xFF2196F3), // Синий
        Color(0xFFFF9800), // Оранжевый
        Color(0xFF9C27B0), // Фиолетовый
        Color(0xFFF44336), // Красный
        Color(0xFF00BCD4), // Голубой
        Color(0xFFFFEB3B), // Желтый
        Color(0xFF795548), // Коричневый
      ],
    ),
  );
}
