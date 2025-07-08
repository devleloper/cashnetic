import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/generated/l10n.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cashnetic/router/router.dart';
import 'package:animated_theme_switcher/animated_theme_switcher.dart';
import 'package:cashnetic/presentation/features/history/view/history_screen.dart';
import 'package:cashnetic/presentation/features/account_edit/view/account_edit_screen.dart';
import 'package:cashnetic/data/api_client.dart';
import 'package:cashnetic/di/di.dart';
import 'dart:developer';
import 'package:cashnetic/main.dart';
import 'package:provider/provider.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  SyncStatus? _lastStatus;

  @override
  void initState() {
    super.initState();
    _testApiGetAccounts();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(context);
    syncStatusNotifier.addListener(_onSyncStatusChanged);
  }

  @override
  void dispose() {
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    syncStatusNotifier.removeListener(_onSyncStatusChanged);
    super.dispose();
  }

  void _onSyncStatusChanged() {
    final syncStatusNotifier = Provider.of<SyncStatusNotifier>(
      context,
      listen: false,
    );
    final status = syncStatusNotifier.status;
    if (_lastStatus == status) return;
    _lastStatus = status;
    String? message;
    Color? color;
    switch (status) {
      case SyncStatus.offline:
        message = 'Offile';
        color = Colors.red;
        break;
      case SyncStatus.syncing:
        message = 'Sync...';
        color = Colors.orange;
        break;
      case SyncStatus.online:
        message = 'Online';
        color = Colors.green;
        break;
      case SyncStatus.error:
        message = syncStatusNotifier.errorMessage ?? 'Sync error';
        color = Colors.red;
        break;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ?? ''),
        backgroundColor: color,
        duration: status == SyncStatus.syncing
            ? Duration(seconds: 2)
            : Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _testApiGetAccounts() async {
    try {
      final apiClient = getIt<ApiClient>();
      final response = await apiClient.getAccounts();
      log('API accounts: \n\t\n\t\n');
      log(response.data.toString());
    } catch (e, st) {
      log('API error: $e', stackTrace: st);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AutoTabsRouter(
      routes: [
        ExpensesTabRoute(),
        IncomesTabRoute(),
        AccountRoute(),
        CategoriesRoute(),
        SettingsRoute(),
      ],
      builder: (context, child) {
        final tabsRouter = AutoTabsRouter.of(context);
        SystemUiOverlayStyle overlayStyle = const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.light,
          systemNavigationBarColor: Colors.green,
          systemNavigationBarIconBrightness: Brightness.light,
          systemNavigationBarDividerColor: Colors.green,
        );
        SystemChrome.setSystemUIOverlayStyle(overlayStyle);

        return ThemeSwitchingArea(
          child: Scaffold(
            appBar: (tabsRouter.activeIndex == 0 || tabsRouter.activeIndex == 1)
                ? null
                : _buildAppBar(context, tabsRouter.activeIndex),
            body: child,
            bottomNavigationBar: Container(
              color: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
              child: SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minWidth: constraints.maxWidth,
                        ),
                        child: GNav(
                          selectedIndex: tabsRouter.activeIndex,
                          onTabChange: (index) {
                            tabsRouter.setActiveIndex(index);
                            if (index == 2) {
                              context.read<AccountBloc>().add(LoadAccount());
                            }
                          },
                          backgroundColor: Colors.green,
                          tabBackgroundColor: Colors.white,
                          activeColor: Colors.green,
                          color: Colors.white,
                          curve: Curves.easeInOut,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 18,
                          ),
                          gap: 6,
                          tabs: [
                            GButton(
                              icon: Icons.bar_chart,
                              text: S.of(context).expenses,
                            ),
                            GButton(
                              icon: Icons.show_chart,
                              text: S.of(context).income,
                            ),
                            GButton(
                              icon: Icons.account_balance_wallet,
                              text: S.of(context).account,
                            ),
                            GButton(
                              icon: Icons.list_alt,
                              text: S.of(context).categories,
                            ),
                            GButton(
                              icon: Icons.settings,
                              text: S.of(context).settings,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  PreferredSizeWidget? _buildAppBar(BuildContext context, int index) {
    switch (index) {
      case 0:
        return AppBar(
          centerTitle: true,
          title: Text(S.of(context).expenses),
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(isIncome: false),
                  ),
                );
              },
            ),
          ],
        );
      case 1:
        return AppBar(
          centerTitle: true,
          title: Text(S.of(context).income),
          actions: [
            IconButton(
              icon: const Icon(Icons.history, color: Colors.white),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => HistoryScreen(isIncome: true),
                  ),
                );
              },
            ),
          ],
        );
      case 2:
        return AppBar(
          centerTitle: true,
          title: Text(S.of(context).myAccounts),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () {
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(builder: (_) => AccountEditScreen()));
              },
            ),
          ],
        );
      case 3:
        return AppBar(title: Text(S.of(context).categories), centerTitle: true);
      case 4:
        return AppBar(title: Text(S.of(context).settings), centerTitle: true);
      default:
        return null;
    }
  }
}
