import 'package:cashnetic/repositories/transactions/transactions_repository.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'ui/ui.dart';

void main() {
  runApp(const CashneticApp());
}

class CashneticApp extends StatelessWidget {
  const CashneticApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) =>
          ExpensesViewModel(repository: TransactionsRepositoryImpl())..load(),

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: themeData(),
        home: const HomeScreen(),
      ),
    );
  }
}
