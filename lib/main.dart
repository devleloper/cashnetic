import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:provider/provider.dart';

import 'router/router.dart';
import 'presentation/presentation.dart';
import 'presentation/features/account/bloc/account_bloc.dart';
import 'presentation/features/analysis/bloc/analysis_bloc.dart';
import 'presentation/features/categories/bloc/categories_bloc.dart';
import 'presentation/features/history/bloc/history_bloc.dart';
import 'di/di.dart';
import 'package:cashnetic/data/sync_manager.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:worker_manager/worker_manager.dart';

enum SyncStatus { offline, syncing, online, error }

class SyncStatusNotifier extends ChangeNotifier {
  SyncStatus _status = SyncStatus.online;
  String? _errorMessage;
  SyncStatus get status => _status;
  String? get errorMessage => _errorMessage;

  void setStatus(SyncStatus status, {String? errorMessage}) {
    _status = status;
    _errorMessage = errorMessage;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await workerManager.init();
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
  late final StreamSubscription<List<ConnectivityResult>>
  _connectivitySubscription;
  final SyncStatusNotifier _syncStatusNotifier = SyncStatusNotifier();

  @override
  void initState() {
    super.initState();
    // Автоматический запуск синхронизации при старте приложения
    Future.microtask(() => _runSync());
    // Слушаем изменения connectivity
    _connectivitySubscription = Connectivity().onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      if (results.any((r) => r != ConnectivityResult.none)) {
        _runSync();
      } else {
        _syncStatusNotifier.setStatus(SyncStatus.offline);
      }
    });
  }

  Future<void> _runSync() async {
    _syncStatusNotifier.setStatus(SyncStatus.syncing);
    try {
      await getIt<SyncManager>().sync();
      _syncStatusNotifier.setStatus(SyncStatus.online);
    } catch (e) {
      _syncStatusNotifier.setStatus(
        SyncStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    _syncStatusNotifier.dispose();
    workerManager.dispose(); // Явное завершение всех worker-изолятов
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _syncStatusNotifier,
      child: MultiBlocProvider(
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
                      return Scaffold(
                        backgroundColor: const Color(0xFF4CAF50),
                        body: Center(
                          child: Image.asset(
                            'assets/splash/logo.gif',
                            width: 400,
                            height: 400,
                          ),
                        ),
                      );
                    }
                    return child!;
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}
