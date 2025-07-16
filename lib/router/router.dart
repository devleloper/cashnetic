import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/presentation/features/lock/widgets/lock_screen.dart';
import 'package:cashnetic/presentation/features/transactions/view/transactions_screen.dart';
import 'package:cashnetic/presentation/features/transactions/view/expenses_tab_screen.dart';
import 'package:cashnetic/presentation/features/transactions/view/incomes_tab_screen.dart';
import 'package:flutter/material.dart';

import '../presentation/presentation.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      initial: true,
      children: [
        AutoRoute(
          page: ExpensesTabRoute.page,
          path: 'expenses',
          initial: true,
          children: [],
        ),
        AutoRoute(page: IncomesTabRoute.page, path: 'incomes'),
        AutoRoute(page: AccountRoute.page, path: 'account'),
        AutoRoute(page: CategoriesRoute.page, path: 'articles'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
    AutoRoute(page: LockRoute.page, path: '/lock'),
  ];
}
