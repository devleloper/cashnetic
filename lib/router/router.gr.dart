// dart format width=80
// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'router.dart';

/// generated route for
/// [AccountScreen]
class AccountRoute extends PageRouteInfo<void> {
  const AccountRoute({List<PageRouteInfo>? children})
    : super(AccountRoute.name, initialChildren: children);

  static const String name = 'AccountRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AccountScreen();
    },
  );
}

/// generated route for
/// [CategoriesScreen]
class CategoriesRoute extends PageRouteInfo<void> {
  const CategoriesRoute({List<PageRouteInfo>? children})
    : super(CategoriesRoute.name, initialChildren: children);

  static const String name = 'CategoriesRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const CategoriesScreen();
    },
  );
}

/// generated route for
/// [ExpensesTabScreen]
class ExpensesTabRoute extends PageRouteInfo<void> {
  const ExpensesTabRoute({List<PageRouteInfo>? children})
    : super(ExpensesTabRoute.name, initialChildren: children);

  static const String name = 'ExpensesTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ExpensesTabScreen();
    },
  );
}

/// generated route for
/// [HomeScreen]
class HomeRoute extends PageRouteInfo<void> {
  const HomeRoute({List<PageRouteInfo>? children})
    : super(HomeRoute.name, initialChildren: children);

  static const String name = 'HomeRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomeScreen();
    },
  );
}

/// generated route for
/// [IncomesTabScreen]
class IncomesTabRoute extends PageRouteInfo<void> {
  const IncomesTabRoute({List<PageRouteInfo>? children})
    : super(IncomesTabRoute.name, initialChildren: children);

  static const String name = 'IncomesTabRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const IncomesTabScreen();
    },
  );
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
    : super(SettingsRoute.name, initialChildren: children);

  static const String name = 'SettingsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
}

/// generated route for
/// [TransactionsScreen]
class TransactionsRoute extends PageRouteInfo<TransactionsRouteArgs> {
  TransactionsRoute({
    Key? key,
    required bool isIncome,
    List<PageRouteInfo>? children,
  }) : super(
         TransactionsRoute.name,
         args: TransactionsRouteArgs(key: key, isIncome: isIncome),
         initialChildren: children,
       );

  static const String name = 'TransactionsRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<TransactionsRouteArgs>();
      return TransactionsScreen(key: args.key, isIncome: args.isIncome);
    },
  );
}

class TransactionsRouteArgs {
  const TransactionsRouteArgs({this.key, required this.isIncome});

  final Key? key;

  final bool isIncome;

  @override
  String toString() {
    return 'TransactionsRouteArgs{key: $key, isIncome: $isIncome}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! TransactionsRouteArgs) return false;
    return key == other.key && isIncome == other.isIncome;
  }

  @override
  int get hashCode => key.hashCode ^ isIncome.hashCode;
}
