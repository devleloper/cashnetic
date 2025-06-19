import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'router/router.dart';
import 'presentation/presentation.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/account_repository.dart';

// Репозитории (моки)
import 'data/repositories/mocks/mocked_account_repository.dart';
import 'data/repositories/shared_prefs_transaction_repository.dart';
import 'data/repositories/shared_prefs_category_repository.dart';

// BLoC
import 'presentation/features/account/bloc/account_bloc.dart';
import 'presentation/features/analysis/bloc/analysis_bloc.dart';
import 'presentation/features/categories/bloc/categories_bloc.dart';
import 'presentation/features/history/bloc/history_bloc.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await initializeDateFormatting('ru');
  runApp(const CashneticApp());
}

class CashneticApp extends StatefulWidget {
  const CashneticApp({super.key});

  @override
  State<CashneticApp> createState() => _CashneticAppState();
}

class _CashneticAppState extends State<CashneticApp> {
  final _router = AppRouter();

  @override
  Widget build(BuildContext context) {
    final transactionsRepo = SharedPreferencesTransactionRepository();
    final accountsRepo = MockedAccountRepository();
    final categoriesRepo = SharedPrefsCategoryRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<TransactionRepository>.value(
          value: transactionsRepo,
        ),
        RepositoryProvider<CategoryRepository>.value(value: categoriesRepo),
        RepositoryProvider<AccountRepository>.value(value: accountsRepo),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => AccountBloc(
              accountRepository: accountsRepo,
              transactionRepository: transactionsRepo,
              categoryRepository: categoriesRepo,
            ),
          ),
          BlocProvider(
            create: (context) => AnalysisBloc(
              transactionRepository: transactionsRepo,
              categoryRepository: categoriesRepo,
            ),
          ),
          BlocProvider(
            create: (context) => CategoriesBloc(
              categoryRepository: categoriesRepo,
              transactionRepository: transactionsRepo,
            ),
          ),

          BlocProvider(
            create: (context) => HistoryBloc(
              transactionRepository: transactionsRepo,
              categoryRepository: categoriesRepo,
            ),
          ),
          // BLoC для добавления/редактирования транзакций создаются локально в соответствующих экранах
        ],
        child: MaterialApp.router(
          debugShowCheckedModeBanner: false,
          theme: themeData(),
          routerConfig: _router.config(),
        ),
      ),
    );
  }
}
