import 'package:cashnetic/generated/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:blur/blur.dart';

import 'router/router.dart';
import 'presentation/presentation.dart';
import 'presentation/features/account/bloc/account_bloc.dart';
import 'presentation/features/analysis/bloc/analysis_bloc.dart';
import 'presentation/features/categories/bloc/categories_bloc.dart';
import 'presentation/features/history/bloc/history_bloc.dart';
import 'di/di.dart';
import 'dart:async';
import 'package:worker_manager/worker_manager.dart';
import 'presentation/features/account/bloc/account_event.dart';
import 'package:drift/drift.dart';
import 'package:cashnetic/data/database.dart';

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
  
  // Инициализация тестовых данных
  final db = appDatabaseSingleton;
  // Добавить тестовый счёт, если нет ни одного
  final accounts = await db.getAllAccounts();
  if (accounts.isEmpty) {
    await db.insertAccount(AccountsCompanion(
      name: Value('Test Account'),
      currency: Value('₽'),
      balance: Value(1000.0),
    ));
  }
  // Добавить тестовые категории, если нет ни одной
  final categories = await db.getAllCategories();
  if (categories.isEmpty) {
    // Добавляем категории расходов
    await db.insertCategory(CategoriesCompanion(
      name: Value('Продукты'),
      emoji: Value('🛒'),
      isIncome: Value(false),
      color: Value('#4CAF50'),
    ));
    await db.insertCategory(CategoriesCompanion(
      name: Value('Транспорт'),
      emoji: Value('🚗'),
      isIncome: Value(false),
      color: Value('#FF9800'),
    ));
    // Добавляем категории доходов
    await db.insertCategory(CategoriesCompanion(
      name: Value('Зарплата'),
      emoji: Value('💰'),
      isIncome: Value(true),
      color: Value('#2196F3'),
    ));
    await db.insertCategory(CategoriesCompanion(
      name: Value('Подарки'),
      emoji: Value('🎁'),
      isIncome: Value(true),
      color: Value('#9C27B0'),
    ));
  }
  
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
  final SyncStatusNotifier _syncStatusNotifier = SyncStatusNotifier();

  @override
  void initState() {
    super.initState();
    // API отключен - работаем только офлайн
    Future.microtask(() => _runSync());
  }

  Future<void> _runSync() async {
    // API полностью отключен - работаем только офлайн
    _syncStatusNotifier.setStatus(SyncStatus.offline);
    // Dispatch LoadAccount to update account screen with local data
    final context = navigatorKey.currentContext;
    if (context != null) {
      context.read<AccountBloc>().add(LoadAccount());
    }
  }

  @override
  void dispose() {
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
                if (state is SettingsLoaded) {
                  themeMode = state.themeMode;
                  language = state.language;
                  primaryColor = state.primaryColor;
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
                    // Устанавливаем системную навигацию с текущим цветом
                    SystemUiOverlayStyle overlayStyle = SystemUiOverlayStyle(
                      statusBarColor: Colors.transparent,
                      statusBarIconBrightness: Brightness.light,
                      statusBarBrightness: Brightness.light,
                      systemNavigationBarColor: primaryColor,
                      systemNavigationBarIconBrightness: Brightness.light,
                      systemNavigationBarDividerColor: primaryColor,
                    );
                    SystemChrome.setSystemUIOverlayStyle(overlayStyle);
                    
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
