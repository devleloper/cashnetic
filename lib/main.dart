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
import 'di/di.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('ru');
  setupDependencies();
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
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AccountBloc()),
        BlocProvider(create: (context) => AnalysisBloc()),
        BlocProvider(create: (context) => CategoriesBloc()),
        BlocProvider(create: (context) => HistoryBloc()),
        BlocProvider(
          create: (context) => SettingsBloc()..add(const LoadSettings()),
        ),
      ],
      child: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is! SettingsLoaded) {
            return const Center(child: CircularProgressIndicator());
          }
          final themeMode = state.themeMode;
          ThemeData initTheme;
          if (themeMode == ThemeMode.dark) {
            initTheme = darkThemeData();
          } else if (themeMode == ThemeMode.light) {
            initTheme = lightThemeData();
          } else {
            // system
            final brightness =
                WidgetsBinding.instance.platformDispatcher.platformBrightness;
            initTheme = brightness == Brightness.dark
                ? darkThemeData()
                : lightThemeData();
          }
          return ThemeProvider(
            initTheme: initTheme,
            builder: (context, _) {
              return MaterialApp.router(
                localizationsDelegates: const [
                  S.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: S.delegate.supportedLocales,
                debugShowCheckedModeBanner: false,
                theme: lightThemeData(),
                darkTheme: darkThemeData(),
                themeMode: themeMode,
                routerConfig: _router.config(),
              );
            },
          );
        },
      ),
    );
  }
}
