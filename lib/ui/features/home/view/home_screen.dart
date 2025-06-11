import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import '../../../ui.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    ExpensesScreen(),
    IncomeScreen(),
    AccountScreen(),
    ArticlesScreen(),
    SettingsScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _screens),
      bottomNavigationBar: Container(
        color: Colors.green,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 20),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: GNav(
                    selectedIndex: _selectedIndex,
                    onTabChange: _onItemTapped,
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
                      GButton(icon: Icons.account_balance_wallet, text: 'Счёт'),
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
  }
}
