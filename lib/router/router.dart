import 'package:auto_route/auto_route.dart';

import '../ui/ui.dart';

part 'router.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen|Page,Route')
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    AutoRoute(
      page: HomeRoute.page,
      initial: true,
      children: [
        AutoRoute(page: ExpensesRoute.page, path: 'expenses', initial: true),
        AutoRoute(page: IncomesRoute.page, path: 'income'),
        AutoRoute(page: AccountRoute.page, path: 'account'),
        AutoRoute(page: ArticlesRoute.page, path: 'articles'),
        AutoRoute(page: SettingsRoute.page, path: 'settings'),
      ],
    ),
  ];
}
