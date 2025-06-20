import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'transactions_screen.dart';

@RoutePage()
class IncomesTabScreen extends StatelessWidget {
  const IncomesTabScreen({super.key});
  @override
  Widget build(BuildContext context) => TransactionsScreen(isIncome: true);
}
