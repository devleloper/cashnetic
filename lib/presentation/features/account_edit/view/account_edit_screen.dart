import 'package:flutter/material.dart';
import 'package:cashnetic/data/models/account/account.dart';
import '../widgets/balance_edit_row.dart';

class AccountEditScreen extends StatefulWidget {
  final AccountDTO account;

  const AccountEditScreen({super.key, required this.account});

  @override
  State<AccountEditScreen> createState() => _AccountEditScreenState();
}

class _AccountEditScreenState extends State<AccountEditScreen> {
  late TextEditingController _controller;
  late double _balance;

  @override
  void initState() {
    super.initState();
    _balance = double.tryParse(widget.account.balance) ?? 0;
    _controller = TextEditingController(text: _balance.toStringAsFixed(0));
  }

  void _save() {
    final value = double.tryParse(_controller.text.replaceAll(',', '.'));
    if (value != null) {
      Navigator.pop(
        context,
        widget.account.copyWith(balance: value.toStringAsFixed(0)),
      );
    }
  }

  void _delete() {
    // По макету удаление здесь не делает навигацию — предполагается soft delete
    Navigator.pop(context, null); // или можно передать сигнал об удалении
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Мой счёт'),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Colors.white),
            onPressed: _save,
          ),
        ],
      ),
      body: Column(
        children: [
          BalanceEditRow(controller: _controller),
          const SizedBox(height: 24),
          // Padding(
          //   padding: const EdgeInsets.symmetric(horizontal: 24),
          //   child: SizedBox(
          //     width: double.infinity,
          //     height: 52,
          //     child: ElevatedButton(
          //       style: ElevatedButton.styleFrom(
          //         foregroundColor: Colors.white,
          //         backgroundColor: Colors.red.shade400,
          //         shape: RoundedRectangleBorder(
          //           borderRadius: BorderRadius.circular(32),
          //         ),
          //       ),
          //       onPressed: _delete,
          //       child: const Text('Удалить счёт'),
          //     ),
          //   ),
          // ),
        ],
      ),
    );
  }
}
