import 'package:auto_route/auto_route.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_bloc.dart';
import 'package:cashnetic/presentation/features/account/bloc/account_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:cashnetic/router/router.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
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

        return Scaffold(
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
                        tabs: const [
                          GButton(icon: Icons.bar_chart, text: 'Расходы'),
                          GButton(icon: Icons.show_chart, text: 'Доходы'),
                          GButton(
                            icon: Icons.account_balance_wallet,
                            text: 'Счёт',
                          ),
                          GButton(icon: Icons.list_alt, text: 'Статьи'),
                          GButton(icon: Icons.settings, text: 'Настройки'),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }
}
