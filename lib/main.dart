import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'router/router.dart';
import 'ui/ui.dart';

// Репозитории (моки)
import 'data/repositories/mocks/mocked_account_repository.dart';
import 'data/repositories/mocks/mocked_category_repository.dart';
import 'data/repositories/mocks/mocked_transaction_repository.dart';

// BLoC
import 'ui/features/account/bloc/account_bloc.dart';
import 'ui/features/analysis/bloc/analysis_bloc.dart';
import 'ui/features/categories/bloc/categories_bloc.dart';
import 'ui/features/expenses/bloc/expenses_bloc.dart';
import 'ui/features/history/bloc/history_bloc.dart';
import 'ui/features/incomes/bloc/incomes_bloc.dart';
import 'ui/features/transaction_add/bloc/transaction_add_bloc.dart';
import 'ui/features/transaction_edit/bloc/transaction_edit_bloc.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
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
    final transactionsRepo = MockedTransactionRepository();
    final accountsRepo = MockedAccountRepository();
    final categoriesRepo = MockedCategoryRepository();

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: transactionsRepo),
        RepositoryProvider.value(value: accountsRepo),
        RepositoryProvider.value(value: categoriesRepo),
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
            create: (context) =>
                ExpensesBloc(transactionRepository: transactionsRepo),
          ),
          BlocProvider(
            create: (context) =>
                HistoryBloc(transactionRepository: transactionsRepo),
          ),
          BlocProvider(
            create: (context) => IncomesBloc(
              transactionRepository: transactionsRepo,
              categoryRepository: categoriesRepo,
            ),
          ),
          BlocProvider(
            create: (context) => TransactionAddBloc(
              categoryRepository: categoriesRepo,
              transactionRepository: transactionsRepo,
            ),
          ),
          BlocProvider(
            create: (context) => TransactionEditBloc(
              categoryRepository: categoriesRepo,
              transactionRepository: transactionsRepo,
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
