import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';

import 'router/router.dart';
import 'presentation/presentation.dart';
import 'presentation/features/account/bloc/account_bloc.dart';
import 'presentation/features/analysis/bloc/analysis_bloc.dart';
import 'presentation/features/categories/bloc/categories_bloc.dart';
import 'presentation/features/history/bloc/history_bloc.dart';
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
          ThemeMode themeMode = ThemeMode.system;
          String language = 'en';
          ThemeData initTheme;
          if (state is SettingsLoaded) {
            themeMode = state.themeMode;
            language = state.language;
          }
          if (themeMode == ThemeMode.dark) {
            initTheme = darkThemeData();
          } else if (themeMode == ThemeMode.light) {
            initTheme = lightThemeData();
          } else {
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
                locale: Locale(language),
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
                builder: (context, child) {
                  if (state is! SettingsLoaded) {
                    return AnimatedSplashScreen(
                      splash: 'assets/splash/logo.gif',
                      nextScreen: const SizedBox.shrink(),
                      splashIconSize: 400,
                      backgroundColor: Color(0xFF4CAF50),
                      splashTransition: SplashTransition.fadeTransition,
                      duration: 1200,
                      curve: Curves.easeInOut,
                      centered: true,
                    );
                  }
                  return child!;
                },
              );
            },
          );
        },
      ),
    );
  }
}
