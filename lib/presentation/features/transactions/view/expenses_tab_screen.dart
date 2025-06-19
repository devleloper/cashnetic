import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'transactions_screen.dart';

@RoutePage()
class ExpensesTabScreen extends StatelessWidget {
  const ExpensesTabScreen({super.key});
  @override
  Widget build(BuildContext context) =>
      const TransactionsScreen(isIncome: false);
}
