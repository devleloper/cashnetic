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

class CashneticApp extends StatelessWidget {
  const CashneticApp({super.key});

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
          create: (_) => AnalysisViewModel(
            repo: AnalysisRepositoryImpl(transactionsRepo: transactionsRepo),
          )..load(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData(),
        home: const HomeScreen(),
      ),
    );
  }
}
