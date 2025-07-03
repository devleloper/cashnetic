import 'package:get_it/get_it.dart';
import 'package:cashnetic/data/database.dart';
import 'package:cashnetic/presentation/features/account/repositories/account_repository.dart';
import 'package:cashnetic/data/repositories/drift_transaction_repository.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';
import 'package:cashnetic/domain/repositories/transaction_repository.dart';
import 'package:cashnetic/domain/repositories/category_repository.dart';
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
import 'package:cashnetic/utils/category_utils.dart';

final getIt = GetIt.instance;

void setupDependencies() {
  getIt.registerLazySingleton<AppDatabase>(() => AppDatabase());

  getIt.registerLazySingleton<AccountRepository>(
    () => AccountRepositoryImpl(
      getIt<AppDatabase>(),
      getIt<TransactionRepository>(),
    ),
  );

  getIt.registerLazySingleton<TransactionRepository>(
    () => DriftTransactionRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<CategoryRepository>(
    () => DriftCategoryRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<CategoriesRepository>(
    () => CategoriesRepositoryImpl(
      categoryRepository: getIt<CategoryRepository>(),
      transactionRepository: getIt<TransactionRepository>(),
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
    () => DriftAccountRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<DriftTransactionRepository>(
    () => DriftTransactionRepository(getIt<AppDatabase>()),
  );
  getIt.registerLazySingleton<DriftCategoryRepository>(
    () => DriftCategoryRepository(getIt<AppDatabase>()),
  );

  getIt.registerLazySingleton<AccountAddRepository>(
    () => AccountAddRepositoryImpl(getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<AccountEditRepository>(
    () => AccountEditRepositoryImpl(getIt<AccountRepository>()),
  );

  getIt.registerLazySingleton<HistoryRepository>(
    () => HistoryRepositoryImpl(
      transactionRepository: getIt<TransactionRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
    ),
  );

  getIt.registerLazySingleton<AnalysisRepository>(
    () => AnalysisRepositoryImpl(
      transactionRepository: getIt<TransactionRepository>(),
      categoryRepository: getIt<CategoryRepository>(),
      sectionColors: sectionColors,
    ),
  );
}
