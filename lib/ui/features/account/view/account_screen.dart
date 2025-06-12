import 'package:cashnetic/models/account/account_model.dart';
import 'package:cashnetic/ui/features/account_edit/account_edit.dart';
import 'package:cashnetic/view_models/account/account_view_model.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AccountViewModel>();
    final account = vm.account;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой счёт'),
        actions: [
          if (account != null)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.white),
              onPressed: () async {
                final updated = await Navigator.push<AccountModel>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => AccountEditScreen(account: account),
                  ),
                );
                if (updated != null) {
                  await vm.updateAccountAndRebuild(updated);
                }
              },
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => vm.load(),
        tooltip: 'Обновить',
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: account == null && vm.loading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  color: Colors.green.withOpacity(0.2),
                  child: Column(
                    children: [
                      _optionRow(
                        icon: Icons.account_balance_wallet,
                        label: 'Баланс',
                        value: NumberFormat.currency(
                          symbol: account!.currency,
                          decimalDigits: 0,
                        ).format(vm.computedBalance),
                        onTap: () async {
                          final updated = await Navigator.push<AccountModel>(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  AccountEditScreen(account: account),
                            ),
                          );
                          if (updated != null) {
                            await vm.updateAccountAndRebuild(updated);
                          }
                        },
                      ),
                      const Divider(height: 1),
                      _optionRow(
                        icon: Icons.currency_exchange,
                        label: 'Валюта',
                        value: account.currency,
                        onTap: () => _showCurrencyPicker(context),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: _BalanceBarChart(),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _optionRow({
    required IconData icon,
    required String label,
    required String value,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: Colors.green),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 16))),
            Text(
              value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showCurrencyPicker(BuildContext context) async {
    final vm = context.read<AccountViewModel>();
    final sel = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: const Text('₽ Российский рубль'),
            onTap: () => Navigator.pop(context, '₽'),
          ),
          ListTile(
            title: const Text('\$ Доллар'),
            onTap: () => Navigator.pop(context, '\$'),
          ),
          ListTile(
            title: const Text('€ Евро'),
            onTap: () => Navigator.pop(context, '€'),
          ),
          const Divider(),
          ListTile(
            title: const Text('Отмена'),
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
    if (sel != null && sel != vm.account?.currency) {
      await vm.updateCurrencyAndRebuild(sel);
    }
  }
}

class _BalanceBarChart extends StatefulWidget {
  @override
  State<_BalanceBarChart> createState() => _BalanceBarChartState();
}

class _BalanceBarChartState extends State<_BalanceBarChart> {
  late AccountViewModel vm;
  int? touchedGroupIndex;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    vm = context.read<AccountViewModel>();
    vm.addListener(_refresh);
  }

  @override
  void dispose() {
    vm.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final pts = vm.dailyPoints;
    if (pts.isEmpty) return const Center(child: Text('Нет данных для графика'));

    final maxVal = pts
        .map((e) => e.income > e.expense ? e.income : e.expense)
        .reduce((a, b) => a > b ? a : b);

    final groups = pts.asMap().entries.map((entry) {
      final idx = entry.key;
      final pt = entry.value;
      return BarChartGroupData(
        x: idx,
        barsSpace: 4,
        barRods: [
          BarChartRodData(toY: pt.expense, color: Colors.orange, width: 12),
          BarChartRodData(toY: pt.income, color: Colors.green, width: 12),
        ],
      );
    }).toList();

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: groups.length * 28.0 + 40,
        height: 300,
        child: BarChart(
          BarChartData(
            maxY: maxVal * 1.2,
            barGroups: groups,
            alignment: BarChartAlignment.start,
            groupsSpace: 12,
            gridData: FlGridData(show: false),
            borderData: FlBorderData(show: false),
            barTouchData: BarTouchData(
              enabled: true,
              touchTooltipData: BarTouchTooltipData(
                getTooltipColor: (group) => Colors.white,
                getTooltipItem: (group, _, rod, rodIndex) {
                  final date = pts[group.x.toInt()].date;
                  final value = rod.toY.toStringAsFixed(0);
                  final label = rodIndex == 0 ? 'Расход' : 'Доход';
                  return BarTooltipItem(
                    '$label ${DateFormat('dd.MM').format(date)}\n',
                    TextStyle(fontWeight: FontWeight.bold, color: rod.color),
                    children: [
                      TextSpan(
                        text: value,
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  );
                },
              ),
            ),
            titlesData: FlTitlesData(
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 28,
                  interval: 1,
                  getTitlesWidget: (val, meta) {
                    final idx = val.toInt();
                    if (idx < 0 || idx >= pts.length)
                      return const SizedBox.shrink();
                    final dt = pts[idx].date;
                    return SizedBox(
                      width: 40,
                      child: SideTitleWidget(
                        meta: meta,
                        child: Text(
                          '${dt.day.toString().padLeft(2, '0')}.${dt.month.toString().padLeft(2, '0')}',
                          style: const TextStyle(fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 48,
                  getTitlesWidget: (value, meta) {
                    String text = value >= 1000
                        ? '${(value / 1000).toStringAsFixed(1)}K'
                        : value.toInt().toString();
                    return SideTitleWidget(
                      meta: meta,
                      space: 8,
                      child: Text(text, style: const TextStyle(fontSize: 12)),
                    );
                  },
                ),
              ),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
            ),
          ),
          swapAnimationDuration: const Duration(milliseconds: 250),
          swapAnimationCurve: Curves.easeInOut,
        ),
      ),
    );
  }
}
