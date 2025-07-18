import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:provider/provider.dart';
import 'package:blur/blur.dart';

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
import 'presentation/widgets/widgets.dart';
import 'presentation/features/account/bloc/account_event.dart';
import 'presentation/features/settings/repositories/pin_service.dart';
import 'presentation/features/pin/repositories/pin_repository.dart';

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

bool isAppUnlocked = false;

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await workerManager.init();
  await initializeDateFormatting('ru');
  setupDependencies();
  runApp(const CashneticApp());
}

class BlurOnPauseWrapper extends StatefulWidget {
  final Widget child;
  const BlurOnPauseWrapper({Key? key, required this.child}) : super(key: key);

  @override
  State<BlurOnPauseWrapper> createState() => _BlurOnPauseWrapperState();
}

class _BlurOnPauseWrapperState extends State<BlurOnPauseWrapper> with WidgetsBindingObserver {
  bool _isBlurred = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    setState(() {
      _isBlurred = state == AppLifecycleState.paused || state == AppLifecycleState.inactive;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isBlurred)
          Positioned.fill(
            child: Blur(
              blur: 24,
              colorOpacity: 0.2,
              child: Container(color: Colors.transparent),
            ),
          ),
      ],
    );
  }
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
    // Automatically start sync on app launch
    Future.microtask(() => _runSync());
    // Listen for connectivity changes
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
      // After going online, perform a full sync with the API
      await getIt<SyncManager>().fullSync();
      // Dispatch LoadAccount to update account screen with fresh data
      final context = navigatorKey.currentContext;
      if (context != null) {
        context.read<AccountBloc>().add(LoadAccount());
      }
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
    workerManager.dispose(); // Explicitly dispose all worker isolates
    super.dispose();
  }

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
      child: ChangeNotifierProvider.value(
        value: _syncStatusNotifier,
        child: Builder(
          builder: (context) {
            return BlocBuilder<SettingsBloc, SettingsState>(
              builder: (context, state) {
                ThemeMode themeMode = ThemeMode.system;
                String language = 'en';
                                        Color primaryColor = Colors.green; // Зеленый по умолчанию
                ThemeData initTheme;
                if (state is SettingsLoaded) {
                  themeMode = state.themeMode;
                  language = state.language;
                  primaryColor = state.primaryColor;
                }
                if (themeMode == ThemeMode.dark) {
                  initTheme = darkThemeData(primaryColor: primaryColor);
                } else if (themeMode == ThemeMode.light) {
                  initTheme = lightThemeData(primaryColor: primaryColor);
                } else {
                  final brightness =
                      WidgetsBinding.instance.platformDispatcher.platformBrightness;
                  initTheme = brightness == Brightness.dark
                      ? darkThemeData(primaryColor: primaryColor)
                      : lightThemeData(primaryColor: primaryColor);
                }
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
                  theme: lightThemeData(primaryColor: primaryColor),
                  darkTheme: darkThemeData(primaryColor: primaryColor),
                  themeMode: themeMode,
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
                    return BlurOnPauseWrapper(
                      child: Stack(children: [child!, const SyncStatusBanner()]),
                    );
                  },
                  routerConfig: _router.config(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
