import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';

import 'router/router.dart';
import 'presentation/presentation.dart';
import 'domain/repositories/category_repository.dart';
import 'domain/repositories/transaction_repository.dart';
import 'domain/repositories/account_repository.dart';

// BLoC
import 'presentation/features/account/bloc/account_bloc.dart';
import 'presentation/features/analysis/bloc/analysis_bloc.dart';
import 'presentation/features/categories/bloc/categories_bloc.dart';
import 'presentation/features/history/bloc/history_bloc.dart';

import 'package:cashnetic/data/database.dart';
import 'package:cashnetic/data/repositories/drift_account_repository.dart';
import 'package:cashnetic/data/repositories/drift_transaction_repository.dart';
import 'package:cashnetic/data/repositories/drift_category_repository.dart';
import 'presentation/theme/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
    final db = appDatabaseSingleton;
    final transactionsRepo = DriftTransactionRepository(db);
    final accountsRepo = DriftAccountRepository(db);
    final categoriesRepo = DriftCategoryRepository(db);

    return ThemeProvider(
      initTheme: lightThemeData(),
      builder: (context, theme) {
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
              BlocProvider(
                create: (context) => SettingsBloc()..add(const LoadSettings()),
              ),
            ],
            child: MaterialApp.router(
              localizationsDelegates: const [
                S.delegate,
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: S.delegate.supportedLocales,
              debugShowCheckedModeBanner: false,
              theme: theme,
              routerConfig: _router.config(),
            ),
          ),
        );
      },
    );
  }
}
