import 'package:cashnetic/router/router.dart';
import 'package:cashnetic/view_models/shared/transactions_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'repositories/transactions/transactions_repository.dart';
import 'repositories/analysis/analysis_repository.dart';
import 'view_models/analysis/analysis_view_model.dart';
import 'ui/ui.dart';

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
    final transactionsRepo = TransactionsRepositoryImpl();

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              ExpensesViewModel(repository: transactionsRepo)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              TransactionsViewModel(transactionsRepo)..loadTransactions(),
        ),
        ChangeNotifierProvider(
          create: (_) => AnalysisViewModel(
            repo: AnalysisRepositoryImpl(transactionsRepo: transactionsRepo),
          )..load(),
        ),
      ],
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: themeData(),
        routerConfig: _router.config(),
      ),
    );
  }
}
